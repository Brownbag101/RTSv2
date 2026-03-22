/*
    OpsRoom_fnc_airStrike_guideProjectile
    
    Per-tick guidance loop for projectiles (rockets and bombs).
    Ported from Drongo's Air Ops GuidePos.sqf.
    
    Continuously adjusts the projectile's velocity vector to steer
    it toward the target position until impact or timeout.
    
    Parameters:
        0: OBJECT - Projectile (rocket/bomb)
        1: ARRAY  - Target position [x,y,z] (ASL)
        2: NUMBER - Speed multiplier (default: use projectile's maxSpeed from config)
    
    Called via spawn from Fired event handlers.
*/

params ["_projectile", "_targetPos", ["_speed", -1]];

if (isNull _projectile) exitWith {};

// Get speed from config if not provided
if (_speed < 0) then {
    _speed = getNumber (configFile >> "CfgAmmo" >> typeOf _projectile >> "maxSpeed");
    if (_speed <= 0) then { _speed = 300 };
};

private _minDistance = 5;
private _triggerDistance = getNumber (configFile >> "CfgAmmo" >> typeOf _projectile >> "triggerDistance");
if (_triggerDistance <= 0) then { _triggerDistance = 3 };

private _startTime = diag_tickTime;
private _maxLifetime = 15;  // Safety timeout

while {!isNull _projectile} do {
    // Timeout safety
    if ((diag_tickTime - _startTime) > _maxLifetime) exitWith {};
    
    private _currentPos = getPosASLVisual _projectile;
    private _forwardVector = vectorNormalized (_targetPos vectorDiff _currentPos);
    private _rightVector = (_forwardVector vectorCrossProduct [0, 0, 1]) vectorMultiply -1;
    private _upVector = _forwardVector vectorCrossProduct _rightVector;
    private _targetVelocity = _forwardVector vectorMultiply _speed;
    
    _projectile setVectorDirAndUp [_forwardVector, _upVector];
    _projectile setVelocity _targetVelocity;
    
    private _distance = (getPosASLVisual _projectile) distance _targetPos;
    
    // Trigger detonation at close range
    if (_distance < _triggerDistance) exitWith {
        triggerAmmo _projectile;
    };
    
    if (_distance <= _minDistance) exitWith {};
    
    sleep 0.01;
};
