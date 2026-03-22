/*
    Storehouse Transfer
    
    Transfers items between a unit and the storehouse virtual inventory.
    
    "toUnit":  Takes selected item from storehouse listbox, gives to unit.
    "toStore": Takes selected item from unit inventory listbox, adds to storehouse.
               Handles items inside containers (vest, uniform, backpack).
    
    Parameters:
        0: STRING - Direction: "toUnit" or "toStore"
    
    Usage:
        ["toUnit"] call OpsRoom_fnc_storehouseTransfer;
        ["toStore"] call OpsRoom_fnc_storehouseTransfer;
*/

params [["_direction", "toUnit", [""]]];

private _display = findDisplay 11007;
if (isNull _display) exitWith {};

private _storehouseId = uiNamespace getVariable ["OpsRoom_SelectedStorehouse", ""];
if (_storehouseId == "") exitWith { hint "No storehouse selected" };

private _storeData = OpsRoom_Storehouses get _storehouseId;
if (isNil "_storeData") exitWith {};

private _inv = _storeData get "inventory";
private _unit = uiNamespace getVariable ["OpsRoom_StorehouseSelectedUnit", objNull];

if (isNull _unit) exitWith { hint "Select a unit first" };
if (!alive _unit) exitWith { hint "Unit is dead" };

// Build reverse lookup: className → equipment database itemId
private _classToId = createHashMap;
{
    private _itemId = _x;
    private _itemData = _y;
    private _className = _itemData get "className";
    if (!isNil "_className" && {_className != ""}) then {
        _classToId set [_className, _itemId];
    };
} forEach OpsRoom_EquipmentDB;

// Helper: get display name for any classname
private _fnc_getDisplayName = {
    params ["_cls"];
    private _n = getText (configFile >> "CfgWeapons" >> _cls >> "displayName");
    if (_n == "") then { _n = getText (configFile >> "CfgMagazines" >> _cls >> "displayName") };
    if (_n == "") then { _n = getText (configFile >> "CfgVehicles" >> _cls >> "displayName") };
    if (_n == "") then { _n = getText (configFile >> "CfgGlasses" >> _cls >> "displayName") };
    if (_n == "") then { _n = _cls };
    _n
};

switch (_direction) do {
    case "toUnit": {
        // Get selected item from storehouse listbox
        private _storeList = _display displayCtrl 11730;
        private _selIdx = lbCurSel _storeList;
        if (_selIdx < 0) exitWith { hint "Select an item from the storehouse" };
        
        private _itemIds = uiNamespace getVariable ["OpsRoom_StorehouseInvItems", []];
        if (_selIdx >= count _itemIds) exitWith {};
        
        private _itemId = _itemIds select _selIdx;
        if (_itemId == "") exitWith { hint "Select an item, not a category header" };
        
        private _stock = _inv getOrDefault [_itemId, 0];
        if (_stock <= 0) exitWith { hint "No stock remaining" };
        
        // Determine the ARMA classname
        private _className = _itemId;
        private _displayName = "";
        private _dbEntry = OpsRoom_EquipmentDB get _itemId;
        if (!isNil "_dbEntry") then {
            _className = _dbEntry get "className";
            _displayName = _dbEntry get "displayName";
        } else {
            _displayName = [_itemId] call _fnc_getDisplayName;
        };
        
        // Detect equipment type using config
        private _equipType = "item";
        
        // Backpack check
        if (getNumber (configFile >> "CfgVehicles" >> _className >> "isBackpack") == 1) then {
            _equipType = "backpack";
        } else {
            // Facewear check
            if (isClass (configFile >> "CfgGlasses" >> _className)) then {
                _equipType = "facewear";
            } else {
                // CfgWeapons — check ItemInfo.type for uniform/vest/headgear
                private _cfgW = configFile >> "CfgWeapons" >> _className;
                if (isClass _cfgW) then {
                    private _iType = getNumber (_cfgW >> "ItemInfo" >> "type");
                    switch (_iType) do {
                        case 801: { _equipType = "uniform" };
                        case 701: { _equipType = "vest" };
                        case 605: { _equipType = "headgear" };
                        default {
                            // Check if it's actually a weapon (has a type value > 0 in CfgWeapons root)
                            if (getNumber (_cfgW >> "type") in [1, 2, 4]) then {
                                _equipType = "weapon";
                            };
                        };
                    };
                } else {
                    // CfgMagazines
                    if (isClass (configFile >> "CfgMagazines" >> _className)) then {
                        _equipType = "magazine";
                    };
                };
            };
        };
        
        // Add to unit based on detected type
        private _added = false;
        
        switch (_equipType) do {
            case "weapon": {
                if (_unit canAdd _className) then {
                    _unit addWeapon _className;
                    _added = true;
                } else {
                    hint "Unit cannot carry this weapon";
                };
            };
            case "magazine": {
                if (_unit canAdd _className) then {
                    _unit addMagazine _className;
                    _added = true;
                } else {
                    hint "Unit cannot carry this magazine";
                };
            };
            case "uniform": {
                if (uniform _unit != "") then {
                    hint "Unit already has a uniform";
                } else {
                    _unit forceAddUniform _className;
                    _added = true;
                };
            };
            case "vest": {
                if (vest _unit != "") then {
                    hint "Unit already has a vest";
                } else {
                    _unit addVest _className;
                    _added = true;
                };
            };
            case "headgear": {
                if (headgear _unit != "") then {
                    hint "Unit already has headgear";
                } else {
                    _unit addHeadgear _className;
                    _added = true;
                };
            };
            case "facewear": {
                if (goggles _unit != "") then {
                    hint "Unit already has facewear";
                } else {
                    _unit addGoggles _className;
                    _added = true;
                };
            };
            case "backpack": {
                if (backpack _unit != "") then {
                    hint "Unit already has a backpack";
                } else {
                    _unit addBackpack _className;
                    _added = true;
                };
            };
            default {
                if (_unit canAdd _className) then {
                    _unit addItem _className;
                    _added = true;
                } else {
                    hint "Unit cannot carry this item";
                };
            };
        };
        
        if (_added) then {
            _inv set [_itemId, (_stock - 1)];
            if ((_stock - 1) <= 0) then { _inv deleteAt _itemId };
            _storeData set ["inventory", _inv];
            OpsRoom_Storehouses set [_storehouseId, _storeData];
            
            [] call OpsRoom_fnc_populateStorehouseInventory;
            [] call OpsRoom_fnc_populateStorehouseUnitInv;
            
            systemChat format ["Issued %1 to %2", _displayName, name _unit];
        };
    };
    
    case "toStore": {
        // Get selected item from unit inventory listbox (dynamic IDC 11722)
        private _unitList = _display displayCtrl 11722;
        if (isNull _unitList) exitWith { hint "Select a unit first" };
        
        private _selIdx = lbCurSel _unitList;
        if (_selIdx < 0) exitWith { hint "Select an item from the unit's inventory" };
        
        private _listMap = uiNamespace getVariable ["OpsRoom_StorehouseUnitListMap", []];
        if (_selIdx >= count _listMap) exitWith {};
        
        private _itemData = _listMap select _selIdx;
        if (count _itemData == 0) exitWith { hint "Select a transferable item" };
        
        _itemData params ["_className", "_qty", "_itemType", "_parentContainer"];
        
        private _displayName = [_className] call _fnc_getDisplayName;
        
        // Remove from unit based on item type and location
        private _removed = false;
        
        if (_parentContainer != "") then {
            // Item is inside a container (uniform, vest, backpack)
            // Use removeItem which searches all containers on the unit
            _unit removeItem _className;
            _removed = true;
        } else {
            // Item is directly on the unit (equipped slot)
            switch (_itemType) do {
                case "weapon": {
                    _unit removeWeapon _className;
                    _removed = true;
                };
                case "magazine": {
                    _unit removeMagazine _className;
                    _removed = true;
                };
                case "uniform": {
                    removeUniform _unit;
                    _removed = true;
                };
                case "vest": {
                    removeVest _unit;
                    _removed = true;
                };
                case "backpack": {
                    removeBackpack _unit;
                    _removed = true;
                };
                case "headgear": {
                    removeHeadgear _unit;
                    _removed = true;
                };
                case "facewear": {
                    removeGoggles _unit;
                    _removed = true;
                };
                default {
                    _unit removeItem _className;
                    _removed = true;
                };
            };
        };
        
        if (_removed) then {
            // Resolve to equipment database key if possible
            private _storeKey = _classToId getOrDefault [_className, _className];
            
            private _existing = _inv getOrDefault [_storeKey, 0];
            _inv set [_storeKey, _existing + 1];
            _storeData set ["inventory", _inv];
            OpsRoom_Storehouses set [_storehouseId, _storeData];
            
            [] call OpsRoom_fnc_populateStorehouseInventory;
            [] call OpsRoom_fnc_populateStorehouseUnitInv;
            
            systemChat format ["Deposited %1 from %2", _displayName, name _unit];
        };
    };
};
