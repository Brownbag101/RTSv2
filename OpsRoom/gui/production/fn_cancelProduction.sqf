/*
    Cancel Production
    
    Stops production in the current factory. No resource refund.
    
    Usage:
        [] call OpsRoom_fnc_cancelProduction;
*/

private _factoryIndex = uiNamespace getVariable ["OpsRoom_ProductionFactoryIndex", 0];
private _factories = missionNamespace getVariable ["OpsRoom_Factories", []];
if (_factoryIndex >= count _factories) exitWith { hint "Invalid factory" };

private _factory = _factories select _factoryIndex;
private _producing = _factory get "producing";

if (_producing == "") exitWith { hint "Factory is not producing anything" };

private _itemData = OpsRoom_EquipmentDB get _producing;
private _itemName = if (!isNil "_itemData") then { _itemData get "displayName" } else { _producing };

// Clear production
_factory set ["producing", ""];
_factory set ["startTime", 0];
_factory set ["cycleTime", 0];

_factories set [_factoryIndex, _factory];
missionNamespace setVariable ["OpsRoom_Factories", _factories];

["ROUTINE", "PRODUCTION CANCELLED", format ["%1 stopped producing %2. No refund for current batch.", _factory get "name", _itemName]] call OpsRoom_fnc_dispatch;

// Refresh the dialog
[_factoryIndex] spawn {
    params ["_idx"];
    closeDialog 0;
    sleep 0.1;
    [_idx] call OpsRoom_fnc_openFactoryInterior;
};

diag_log format ["[OpsRoom] Production cancelled: %1 in %2", _producing, _factory get "name"];
