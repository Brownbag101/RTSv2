/*
    Open Factory Interior
    
    Opens production selection for a specific factory.
    Left: categorised list of researched items.
    Right: item details + produce button.
    Bottom: current production status.
    
    Parameters:
        0: NUMBER - Factory index in OpsRoom_Factories array
    
    Usage:
        [0] call OpsRoom_fnc_openFactoryInterior;
*/

params [["_factoryIndex", 0, [0]]];

private _factories = missionNamespace getVariable ["OpsRoom_Factories", []];
if (_factoryIndex >= count _factories) exitWith { hint "Invalid factory" };

private _factory = _factories select _factoryIndex;

// Store for navigation and reference
uiNamespace setVariable ["OpsRoom_ProductionFactoryIndex", _factoryIndex];

createDialog "OpsRoom_FactoryInteriorDialog";
waitUntil {!isNull findDisplay 11004};

private _display = findDisplay 11004;

// Set title
private _titleCtrl = _display displayCtrl 11300;
_titleCtrl ctrlSetText format ["%1", _factory get "name"];

// Back button → factory grid
private _backBtn = _display displayCtrl 11301;
_backBtn ctrlAddEventHandler ["ButtonClick", {
    [] spawn {
        closeDialog 0;
        sleep 0.1;
        [] call OpsRoom_fnc_openFactories;
    };
}];

// Populate item list
[] call OpsRoom_fnc_populateProductionList;

// Listbox selection handler
private _listbox = _display displayCtrl 11310;
_listbox ctrlAddEventHandler ["LBSelChanged", {
    params ["_control", "_selectedIndex"];
    [_selectedIndex] call OpsRoom_fnc_showProductionDetails;
}];

// Produce button handler
private _produceBtn = _display displayCtrl 11330;
_produceBtn ctrlAddEventHandler ["ButtonClick", {
    [] call OpsRoom_fnc_startProduction;
}];

// Cancel button handler
private _cancelBtn = _display displayCtrl 11331;
_cancelBtn ctrlAddEventHandler ["ButtonClick", {
    [] call OpsRoom_fnc_cancelProduction;
}];

// Show current production status
private _producing = _factory get "producing";
private _statusCtrl = _display displayCtrl 11340;

if (_producing != "") then {
    private _itemData = OpsRoom_EquipmentDB get _producing;
    private _itemName = if (!isNil "_itemData") then { _itemData get "displayName" } else { _producing };
    private _batchSize = if (!isNil "_itemData") then { _itemData get "batchSize" } else { 1 };
    
    private _startTime = _factory get "startTime";
    private _cycleTime = _factory get "cycleTime";
    private _elapsed = time - _startTime;
    private _totalSecs = _cycleTime * 60;
    private _pct = floor ((_elapsed / _totalSecs) * 100) min 100;
    private _minsLeft = ceil ((_totalSecs - _elapsed) / 60) max 0;
    
    _statusCtrl ctrlSetStructuredText parseText format [
        "<t font='PuristaBold' color='#FFD966'>CURRENT PRODUCTION</t><br/><t size='0.9'>%1 — Batch of %2</t><br/><t size='0.85' color='#AAAAAA'>Progress: %3%4 — %5 min remaining (continuous)</t>",
        _itemName, _batchSize, _pct, "%", _minsLeft
    ];
    
    _produceBtn ctrlSetText "CHANGE ITEM";
    _cancelBtn ctrlShow true;
} else {
    _statusCtrl ctrlSetStructuredText parseText "<t color='#AAAAAA'>Factory is idle. Select an item to begin production.</t>";
    _cancelBtn ctrlShow false;
};

// Select first item
_listbox lbSetCurSel 0;

diag_log format ["[OpsRoom] Factory interior opened: %1", _factory get "name"];
