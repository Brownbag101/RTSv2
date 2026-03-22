/*
    Open Storehouse Interior
    
    Opens the interior view for a specific storehouse.
    Shows units nearby, unit inventory, and storehouse contents.
    
    Parameters:
        0: STRING - Storehouse ID
    
    Usage:
        ["stores_1"] call OpsRoom_fnc_openStorehouseInterior;
*/

params [["_storehouseId", "", [""]]];

if (_storehouseId == "") exitWith { hint "Error: No storehouse ID" };

private _storeData = OpsRoom_Storehouses get _storehouseId;
if (isNil "_storeData") exitWith { hint "Error: Storehouse not found" };

// Store context for navigation
uiNamespace setVariable ["OpsRoom_SelectedStorehouse", _storehouseId];

createDialog "OpsRoom_StorehouseInteriorDialog";
waitUntil {!isNull findDisplay 11007};

private _display = findDisplay 11007;

// Set title
private _titleCtrl = _display displayCtrl 11700;
_titleCtrl ctrlSetText format ["SUPPLY STORES — %1", toUpper (_storeData get "name")];

// Setup back button
private _backBtn = _display displayCtrl 11701;
_backBtn ctrlAddEventHandler ["ButtonClick", {
    [] spawn {
        closeDialog 0;
        sleep 0.1;
        [] call OpsRoom_fnc_openStorehouseGrid;
    };
}];

// Setup unit listbox selection handler
private _unitList = _display displayCtrl 11710;
_unitList ctrlAddEventHandler ["LBSelChanged", {
    params ["_ctrl", "_index"];
    private _units = uiNamespace getVariable ["OpsRoom_StorehouseUnitList", []];
    if (_index >= 0 && _index < count _units) then {
        private _unit = _units select _index;
        uiNamespace setVariable ["OpsRoom_StorehouseSelectedUnit", _unit];
        [] call OpsRoom_fnc_populateStorehouseUnitInv;
    };
}];

// Setup absorb crates button
private _absorbBtn = _display displayCtrl 11750;
_absorbBtn ctrlAddEventHandler ["ButtonClick", {
    [] call OpsRoom_fnc_absorbCrates;
}];

// Setup transfer buttons
private _toUnitBtn = _display displayCtrl 11760;
_toUnitBtn ctrlAddEventHandler ["ButtonClick", {
    ["toUnit"] call OpsRoom_fnc_storehouseTransfer;
}];

private _toStoreBtn = _display displayCtrl 11761;
_toStoreBtn ctrlAddEventHandler ["ButtonClick", {
    ["toStore"] call OpsRoom_fnc_storehouseTransfer;
}];

// Populate panels
[] call OpsRoom_fnc_populateStorehouseUnits;
[] call OpsRoom_fnc_populateStorehouseInventory;
[] call OpsRoom_fnc_scanStorehouseCrates;

diag_log format ["[OpsRoom] Storehouse interior opened: %1", _storehouseId];
