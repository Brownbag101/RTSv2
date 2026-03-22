/*
    OpsRoom_fnc_airStrike_hasGuns
    
    Check if an aircraft has a cannon or machine gun with ammo.
    Ported from Drongo's Air Ops HasGun.sqf logic.
    
    Parameters:
        0: OBJECT - Aircraft vehicle
    
    Returns:
        BOOL - true if aircraft has gun with ammo
*/

params ["_aircraft"];

if (isNull _aircraft) exitWith { false };

private _hasGun = false;
private _weapons = weapons _aircraft;

// Check weapon parents for gun types
{
    private _parents = [configFile >> "CfgWeapons" >> _x, true] call BIS_fnc_returnParents;
    if ("CannonCore" in _parents || "MGun" in _parents) exitWith {
        _hasGun = true;
    };
} forEach _weapons;

// If we found a gun, verify it has ammo
if (_hasGun) then {
    _hasGun = false;
    {
        private _ammo = getText (configFile >> "CfgMagazines" >> (_x select 0) >> "ammo");
        private _rounds = _x select 2;
        if (_rounds > 0 && {_ammo isKindOf "BulletCore" || _ammo isKindOf "CannonCore"}) exitWith {
            _hasGun = true;
        };
    } forEach (magazinesAmmo _aircraft);
};

_hasGun
