/*
    OpsRoom_fnc_airStrike_strafeRun
    
    Flies aircraft to approach position (FAH), turns toward target,
    then performs a combined guns + rockets strafing pass.
    
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
_aircraft flyInHeight 300;

// === PHASE 1: FLY TO APPROACH POSITION (FAH) ===
{ _x doMove _approachPos } forEach (units _group);

["PRIORITY", "STRAFE RUN INBOUND",
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
{ _x doWatch _targetPos } forEach (units _group);
{ _x doMove _targetPos } forEach (units _group);
_group setSpeedMode "FULL";

["ROUTINE", "CLEARED HOT", "Aircraft turning onto strafe heading.", nil, _radioOp] call OpsRoom_fnc_dispatch;

while { true } do {
    if (!alive _aircraft) exitWith { _exit = true };
    if ((_aircraft getVariable ["OpsRoom_AirStrike_Active", 0]) != _startTime) exitWith { _exit = true };
    private _relDir = _aircraft getRelDir _targetPos;
    if (_relDir > 270 || _relDir < 90) exitWith {};
    sleep 0.5;
};

if (_exit) exitWith {
    { _x enableAI "TARGET"; _x enableAI "AUTOTARGET" } forEach (units _group);
    [_markerID] call OpsRoom_fnc_airStrike_cleanup;
};

// === PHASE 3: CLOSE TO STRAFE RANGE ===
_group setSpeedMode "LIMITED";
while { true } do {
    if (!alive _aircraft) exitWith { _exit = true };
    if ((_aircraft getVariable ["OpsRoom_AirStrike_Active", 0]) != _startTime) exitWith { _exit = true };
    if ((_aircraft distance2D _targetPos) < 1500) exitWith {};
    sleep 0.5;
};

if (_exit) exitWith {
    { _x enableAI "TARGET"; _x enableAI "AUTOTARGET" } forEach (units _group);
    [_markerID] call OpsRoom_fnc_airStrike_cleanup;
};

// === PHASE 4: FIND WEAPONS ===
private _gun = "";
{
    private _parents = [configFile >> "CfgWeapons" >> _x, true] call BIS_fnc_returnParents;
    if ("CannonCore" in _parents) exitWith { _gun = _x };
} forEach (weapons _aircraft);
if (_gun == "") then {
    {
        private _parents = [configFile >> "CfgWeapons" >> _x, true] call BIS_fnc_returnParents;
        if ("MGun" in _parents) exitWith { _gun = _x };
    } forEach (weapons _aircraft);
};

private _rocketLauncher = "";
{
    private _parents = [configFile >> "CfgWeapons" >> _x, true] call BIS_fnc_returnParents;
    if ("RocketPods" in _parents) exitWith { _rocketLauncher = _x };
} forEach (weapons _aircraft);

// === PHASE 5: DIVE ATTACK ===
private _pos = [_targetPos select 0, _targetPos select 1, getTerrainHeightASL _targetPos];

// Snap to nearby vehicles
private _nearVehicles = _pos nearEntities [["LandVehicle"], 20];
if (count _nearVehicles > 0) then {
    _pos = getPosASL (selectRandom _nearVehicles);
};

// 1. Point aircraft direction at target
_aircraft setDir (_aircraft getDir _pos);

// 2. Fired EH — guide all projectiles
private _fireEH = _aircraft addEventHandler ["Fired", compile format [
    "params ['_veh','_wep','_muz','_mode','_ammo','_mag','_proj'];
    if (!isNull _proj) then {
        private _ammoType = typeOf _proj;
        private _cfg = configFile >> 'CfgAmmo' >> _ammoType;
        private _thrust = getNumber (_cfg >> 'thrust');
        if (_thrust > 0) then {
            // Rocket - use per-tick guidance
            private _speed = getNumber (_cfg >> 'maxSpeed');
            private _tgt = [%1, 15] call OpsRoom_fnc_airStrike_scatterPos;
            [_proj, _tgt, _speed] spawn OpsRoom_fnc_airStrike_guideProjectile;
        } else {
            // Bullet - set initial velocity toward target with scatter
            private _tgt = [%1, 20] call OpsRoom_fnc_airStrike_scatterPos;
            _proj setVelocity (([getPosASL _proj, _tgt] call BIS_fnc_VectorFromXtoY) vectorMultiply 3);
        };
    };",
    _pos
]];

// 3. Calculate dive pitch
private _pitchBank = _aircraft call BIS_fnc_getPitchBank;
private _bank = _pitchBank select 1;
private _pitchTarget = (((getPosASL _aircraft) select 2) - (_pos select 2)) atan2 (_aircraft distance _pos);
_pitchTarget = _pitchTarget - (_pitchTarget * 2);
[_aircraft, _pitchTarget, _bank] call BIS_fnc_setPitchBank;

_pitchBank = _aircraft call BIS_fnc_getPitchBank;
private _pitch = _pitchBank select 0;
_bank = _pitchBank select 1;

// 5. Set vector direction toward target
private _vectorDir = [getPosASL _aircraft, _pos] call BIS_fnc_VectorFromXtoY;
_aircraft setVectorDir _vectorDir;

// 6. Calculate velocity vector toward target
private _aircraftSpeed = (speed _aircraft) * 0.3;
private _travelTime = (_pos distance _aircraft) / _aircraftSpeed;
private _velocityX = ((_pos select 0) - ((getPosASL _aircraft) select 0)) / _travelTime;
private _velocityY = ((_pos select 1) - ((getPosASL _aircraft) select 1)) / _travelTime;
private _velocityZ = ((_pos select 2) - ((getPosASL _aircraft) select 2)) / _travelTime;
private _velocity = [_velocityX, _velocityY, _velocityZ];

// === GUNS PHASE (1.5 seconds) ===
private _endTime = diag_tickTime + 1.5;
while { true } do {
    if (diag_tickTime > _endTime) exitWith {};
    if (!alive _aircraft) exitWith { _exit = true };
    if ((_aircraft distance _pos) < 200) exitWith {};
    if (((getPosATL _aircraft) select 2) < 30) exitWith {};

    _aircraft setVelocity _velocity;
    [_aircraft, _pitch, _bank] call BIS_fnc_setPitchBank;
    _pitch = _pitch + 0.025;

    if (_gun != "") then {
        _aircraft fireAtTarget [objNull, _gun];
    };

    sleep 0.1;
};

// === ROCKETS PHASE (1.5 seconds) ===
private _rocketCount = selectRandom [3, 4, 5];
_endTime = diag_tickTime + 1.5;

while { true } do {
    if (_rocketCount < 1) exitWith {};
    if (diag_tickTime > _endTime) exitWith {};
    if (!alive _aircraft) exitWith { _exit = true };
    if ((_aircraft distance _pos) < 100) exitWith {};
    if (((getPosATL _aircraft) select 2) < 30) exitWith {};

    _aircraft setVelocity _velocity;
    [_aircraft, _pitch, _bank] call BIS_fnc_setPitchBank;
    _pitch = _pitch + 0.025;

    if (_rocketLauncher != "") then {
        private _rl = toUpper _rocketLauncher;
        _aircraft selectWeapon _rl;
        _aircraft fireAtTarget [objNull, _rl];
    };

    _rocketCount = _rocketCount - 1;
    sleep 0.3;
};

_aircraft removeEventHandler ["Fired", _fireEH];

["FLASH", "STRAFE COMPLETE",
    format ["%1 strafe run complete.", getText (configFile >> "CfgVehicles" >> typeOf _aircraft >> "displayName")],
    nil, _radioOp
] call OpsRoom_fnc_dispatch;

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

diag_log format ["[OpsRoom] Strafe run complete on %1", typeOf _aircraft];
