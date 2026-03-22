/*
    Ship Items
    
    Takes items from the shipment queue, removes them from warehouse,
    and creates an active shipment that will deliver after a set time.
    
    Delivery time: 5 minutes (configurable)
    Items spawn at editor-placed marker "OpsRoom_SupplyPoint" on delivery.
    
    Usage:
        [] call OpsRoom_fnc_shipItems;
*/

if (count OpsRoom_ShipmentQueue == 0) exitWith { hint "No items in shipment queue!" };

// Remove items from warehouse
{
    _x params ["_itemId", "_qty"];
    private _stock = OpsRoom_Warehouse getOrDefault [_itemId, 0];
    
    if (_stock < _qty) exitWith {
        hint format ["Error: Not enough %1 in warehouse (need %2, have %3)", _itemId, _qty, _stock];
    };
    
    OpsRoom_Warehouse set [_itemId, _stock - _qty];
    
    // Clean up zero-stock entries
    if ((_stock - _qty) <= 0) then {
        OpsRoom_Warehouse deleteAt _itemId;
    };
} forEach OpsRoom_ShipmentQueue;

// Create active shipment
private _deliveryTime = missionNamespace getVariable ["OpsRoom_Settings_DeliveryTime", 5];  // minutes

private _shipment = [
    +OpsRoom_ShipmentQueue,  // Deep copy the items
    time,                     // Start time
    _deliveryTime             // Delivery time in minutes
];

private _activeShipments = missionNamespace getVariable ["OpsRoom_ActiveShipments", []];
_activeShipments pushBack _shipment;
missionNamespace setVariable ["OpsRoom_ActiveShipments", _activeShipments];

// Build summary for notification
private _summary = "";
{
    _x params ["_itemId", "_qty"];
    private _itemData = OpsRoom_EquipmentDB get _itemId;
    private _name = if (!isNil "_itemData") then { _itemData get "displayName" } else { _itemId };
    _summary = _summary + format ["\n  %1x %2", _qty, _name];
} forEach OpsRoom_ShipmentQueue;

["ROUTINE", "SHIPMENT DISPATCHED", format ["Shipment en route! ETA: %1 minutes.%2", _deliveryTime, _summary]] call OpsRoom_fnc_dispatch;

// Clear queue
OpsRoom_ShipmentQueue = [];

// Refresh display
[] call OpsRoom_fnc_populateWarehouse;
[] call OpsRoom_fnc_updateShipmentQueue;
[] call OpsRoom_fnc_updateActiveShipments;

// Re-select first item to refresh details
private _display = findDisplay 11005;
if (!isNull _display) then {
    private _listbox = _display displayCtrl 11410;
    _listbox lbSetCurSel 0;
};

diag_log format ["[OpsRoom] Shipment dispatched: %1 item types, delivery in %2 min", count (_shipment select 0), _deliveryTime];
