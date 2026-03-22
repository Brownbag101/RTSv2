/*
    OpsRoom_fnc_getContainerItems
    
    Gets items from a unit or container in a standardized format.
    
    Parameters:
        _target - Unit or container object
    
    Returns: Array of sections, each: [sectionName, [[displayName, className, qty, itemType]]]
    itemType: "weapon", "magazine", "item", "container_item", "attachment", "loaded_mag",
              "uniform", "vest", "backpack", "headgear", "facewear"
*/

params ["_target"];

// --- Helper: Get display name from config ---
private _fnc_displayName = {
    params ["_className"];
    if (_className == "" || {isNil "_className"}) exitWith {"?"};
    private _cfg = configFile >> "CfgWeapons" >> _className;
    if (!isClass _cfg) then { _cfg = configFile >> "CfgMagazines" >> _className };
    if (!isClass _cfg) then { _cfg = configFile >> "CfgVehicles" >> _className };
    if (!isClass _cfg) then { _cfg = configFile >> "CfgGlasses" >> _className };
    if (isClass _cfg) then { getText (_cfg >> "displayName") } else { _className };
};

private _sections = [];

// ========================================
// UNIT INVENTORY (via getUnitLoadout)
// ========================================
if (_target isKindOf "Man") then {
    private _loadout = getUnitLoadout _target;
    
    // --- WEAPONS ---
    private _weapItems = [];
    {
        private _wArr = _loadout select _x;
        if (count _wArr > 0) then {
            private _wClass = _wArr select 0;
            if (_wClass != "") then {
                _weapItems pushBack [_wClass call _fnc_displayName, _wClass, 1, "weapon"];
                { if (_x != "") then {
                    _weapItems pushBack [format ["  %1", _x call _fnc_displayName], _x, 1, "attachment"];
                }} forEach [_wArr select 1, _wArr select 2, _wArr select 3];
                private _mag = _wArr select 4;
                if (count _mag > 0 && {(_mag select 0) != ""}) then {
                    _weapItems pushBack [format ["  %1 [%2]", (_mag select 0) call _fnc_displayName, _mag select 1], _mag select 0, 1, "loaded_mag"];
                };
            };
        };
    } forEach [0, 1, 2];
    if (count _weapItems > 0) then { _sections pushBack ["WEAPONS", _weapItems] };
    
    // --- Helper: Parse container contents ---
    private _fnc_parseContainer = {
        params ["_arr", "_sectionName", "_containerType"];
        if (count _arr == 0) exitWith {};
        private _cClass = _arr select 0;
        if (_cClass == "") exitWith {};
        private _items = [];
        _items pushBack [_cClass call _fnc_displayName, _cClass, 1, _containerType];
        if (count _arr > 1) then {
            private _contents = _arr select 1;
            private _counts = createHashMap;
            { 
                private _cls = _x select 0;
                private _qty = _x select 1;
                if (_qty isEqualType true) then { _qty = 1 };
                if (_qty isEqualType 0) then { _qty = _qty max 1 };
                private _existing = _counts getOrDefault [_cls, 0];
                _counts set [_cls, _existing + _qty];
            } forEach _contents;
            {
                private _dName = _x call _fnc_displayName;
                private _label = if (_y > 1) then { format ["  %1  x%2", _dName, _y] } else { format ["  %1", _dName] };
                _items pushBack [_label, _x, _y, "item"];
            } forEach _counts;
        };
        if (count _items > 0) then { _sections pushBack [_sectionName, _items] };
    };
    
    [_loadout select 3, "UNIFORM", "uniform"] call _fnc_parseContainer;
    [_loadout select 4, "VEST", "vest"] call _fnc_parseContainer;
    [_loadout select 5, "BACKPACK", "backpack"] call _fnc_parseContainer;
    
    // --- EQUIPMENT ---
    private _equipItems = [];
    private _hg = _loadout select 6;
    if (_hg != "") then { _equipItems pushBack [_hg call _fnc_displayName, _hg, 1, "headgear"] };
    private _gg = _loadout select 7;
    if (_gg != "") then { _equipItems pushBack [_gg call _fnc_displayName, _gg, 1, "facewear"] };
    private _bn = _loadout select 8;
    if (count _bn > 0 && {(_bn select 0) != ""}) then {
        _equipItems pushBack [(_bn select 0) call _fnc_displayName, _bn select 0, 1, "weapon"];
    };
    private _linked = _loadout select 9;
    if (count _linked > 0) then {
        { if (_x != "") then {
            _equipItems pushBack [_x call _fnc_displayName, _x, 1, "item"];
        }} forEach _linked;
    };
    if (count _equipItems > 0) then { _sections pushBack ["EQUIPMENT", _equipItems] };

} else {
    // ========================================
    // CONTAINER / VEHICLE / GROUND ITEM
    // Use the type override map to remember equipment types
    // ========================================
    private _typeOverrides = missionNamespace getVariable ["OpsRoom_InventoryTypeOverrides", createHashMap];
    
    private _weapItems = [];
    private _weapCounts = createHashMap;
    private _weaponsData = weaponsItemsCargo _target;
    {
        private _wClass = _x select 0;
        if (_wClass != "") then {
            private _existing = _weapCounts getOrDefault [_wClass, 0];
            _weapCounts set [_wClass, _existing + 1];
        };
    } forEach _weaponsData;
    {
        private _dName = _x call _fnc_displayName;
        private _label = if (_y > 1) then { format ["%1  x%2", _dName, _y] } else { _dName };
        _weapItems pushBack [_label, _x, _y, "weapon"];
    } forEach _weapCounts;
    if (count _weapItems > 0) then { _sections pushBack ["WEAPONS", _weapItems] };
    
    private _magItems = [];
    private _magCounts = createHashMap;
    private _magsData = magazinesAmmoCargo _target;
    {
        private _cls = _x select 0;
        private _existing = _magCounts getOrDefault [_cls, 0];
        _magCounts set [_cls, _existing + 1];
    } forEach _magsData;
    {
        private _dName = _x call _fnc_displayName;
        private _label = if (_y > 1) then { format ["%1  x%2", _dName, _y] } else { _dName };
        _magItems pushBack [_label, _x, _y, "magazine"];
    } forEach _magCounts;
    if (count _magItems > 0) then { _sections pushBack ["MAGAZINES", _magItems] };
    
    // --- Helper: Detect equipment type from config ---
    private _fnc_detectType = {
        params ["_cls"];
        // Check cache first
        private _cached = _typeOverrides getOrDefault [_cls, ""];
        if (_cached != "") exitWith { _cached };
        // Backpack
        if (getNumber (configFile >> "CfgVehicles" >> _cls >> "isBackpack") == 1) exitWith { "backpack" };
        // Facewear
        if (isClass (configFile >> "CfgGlasses" >> _cls)) exitWith { "facewear" };
        // Check CfgWeapons ItemInfo.type
        private _cfgW = configFile >> "CfgWeapons" >> _cls;
        if (isClass _cfgW) then {
            private _iType = getNumber (_cfgW >> "ItemInfo" >> "type");
            switch (_iType) do {
                case 801: { "uniform" };
                case 701: { "vest" };
                case 605: { "headgear" };
                default { "item" };
            };
        } else {
            "item"
        };
    };
    
    private _itemCounts = createHashMap;
    
    private _itemsData = itemCargo _target;
    {
        private _existing = _itemCounts getOrDefault [_x, 0];
        _itemCounts set [_x, _existing + 1];
    } forEach _itemsData;
    
    private _bpData = backpackCargo _target;
    {
        private _existing = _itemCounts getOrDefault [_x, 0];
        _itemCounts set [_x, _existing + 1];
    } forEach _bpData;
    
    // Sort into typed groups
    private _uniformItems = [];
    private _vestItems = [];
    private _headgearItems = [];
    private _facewearItems = [];
    private _backpackItems = [];
    private _otherItems = [];
    
    {
        private _cls = _x;
        private _qty = _y;
        private _dName = _cls call _fnc_displayName;
        private _detectedType = [_cls] call _fnc_detectType;
        // Backpacks from backpackCargo override
        if (_cls in _bpData) then { _detectedType = "backpack" };
        private _label = if (_qty > 1) then { format ["%1  x%2", _dName, _qty] } else { _dName };
        private _entry = [_label, _cls, _qty, _detectedType];
        
        switch (_detectedType) do {
            case "uniform": { _uniformItems pushBack _entry };
            case "vest": { _vestItems pushBack _entry };
            case "headgear": { _headgearItems pushBack _entry };
            case "facewear": { _facewearItems pushBack _entry };
            case "backpack": { _backpackItems pushBack _entry };
            default { _otherItems pushBack _entry };
        };
    } forEach _itemCounts;
    
    if (count _uniformItems > 0) then { _sections pushBack ["UNIFORMS", _uniformItems] };
    if (count _vestItems > 0) then { _sections pushBack ["VESTS", _vestItems] };
    if (count _headgearItems > 0) then { _sections pushBack ["HEADGEAR", _headgearItems] };
    if (count _facewearItems > 0) then { _sections pushBack ["FACEWEAR", _facewearItems] };
    if (count _backpackItems > 0) then { _sections pushBack ["BACKPACKS", _backpackItems] };
    if (count _otherItems > 0) then { _sections pushBack ["ITEMS", _otherItems] };
};

_sections
