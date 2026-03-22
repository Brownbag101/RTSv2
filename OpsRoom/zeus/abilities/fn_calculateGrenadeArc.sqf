/*
    OpsRoom_fnc_calculateGrenadeArc
    
    Calculates ballistic trajectory for grenade throw
    Returns array of 3D positions forming the arc
    
    Params:
        _startPos - Start position ASL [x, y, z]
        _targetPos - Target position (ground level)
        _inRange - Boolean, true if target is in range
        
    Returns:
        Array of positions forming the arc
*/

params ["_startPos", "_targetPos", ["_inRange", true]];

private _arc = [];

// Target position at visual ground level (Z=0 for VR)
private _targetASL = [_targetPos select 0, _targetPos select 1, 0];

// Calculate 2D distance
private _distance2D = _startPos distance2D _targetASL;
private _heightDiff = (_targetASL select 2) - (_startPos select 2);

// Grenade physics constants - REDUCED velocity for shorter throw
private _velocity = 18; // m/s - reduced from 25 to 18 for more accurate landing
private _gravity = 9.81; // m/s²

// Calculate throw angle - HIGHER angle for more vertical arc
private _angle = 60; // Steep angle
if (_distance2D > 0) then {
    // Use simplified ballistic formula
    private _vSquared = _velocity * _velocity;
    private _range = _distance2D;
    
    // Calculate required angle: angle = 0.5 * arcsin((g * range) / v²)
    private _sinAngle = (_gravity * _range) / _vSquared;
    
    if (_sinAngle < 1) then {
        // Use steeper angle (closer to 90°)
        _angle = (asin _sinAngle) / 1.5; // Steeper arc
    } else {
        _angle = 60; // Higher max angle
    };
};

// Direction from unit to target
private _dir = _startPos getDir _targetASL;

// Calculate trajectory points
private _numPoints = 20;
private _timeStep = 0.1;

// Calculate total flight time
private _vx = _velocity * cos _angle;
private _vy = _velocity * sin _angle;
private _totalTime = (_distance2D / _vx) min 5; // Cap at 5 seconds

for "_i" from 0 to _numPoints do {
    private _t = (_totalTime * _i) / _numPoints;
    
    // Calculate position at time t
    private _x = _vx * _t; // Horizontal distance
    private _y = (_vy * _t) - (0.5 * _gravity * _t * _t); // Vertical height
    
    // Convert to world position
    private _worldPos = [
        (_startPos select 0) + (_x * sin _dir),
        (_startPos select 1) + (_x * cos _dir),
        (_startPos select 2) + _y
    ];
    
    // Check if below visual ground (Z=0)
    if ((_worldPos select 2) < 0) then {
        // Hit ground, stop here at Z=0
        _worldPos set [2, 0];
        _arc pushBack _worldPos;
        break;
    };
    
    _arc pushBack _worldPos;
};

// Ensure we have at least 2 points
if (count _arc < 2) then {
    _arc = [_startPos, _targetASL];
};

_arc
