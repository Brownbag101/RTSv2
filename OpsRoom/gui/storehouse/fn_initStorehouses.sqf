/*
    fn_initStorehouses
    
    Scans Eden Editor markers for storehouse locations.
    Mission maker places markers named: opsroom_stores_[number]
    
    Examples:
        opsroom_stores_1
        opsroom_stores_2
    
    Optional: Set marker text in Eden to give a custom name.
    If no text set, auto-generates name from number.
    
    Each storehouse gets a virtual inventory (HashMap).
    
    Usage:
        [] call OpsRoom_fnc_initStorehouses;
*/

if (isNil "OpsRoom_Storehouses") then {
    OpsRoom_Storehouses = createHashMap;
};

private _radius = missionNamespace getVariable ["OpsRoom_Settings_StorehouseRadius", 50];
private _count = 0;

// Scan for markers named opsroom_stores_N
for "_i" from 1 to (missionNamespace getVariable ["OpsRoom_Settings_MaxStorehouses", 8]) do {
    private _markerName = format ["opsroom_stores_%1", _i];
    private _pos = getMarkerPos _markerName;
    
    // Skip if marker doesn't exist (position [0,0,0])
    if (_pos select 0 != 0 || _pos select 1 != 0) then {
        private _storehouseId = format ["stores_%1", _i];
        
        // Get custom name from marker text, or generate one
        private _customName = markerText _markerName;
        if (_customName == "") then {
            _customName = format ["Supply Depot %1", _i];
        };
        
        private _storehouseData = createHashMapFromArray [
            ["id", _storehouseId],
            ["name", _customName],
            ["marker", _markerName],
            ["position", _pos],
            ["radius", _radius],
            ["inventory", createHashMap]
        ];
        
        OpsRoom_Storehouses set [_storehouseId, _storehouseData];
        _count = _count + 1;
        
        diag_log format ["[OpsRoom] Storehouse found: %1 at %2 (marker: %3)", _customName, _pos, _markerName];
    };
};

// Also check for the legacy supply point — if it exists and no storehouses found,
// create a default storehouse at the supply point
if (_count == 0) then {
    private _supplyPos = getMarkerPos "OpsRoom_SupplyPoint";
    if (_supplyPos select 0 != 0 || _supplyPos select 1 != 0) then {
        private _storehouseData = createHashMapFromArray [
            ["id", "stores_1"],
            ["name", "Main Supply Depot"],
            ["marker", "OpsRoom_SupplyPoint"],
            ["position", _supplyPos],
            ["radius", _radius],
            ["inventory", createHashMap]
        ];
        
        OpsRoom_Storehouses set ["stores_1", _storehouseData];
        _count = 1;
        
        diag_log "[OpsRoom] No storehouse markers found — created default at OpsRoom_SupplyPoint";
    };
};

systemChat format ["Storehouses: %1 supply depots initialised", _count];
diag_log format ["[OpsRoom] Storehouses initialised: %1 total", _count];
