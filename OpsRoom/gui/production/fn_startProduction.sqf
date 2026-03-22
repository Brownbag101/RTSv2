/*
    Start Production
    
    Assigns an item to the current factory for continuous production.
    Deducts first batch of resources immediately.
    Factory produces a batch every X minutes, adding to warehouse.
    
    Usage:
        [] call OpsRoom_fnc_startProduction;
*/

private _itemId = uiNamespace getVariable ["OpsRoom_ProductionSelectedItem", ""];
if (_itemId == "") exitWith { hint "No item selected" };

private _itemData = OpsRoom_EquipmentDB get _itemId;
if (isNil "_itemData") exitWith { hint "Invalid item" };

private _factoryIndex = uiNamespace getVariable ["OpsRoom_ProductionFactoryIndex", 0];
private _factories = missionNamespace getVariable ["OpsRoom_Factories", []];
if (_factoryIndex >= count _factories) exitWith { hint "Invalid factory" };

private _factory = _factories select _factoryIndex;
private _name = _itemData get "displayName";
private _buildTime = _itemData get "buildTime";
private _buildCost = _itemData get "buildCost";
private _batchSize = _itemData get "batchSize";

// Check resources for first batch
private _canAfford = true;
{
    _x params ["_resName", "_amount"];
    private _cleanName = _resName;
    while {_cleanName find " " != -1} do {
        private _spacePos = _cleanName find " ";
        _cleanName = (_cleanName select [0, _spacePos]) + "_" + (_cleanName select [_spacePos + 1]);
    };
    private _varName = format ["OpsRoom_Resource_%1", _cleanName];
    private _have = missionNamespace getVariable [_varName, 0];
    if (_have < _amount) then { _canAfford = false };
} forEach _buildCost;

if (!_canAfford) exitWith { hint "Not enough resources for first production batch!" };

// Deduct resources for first batch
{
    _x params ["_resName", "_amount"];
    private _cleanName = _resName;
    while {_cleanName find " " != -1} do {
        private _spacePos = _cleanName find " ";
        _cleanName = (_cleanName select [0, _spacePos]) + "_" + (_cleanName select [_spacePos + 1]);
    };
    private _varName = format ["OpsRoom_Resource_%1", _cleanName];
    private _have = missionNamespace getVariable [_varName, 0];
    missionNamespace setVariable [_varName, _have - _amount];
    // Also update the direct variable
    call compile format ["%1 = %2;", _varName, _have - _amount];
} forEach _buildCost;

[] call OpsRoom_fnc_updateResources;

// Set factory to producing
_factory set ["producing", _itemId];
_factory set ["startTime", time];
_factory set ["cycleTime", _buildTime];
_factory set ["continuous", true];

_factories set [_factoryIndex, _factory];
missionNamespace setVariable ["OpsRoom_Factories", _factories];

["ROUTINE", "PRODUCTION STARTED", format ["%1 now producing %2 (batch of %3 every %4 min)", _factory get "name", _name, _batchSize, _buildTime]] call OpsRoom_fnc_dispatch;

// Refresh the dialog
[_factoryIndex] spawn {
    params ["_idx"];
    closeDialog 0;
    sleep 0.1;
    [_idx] call OpsRoom_fnc_openFactoryInterior;
};

diag_log format ["[OpsRoom] Production started: %1 in %2", _itemId, _factory get "name"];
