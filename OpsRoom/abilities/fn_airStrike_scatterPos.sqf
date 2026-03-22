/*
    OpsRoom_fnc_airStrike_scatterPos
    
    Returns a position scattered randomly within a circle around the target.
    Ported from Drongo's ScatterInCircle.
    
    Parameters:
        0: ARRAY  - Centre position [x,y,z]
        1: NUMBER - Scatter radius in metres
    
    Returns: ARRAY - Scattered position [x,y,z] (ASL)
*/

params ["_pos", "_size"];

if (_size < 0.1) then { _size = 0.1 };

private _a = random (_size) * 2 * 3.14;
private _r = _size * sqrt (random 1);
private _posX = _r * cos _a + (_pos select 0);
private _posY = _r * sin _a + (_pos select 1);
private _posZ = getTerrainHeightASL [_posX, _posY];

[_posX, _posY, _posZ]
