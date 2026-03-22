/*
    Check Area Clear
    
    Checks if a specified area is clear of enemy forces.
    Enemies are determined by being hostile to the player's side.
    
    Parameters:
        0: ARRAY - Position to check (default: player position)
        1: NUMBER - Radius in meters (default: 500)
    
    Returns:
        BOOL - True if no enemies in area
    
    Usage:
        private _isClear = [] call OpsRoom_fnc_checkAreaClear;
        private _isClear = [getPos player, 500] call OpsRoom_fnc_checkAreaClear;
*/

params [
    ["_position", getPos player, [[]]],
    ["_radius", 500, [0]]
];

private _nearUnits = _position nearEntities ["Man", _radius];

// Get player's side
private _playerSide = side player;
if (_playerSide == sideLogic) then {
    _playerSide = independent;  // Default if Zeus
};

// Count enemy units (anyone hostile to player's side)
private _enemyCount = 0;
{
    private _unitSide = side _x;
    
    // Check if this unit is an enemy (hostile to player's side)
    if (alive _x && [_playerSide, _unitSide] call BIS_fnc_sideIsEnemy) then {
        _enemyCount = _enemyCount + 1;
        diag_log format ["[OpsRoom Mission1] Enemy detected: %1 (%2) at %3m", typeOf _x, _unitSide, _position distance _x];
    };
} forEach _nearUnits;

private _isClear = (_enemyCount == 0);

if (_isClear) then {
    diag_log format ["[OpsRoom Mission1] Area clear: no enemies within %1m of %2", _radius, _position];
} else {
    diag_log format ["[OpsRoom Mission1] Area contested: %1 enemies within %2m", _enemyCount, _radius];
};

_isClear
