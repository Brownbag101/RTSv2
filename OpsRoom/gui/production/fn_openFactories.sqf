/*
    Open Factories Dialog
    
    Opens the factory grid showing all factories + build new option.
    
    Usage:
        [] call OpsRoom_fnc_openFactories;
*/

createDialog "OpsRoom_FactoriesDialog";
waitUntil {!isNull findDisplay 11003};

private _display = findDisplay 11003;

// Populate warehouse summary
private _warehouseCtrl = _display displayCtrl 11211;
private _warehouseItems = 0;
{
    _warehouseItems = _warehouseItems + _y;
} forEach OpsRoom_Warehouse;

if (_warehouseItems > 0) then {
    _warehouseCtrl ctrlSetStructuredText parseText format [
        "<t color='#D9D5C9'>WAREHOUSE: %1 items ready for shipment</t>", _warehouseItems
    ];
} else {
    _warehouseCtrl ctrlSetStructuredText parseText "<t color='#AAAAAA'>WAREHOUSE: Empty — produce items to fill it</t>";
};

// Populate factory grid
[] call OpsRoom_fnc_populateFactoryGrid;

diag_log "[OpsRoom] Factories dialog opened";
