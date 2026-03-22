/*
    OpsRoom_fnc_airStrike_bombRun
    
    Flies aircraft to approach position (FAH), turns toward target,
    then performs a dive-bomb approach with guided bomb release.
    
    Parameters:
        0: OBJECT - aircraft vehicle
        1: GROUP  - aircraft group
        2: ARRAY  - target position [x,y,z]
        3: OBJECT - radio operator unit
        4: STRING - marker ID for Draw3D cleanup
        5: ARRAY  - approach position [x,y,z] (FAH)
*/

params ["_aircraft", "_group", "_targetPos", "_radioOp", "_markerID", "_approachPos"];

if (!alive _aircraft) exitWith {
    [_markerID] call OpsRoom_fnc_airStrike_cleanup;
};

private _startTime = diag_tickTime;
_aircraft setVariable ["OpsRoom_AirStrike_Active", _startTime, true];

// Disable AI targeting
{ _x disableAI "TARGET" } forEach (units _group);
{ _x disableAI "AUTOTARGET" } forEach (units _group);

// Boost pilot skill
{ _x setUnitAbility OpsRoom_Settings_PilotSkill } forEach (crew _aircraft);

// Clear existing waypoints (loiter etc) so the aircraft actually responds
while {count waypoints _group > 0} do {
    deleteWaypoint [_group, 0];
};

_group setBehaviourStrong "AWARE";
_group setSpeedMode "FULL";

// Find a bomb magazine on this aircraft
private _bombMag = "";
{
    _x params ["_mag", "", "_count"];
    if (_count > 0) then {
        private _ammo = getText (configFile >> "CfgMagazines" >> _mag >> "ammo");
        if (_ammo != "") then {
            private _cfg = configFile >> "CfgAmmo" >> _ammo;
            private _parents = [_cfg, true] call BIS_fnc_returnParents;
            if ("BombCore" in _parents) exitWith { _bombMag = _mag };
            private _hit = getNumber (_cfg >> "hit");
            private _thrust = getNumber (_cfg >> "thrust");
            if (_hit > 100 && _thrust == 0) exitWith { _bombMag = _mag };
        };
    };
} forEach (magazinesAllTurrets _aircraft);

if (_bombMag == "") exitWith {
    hint "Aircraft has no bombs.";
    { _x enableAI "TARGET"; _x enableAI "AUTOTARGET" } forEach (units _group);
    [_markerID] call OpsRoom_fnc_airStrike_cleanup;
};

// Find the launcher (weapon) for this bomb magazine
private _bombLauncher = "";
{
    private _wep = _x;
    private _mags = getArray (configFile >> "CfgWeapons" >> _wep >> "magazines");
    if (_bombMag in _mags) exitWith { _bombLauncher = _wep };
    private _subClasses = configProperties [configFile >> "CfgWeapons" >> _wep, "isClass _x", true];
    {
        private _subName = configName _x;
        private _subMags = getArray (configFile >> "CfgWeapons" >> _wep >> _subName >> "magazines");
        if (_bombMag in _subMags) exitWith { _bombLauncher = _wep };
    } forEach _subClasses;
    if (_bombLauncher != "") exitWith {};
} forEach (weapons _aircraft);

// === PHASE 1: FLY TO APPROACH POSITION (FAH) ===
{ _x doMove _approachPos } forEach (units _group);
_aircraft flyInHeight 200;

["PRIORITY", "BOMB RUN INBOUND",
    format ["%1 flying to attack heading.", getText (configFile >> "CfgVehicles" >> typeOf _aircraft >> "displayName")],
    nil, _radioOp
] call OpsRoom_fnc_dispatch;

private _exit = false;
private _fahTimeout = diag_tickTime + 180;
while { true } do {
    if (!alive _aircraft) exitWith { _exit = true };
    if ((_aircraft getVariable ["OpsRoom_AirStrike_Active", 0]) != _startTime) exitWith { _exit = true };
    if (diag_tickTime > _fahTimeout) exitWith {};
    if ((_aircraft distance2D _approachPos) < 600) exitWith {};
    sleep 1;
};

if (_exit) exitWith {
    { _x enableAI "TARGET"; _x enableAI "AUTOTARGET" } forEach (units _group);
    [_markerID] call OpsRoom_fnc_airStrike_cleanup;
};

// === PHASE 2: TURN TOWARD TARGET ===
{ _x doMove _targetPos } forEach (units _group);
_group setSpeedMode "LIMITED";

["ROUTINE", "CLEARED HOT", "Aircraft turning onto bomb run heading.", nil, _radioOp] call OpsRoom_fnc_dispatch;

while { true } do {
    if (!alive _aircraft) exitWith { _exit = true };
    if ((_aircraft getVariable ["OpsRoom_AirStrike_Active", 0]) != _startTime) exitWith { _exit = true };
    private _relDir = _aircraft getRelDir _targetPos;
    if (_relDir > 315 || _relDir < 45) exitWith {};
    sleep 0.5;
};

if (_exit) exitWith {
    { _x enableAI "TARGET"; _x enableAI "AUTOTARGET" } forEach (units _group);
    [_markerID] call OpsRoom_fnc_airStrike_cleanup;
};

// === PHASE 3: LEVEL BOMB APPROACH (Fix #7: reliable bomb release) ===
// Fly level toward target. When overhead, simulate bomb drop.
// This avoids fighting ARMA AI with setVelocity/setPitchBank.

private _pos = [_targetPos select 0, _targetPos select 1, getTerrainHeightASL _targetPos];

// Reduce altitude for bomb run
_aircraft flyInHeight 200;
_group setSpeedMode "FULL";
{ _x doMove _targetPos } forEach (units _group);

// Wait until aircraft is within release distance (500m overhead)
private _releaseDistance = 500;
private _releaseTimeout = diag_tickTime + 120;
private _released = false;

while { true } do {
    if (!alive _aircraft) exitWith { _exit = true };
    if ((_aircraft getVariable ["OpsRoom_AirStrike_Active", 0]) != _startTime) exitWith { _exit = true };
    if (diag_tickTime > _releaseTimeout) exitWith {};
    if ((_aircraft distance2D _targetPos) < _releaseDistance) exitWith {};
    sleep 0.5;
};

if (_exit) exitWith {
    { _x enableAI "TARGET"; _x enableAI "AUTOTARGET" } forEach (units _group);
    [_markerID] call OpsRoom_fnc_airStrike_cleanup;
};

// === BOMB RELEASE — DROP FULL PAYLOAD ===
// Scan all bomb magazines. Each entry has a count (rounds in that mag).
// We expand into individual bombs: one simulated bomb per round.
private _bombsToDrop = [];  // Array of [magClass, ammoClass, turretPath]
private _seenMagTurrets = [];  // Track [mag+turret] pairs to prevent double-counting
{
    _x params ["_mag", "_turretPath", "_count"];
    if (_count > 0) then {
        // Deduplicate: same mag on same turret path = skip (SAB mods report duplicates)
        private _key = format ["%1_%2", _mag, _turretPath];
        if (_key in _seenMagTurrets) then { continue };
        _seenMagTurrets pushBack _key;
        
        private _ammoStr = getText (configFile >> "CfgMagazines" >> _mag >> "ammo");
        if (_ammoStr != "") then {
            private _cfg = configFile >> "CfgAmmo" >> _ammoStr;
            private _parents = [_cfg, true] call BIS_fnc_returnParents;
            private _isBomb = false;
            if ("BombCore" in _parents) then { _isBomb = true };
            if (!_isBomb) then {
                private _hit = getNumber (_cfg >> "hit");
                private _thrust = getNumber (_cfg >> "thrust");
                if (_hit > 100 && _thrust == 0) then { _isBomb = true };
            };
            if (_isBomb) then {
                // Expand: one entry per round in this magazine
                for "_i" from 1 to _count do {
                    _bombsToDrop pushBack [_mag, _ammoStr, _turretPath];
                };
            };
        };
    };
} forEach (magazinesAllTurrets _aircraft);

diag_log format ["[OpsRoom] Bomb scan: %1 unique mag/turret pairs, %2 total bombs to drop", count _seenMagTurrets, count _bombsToDrop];

private _bombCount = count _bombsToDrop;
if (_bombCount == 0) then { _bombCount = 1 };

private _ammoClass = if (_bombCount > 0 && {count _bombsToDrop > 0}) then {
    (_bombsToDrop select 0) select 1
} else {
    "Bo_GBU12_LGB"
};

diag_log format ["[OpsRoom] Bomb run: dropping %1 bombs (%2) from %3", _bombCount, _ammoClass, typeOf _aircraft];

// Drop bombs in a staggered sequence
private _dropIndex = 0;
{
    _x params ["_mag", "_ammoStr", "_turretPath"];
    
    if (!alive _aircraft) exitWith {};
    
    private _acPos = getPosASL _aircraft;
    private _dir = getDir _aircraft;
    private _offset = _dropIndex * 12;  // 12m spacing between bomb drops
    private _dropPos = [
        (_acPos select 0) - (_offset * sin _dir),
        (_acPos select 1) - (_offset * cos _dir),
        (_acPos select 2) - 5
    ];
    
    // Scatter target slightly for each bomb
    private _scatterTarget = [_pos, 30] call OpsRoom_fnc_airStrike_scatterPos;
    
    // Spawn guided bomb projectile
    private _bomb = createVehicle [_ammoStr, ASLToATL _dropPos, [], 0, "FLY"];
    _bomb setPosASL _dropPos;
    [_bomb, _scatterTarget, 250] spawn OpsRoom_fnc_airStrike_guideProjectile;
    
    _dropIndex = _dropIndex + 1;
    
    sleep 0.3;  // Stagger drops
} forEach _bombsToDrop;

// Remove ALL bomb magazines from the aircraft (consume entire payload)
{
    _x params ["_mag", "_turretPath2", "_count"];
    private _ammoStr = getText (configFile >> "CfgMagazines" >> _mag >> "ammo");
    if (_ammoStr != "") then {
        private _cfg = configFile >> "CfgAmmo" >> _ammoStr;
        private _parents = [_cfg, true] call BIS_fnc_returnParents;
        private _isBomb = false;
        if ("BombCore" in _parents) then { _isBomb = true };
        if (!_isBomb) then {
            private _hit = getNumber (_cfg >> "hit");
            private _thrust = getNumber (_cfg >> "thrust");
            if (_hit > 100 && _thrust == 0) then { _isBomb = true };
        };
        if (_isBomb) then {
            _aircraft removeMagazineTurret [_mag, _turretPath2];
        };
    };
} forEach (magazinesAllTurrets _aircraft);

_released = true;

["FLASH", "BOMBS AWAY",
    format ["%1: %2 bombs released on target.", getText (configFile >> "CfgVehicles" >> typeOf _aircraft >> "displayName"), _bombCount],
    nil, _radioOp
] call OpsRoom_fnc_dispatch;

sleep 2;

// === EGRESS ===
{ _x enableAI "TARGET"; _x enableAI "AUTOTARGET" } forEach (units _group);
_group setSpeedMode "FULL";
_group setBehaviourStrong "AWARE";

private _egressDir = _targetPos getDir (getPos _aircraft);
private _egressPos = _targetPos getPos [3000, _egressDir];
{ _x doMove _egressPos } forEach (units _group);
_aircraft flyInHeight 500;

_aircraft setVariable ["OpsRoom_AirStrike_Active", nil, true];

sleep 5;
[_markerID] call OpsRoom_fnc_airStrike_cleanup;

// Fix #3: Return to loiter position after attack
sleep 3;
[_aircraft, _group] call OpsRoom_fnc_airStrike_returnToLoiter;

diag_log format ["[OpsRoom] Bomb run complete on %1", typeOf _aircraft];
