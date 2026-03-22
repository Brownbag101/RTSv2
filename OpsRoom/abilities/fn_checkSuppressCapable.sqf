/*
    Author: OpsRoom
    Description: Check if units are capable of suppression (have MG + ammo)
    
    Parameters:
        0: ARRAY - Units to check
    
    Returns:
        ARRAY - [capable units, failed units]
*/

params [["_units", []]];

// Defensive: ensure _units is an array
if (typeName _units != "ARRAY") then {
    _units = [_units];
};

private _mgWeapons = [
    "fow_w_bren",
    "fow_v_uk_bren",
    "JMSSA_bren2_Rifle"
    // Add more MG weapons here as needed
];

private _capable = [];
private _failed = [];

{
    private _unit = _x;
    
    // Skip if not a valid unit object
    if (isNull _unit || {typeName _unit != "OBJECT"}) then {
        continue;
    };
    
    private _weapon = primaryWeapon _unit;
    private _ammo = _unit ammo _weapon;
    
    // Check: has MG weapon AND has ammo
    private _hasMG = _weapon in _mgWeapons;
    private _hasAmmo = _ammo > 0;
    
    if (_hasMG && _hasAmmo) then {
        _capable pushBack _unit;
    } else {
        _failed pushBack _unit;
    };
    
} forEach _units;

[_capable, _failed]
