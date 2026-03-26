/*
    Cargo System - Unload All Cargo
    
    Unloads all cargo items from a vehicle sequentially, one by one.
    
    Parameters:
        0: OBJECT - Vehicle to unload from
    
    Usage:
        [_vehicle] call OpsRoom_fnc_unloadAllCargo;
*/

params [["_vehicle", objNull]];

if (isNull _vehicle) exitWith {};

private _cargo = _vehicle getVariable ["OpsRoom_CargoItems", []];
if (count _cargo == 0) exitWith { hint "No cargo to unload" };

// Spawn sequential unloading (always unload index 0 since array shrinks)
[_vehicle] spawn {
    params ["_vehicle"];
    
    private _unloadTime = missionNamespace getVariable ["OpsRoom_Settings_CargoUnloadTime", 3];
    private _unloaded = 0;
    
    while {true} do {
        private _cargo = _vehicle getVariable ["OpsRoom_CargoItems", []];
        if (count _cargo == 0) exitWith {};
        if (!alive _vehicle) exitWith {};
        
        // Always unload index 0 (first item)
        [_vehicle, 0] call OpsRoom_fnc_unloadCargo;
        
        // Wait for unload to complete
        sleep (_unloadTime + 0.5);
        
        _unloaded = _unloaded + 1;
    };
    
    if (_unloaded > 0) then {
        private _vehName = getText (configFile >> "CfgVehicles" >> typeOf _vehicle >> "displayName");
        hint format ["Unload All complete: %1 items unloaded from %2", _unloaded, _vehName];
    };
};
