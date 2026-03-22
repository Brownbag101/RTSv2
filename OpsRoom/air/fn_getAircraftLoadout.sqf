/*
    OpsRoom_fnc_getAircraftLoadout
    
    Returns a formatted string describing the weapon loadout
    of an aircraft from its CfgVehicles config (for hangared display)
    or from live vehicle data (for airborne display).
    
    Parameters:
        _className - Vehicle classname (string)
    
    Returns:
        String - Formatted weapon text like "8x 1000lb Bomb, 2x .303 MG"
*/
params ["_className"];

private _allMags = [];

// Recursive function to gather magazines from all turret levels
private _fnc_scanTurrets = {
    params ["_cfgPath"];
    private _turretClasses = configProperties [_cfgPath, "isClass _x", true];
    {
        private _tMags = getArray (_x >> "magazines");
        _allMags append _tMags;
        // Recurse into sub-turrets
        if (isClass (_x >> "Turrets")) then {
            [_x >> "Turrets"] call _fnc_scanTurrets;
        };
    } forEach _turretClasses;
};

// Get top-level vehicle magazines
private _vehicleCfg = configFile >> "CfgVehicles" >> _className;
private _topMags = getArray (_vehicleCfg >> "magazines");
_allMags append _topMags;

// Scan all turret levels
if (isClass (_vehicleCfg >> "Turrets")) then {
    [_vehicleCfg >> "Turrets"] call _fnc_scanTurrets;
};

if (count _allMags == 0) exitWith { "" };

// Count unique magazine display names
private _magCounts = createHashMap;
{
    private _magName = getText (configFile >> "CfgMagazines" >> _x >> "displayName");
    if (_magName == "") then { _magName = _x };
    private _cur = _magCounts getOrDefault [_magName, 0];
    _magCounts set [_magName, _cur + 1];
} forEach _allMags;

private _parts = [];
{ _parts pushBack format ["%1x %2", _y, _x] } forEach _magCounts;

_parts joinString ", "
