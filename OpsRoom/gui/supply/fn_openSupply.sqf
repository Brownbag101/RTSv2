/*
    Open Supply Dialog (Convoy System v3 — Per-Port Routes)
    
    Route = sea lane entry + destination port (both must be BRITISH-owned).
    
    1. Select route from dropdown (shows "Channel Route → Port 1")
    2. Load items into ship manifests
    3. Dispatch convoy along the selected route
    
    Usage:
        [] call OpsRoom_fnc_openSupply;
*/

if (isNil "OpsRoom_ShipmentQueue") then { OpsRoom_ShipmentQueue = [] };
if (isNil "OpsRoom_ActiveConvoys") then { OpsRoom_ActiveConvoys = [] };
if (isNil "OpsRoom_CargoShips") then { OpsRoom_CargoShips = 0 };

createDialog "OpsRoom_SupplyDialog";
waitUntil {!isNull findDisplay 11005};

private _display = findDisplay 11005;

// Reset convoy builder state
OpsRoom_ShipmentQueue = [];
uiNamespace setVariable ["OpsRoom_SupplySelectedQty", 1];
uiNamespace setVariable ["OpsRoom_ConvoyShips", []];

// Update ship pool display
(_display displayCtrl 11470) ctrlSetText format ["Ships Available: %1", OpsRoom_CargoShips];

// --- Populate route dropdown (only BRITISH entry + BRITISH port) ---
private _routeCombo = _display displayCtrl 11471;
lbClear _routeCombo;

private _availableRoutes = ["BRITISH"] call OpsRoom_fnc_getAvailableRoutes;
// Each entry: [laneId, portLocId, laneName, portName]

private _routeData = [];  // Store for lookup on dispatch
{
    _x params ["_laneId", "_portLocId", "_laneName", "_portName"];
    _routeCombo lbAdd format ["%1  →  %2", _laneName, _portName];
    _routeData pushBack [_laneId, _portLocId];
} forEach _availableRoutes;

uiNamespace setVariable ["OpsRoom_RouteData", _routeData];

if (count _routeData > 0) then {
    _routeCombo lbSetCurSel 0;
} else {
    _routeCombo lbAdd "No active routes (capture entry + port)";
};

// Hide the port combo (no longer needed — route combo includes both)
private _portCombo = _display displayCtrl 11475;
if (!isNull _portCombo) then { _portCombo ctrlShow false };
private _portLabel = _display displayCtrl -1;
// Can't hide by IDC -1, but it's just a static label — harmless

// Populate warehouse list
[] call OpsRoom_fnc_populateWarehouse;

// ========== EVENT HANDLERS ==========

// Listbox selection
private _listbox = _display displayCtrl 11410;
_listbox ctrlAddEventHandler ["LBSelChanged", {
    params ["_control", "_selectedIndex"];
    uiNamespace setVariable ["OpsRoom_SupplySelectedQty", 1];
    private _display = findDisplay 11005;
    if (!isNull _display) then { (_display displayCtrl 11431) ctrlSetText "1" };
    [_selectedIndex] call OpsRoom_fnc_showSupplyDetails;
}];

// Quantity minus
(_display displayCtrl 11430) ctrlAddEventHandler ["ButtonClick", {
    private _qty = (uiNamespace getVariable ["OpsRoom_SupplySelectedQty", 1]) - 1;
    _qty = _qty max 1;
    uiNamespace setVariable ["OpsRoom_SupplySelectedQty", _qty];
    private _display = findDisplay 11005;
    if (!isNull _display) then { (_display displayCtrl 11431) ctrlSetText str _qty };
}];

// Quantity plus
(_display displayCtrl 11432) ctrlAddEventHandler ["ButtonClick", {
    private _qty = uiNamespace getVariable ["OpsRoom_SupplySelectedQty", 1];
    private _itemId = uiNamespace getVariable ["OpsRoom_SupplySelectedItem", ""];
    private _stock = if (_itemId != "") then { OpsRoom_Warehouse getOrDefault [_itemId, 0] } else { 0 };
    _qty = (_qty + 1) min _stock;
    uiNamespace setVariable ["OpsRoom_SupplySelectedQty", _qty];
    private _display = findDisplay 11005;
    if (!isNull _display) then { (_display displayCtrl 11431) ctrlSetText str _qty };
}];

// Add to manifest
(_display displayCtrl 11440) ctrlAddEventHandler ["ButtonClick", {
    private _itemId = uiNamespace getVariable ["OpsRoom_SupplySelectedItem", ""];
    private _qty = uiNamespace getVariable ["OpsRoom_SupplySelectedQty", 1];
    if (_itemId == "") exitWith { hint "No item selected" };
    if (count OpsRoom_ShipmentQueue >= 5) exitWith { hint "Manifest full! Maximum 5 item types per ship." };
    
    private _stock = OpsRoom_Warehouse getOrDefault [_itemId, 0];
    private _alreadyQueued = 0;
    { _x params ["_qId", "_qQty"]; if (_qId == _itemId) then { _alreadyQueued = _alreadyQueued + _qQty } } forEach OpsRoom_ShipmentQueue;
    private _confirmedShips = uiNamespace getVariable ["OpsRoom_ConvoyShips", []];
    { { _x params ["_qId", "_qQty"]; if (_qId == _itemId) then { _alreadyQueued = _alreadyQueued + _qQty } } forEach _x } forEach _confirmedShips;
    
    private _available = _stock - _alreadyQueued;
    if (_qty > _available) exitWith { hint format ["Not enough. Available: %1 (allocated: %2)", _available, _alreadyQueued] };
    
    private _found = false;
    { _x params ["_qId", "_qQty"]; if (_qId == _itemId) exitWith { _x set [1, _qQty + _qty]; _found = true } } forEach OpsRoom_ShipmentQueue;
    if (!_found) then { OpsRoom_ShipmentQueue pushBack [_itemId, _qty] };
    
    uiNamespace setVariable ["OpsRoom_SupplySelectedQty", 1];
    private _display = findDisplay 11005;
    if (!isNull _display) then { (_display displayCtrl 11431) ctrlSetText "1" };
    [] call OpsRoom_fnc_updateShipmentQueue;
}];

// Clear manifest
(_display displayCtrl 11452) ctrlAddEventHandler ["ButtonClick", {
    OpsRoom_ShipmentQueue = [];
    [] call OpsRoom_fnc_updateShipmentQueue;
}];

// Confirm Ship + Add Another
(_display displayCtrl 11474) ctrlAddEventHandler ["ButtonClick", {
    if (count OpsRoom_ShipmentQueue == 0) exitWith { hint "Current manifest is empty!" };
    private _confirmedShips = uiNamespace getVariable ["OpsRoom_ConvoyShips", []];
    private _maxShips = missionNamespace getVariable ["OpsRoom_Settings_MaxShipsPerConvoy", 5];
    private _totalShips = (count _confirmedShips) + 1;
    if (_totalShips > OpsRoom_CargoShips) exitWith { hint format ["Not enough ships! Available: %1, assigned: %2", OpsRoom_CargoShips, count _confirmedShips] };
    if (_totalShips >= _maxShips) exitWith { hint format ["Maximum %1 ships per convoy!", _maxShips] };
    
    _confirmedShips pushBack (+OpsRoom_ShipmentQueue);
    uiNamespace setVariable ["OpsRoom_ConvoyShips", _confirmedShips];
    OpsRoom_ShipmentQueue = [];
    [] call OpsRoom_fnc_updateShipmentQueue;
    hint format ["Ship %1 confirmed. Loading Ship %2...", count _confirmedShips, (count _confirmedShips) + 1];
}];

// Dispatch Convoy
(_display displayCtrl 11453) ctrlAddEventHandler ["ButtonClick", {
    private _confirmedShips = uiNamespace getVariable ["OpsRoom_ConvoyShips", []];
    if (count OpsRoom_ShipmentQueue > 0) then { _confirmedShips pushBack (+OpsRoom_ShipmentQueue) };
    if (count _confirmedShips == 0) exitWith { hint "No ships loaded!" };
    if (count _confirmedShips > OpsRoom_CargoShips) exitWith { hint format ["Not enough ships! Need %1, have %2", count _confirmedShips, OpsRoom_CargoShips] };
    
    // Check route selected
    private _routeData = uiNamespace getVariable ["OpsRoom_RouteData", []];
    private _display = findDisplay 11005;
    private _routeIdx = lbCurSel (_display displayCtrl 11471);
    if (_routeIdx < 0 || _routeIdx >= count _routeData) exitWith { hint "No active route selected! Capture a sea lane entry AND a port." };
    
    private _selectedRoute = _routeData select _routeIdx;
    private _seaLaneId = _selectedRoute select 0;
    private _portLocId = _selectedRoute select 1;
    
    // Deduct ships
    OpsRoom_CargoShips = OpsRoom_CargoShips - (count _confirmedShips);
    
    // Remove items from warehouse
    { { _x params ["_itemId", "_qty"];
        private _stock = OpsRoom_Warehouse getOrDefault [_itemId, 0];
        OpsRoom_Warehouse set [_itemId, (_stock - _qty) max 0];
        if ((OpsRoom_Warehouse get _itemId) <= 0) then { OpsRoom_Warehouse deleteAt _itemId };
    } forEach _x } forEach _confirmedShips;
    
    // Generate codename
    private _codename = "UNKNOWN";
    private _available = (missionNamespace getVariable ["OpsRoom_Settings_ConvoyCodenames", []]) - OpsRoom_UsedCodenames;
    if (count _available > 0) then { _codename = selectRandom _available; OpsRoom_UsedCodenames pushBack _codename } else { _codename = format ["CV-%1", OpsRoom_ConvoyNextID] };
    
    // Build ship array
    private _ships = [];
    { _ships pushBack [_x, objNull] } forEach _confirmedShips;
    
    private _spawnDelay = missionNamespace getVariable ["OpsRoom_Settings_ConvoySpawnDelay", 1];
    private _orderTime = [daytime, +date];
    
    private _convoyId = format ["convoy_%1", OpsRoom_ConvoyNextID];
    OpsRoom_ConvoyNextID = OpsRoom_ConvoyNextID + 1;
    
    // Convoy: [id, codename, ships, laneId, portLocId, orderTime, spawnDelay, status, shipsAlive]
    private _convoy = [_convoyId, _codename, _ships, _seaLaneId, _portLocId, _orderTime, _spawnDelay, "ordered", count _ships];
    OpsRoom_ActiveConvoys pushBack _convoy;
    
    // Names for dispatch
    private _laneData = OpsRoom_SeaLanes get _seaLaneId;
    private _laneName = if (!isNil "_laneData") then { _laneData get "name" } else { "Unknown" };
    private _portData = OpsRoom_StrategicLocations getOrDefault [_portLocId, createHashMap];
    private _portName = if (count _portData > 0) then { _portData get "name" } else { "Unknown Port" };
    
    private _summary = "";
    { private _sIdx = _forEachIndex + 1; _summary = _summary + format ["\n  Ship %1:", _sIdx];
        { _x params ["_iId", "_iQty"]; private _iData = OpsRoom_EquipmentDB get _iId;
          private _iName = if (!isNil "_iData") then { _iData get "displayName" } else { _iId };
          _summary = _summary + format [" %1x%2", _iQty, _iName];
        } forEach _x;
    } forEach _confirmedShips;
    
    ["PRIORITY", format ["CONVOY %1 ORDERED", _codename],
        format ["%1 ship(s) via %2 → %3. ETA: %4 hour(s).%5", count _ships, _laneName, _portName, _spawnDelay, _summary]
    ] call OpsRoom_fnc_dispatch;
    
    systemChat format ["Convoy %1: %2 ships via %3 → %4", _codename, count _ships, _laneName, _portName];
    
    // Reset UI
    OpsRoom_ShipmentQueue = [];
    uiNamespace setVariable ["OpsRoom_ConvoyShips", []];
    [] call OpsRoom_fnc_populateWarehouse;
    [] call OpsRoom_fnc_updateShipmentQueue;
    [] call OpsRoom_fnc_updateActiveShipments;
    (_display displayCtrl 11470) ctrlSetText format ["Ships Available: %1", OpsRoom_CargoShips];
    
    diag_log format ["[OpsRoom] Convoy %1 (%2) ordered: %3 ships via %4 → %5", _convoyId, _codename, count _ships, _seaLaneId, _portLocId];
}];

// Initial display updates
[] call OpsRoom_fnc_updateShipmentQueue;
[] call OpsRoom_fnc_updateActiveShipments;
_listbox lbSetCurSel 0;

diag_log "[OpsRoom] Supply dialog opened (convoy v3 — per-port routes)";
