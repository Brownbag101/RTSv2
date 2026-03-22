/*
    Populate Storehouse Inventory
    
    Fills the storehouse inventory listbox with virtual contents, grouped by category.
    
    Items stored by equipment database key → uses database category.
    Items stored by raw classname → categorised by ARMA config type.
    
    Usage:
        [] call OpsRoom_fnc_populateStorehouseInventory;
*/

private _display = findDisplay 11007;
if (isNull _display) exitWith {};

private _storehouseId = uiNamespace getVariable ["OpsRoom_SelectedStorehouse", ""];
if (_storehouseId == "") exitWith {};

private _storeData = OpsRoom_Storehouses get _storehouseId;
if (isNil "_storeData") exitWith {};

private _inv = _storeData get "inventory";

private _listbox = _display displayCtrl 11730;
lbClear _listbox;

private _itemIds = [];

// Count total
private _totalItems = 0;
{ _totalItems = _totalItems + _y } forEach _inv;

if (_totalItems == 0) exitWith {
    private _idx = _listbox lbAdd "Storehouse empty";
    _listbox lbSetColor [_idx, [0.5, 0.5, 0.5, 0.7]];
    _idx = _listbox lbAdd "Absorb crates or transfer";
    _listbox lbSetColor [_idx, [0.5, 0.5, 0.5, 0.5]];
    _idx = _listbox lbAdd "items from units.";
    _listbox lbSetColor [_idx, [0.5, 0.5, 0.5, 0.5]];
    uiNamespace setVariable ["OpsRoom_StorehouseInvItems", []];
};

// Separate items into "known" (in equipment DB) and "raw" (classnames)
private _knownItems = createHashMap;  // category → [[itemId, stock, itemData], ...]
private _rawWeapons = [];   // [[classname, stock, displayName], ...]
private _rawMags = [];
private _rawItems = [];

{
    private _key = _x;
    private _stock = _y;
    if (_stock <= 0) then { continue };
    
    // Check if this is an equipment database key
    private _dbEntry = OpsRoom_EquipmentDB get _key;
    
    if (!isNil "_dbEntry") then {
        // Known item — group by database category
        private _cat = _dbEntry get "category";
        private _catItems = _knownItems getOrDefault [_cat, []];
        _catItems pushBack [_key, _stock, _dbEntry];
        _knownItems set [_cat, _catItems];
    } else {
        // Raw classname — categorise by ARMA config
        private _displayName = "";
        private _placed = false;
        
        // Check CfgWeapons
        if (isClass (configFile >> "CfgWeapons" >> _key)) then {
            _displayName = getText (configFile >> "CfgWeapons" >> _key >> "displayName");
            if (_displayName == "") then { _displayName = _key };
            _rawWeapons pushBack [_key, _stock, _displayName];
            _placed = true;
        };
        
        // Check CfgMagazines
        if (!_placed && {isClass (configFile >> "CfgMagazines" >> _key)}) then {
            _displayName = getText (configFile >> "CfgMagazines" >> _key >> "displayName");
            if (_displayName == "") then { _displayName = _key };
            _rawMags pushBack [_key, _stock, _displayName];
            _placed = true;
        };
        
        // Check CfgVehicles (backpacks, etc.)
        if (!_placed && {isClass (configFile >> "CfgVehicles" >> _key)}) then {
            _displayName = getText (configFile >> "CfgVehicles" >> _key >> "displayName");
            if (_displayName == "") then { _displayName = _key };
            _rawItems pushBack [_key, _stock, _displayName];
            _placed = true;
        };
        
        // Check CfgGlasses
        if (!_placed && {isClass (configFile >> "CfgGlasses" >> _key)}) then {
            _displayName = getText (configFile >> "CfgGlasses" >> _key >> "displayName");
            if (_displayName == "") then { _displayName = _key };
            _rawItems pushBack [_key, _stock, _displayName];
            _placed = true;
        };
        
        // Total fallback
        if (!_placed) then {
            _rawItems pushBack [_key, _stock, _key];
        };
    };
} forEach _inv;

// Sort known categories
private _sortedCats = keys _knownItems;
_sortedCats sort true;

// Render known items (from equipment database)
{
    private _category = _x;
    private _catItems = _knownItems get _category;
    
    // Category header
    private _idx = _listbox lbAdd format ["── %1 ──", toUpper _category];
    _listbox lbSetColor [_idx, [0.95, 0.85, 0.40, 1.0]];
    _itemIds pushBack "";
    
    // Sort by display name
    _catItems = [_catItems, [], { (_x select 2) get "displayName" }] call BIS_fnc_sortBy;
    
    {
        _x params ["_itemId", "_stock", "_itemData"];
        private _name = _itemData get "displayName";
        
        private _idx = _listbox lbAdd format ["  %1 (x%2)", _name, _stock];
        _listbox lbSetColor [_idx, [0.85, 0.82, 0.74, 1.0]];
        _itemIds pushBack _itemId;
    } forEach _catItems;
} forEach _sortedCats;

// Render raw weapons
if (count _rawWeapons > 0) then {
    private _idx = _listbox lbAdd "── WEAPONS (FIELD) ──";
    _listbox lbSetColor [_idx, [0.85, 0.75, 0.35, 1.0]];
    _itemIds pushBack "";
    
    _rawWeapons sort true;
    {
        _x params ["_key", "_stock", "_displayName"];
        private _idx = _listbox lbAdd format ["  %1 (x%2)", _displayName, _stock];
        _listbox lbSetColor [_idx, [0.75, 0.72, 0.64, 1.0]];
        _itemIds pushBack _key;
    } forEach _rawWeapons;
};

// Render raw magazines
if (count _rawMags > 0) then {
    private _idx = _listbox lbAdd "── AMMUNITION (FIELD) ──";
    _listbox lbSetColor [_idx, [0.85, 0.75, 0.35, 1.0]];
    _itemIds pushBack "";
    
    _rawMags sort true;
    {
        _x params ["_key", "_stock", "_displayName"];
        private _idx = _listbox lbAdd format ["  %1 (x%2)", _displayName, _stock];
        _listbox lbSetColor [_idx, [0.75, 0.72, 0.64, 1.0]];
        _itemIds pushBack _key;
    } forEach _rawMags;
};

// Render raw items (equipment, backpacks, glasses, unknown)
if (count _rawItems > 0) then {
    private _idx = _listbox lbAdd "── EQUIPMENT (FIELD) ──";
    _listbox lbSetColor [_idx, [0.85, 0.75, 0.35, 1.0]];
    _itemIds pushBack "";
    
    _rawItems sort true;
    {
        _x params ["_key", "_stock", "_displayName"];
        private _idx = _listbox lbAdd format ["  %1 (x%2)", _displayName, _stock];
        _listbox lbSetColor [_idx, [0.75, 0.72, 0.64, 1.0]];
        _itemIds pushBack _key;
    } forEach _rawItems;
};

uiNamespace setVariable ["OpsRoom_StorehouseInvItems", _itemIds];

diag_log format ["[OpsRoom] Storehouse inventory: %1 total items, %2 known categories, %3 raw weapons, %4 raw mags, %5 raw items",
    _totalItems, count _sortedCats, count _rawWeapons, count _rawMags, count _rawItems];
