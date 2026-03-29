/*
    fn_radioCallback
    
    Called when a radioman reaches the radio object.
    Starts a 30-second transmission delay.
    
    During transmission:
        - Unit plays animation (or stays still)
        - Draw3D shows "TRANSMITTING..." in red
        - If unit killed → alarm cancelled
        - If radio destroyed → alarm cancelled
        - If transmission completes → AI commander alerted immediately
    
    Parameters:
        0: OBJECT - The radioman unit
        1: OBJECT - The radio object
        2: STRING - Location ID
        3: STRING - Location name
        4: ARRAY  - Radio position
*/

params ["_unit", "_radio", "_locId", "_locName", "_radioPos"];

if (!alive _unit || !alive _radio) exitWith {
    diag_log format ["[OpsRoom] RadioCallback: Unit or radio dead at %1, alarm cancelled", _locName];
};

// Stop the unit at the radio
_unit doMove (getPosATL _unit);  // Cancel movement
_unit setUnitPos "MIDDLE";  // Kneel at radio
_unit disableAI "MOVE";     // Stay put during transmission

diag_log format ["[OpsRoom] RadioCallback: Transmission started at %1 (%2s)", _locName, OpsRoom_AI_RadioTransmitTime];

// Track for Draw3D (transmitting state)
OpsRoom_AI_ActiveRadiomen pushBack [_unit, _locId, _locName, true];  // true = transmitting

// Dispatch to player: they might see this
["FLASH", "ENEMY RADIO ACTIVE", format ["Enemy radioman at %1 is transmitting! Stop him before reinforcements are called!", _locName], _radioPos] call OpsRoom_fnc_dispatch;

// 30-second transmission countdown
private _transmitTime = OpsRoom_AI_RadioTransmitTime;
private _elapsed = 0;
private _success = false;

while {_elapsed < _transmitTime} do {
    sleep 1;
    _elapsed = _elapsed + 1;
    
    // Check if radioman killed during transmission
    if (!alive _unit) exitWith {
        diag_log format ["[OpsRoom] RadioCallback: Radioman killed during transmission at %1!", _locName];
        ["PRIORITY", "TRANSMISSION STOPPED", format ["Enemy radioman at %1 eliminated during transmission! Reinforcements NOT called.", _locName], _radioPos] call OpsRoom_fnc_dispatch;
    };
    
    // Check if radio destroyed during transmission
    if (!alive _radio) exitWith {
        diag_log format ["[OpsRoom] RadioCallback: Radio destroyed during transmission at %1!", _locName];
        ["PRIORITY", "RADIO DESTROYED", format ["Radio at %1 destroyed during transmission! Reinforcements NOT called.", _locName], _radioPos] call OpsRoom_fnc_dispatch;
    };
};

// Remove from transmitting Draw3D list
OpsRoom_AI_ActiveRadiomen = OpsRoom_AI_ActiveRadiomen select {
    (_x select 1) != _locId
};

// Re-enable the radioman's AI
if (alive _unit) then {
    _unit enableAI "MOVE";
    _unit setUnitPos "AUTO";
    _unit setVariable ["OpsRoom_AI_IsRadioman", false, true];
};

// Check if transmission completed
if (_elapsed >= _transmitTime && alive _unit && alive _radio) then {
    _success = true;
};

if (!_success) exitWith {};

// ========================================
// TRANSMISSION SUCCESSFUL — ALERT AI COMMANDER
// ========================================
diag_log format ["[OpsRoom] RadioCallback: ALARM RECEIVED from %1! Deploying reinforcements.", _locName];

["FLASH", "ENEMY REINFORCEMENTS INCOMING", format ["Enemy transmission from %1 complete! Reinforcements are being dispatched!", _locName], _radioPos] call OpsRoom_fnc_dispatch;

// Determine what to send (use reinforce templates)
private _templateList = OpsRoom_AI_TemplatesByMission getOrDefault ["reinforce", ["rifle_section"]];
private _templateKey = selectRandom _templateList;
private _template = OpsRoom_AI_GroupTemplates getOrDefault [_templateKey, createHashMap];

if (count _template == 0) exitWith {
    diag_log "[OpsRoom] RadioCallback: No valid template found for reinforcement";
};

private _cost = _template get "manpower";

// Check manpower
if (OpsRoom_AI_Manpower < _cost) exitWith {
    diag_log format ["[OpsRoom] RadioCallback: Insufficient manpower (%1) for %2 (costs %3)", OpsRoom_AI_Manpower, _templateKey, _cost];
    ["ROUTINE", "ENEMY RESPONSE DELAYED", format ["Enemy forces at %1 called for help but no reinforcements available.", _locName], _radioPos] call OpsRoom_fnc_dispatch;
};

// Check group slots (same formula as aiCommanderMonitor)
private _groupBonus = 0;
private _settlementCount = 0;
{
    private _locD = _y;
    if ((_locD getOrDefault ["owner", "NAZI"]) != "NAZI") then { continue };
    if ((_locD get "status") == "destroyed") then { continue };
    private _t = _locD get "type";
    switch (_t) do {
        case "barracks":  { _groupBonus = _groupBonus + 1; };
        case "motorpool": { _groupBonus = _groupBonus + 1; };
        case "port":      { _groupBonus = _groupBonus + 2; };
        case "airfield":  { _groupBonus = _groupBonus + 1; };
        case "hq":        { _groupBonus = _groupBonus + 1; };
        case "town":      { _settlementCount = _settlementCount + 1; };
        case "village":   { _settlementCount = _settlementCount + 1; };
    };
} forEach OpsRoom_StrategicLocations;
_groupBonus = _groupBonus + (floor (_settlementCount / 2));
private _maxGroups = OpsRoom_AI_BaseMaxGroups + _groupBonus;

// Radio alarm gets +1 bonus slot (urgency override)
private _currentGroups = count OpsRoom_AI_ActiveGroups;
if (_currentGroups >= _maxGroups + 1) exitWith {
    diag_log "[OpsRoom] RadioCallback: All group slots full, even with urgency override";
};

// Find spawn location
private _spawnType = _template get "spawnType";
private _locData = OpsRoom_StrategicLocations get _locId;
private _targetPos = _locData get "pos";
private _spawnLocId = [_spawnType, _targetPos] call OpsRoom_fnc_aiFindSpawnLocation;

if (_spawnLocId == "") exitWith {
    diag_log format ["[OpsRoom] RadioCallback: No %1 available for spawning", _spawnType];
};

// Spawn and deploy
private _spawnResult = [_templateKey, _spawnLocId] call OpsRoom_fnc_aiSpawnGroup;
private _grp = _spawnResult getOrDefault ["group", grpNull];

if (isNull _grp) exitWith {
    diag_log "[OpsRoom] RadioCallback: Failed to spawn reinforcement group";
};

// Deduct manpower
OpsRoom_AI_Manpower = OpsRoom_AI_Manpower - _cost;

// Move to target
[_grp, _targetPos, "reinforce"] call OpsRoom_fnc_aiMoveGroup;

// Track
private _grpData = createHashMapFromArray [
    ["group", _grp],
    ["templateKey", _templateKey],
    ["templateName", _template get "name"],
    ["missionType", "reinforce"],
    ["targetLocId", _locId],
    ["targetName", _locName],
    ["targetPos", _targetPos],
    ["spawnTime", daytime],
    ["spawnLocId", _spawnLocId],
    ["radioTriggered", true]
];
OpsRoom_AI_ActiveGroups pushBack _grpData;

private _spawnLocData = OpsRoom_StrategicLocations getOrDefault [_spawnLocId, createHashMap];
private _spawnName = if (count _spawnLocData > 0) then { _spawnLocData get "name" } else { "Unknown" };

["FLASH", "ENEMY REINFORCEMENTS DISPATCHED",
    format ["Enemy %1 dispatched from %2 to reinforce %3! (Radio alarm)", _template get "name", _spawnName, _locName],
    _targetPos
] call OpsRoom_fnc_dispatch;

diag_log format ["[OpsRoom] RadioCallback: Deployed %1 from %2 -> %3 (RADIO ALARM). Manpower: %4",
    _templateKey, _spawnName, _locName, OpsRoom_AI_Manpower];
