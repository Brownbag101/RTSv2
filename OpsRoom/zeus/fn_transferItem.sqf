/*
    OpsRoom_fnc_transferItem
    
    Transfers an item between a unit and a container (or vice versa).
    
    Parameters:
        _className  - Class name of item to transfer
        _qty        - Quantity to transfer (default 1)
        _itemType   - "weapon", "magazine", "item", "attachment", "loaded_mag", 
                      "container_item", "uniform", "vest", "backpack", "headgear", "facewear"
        _from       - Source object (unit or container)
        _to         - Destination object (unit or container)
    
    Returns: Boolean - true if transfer succeeded
*/

params ["_className", ["_qty", 1], ["_itemType", "item"], "_from", "_to"];

if (isNull _from || {isNull _to}) exitWith { false };

private _success = false;

// ========================================
// HELPER: Detect actual equipment type by testing on a temp unit
// This is the nuclear option — spawn a temp unit, try equipping, see what sticks
// Works with ANY mod regardless of config structure
// ========================================
private _fnc_detectEquipType = {
    params ["_cls"];
    
    // Quick checks first (cheap)
    if (getNumber (configFile >> "CfgVehicles" >> _cls >> "isBackpack") == 1) exitWith { "backpack" };
    if (isClass (configFile >> "CfgGlasses" >> _cls)) exitWith { "facewear" };
    
    // Check type override map (remembers from same session)
    private _overrides = missionNamespace getVariable ["OpsRoom_InventoryTypeOverrides", createHashMap];
    private _override = _overrides getOrDefault [_cls, ""];
    if (_override != "") exitWith { _override };
    
    // Check ARMA config ItemInfo.type values
    // This avoids the brute-force equip approach that throws errors
    private _result = "item";
    
    // Check CfgWeapons ItemInfo for type
    private _cfgPath = configFile >> "CfgWeapons" >> _cls;
    if (isClass _cfgPath) then {
        private _itemType = getNumber (_cfgPath >> "ItemInfo" >> "type");
        // Type values: 0=generic, 605=headgear, 701=vest, 801=uniform
        switch (_itemType) do {
            case 801: { _result = "uniform" };
            case 701: { _result = "vest" };
            case 605: { _result = "headgear" };
        };
    };
    
    // If still "item", try headgear class check (some mods use CfgVehicles for headgear)
    if (_result == "item") then {
        private _cfgVeh = configFile >> "CfgVehicles" >> _cls;
        if (isClass _cfgVeh) then {
            // Backpack already checked above
            // Some mods put headgear in CfgVehicles
            private _simulation = getText (_cfgVeh >> "simulation");
            if (_simulation == "" || _simulation == "thing") then {
                // Last resort: test equip on temp unit but check headgear first (least destructive)
                private _testUnit = createAgent ["B_Soldier_F", [0,0,0], [], 0, "NONE"];
                removeHeadgear _testUnit;
                removeUniform _testUnit;
                removeVest _testUnit;
                
                _testUnit addHeadgear _cls;
                if (headgear _testUnit == _cls) then {
                    _result = "headgear";
                } else {
                    _testUnit forceAddUniform _cls;
                    if (uniform _testUnit == _cls) then {
                        _result = "uniform";
                    } else {
                        _testUnit addVest _cls;
                        if (vest _testUnit == _cls) then {
                            _result = "vest";
                        };
                    };
                };
                
                deleteVehicle _testUnit;
            };
        };
    };
    
    // Cache the result
    _overrides set [_cls, _result];
    missionNamespace setVariable ["OpsRoom_InventoryTypeOverrides", _overrides];
    
    _result
};

// ========================================
// HELPER: Empty container contents into destination
// ========================================
private _fnc_emptyContainerContents = {
    params ["_unit", "_containerType", "_dest"];
    
    private _loadout = getUnitLoadout _unit;
    private _slotIndex = switch (_containerType) do {
        case "uniform": { 3 };
        case "vest": { 4 };
        case "backpack": { 5 };
        default { -1 };
    };
    
    if (_slotIndex < 0) exitWith {};
    
    private _arr = _loadout select _slotIndex;
    if (count _arr < 2) exitWith {};
    
    private _contents = _arr select 1;
    {
        private _cls = _x select 0;
        private _itemQty = _x select 1;
        if (_itemQty isEqualType true) then { _itemQty = 1 };
        if (_itemQty isEqualType 0) then { _itemQty = _itemQty max 1 };
        
        if (_dest isKindOf "Man") then {
            for "_i" from 1 to _itemQty do {
                if (_dest canAdd _cls) then {
                    _dest addItem _cls;
                } else {
                    systemChat format ["No space for %1", _cls];
                };
            };
        } else {
            private _isMag = isClass (configFile >> "CfgMagazines" >> _cls);
            if (_isMag) then {
                _dest addMagazineCargoGlobal [_cls, _itemQty];
            } else {
                if (getNumber (configFile >> "CfgVehicles" >> _cls >> "isBackpack") == 1) then {
                    _dest addBackpackCargoGlobal [_cls, _itemQty];
                } else {
                    _dest addItemCargoGlobal [_cls, _itemQty];
                };
            };
        };
    } forEach _contents;
};

// ========================================
// HELPER: Store type override for equipment in containers
// ========================================
private _fnc_storeTypeOverride = {
    params ["_cls", "_type"];
    if (_type in ["uniform", "vest", "backpack", "headgear", "facewear"]) then {
        private _overrides = missionNamespace getVariable ["OpsRoom_InventoryTypeOverrides", createHashMap];
        _overrides set [_cls, _type];
        missionNamespace setVariable ["OpsRoom_InventoryTypeOverrides", _overrides];
    };
};

// ========================================
// If item type is "item" and destination is a unit, detect actual type
// This handles items from containers/ground that lost their type tag
// ========================================
if (_itemType == "item" && {_to isKindOf "Man"}) then {
    private _detected = [_className] call _fnc_detectEquipType;
    if (_detected != "item") then {
        _itemType = _detected;
    };
};

// ========================================
// REMOVE FROM SOURCE
// ========================================
private _removed = false;

if (_from isKindOf "Man") then {
    switch (_itemType) do {
        case "weapon": {
            _from removeWeapon _className;
            _removed = true;
        };
        case "magazine": {
            for "_i" from 1 to _qty do {
                _from removeMagazine _className;
            };
            _removed = true;
        };
        case "item";
        case "container_item": {
            for "_i" from 1 to _qty do {
                _from removeItem _className;
            };
            _removed = true;
        };
        case "uniform": {
            [_from, "uniform", _to] call _fnc_emptyContainerContents;
            removeUniform _from;
            _removed = true;
        };
        case "vest": {
            [_from, "vest", _to] call _fnc_emptyContainerContents;
            removeVest _from;
            _removed = true;
        };
        case "backpack": {
            [_from, "backpack", _to] call _fnc_emptyContainerContents;
            removeBackpack _from;
            _removed = true;
        };
        case "headgear": {
            removeHeadgear _from;
            _removed = true;
        };
        case "facewear": {
            removeGoggles _from;
            _removed = true;
        };
        case "attachment": {
            systemChat "Cannot transfer weapon attachments individually";
            _removed = false;
        };
        case "loaded_mag": {
            systemChat "Cannot transfer loaded magazine separately";
            _removed = false;
        };
    };
} else {
    switch (_itemType) do {
        case "weapon": {
            private _allWeapons = weaponsItemsCargo _from;
            private _found = false;
            private _remaining = [];
            {
                if (!_found && {(_x select 0) == _className}) then {
                    _found = true;
                } else {
                    _remaining pushBack _x;
                };
            } forEach _allWeapons;
            
            if (_found) then {
                clearWeaponCargoGlobal _from;
                { _from addWeaponWithAttachmentsCargo [_x, 1] } forEach _remaining;
                _removed = true;
            };
        };
        case "magazine": {
            private _allMags = magazinesAmmoCargo _from;
            private _removeCount = _qty;
            private _remaining = [];
            {
                if (_removeCount > 0 && {(_x select 0) == _className}) then {
                    _removeCount = _removeCount - 1;
                } else {
                    _remaining pushBack _x;
                };
            } forEach _allMags;
            
            if (_removeCount < _qty) then {
                clearMagazineCargoGlobal _from;
                { _from addMagazineAmmoCargo [_x select 0, 1, _x select 1] } forEach _remaining;
                _removed = true;
            };
        };
        case "item";
        case "container_item";
        case "uniform";
        case "vest";
        case "backpack";
        case "headgear";
        case "facewear": {
            private _allItems = itemCargo _from;
            private _removeCount = _qty;
            private _remaining = [];
            {
                if (_removeCount > 0 && {_x == _className}) then {
                    _removeCount = _removeCount - 1;
                } else {
                    _remaining pushBack _x;
                };
            } forEach _allItems;
            
            private _allBP = backpackCargo _from;
            private _remainingBP = [];
            {
                if (_removeCount > 0 && {_x == _className}) then {
                    _removeCount = _removeCount - 1;
                } else {
                    _remainingBP pushBack _x;
                };
            } forEach _allBP;
            
            if (_removeCount < _qty) then {
                clearItemCargoGlobal _from;
                clearBackpackCargoGlobal _from;
                { _from addItemCargoGlobal [_x, 1] } forEach _remaining;
                { _from addBackpackCargoGlobal [_x, 1] } forEach _remainingBP;
                _removed = true;
            };
        };
    };
};

if (!_removed) exitWith { false };

// ========================================
// ADD TO DESTINATION
// ========================================
if (_to isKindOf "Man") then {
    switch (_itemType) do {
        case "weapon": {
            if (_to canAdd _className) then {
                _to addWeapon _className;
                _success = true;
            } else {
                systemChat "No space for weapon";
                if (_from isKindOf "Man") then { _from addWeapon _className } else { _from addWeaponCargoGlobal [_className, 1] };
            };
        };
        case "magazine": {
            private _added = 0;
            for "_i" from 1 to _qty do {
                if (_to canAdd _className) then {
                    _to addMagazine _className;
                    _added = _added + 1;
                };
            };
            if (_added > 0) then { _success = true };
            if (_added < _qty) then {
                private _returnQty = _qty - _added;
                if (_from isKindOf "Man") then {
                    for "_i" from 1 to _returnQty do { _from addMagazine _className };
                } else {
                    _from addMagazineCargoGlobal [_className, _returnQty];
                };
                if (_added == 0) then { systemChat "No space for magazines" };
            };
        };
        case "uniform": {
            if (uniform _to != "") then {
                systemChat "Unit already has a uniform equipped";
                if (_from isKindOf "Man") then { _from forceAddUniform _className } else { _from addItemCargoGlobal [_className, 1] };
            } else {
                _to forceAddUniform _className;
                _success = true;
            };
        };
        case "vest": {
            if (vest _to != "") then {
                systemChat "Unit already has a vest equipped";
                if (_from isKindOf "Man") then { _from addVest _className } else { _from addItemCargoGlobal [_className, 1] };
            } else {
                _to addVest _className;
                _success = true;
            };
        };
        case "backpack": {
            if (backpack _to != "") then {
                systemChat "Unit already has a backpack equipped";
                if (_from isKindOf "Man") then { _from addBackpack _className } else { _from addBackpackCargoGlobal [_className, 1] };
            } else {
                _to addBackpack _className;
                _success = true;
            };
        };
        case "headgear": {
            if (headgear _to != "") then {
                systemChat "Unit already has headgear equipped";
                if (_from isKindOf "Man") then { _from addHeadgear _className } else { _from addItemCargoGlobal [_className, 1] };
            } else {
                _to addHeadgear _className;
                _success = true;
            };
        };
        case "facewear": {
            if (goggles _to != "") then {
                systemChat "Unit already has facewear equipped";
                if (_from isKindOf "Man") then { _from addGoggles _className } else { _from addItemCargoGlobal [_className, 1] };
            } else {
                _to addGoggles _className;
                _success = true;
            };
        };
        case "item";
        case "container_item": {
            private _added = 0;
            for "_i" from 1 to _qty do {
                if (_to canAdd _className) then {
                    _to addItem _className;
                    _added = _added + 1;
                };
            };
            if (_added > 0) then { _success = true };
            if (_added < _qty) then {
                private _returnQty = _qty - _added;
                if (_from isKindOf "Man") then {
                    for "_i" from 1 to _returnQty do { _from addItem _className };
                } else {
                    _from addItemCargoGlobal [_className, _returnQty];
                };
                if (_added == 0) then { systemChat "No space" };
            };
        };
    };
} else {
    // Adding to container — store type override
    [_className, _itemType] call _fnc_storeTypeOverride;
    
    switch (_itemType) do {
        case "weapon": {
            _to addWeaponCargoGlobal [_className, 1];
            _success = true;
        };
        case "magazine": {
            _to addMagazineCargoGlobal [_className, _qty];
            _success = true;
        };
        case "uniform";
        case "vest";
        case "headgear";
        case "facewear";
        case "item";
        case "container_item": {
            _to addItemCargoGlobal [_className, _qty];
            _success = true;
        };
        case "backpack": {
            _to addBackpackCargoGlobal [_className, _qty];
            _success = true;
        };
    };
};

if (_success) then {
    [] call OpsRoom_fnc_refreshInventory;
};

_success
