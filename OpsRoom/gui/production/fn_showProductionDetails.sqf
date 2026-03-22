/*
    Show Production Details
    
    Displays item details in the right panel when selected from the list.
    Shows: name, description, cost, build time, batch size, resource requirements.
    
    Parameters:
        0: NUMBER - Selected listbox index
    
    Usage:
        [0] call OpsRoom_fnc_showProductionDetails;
*/

params [["_index", -1, [0]]];

private _display = findDisplay 11004;
if (isNull _display) exitWith {};

if (_index < 0) exitWith {};

// Get item ID from stored list
private _itemIds = uiNamespace getVariable ["OpsRoom_ProductionListItems", []];
if (_index >= count _itemIds) exitWith {};

private _itemId = _itemIds select _index;

// Skip category headers
if (_itemId == "") exitWith {
    private _detailsCtrl = _display displayCtrl 11320;
    _detailsCtrl ctrlSetStructuredText parseText "";
    private _produceBtn = _display displayCtrl 11330;
    _produceBtn ctrlEnable false;
};

// Store selected item
uiNamespace setVariable ["OpsRoom_ProductionSelectedItem", _itemId];

private _itemData = OpsRoom_EquipmentDB get _itemId;
if (isNil "_itemData") exitWith {};

private _name = _itemData get "displayName";
private _desc = _itemData get "buildDesc";
private _buildTime = _itemData get "buildTime";
private _buildCost = _itemData get "buildCost";
private _batchSize = _itemData get "batchSize";
private _category = _itemData get "category";
private _subcategory = _itemData get "subcategory";

// Build details text
private _text = "";

// Name header
_text = _text + format ["<t size='1.3' font='PuristaBold'>%1</t><br/>", _name];
_text = _text + format ["<t size='0.8' color='#AAAAAA'>%1 > %2</t><br/><br/>", _category, _subcategory];

// Description
_text = _text + format ["<t size='0.85'>%1</t><br/><br/>", _desc];

// Production info
_text = _text + format ["<t size='0.9' font='PuristaBold'>Production Cycle:</t><br/>"];
_text = _text + format ["<t size='0.85'>  Time: %1 minutes per batch</t><br/>", _buildTime];
_text = _text + format ["<t size='0.85'>  Output: %1 per batch</t><br/><br/>", _batchSize];

// Resource cost
_text = _text + "<t size='0.9' font='PuristaBold'>Resource Cost per Batch:</t><br/>";

private _canAfford = true;
{
    _x params ["_resName", "_amount"];
    
    // Get current resource
    private _cleanName = _resName;
    while {_cleanName find " " != -1} do {
        private _spacePos = _cleanName find " ";
        _cleanName = (_cleanName select [0, _spacePos]) + "_" + (_cleanName select [_spacePos + 1]);
    };
    private _varName = format ["OpsRoom_Resource_%1", _cleanName];
    private _have = missionNamespace getVariable [_varName, 0];
    
    private _color = if (_have >= _amount) then { "#80FF80" } else { "#FF6666" };
    if (_have < _amount) then { _canAfford = false };
    
    _text = _text + format ["<t size='0.85' color='%1'>  %2: %3 (have %4)</t><br/>", _color, _resName, _amount, _have];
} forEach _buildCost;

// Set details
private _detailsCtrl = _display displayCtrl 11320;
_detailsCtrl ctrlSetStructuredText parseText _text;

// Update produce button
private _produceBtn = _display displayCtrl 11330;
private _factory = (missionNamespace getVariable ["OpsRoom_Factories", []]) select (uiNamespace getVariable ["OpsRoom_ProductionFactoryIndex", 0]);
private _isProducing = (_factory get "producing") != "";

if (_isProducing) then {
    _produceBtn ctrlSetText "CHANGE ITEM";
    if (_canAfford) then {
        _produceBtn ctrlEnable true;
    } else {
        _produceBtn ctrlEnable false;
    };
} else {
    _produceBtn ctrlSetText "START PRODUCTION";
    if (_canAfford) then {
        _produceBtn ctrlEnable true;
    } else {
        _produceBtn ctrlEnable false;
    };
};
