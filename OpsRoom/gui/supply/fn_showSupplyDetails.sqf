/*
    Show Supply Details
    
    Displays item details in the center panel when selected from warehouse.
    Shows: name, description, warehouse stock, batch info.
    
    Parameters:
        0: NUMBER - Selected listbox index
    
    Usage:
        [0] call OpsRoom_fnc_showSupplyDetails;
*/

params [["_index", -1, [0]]];

private _display = findDisplay 11005;
if (isNull _display) exitWith {};

if (_index < 0) exitWith {};

private _itemIds = uiNamespace getVariable ["OpsRoom_SupplyListItems", []];
if (_index >= count _itemIds) exitWith {};

private _itemId = _itemIds select _index;

// Skip category headers
if (_itemId == "") exitWith {
    private _detailsCtrl = _display displayCtrl 11420;
    _detailsCtrl ctrlSetStructuredText parseText "";
    private _addBtn = _display displayCtrl 11440;
    _addBtn ctrlEnable false;
    uiNamespace setVariable ["OpsRoom_SupplySelectedItem", ""];
};

uiNamespace setVariable ["OpsRoom_SupplySelectedItem", _itemId];

private _itemData = OpsRoom_EquipmentDB get _itemId;
if (isNil "_itemData") exitWith {};

private _name = _itemData get "displayName";
private _desc = _itemData get "supplyDesc";
private _category = _itemData get "category";
private _subcategory = _itemData get "subcategory";
private _spawnType = _itemData get "spawnType";
private _batchSize = _itemData get "batchSize";
private _stock = OpsRoom_Warehouse getOrDefault [_itemId, 0];

// Account for already queued
private _queued = 0;
{
    _x params ["_qId", "_qQty"];
    if (_qId == _itemId) then { _queued = _queued + _qQty };
} forEach OpsRoom_ShipmentQueue;

private _available = _stock - _queued;

// Build details
private _text = "";

_text = _text + format ["<t size='1.2' font='PuristaBold'>%1</t><br/>", _name];
_text = _text + format ["<t size='0.8' color='#AAAAAA'>%1 > %2</t><br/><br/>", _category, _subcategory];

_text = _text + format ["<t size='0.85'>%1</t><br/><br/>", _desc];

// Stock info
private _stockColor = if (_available > 0) then { "#80FF80" } else { "#FF6666" };
_text = _text + format ["<t size='0.9' font='PuristaBold'>In Warehouse:</t><br/>"];
_text = _text + format ["<t size='0.9' color='%1'>  %2 available</t>", _stockColor, _available];
if (_queued > 0) then {
    _text = _text + format ["<t size='0.8' color='#FFD966'> (%1 queued)</t>", _queued];
};
_text = _text + "<br/><br/>";

// Delivery info
private _typeStr = switch (_spawnType) do {
    case "crate": { format ["Crate of %1", _batchSize] };
    case "vehicle": { "Vehicle" };
    case "single": { "Single item" };
    default { "Item" };
};
_text = _text + format ["<t size='0.85' color='#AAAAAA'>Delivery type: %1</t><br/>", _typeStr];

private _detailsCtrl = _display displayCtrl 11420;
_detailsCtrl ctrlSetStructuredText parseText _text;

// Update add button state
private _addBtn = _display displayCtrl 11440;
if (_available > 0 && count OpsRoom_ShipmentQueue < 5) then {
    _addBtn ctrlEnable true;
} else {
    _addBtn ctrlEnable false;
};

// Cap quantity display to available
private _qty = uiNamespace getVariable ["OpsRoom_SupplySelectedQty", 1];
if (_qty > _available) then {
    _qty = _available max 1;
    uiNamespace setVariable ["OpsRoom_SupplySelectedQty", _qty];
    (_display displayCtrl 11431) ctrlSetText str _qty;
};
