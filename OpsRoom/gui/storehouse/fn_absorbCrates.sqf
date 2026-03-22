/*
    Absorb Crates
    
    Scans for physical crates/containers within the storehouse radius.
    Reads their contents, adds to the storehouse virtual inventory,
    then deletes the physical crate.
    
    Maps ARMA classnames to equipment database IDs where possible.
    Items not in the database are stored by classname under MISCELLANEOUS.
    
    Usage:
        [] call OpsRoom_fnc_absorbCrates;
*/

private _storehouseId = uiNamespace getVariable ["OpsRoom_SelectedStorehouse", ""];
if (_storehouseId == "") exitWith { hint "No storehouse selected" };

private _storeData = OpsRoom_Storehouses get _storehouseId;
if (isNil "_storeData") exitWith { hint "Storehouse not found" };

private _pos = _storeData get "position";
private _radius = _storeData get "radius";
private _inv = _storeData get "inventory";
private _storeName = _storeData get "name";

// Build reverse lookup: className → itemId
private _classToId = createHashMap;
{
    private _itemId = _x;
    private _itemData = _y;
    private _className = _itemData get "className";
    if (!isNil "_className" && {_className != ""}) then {
        _classToId set [_className, _itemId];
    };
} forEach OpsRoom_EquipmentDB;

// Helper: resolve a classname to a storehouse key
// Returns equipment database ID if found, otherwise the raw classname
private _fnc_resolveKey = {
    params ["_className"];
    _classToId getOrDefault [_className, _className]
};

// Find crates/containers in radius
private _searchTypes = [
    "ReammoBox_F", "ThingX", "WeaponHolder",
    "WeaponHolderSimulated", "GroundWeaponHolder"
];
private _nearObjects = nearestObjects [_pos, _searchTypes, _radius];

// Filter out anything that isn't really a container
private _crates = [];
{
    private _obj = _x;
    if (!(_obj isKindOf "Man") && !(_obj isKindOf "Car") && !(_obj isKindOf "Tank") && !(_obj isKindOf "Air")) then {
        _crates pushBack _obj;
    };
} forEach _nearObjects;

if (count _crates == 0) exitWith {
    private _display = findDisplay 11007;
    if (!isNull _display) then {
        private _statusCtrl = _display displayCtrl 11740;
        _statusCtrl ctrlSetStructuredText parseText "<t color='#A09A8C'>No crates found within depot radius.</t>";
    };
    hint "No crates found to absorb.";
};

// Process each crate
private _totalAbsorbed = 0;
private _cratesProcessed = 0;
private _summary = "";

{
    private _crate = _x;
    private _crateType = typeOf _crate;
    private _crateName = getText (configFile >> "CfgVehicles" >> _crateType >> "displayName");
    if (_crateName == "") then { _crateName = _crateType };
    
    private _itemsFound = 0;
    
    // Extract weapons
    private _weapons = weaponsItemsCargo _crate;
    {
        private _wClass = _x select 0;
        if (_wClass != "") then {
            private _key = [_wClass] call _fnc_resolveKey;
            private _existing = _inv getOrDefault [_key, 0];
            _inv set [_key, _existing + 1];
            _itemsFound = _itemsFound + 1;
        };
    } forEach _weapons;
    
    // Extract magazines
    private _mags = magazinesAmmoCargo _crate;
    {
        private _mClass = _x select 0;
        if (_mClass != "") then {
            private _key = [_mClass] call _fnc_resolveKey;
            private _existing = _inv getOrDefault [_key, 0];
            _inv set [_key, _existing + 1];
            _itemsFound = _itemsFound + 1;
        };
    } forEach _mags;
    
    // Extract items
    private _items = itemCargo _crate;
    {
        if (_x != "") then {
            private _key = [_x] call _fnc_resolveKey;
            private _existing = _inv getOrDefault [_key, 0];
            _inv set [_key, _existing + 1];
            _itemsFound = _itemsFound + 1;
        };
    } forEach _items;
    
    // Extract backpacks
    private _bps = backpackCargo _crate;
    {
        if (_x != "") then {
            private _key = [_x] call _fnc_resolveKey;
            private _existing = _inv getOrDefault [_key, 0];
            _inv set [_key, _existing + 1];
            _itemsFound = _itemsFound + 1;
        };
    } forEach _bps;
    
    if (_itemsFound > 0) then {
        _summary = _summary + format ["\n  %1: %2 items", _crateName, _itemsFound];
        _totalAbsorbed = _totalAbsorbed + _itemsFound;
        _cratesProcessed = _cratesProcessed + 1;
        
        // Delete the physical crate
        deleteVehicle _crate;
    };
} forEach _crates;

// Save updated inventory back to storehouse
_storeData set ["inventory", _inv];
OpsRoom_Storehouses set [_storehouseId, _storeData];

// Refresh display
[] call OpsRoom_fnc_populateStorehouseInventory;
[] call OpsRoom_fnc_scanStorehouseCrates;

// Update status
private _display = findDisplay 11007;
if (!isNull _display) then {
    private _statusCtrl = _display displayCtrl 11740;
    if (_cratesProcessed > 0) then {
        _statusCtrl ctrlSetStructuredText parseText format [
            "<t color='#8BC34A'>Absorbed %1 crates — %2 items stored.%3</t>",
            _cratesProcessed, _totalAbsorbed, _summary
        ];
    } else {
        _statusCtrl ctrlSetStructuredText parseText "<t color='#A09A8C'>Crates found but contained no items.</t>";
    };
};

// Dispatch notification
if (_cratesProcessed > 0) then {
    [
        "ROUTINE",
        "STORES — INTAKE",
        format ["%1: %2 crates absorbed, %3 items catalogued.%4", _storeName, _cratesProcessed, _totalAbsorbed, _summary],
        _pos
    ] call OpsRoom_fnc_dispatch;
};

diag_log format ["[OpsRoom] Crates absorbed: %1 crates, %2 items into %3", _cratesProcessed, _totalAbsorbed, _storehouseId];
