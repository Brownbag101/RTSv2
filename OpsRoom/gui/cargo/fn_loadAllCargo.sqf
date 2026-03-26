/*
    Cargo System - Load All Cargo
    
    Loads all nearby loadable items onto the vehicle sequentially.
    Items are loaded one at a time in order of proximity.
    Stops when vehicle is full or no more items nearby.
    
    Parameters:
        0: OBJECT - Vehicle to load into
    
    Usage:
        [_vehicle] call OpsRoom_fnc_loadAllCargo;
*/

params [["_vehicle", objNull]];

if (isNull _vehicle) exitWith {};

private _cap = [_vehicle] call OpsRoom_fnc_getCargoCapacity;
_cap params ["_usedSlots", "_maxSlots", "_isCarrier"];

if (!_isCarrier) exitWith { hint "Vehicle cannot carry cargo" };
if (_usedSlots >= _maxSlots) exitWith { hint "Vehicle is full!" };

private _radius = missionNamespace getVariable ["OpsRoom_Settings_CargoScanRadius", 25];

// Build list of all loadable items (same scan as openCargoMenu)
private _loadableItems = [];

// Objects (crates, barrels etc)
private _nearObjects = nearestObjects [_vehicle, OpsRoom_CargoLoadableTypes, _radius];
{
    if (isNull (_x getVariable ["OpsRoom_LoadedIn", objNull]) && alive _x && _x != _vehicle) then {
        private _cn = typeOf _x;
        private _dn = getText (configFile >> "CfgVehicles" >> _cn >> "displayName");
        if (_dn == "") then { _dn = _cn };
        private _w = OpsRoom_CargoWeights getOrDefault [_cn, missionNamespace getVariable ["OpsRoom_Settings_CargoDefaultWeight", 1]];
        _loadableItems pushBack [_x, _cn, _dn, _w, false];
    };
} forEach _nearObjects;

// Friendly men
private _nearMen = nearestObjects [_vehicle, ["Man"], _radius];
{
    if (isNull (_x getVariable ["OpsRoom_LoadedIn", objNull]) && alive _x && side _x == side player && vehicle _x == _x) then {
        private _rankText = switch (rank _x) do {
            case "PRIVATE": {"Pte."}; case "CORPORAL": {"Cpl."}; case "SERGEANT": {"Sgt."};
            case "LIEUTENANT": {"Lt."}; case "CAPTAIN": {"Capt."}; case "MAJOR": {"Maj."};
            default {rank _x};
        };
        _loadableItems pushBack [_x, typeOf _x, format ["%1 %2", _rankText, name _x], 1, true];
    };
} forEach _nearMen;

if (count _loadableItems == 0) exitWith { hint "No items nearby to load" };

// Close the menu
[] call OpsRoom_fnc_closeButtonMenu;

// Spawn sequential loading
[_vehicle, _loadableItems] spawn {
    params ["_vehicle", "_items"];
    
    private _loadTime = missionNamespace getVariable ["OpsRoom_Settings_CargoLoadTime", 4];
    private _loaded = 0;
    
    {
        _x params ["_obj", "_cn", "_dn", "_w", "_isUnit"];
        
        // Check capacity before each load
        private _cap = [_vehicle] call OpsRoom_fnc_getCargoCapacity;
        _cap params ["_used", "_max"];
        if ((_used + _w) > _max) exitWith {
            hint format ["Vehicle full after loading %1 items", _loaded];
        };
        
        // Skip if item was loaded/moved/destroyed in the meantime
        if (isNull _obj || !alive _obj) then { continue };
        if (!isNull (_obj getVariable ["OpsRoom_LoadedIn", objNull])) then { continue };
        
        // Load this item (calls the existing load function which has progress bar)
        [_vehicle, [_obj, _cn, _dn, _w, _isUnit]] call OpsRoom_fnc_loadCargo;
        
        // Wait for load to complete (loadTime + small buffer)
        sleep (_loadTime + 0.5);
        
        _loaded = _loaded + 1;
        
    } forEach _items;
    
    if (_loaded > 0) then {
        private _cap = [_vehicle] call OpsRoom_fnc_getCargoCapacity;
        _cap params ["_used", "_max"];
        private _vehName = getText (configFile >> "CfgVehicles" >> typeOf _vehicle >> "displayName");
        hint format ["Load All complete: %1 items loaded\n%2 cargo: %3/%4", _loaded, _vehName, _used, _max];
    };
};
