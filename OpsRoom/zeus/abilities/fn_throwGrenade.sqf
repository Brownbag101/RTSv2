/*
    OpsRoom_fnc_throwGrenade
    
    Executes the grenade throw with proper animation sequence
    Uses unit's actual grenade magazine
    
    Params:
        _unit - Unit throwing grenade
        _grenadeType - Magazine classname
        _targetPos - Target position [x, y, z]
*/

params ["_unit", "_grenadeType", "_targetPos"];

// Get grenade projectile class from magazine config
private _ammoClass = getText (configFile >> "CfgMagazines" >> _grenadeType >> "ammo");

if (_ammoClass == "") exitWith {
    hint "Invalid grenade type";
    diag_log format ["[OpsRoom] ERROR: Invalid grenade ammo class for %1", _grenadeType];
};

// Remove one magazine from unit
_unit removeMagazine _grenadeType;

// Calculate throw position
private _unitPos = getPosASL _unit;
_unitPos set [2, (_unitPos select 2) + 1.5]; // Throw from shoulder height

private _targetASL = ATLtoASL [_targetPos select 0, _targetPos select 1, 0];
_targetASL set [2, getTerrainHeightASL [_targetPos select 0, _targetPos select 1]];

// Calculate velocity
private _distance2D = _unitPos distance2D _targetASL;
private _heightDiff = (_targetASL select 2) - (_unitPos select 2);
private _throwVelocity = 18; // m/s - reduced from 25 to match arc preview
private _gravity = 9.81;

// Calculate optimal angle
private _angle = 60;
if (_distance2D > 0) then {
    private _vSquared = _throwVelocity * _throwVelocity;
    private _sinAngle = (_gravity * _distance2D) / _vSquared;
    
    if (_sinAngle < 1) then {
        _angle = (asin _sinAngle) / 2;
    };
};

// Direction to target
private _dir = _unitPos getDir _targetASL;

// Calculate velocity vector
private _vx = _throwVelocity * cos _angle * sin _dir;
private _vy = _throwVelocity * cos _angle * cos _dir;
private _vz = _throwVelocity * sin _angle;

private _velocity = [_vx, _vy, _vz];

// Execute throw with proper animation sequence
[_unit, _ammoClass, _unitPos, _velocity, _targetPos, _distance2D, _grenadeType] spawn {
    params ["_unit", "_ammoClass", "_spawnPos", "_velocity", "_targetPos", "_distance", "_grenadeType"];
    
    // Only do animation if unit is on foot
    if (vehicle _unit == _unit) then {
        // Snap unit to face target instantly, then doWatch for tracking
        private _dirToTarget = _unit getDir _targetPos;
        _unit setDir _dirToTarget;
        _unit doWatch _targetPos;
        sleep 0.5;
        
        // Play grenade throw animation sequence
        _unit playMove "AwopPercMstpSgthWnonDnon_start";
        sleep 1.2;
        
        _unit playMove "AwopPercMstpSgthWnonDnon_throw";
        sleep 1.5;
        
        // Additional wait to reach 4.5 seconds total (0.3 + 1.2 + 1.5 + 1.5 = 4.5)
        sleep 1.5;
        
    } else {
        // In vehicle, just wait 4.5 seconds
        sleep 4.5;
    };
    
    // Spawn grenade at exactly 4.5 seconds
    private _grenade = createVehicle [_ammoClass, ASLtoAGL _spawnPos, [], 0, "CAN_COLLIDE"];
    _grenade setPosASL _spawnPos;
    _grenade setVelocity _velocity;
    
    // Visual feedback
    systemChat format ["Grenade thrown at %.0fm", _distance];
    diag_log format ["[OpsRoom] Grenade spawned at 4.5s: Type=%1, Distance=%.0fm", _grenadeType, _distance];
    
    // Play end animation
    sleep 0.5;
    _unit playMove "AwopPercMstpSgthWnonDnon_end";
};

// Immediate feedback (don't wait for spawn)
diag_log format ["[OpsRoom] Grenade throw initiated: Type=%1, Distance=%.0fm", _grenadeType, _distance2D];
