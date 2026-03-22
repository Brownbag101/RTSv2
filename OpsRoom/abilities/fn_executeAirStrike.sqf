/*
    OpsRoom_fnc_executeAirStrike
    
    Master dispatcher. Finds the best aircraft for the requested attack type
    and routes to the appropriate attack function.
    
    Parameters:
        0: OBJECT - Radio Operator unit (for dispatch messages)
        1: ARRAY  - Target position [x,y,z]
        2: STRING - Attack type: "GUNS", "BOMBS", "ROCKETS", "STRAFE"
        3: ARRAY  - Approach position [x,y,z] (FAH — where aircraft flies to first)
*/

params ["_unit", "_targetPos", "_attackType", "_approachPos", ["_wingId", ""]];

diag_log format ["[OpsRoom] AirStrike: Execute %1 at %2, approach from %3, wingFilter=%4", _attackType, _targetPos, _approachPos, _wingId];

private _available = [];

// If a specific wing was specified, build aircraft list directly from wing data
// This bypasses getAvailable's altitude/side/touchingGround checks which can
// fail for freshly launched aircraft on scheduled missions
if (_wingId != "") then {
    private _wingData = OpsRoom_AirWings getOrDefault [_wingId, createHashMap];
    private _wingSpawned = _wingData getOrDefault ["spawnedObjects", []];
    
    {
        if (_x isKindOf "Air" && {alive _x} && {count crew _x > 0}) then {
            private _veh = _x;
            private _typeLC = toLower (typeOf _veh);
            
            // Check weapons directly
            private _hasGuns = [_veh, "GUNS"] call OpsRoom_fnc_airStrike_hasWeaponType;
            private _hasBombs = [_veh, "BOMBS"] call OpsRoom_fnc_airStrike_hasWeaponType;
            private _hasRockets = [_veh, "ROCKETS"] call OpsRoom_fnc_airStrike_hasWeaponType;
            
            if (_hasGuns || _hasBombs || _hasRockets) then {
                // Get display name from equipment DB
                private _dName = typeOf _veh;
                {
                    private _itemData = _y;
                    if (toLower (_itemData getOrDefault ["className", ""]) == _typeLC) exitWith {
                        _dName = _itemData get "displayName";
                    };
                } forEach OpsRoom_EquipmentDB;
                
                private _hasTorpedo = [_veh, "TORPEDO"] call OpsRoom_fnc_airStrike_hasWeaponType;
                
                _available pushBack createHashMapFromArray [
                    ["vehicle", _veh],
                    ["displayName", _dName],
                    ["capabilities", ["GUNS", "BOMBS", "ROCKETS", "TORPEDO"]],
                    ["hasGuns", _hasGuns],
                    ["hasBombs", _hasBombs],
                    ["hasRockets", _hasRockets],
                    ["hasTorpedo", _hasTorpedo]
                ];
            };
        };
    } forEach _wingSpawned;
    
    diag_log format ["[OpsRoom] AirStrike: Direct wing scan %1, %2 aircraft with weapons", _wingId, count _available];
} else {
    // No wing specified — use standard global scan
    _available = [] call OpsRoom_fnc_airStrike_getAvailable;
};

if (count _available == 0) exitWith {
    hint "No aircraft available — they may have been shot down or run out of ammo.";
    ["FLASH", "AIR STRIKE FAILED", "No ground attack aircraft available for tasking."] call OpsRoom_fnc_dispatch;
};

// Filter for aircraft that can perform the requested attack type
private _candidates = [];

switch (_attackType) do {
    case "GUNS": {
        _candidates = _available select { _x get "hasGuns" };
    };
    case "BOMBS": {
        _candidates = _available select { _x get "hasBombs" };
    };
    case "ROCKETS": {
        _candidates = _available select { _x get "hasRockets" };
    };
    case "STRAFE": {
        _candidates = _available select { (_x get "hasGuns") && (_x get "hasRockets") };
    };
    case "TORPEDO": {
        _candidates = _available select { _x get "hasTorpedo" };
    };
};

if (count _candidates == 0) exitWith {
    hint format ["No aircraft with %1 capability available.", _attackType];
    ["PRIORITY", "AIR STRIKE UNAVAILABLE", format ["No aircraft armed for %1 attack.", _attackType]] call OpsRoom_fnc_dispatch;
};

// Pick nearest aircraft to the APPROACH position (not target)
// This selects the aircraft best positioned for the run-in
private _bestAircraft = objNull;
private _bestData = createHashMap;
private _bestDist = 999999;

{
    private _veh = _x get "vehicle";
    private _dist = _veh distance2D _approachPos;
    if (_dist < _bestDist) then {
        _bestDist = _dist;
        _bestAircraft = _veh;
        _bestData = _x;
    };
} forEach _candidates;

if (isNull _bestAircraft) exitWith {
    hint "Failed to assign aircraft.";
};

private _acName = _bestData get "displayName";
private _gridRef = mapGridPosition _targetPos;
private _approachDir = round (_approachPos getDir _targetPos);

// Dispatch: strike requested
["FLASH", "AIR STRIKE REQUESTED", 
    format ["%1 requesting %2 at grid %3. %4 tasked. Approach bearing %5°.", name _unit, _attackType, _gridRef, _acName, _approachDir]
] call OpsRoom_fnc_dispatch;

hint format ["%1\n%2 inbound\nTarget: %3\nApproach: %4°", _attackType, _acName, _gridRef, _approachDir];

// Draw3D marker at target position (persists during attack run)
private _markerID = format ["airstrike_%1", floor (diag_tickTime * 100)];
missionNamespace setVariable [_markerID + "_pos", _targetPos];
missionNamespace setVariable [_markerID + "_approachPos", _approachPos];
missionNamespace setVariable [_markerID + "_type", _attackType];
missionNamespace setVariable [_markerID + "_active", true];

// Store marker ID for the Draw3D handler to read
missionNamespace setVariable ["OpsRoom_AirStrike_ActiveMarker", _markerID];

private _drawHandler = addMissionEventHandler ["Draw3D", {
    private _mid = missionNamespace getVariable ["OpsRoom_AirStrike_ActiveMarker", ""];
    if (_mid == "") exitWith {};
    if !(missionNamespace getVariable [_mid + "_active", false]) exitWith {};
    
    private _pos = missionNamespace getVariable [_mid + "_pos", [0,0,0]];
    private _aPos = missionNamespace getVariable [_mid + "_approachPos", [0,0,0]];
    private _type = missionNamespace getVariable [_mid + "_type", ""];
    
    // Target circle
    private _radius = 50;
    for "_i" from 0 to 23 do {
        private _a1 = (_i / 24) * 360;
        private _a2 = ((_i + 1) / 24) * 360;
        private _p1 = _pos getPos [_radius, _a1];
        private _p2 = _pos getPos [_radius, _a2];
        _p1 set [2, 1]; _p2 set [2, 1];
        drawLine3D [_p1, _p2, [1, 0, 0, 0.8]];
    };
    
    // Target label
    drawIcon3D ["", [1, 0, 0, 1], [_pos select 0, _pos select 1, 5], 0, 0, 0,
        format ["TARGET: %1", _type], 2, 0.04, "RobotoCondensed"];
    
    // Approach direction arrow (draw from approach pos toward target, capped at 300m for visibility)
    if (count _aPos > 0) then {
        private _dir = _aPos getDir _pos;
        private _arrowStart = _pos getPos [300, _dir + 180];  // 300m out from target along approach vector
        _arrowStart set [2, 2];
        private _arrowEnd = [_pos select 0, _pos select 1, 2];
        drawLine3D [_arrowStart, _arrowEnd, [1, 0.6, 0, 0.7]];
        
        // Arrowhead
        private _headSize = 30;
        private _headL = _pos getPos [_headSize, _dir + 150];
        private _headR = _pos getPos [_headSize, _dir - 150];
        _headL set [2, 2]; _headR set [2, 2];
        drawLine3D [_arrowEnd, [_headL select 0, _headL select 1, 2], [1, 0.6, 0, 0.7]];
        drawLine3D [_arrowEnd, [_headR select 0, _headR select 1, 2], [1, 0.6, 0, 0.7]];
    };
}];

missionNamespace setVariable [_markerID + "_drawHandler", _drawHandler];

// Route to attack function — now passing _approachPos
private _group = group _bestAircraft;

switch (_attackType) do {
    case "GUNS": {
        [_bestAircraft, _group, _targetPos, _unit, _markerID, _approachPos] spawn OpsRoom_fnc_airStrike_gunRun;
    };
    case "BOMBS": {
        [_bestAircraft, _group, _targetPos, _unit, _markerID, _approachPos] spawn OpsRoom_fnc_airStrike_bombRun;
    };
    case "ROCKETS": {
        [_bestAircraft, _group, _targetPos, _unit, _markerID, _approachPos] spawn OpsRoom_fnc_airStrike_rocketRun;
    };
    case "STRAFE": {
        [_bestAircraft, _group, _targetPos, _unit, _markerID, _approachPos] spawn OpsRoom_fnc_airStrike_strafeRun;
    };
    case "TORPEDO": {
        [_bestAircraft, _group, _targetPos, _unit, _markerID, _approachPos] spawn OpsRoom_fnc_airStrike_torpedoRun;
    };
};
