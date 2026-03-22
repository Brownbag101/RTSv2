/*
    OpsRoom_fnc_checkAimedShotCapable
    
    Validates which units qualify for Aimed Shot.
    
    Requirements:
        - Has OpsRoom_Ability_MarksmanShot variable (granted by Marksmanship Training)
        - Has ammo in primary weapon
    
    Parameters:
        0: ARRAY - Units to check
    
    Returns:
        ARRAY - [capable units, failed units]
*/

params [["_units", []]];

if (typeName _units != "ARRAY") then {
    _units = [_units];
};

private _capable = [];
private _failed = [];

{
    private _unit = _x;

    // Skip invalid
    if (isNull _unit || {typeName _unit != "OBJECT"}) then {
        continue;
    };

    // Must have the marksman qualification from training
    private _hasQual = _unit getVariable ["OpsRoom_Ability_MarksmanShot", false];

    // Must have ammo in primary weapon
    private _weapon = primaryWeapon _unit;
    private _hasAmmo = (_unit ammo _weapon) > 0;

    if (_hasQual && {_hasAmmo}) then {
        _capable pushBack _unit;
    } else {
        _failed pushBack _unit;
    };
} forEach _units;

[_capable, _failed]
