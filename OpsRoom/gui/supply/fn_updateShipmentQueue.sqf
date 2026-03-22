/*
    Update Shipment Queue Display (Convoy Version)
    
    Shows current ship manifest and convoy summary
    (confirmed ships + current ship being loaded).
    
    Usage:
        [] call OpsRoom_fnc_updateShipmentQueue;
*/

private _display = findDisplay 11005;
if (isNull _display) exitWith {};

private _manifestCtrl = _display displayCtrl 11450;
private _headerCtrl = _display displayCtrl 11472;
private _summaryCtrl = _display displayCtrl 11473;
private _dispatchBtn = _display displayCtrl 11453;
private _addShipBtn = _display displayCtrl 11474;

private _confirmedShips = uiNamespace getVariable ["OpsRoom_ConvoyShips", []];
private _currentShipNum = (count _confirmedShips) + 1;
private _queueCount = count OpsRoom_ShipmentQueue;

// Update manifest header
_headerCtrl ctrlSetText format ["Ship %1 Manifest (%2/5 slots)", _currentShipNum, _queueCount];

// Build current manifest text
if (_queueCount == 0) then {
    _manifestCtrl ctrlSetStructuredText parseText "<t color='#666666' size='0.85'>No items loaded.<br/><br/>Select items from the warehouse and click ADD TO MANIFEST.</t>";
} else {
    private _text = "";
    private _slotNum = 1;
    {
        _x params ["_itemId", "_qty"];
        private _itemData = OpsRoom_EquipmentDB get _itemId;
        private _name = if (!isNil "_itemData") then { _itemData get "displayName" } else { _itemId };
        _text = _text + format ["<t size='0.85' color='#D9D5C9'>%1. %2 x%3</t><br/>", _slotNum, _name, _qty];
        _slotNum = _slotNum + 1;
    } forEach OpsRoom_ShipmentQueue;
    _manifestCtrl ctrlSetStructuredText parseText _text;
};

// Build convoy summary (confirmed ships)
if (count _confirmedShips == 0) then {
    _summaryCtrl ctrlSetStructuredText parseText "<t color='#666666' size='0.8'>No ships confirmed yet.</t>";
} else {
    private _text = format ["<t color='#80FF80' font='PuristaBold' size='0.85'>%1 ship(s) confirmed:</t><br/>", count _confirmedShips];
    {
        private _shipNum = _forEachIndex + 1;
        private _itemCount = 0;
        { _itemCount = _itemCount + (_x select 1) } forEach _x;
        _text = _text + format ["<t size='0.8' color='#AAAAAA'>  Ship %1: %2 item type(s)</t><br/>", _shipNum, count _x];
    } forEach _confirmedShips;
    _summaryCtrl ctrlSetStructuredText parseText _text;
};

// Enable/disable buttons
private _hasManifest = _queueCount > 0;
private _hasConfirmedOrManifest = (count _confirmedShips > 0) || _hasManifest;

_dispatchBtn ctrlEnable _hasConfirmedOrManifest;

// Add Ship button: only if manifest has items AND more ships available
private _maxShips = missionNamespace getVariable ["OpsRoom_Settings_MaxShipsPerConvoy", 5];
private _canAddMore = _hasManifest && {(count _confirmedShips + 1) < _maxShips} && {(count _confirmedShips + 1) < OpsRoom_CargoShips};
_addShipBtn ctrlEnable _canAddMore;
