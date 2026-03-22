/*
    OpsRoom_fnc_airStrike_torpedoRun
    
    Low-level torpedo attack. Aircraft flies to approach position (FAH),
    descends to wave-top height, flies level toward target, and releases
    torpedo at close range (~300m).
    
    Based on real Swordfish doctrine: approach at altitude, dive to
    release height of ~20m, straight and level run-in, torpedo away.
    
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

// Clear existing waypoints
while {count waypoints _group > 0} do {
    deleteWaypoint [_group, 0];
};

_group setBehaviourStrong "AWARE";
_group setSpeedMode "FULL";
_aircraft flyInHeight 200;

private _acName = getText (configFile >> "CfgVehicles" >> typeOf _aircraft >> "displayName");

// === PHASE 1: FLY TO APPROACH POSITION (FAH) ===
{ _x doMove _approachPos } forEach (units _group);

["PRIORITY", "TORPEDO RUN INBOUND",
    format ["%1 flying to attack heading.", _acName],
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

// === PHASE 2: TURN TOWARD TARGET AND DESCEND ===
{ _x doMove _targetPos } forEach (units _group);
_group setSpeedMode "NORMAL";

// Drop to torpedo release altitude - very low
_aircraft flyInHeight 30;

["ROUTINE", "CLEARED HOT", "Aircraft descending to torpedo release altitude.", nil, _radioOp] call OpsRoom_fnc_dispatch;

// Wait until aircraft is roughly facing target
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

// === PHASE 3: LOW-LEVEL RUN-IN ===
// Force aircraft to stay low and fly straight toward target
// Keep pushing flyInHeight and correcting altitude until within release range

_group setSpeedMode "NORMAL";
{ _x doMove _targetPos } forEach (units _group);

private _releaseDistance = 800;  // Release torpedo at 800m (historical: 900-1400m)
private _releaseTimeout = diag_tickTime + 120;

while { true } do {
    if (!alive _aircraft) exitWith { _exit = true };
    if ((_aircraft getVariable ["OpsRoom_AirStrike_Active", 0]) != _startTime) exitWith { _exit = true };
    if (diag_tickTime > _releaseTimeout) exitWith {};
    
    // Keep altitude low - clamp to ~30m
    private _currentAlt = (getPosATL _aircraft) select 2;
    if (_currentAlt > 50) then {
        _aircraft flyInHeight 25;
        // If way too high, push down
        if (_currentAlt > 80) then {
            private _vel = velocity _aircraft;
            _aircraft setVelocity [_vel select 0, _vel select 1, (_vel select 2) min -2];
        };
    };
    
    // Check distance to target
    if ((_aircraft distance2D _targetPos) < _releaseDistance) exitWith {};
    
    sleep 0.3;
};

if (_exit) exitWith {
    { _x enableAI "TARGET"; _x enableAI "AUTOTARGET" } forEach (units _group);
    [_markerID] call OpsRoom_fnc_airStrike_cleanup;
};

// === PHASE 4: TORPEDO RELEASE ===
// Find torpedo weapon and magazine
private _torpMag = "";
private _torpAmmo = "";
private _torpTurret = [];
private _torpWeapon = "";

// First: find the torpedo magazine
{
    _x params ["_mag", "_turretPath", "_count"];
    if (_count > 0 && _torpMag == "") then {
        private _ammo = getText (configFile >> "CfgMagazines" >> _mag >> "ammo");
        if (_ammo != "") then {
            private _cfg = configFile >> "CfgAmmo" >> _ammo;
            private _parents = [_cfg, true] call BIS_fnc_returnParents;
            private _ammoLC = toLower _ammo;
            private _magLC = toLower _mag;
            
            private _isTorp = false;
            if ("TorpedoCore" in _parents) then { _isTorp = true };
            if ("torp" in _ammoLC || "torp" in _magLC) then { _isTorp = true };
            if ("MissileCore" in _parents && {getNumber (_cfg >> "hit") > 500}) then { _isTorp = true };
            
            if (_isTorp) then {
                _torpMag = _mag;
                _torpAmmo = _ammo;
                _torpTurret = _turretPath;
            };
        };
    };
} forEach (magazinesAllTurrets _aircraft);

if (_torpAmmo == "") exitWith {
    hint "Aircraft has no torpedo - aborting run.";
    { _x enableAI "TARGET"; _x enableAI "AUTOTARGET" } forEach (units _group);
    [_markerID] call OpsRoom_fnc_airStrike_cleanup;
    [_aircraft, _group] call OpsRoom_fnc_airStrike_returnToLoiter;
};

// Second: find the weapon that fires this magazine
{
    private _wep = _x;
    private _mags = getArray (configFile >> "CfgWeapons" >> _wep >> "magazines");
    if (_torpMag in _mags) exitWith { _torpWeapon = _wep };
    // Check sub-modes (some weapons have nested magazine lists)
    private _subClasses = configProperties [configFile >> "CfgWeapons" >> _wep, "isClass _x", true];
    {
        private _subMags = getArray (configFile >> "CfgWeapons" >> _wep >> (configName _x) >> "magazines");
        if (_torpMag in _subMags) exitWith { _torpWeapon = _wep };
    } forEach _subClasses;
    if (_torpWeapon != "") exitWith {};
} forEach (weapons _aircraft);

diag_log format ["[OpsRoom] Torpedo: mag=%1 ammo=%2 weapon=%3 turret=%4", _torpMag, _torpAmmo, _torpWeapon, _torpTurret];

// Try legitimate weapon fire first - ARMA handles trajectory naturally
private _firedLegit = false;

if (_torpWeapon != "") then {
    // Enable AI targeting briefly so fireAtTarget works, then point at target
    { _x enableAI "TARGET"; _x enableAI "AUTOTARGET" } forEach (units _group);
    _aircraft doWatch _targetPos;
    sleep 0.2;
    
    // Select the torpedo weapon and fire
    _aircraft selectWeapon _torpWeapon;
    sleep 0.1;
    _aircraft fireAtTarget [objNull, _torpWeapon];
    
    // Immediately start egress to clear blast zone
    { _x disableAI "TARGET"; _x disableAI "AUTOTARGET" } forEach (units _group);
    _aircraft flyInHeight 100;
    private _egressDirImm = _targetPos getDir (getPos _aircraft);
    private _egressPosImm = _targetPos getPos [2000, _egressDirImm];
    { _x doMove _egressPosImm } forEach (units _group);
    
    // Check if ammo count decreased (confirming fire worked)
    sleep 0.5;
    private _stillHasTorp = [_aircraft, "TORPEDO"] call OpsRoom_fnc_airStrike_hasWeaponType;
    if (!_stillHasTorp) then {
        _firedLegit = true;
        diag_log format ["[OpsRoom] Torpedo: Legit fire succeeded via %1", _torpWeapon];
    } else {
        // Try fire command without target
        _aircraft fire [_torpWeapon, _torpTurret];
        sleep 0.5;
        _stillHasTorp = [_aircraft, "TORPEDO"] call OpsRoom_fnc_airStrike_hasWeaponType;
        if (!_stillHasTorp) then {
            _firedLegit = true;
            diag_log format ["[OpsRoom] Torpedo: Legit fire succeeded via direct fire %1", _torpWeapon];
        };
    };
};

// Fallback: simulate torpedo with level guidance (not dive-bomb guidance)
if (!_firedLegit) then {
    diag_log "[OpsRoom] Torpedo: Legit fire failed, using level simulation";
    
    private _acPos = getPosASL _aircraft;
    private _dir = getDir _aircraft;
    private _terrainZ = getTerrainHeightASL _targetPos;
    
    // Spawn torpedo ahead of aircraft at same altitude (not below)
    private _torpSpawnPos = [
        (_acPos select 0) + (15 * sin _dir),
        (_acPos select 1) + (15 * cos _dir),
        _acPos select 2  // Same altitude as aircraft
    ];
    
    // Get torpedo speed from config
    private _torpSpeed = getNumber (configFile >> "CfgAmmo" >> _torpAmmo >> "maxSpeed");
    if (_torpSpeed <= 0) then { _torpSpeed = 80 };
    
    private _torpedo = createVehicle [_torpAmmo, ASLToATL _torpSpawnPos, [], 0, "FLY"];
    _torpedo setPosASL _torpSpawnPos;
    
    // Level guidance: steer torpedo horizontally toward target,
    // only descending gently - NOT diving like guideProjectile does
    private _targetFlat = [_targetPos select 0, _targetPos select 1, _terrainZ + 1];
    
    [_torpedo, _targetFlat, _torpSpeed, _torpSpawnPos select 2] spawn {
        params ["_proj", "_tgt", "_spd", "_startZ"];
        
        private _startTime = diag_tickTime;
        while {!isNull _proj} do {
            if ((diag_tickTime - _startTime) > 20) exitWith {};
            
            private _curPos = getPosASLVisual _proj;
            private _dist2D = [_curPos select 0, _curPos select 1, 0] distance2D [_tgt select 0, _tgt select 1, 0];
            
            // Horizontal direction to target
            private _dirX = ((_tgt select 0) - (_curPos select 0));
            private _dirY = ((_tgt select 1) - (_curPos select 1));
            private _dirMag = sqrt (_dirX * _dirX + _dirY * _dirY);
            if (_dirMag < 1) exitWith { triggerAmmo _proj };
            _dirX = _dirX / _dirMag;
            _dirY = _dirY / _dirMag;
            
            // Gentle descent: drop from aircraft altitude to ground level
            // over the travel distance
            private _progress = 1 - (_dist2D / ((_startZ - (_tgt select 2)) max 1 + _dist2D));
            private _targetZ = _startZ + ((_tgt select 2) - _startZ) * (_progress min 1 max 0);
            private _velZ = ((_targetZ - (_curPos select 2)) * 2) max -5 min 2;
            
            _proj setVelocity [_dirX * _spd, _dirY * _spd, _velZ];
            _proj setVectorDir [_dirX, _dirY, _velZ / _spd];
            
            if (_dist2D < 10) exitWith { triggerAmmo _proj };
            
            sleep 0.05;
        };
    };
    
    // Remove the magazine
    _aircraft removeMagazineTurret [_torpMag, _torpTurret];
};

["FLASH", "TORPEDO AWAY",
    format ["%1: Torpedo released at %2m. Fish in the water!", _acName, round (_aircraft distance2D _targetPos)],
    nil, _radioOp
] call OpsRoom_fnc_dispatch;

diag_log format ["[OpsRoom] Torpedo released: %1 from %2 at %3m range (legit: %4)", _torpAmmo, typeOf _aircraft, round (_aircraft distance2D _targetPos), _firedLegit];

sleep 2;

// === PHASE 5: EGRESS ===
{ _x enableAI "TARGET"; _x enableAI "AUTOTARGET" } forEach (units _group);
_group setSpeedMode "FULL";
_group setBehaviourStrong "AWARE";

// Climb and egress away from target
private _egressDir = _targetPos getDir (getPos _aircraft);
private _egressPos = _targetPos getPos [3000, _egressDir];
{ _x doMove _egressPos } forEach (units _group);
_aircraft flyInHeight 500;

["ROUTINE", "TORPEDO RUN COMPLETE",
    format ["%1 torpedo run complete. Aircraft egressing.", _acName],
    nil, _radioOp
] call OpsRoom_fnc_dispatch;

_aircraft setVariable ["OpsRoom_AirStrike_Active", nil, true];

sleep 5;
[_markerID] call OpsRoom_fnc_airStrike_cleanup;

// Return to loiter (or auto-RTB if scheduled)
sleep 3;
[_aircraft, _group] call OpsRoom_fnc_airStrike_returnToLoiter;

diag_log format ["[OpsRoom] Torpedo run complete on %1", typeOf _aircraft];
