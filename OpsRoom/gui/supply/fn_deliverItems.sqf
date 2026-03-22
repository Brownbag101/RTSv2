/*
    Deliver Items
    
    Spawns delivered items at the supply point marker.
    Called by the supply monitor when a shipment's delivery time expires.
    
    For "crate" type items: spawns an ammo crate and fills it.
    For "vehicle" type items: spawns the vehicle directly.
    
    Looks for editor-placed marker named "OpsRoom_SupplyPoint".
    Falls back to player position if marker not found.
    
    Parameters:
        0: ARRAY - Shipment items [[itemId, qty], [itemId, qty], ...]
    
    Usage:
        [_items] call OpsRoom_fnc_deliverItems;
*/

params [["_items", [], [[]]]];

if (count _items == 0) exitWith {};

// Find supply point
private _supplyPos = [0, 0, 0];
private _markerName = "OpsRoom_SupplyPoint";

if (getMarkerPos _markerName select 0 != 0 || getMarkerPos _markerName select 1 != 0) then {
    _supplyPos = getMarkerPos _markerName;
} else {
    // Fallback to player position
    _supplyPos = getPos player;
    systemChat "WARNING: No 'OpsRoom_SupplyPoint' marker found — delivering to player position";
};

private _spawnOffset = 0;

{
    _x params ["_itemId", "_qty"];
    
    private _itemData = OpsRoom_EquipmentDB get _itemId;
    if (isNil "_itemData") then { continue };
    
    // Aircraft go to the hangar, not the supply point
    if ((_itemData getOrDefault ["category", ""]) == "Aircraft") then {
        for "_i" from 1 to _qty do {
            [_itemId] call OpsRoom_fnc_addToHangar;
        };
        continue;
    };
    
    // Naval items (cargo ships) go to fleet pool
    if ((_itemData getOrDefault ["spawnType", ""]) == "naval") then {
        OpsRoom_CargoShips = (missionNamespace getVariable ["OpsRoom_CargoShips", 0]) + _qty;
        ["PRIORITY", "SHIP COMMISSIONED",
            format ["%1x %2 added to convoy fleet pool. Total ships: %3", _qty, _itemData get "displayName", OpsRoom_CargoShips]
        ] call OpsRoom_fnc_dispatch;
        diag_log format ["[OpsRoom] Naval: %1x %2 added to fleet pool (total: %3)", _qty, _itemId, OpsRoom_CargoShips];
        continue;
    };
    
    private _spawnType = _itemData get "spawnType";
    private _className = _itemData get "className";
    private _crateClass = _itemData get "crateClass";
    private _displayName = _itemData get "displayName";
    private _batchSize = _itemData get "batchSize";
    
    switch (_spawnType) do {
        case "crate": {
            // Spawn crate(s) filled with items
            // Each "qty" in warehouse represents one batch (batchSize items)
            for "_i" from 1 to _qty do {
                private _spawnPos = [
                    (_supplyPos select 0) + _spawnOffset,
                    (_supplyPos select 1) + (random 2 - 1),
                    0
                ];
                
                private _crate = createVehicle [_crateClass, _spawnPos, [], 0, "NONE"];
                
                // Clear default contents
                clearWeaponCargoGlobal _crate;
                clearMagazineCargoGlobal _crate;
                clearItemCargoGlobal _crate;
                clearBackpackCargoGlobal _crate;
                
                // Add items
                // Determine if it's a weapon or magazine/item
                if (isClass (configFile >> "CfgWeapons" >> _className)) then {
                    _crate addWeaponCargoGlobal [_className, _batchSize];
                } else {
                    if (isClass (configFile >> "CfgMagazines" >> _className)) then {
                        _crate addMagazineCargoGlobal [_className, _batchSize];
                    } else {
                        _crate addItemCargoGlobal [_className, _batchSize];
                    };
                };
                
                _spawnOffset = _spawnOffset + 1.5;
                
                diag_log format ["[OpsRoom] Delivered crate: %1x %2 at %3", _batchSize, _displayName, _spawnPos];
            };
        };
        
        case "vehicle": {
            // Spawn vehicle(s) directly
            for "_i" from 1 to _qty do {
                private _spawnPos = [
                    (_supplyPos select 0) + _spawnOffset,
                    (_supplyPos select 1),
                    0
                ];
                
                private _vehicle = createVehicle [_className, _spawnPos, [], 0, "NONE"];
                _vehicle setDir (random 360);
                
                _spawnOffset = _spawnOffset + 6;
                
                diag_log format ["[OpsRoom] Delivered vehicle: %1 at %2", _displayName, _spawnPos];
            };
        };
        
        case "single": {
            // Spawn single items on ground
            private _holder = createVehicle ["GroundWeaponHolder", _supplyPos, [], 0, "NONE"];
            
            if (isClass (configFile >> "CfgWeapons" >> _className)) then {
                _holder addWeaponCargoGlobal [_className, _qty];
            } else {
                if (isClass (configFile >> "CfgMagazines" >> _className)) then {
                    _holder addMagazineCargoGlobal [_className, _qty];
                } else {
                    _holder addItemCargoGlobal [_className, _qty];
                };
            };
            
            _spawnOffset = _spawnOffset + 1.5;
            
            diag_log format ["[OpsRoom] Delivered items: %1x %2 at %3", _qty, _displayName, _supplyPos];
        };
    };
} forEach _items;

// Build notification summary
private _summary = "";
{
    _x params ["_itemId", "_qty"];
    private _itemData = OpsRoom_EquipmentDB get _itemId;
    private _name = if (!isNil "_itemData") then { _itemData get "displayName" } else { _itemId };
    _summary = _summary + format ["\n  %1x %2", _qty, _name];
} forEach _items;

["PRIORITY", "SHIPMENT DELIVERED", format ["Supply shipment arrived at supply point!%1", _summary], _supplyPos] call OpsRoom_fnc_dispatch;

diag_log format ["[OpsRoom] Shipment delivered: %1 item types at %2", count _items, _supplyPos];
