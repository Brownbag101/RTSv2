/*
    Cargo System - Get Cargo Capacity
    
    Returns the current cargo usage and max slots for a vehicle.
    Checks both the equipment database lookup AND the vehicle's
    ARMA config VehicleTransport/Cargo capacity as fallback.
    
    Parameters:
        0: OBJECT - Vehicle to check
    
    Returns:
        [usedSlots, maxSlots, isCarrier]
        Returns [0, 0, false] if vehicle cannot carry cargo.
    
    Usage:
        private _cap = [_vehicle] call OpsRoom_fnc_getCargoCapacity;
        _cap params ["_used", "_max", "_isCarrier"];
*/

params [["_vehicle", objNull]];

if (isNull _vehicle) exitWith {[0, 0, false]};

private _vehType = typeOf _vehicle;

// Check our registered carriers first (from equipment DB)
private _maxSlots = OpsRoom_CargoCarriers getOrDefault [_vehType, -1];

if (_maxSlots < 0) exitWith {[0, 0, false]};

// Calculate used slots from current cargo
private _cargo = _vehicle getVariable ["OpsRoom_CargoItems", []];
private _usedSlots = 0;

{
    _x params ["_obj", "_type", "_name", "_weight", "_isUnit"];
    _usedSlots = _usedSlots + _weight;
} forEach _cargo;

// Also count crew/passengers as slot usage
// Crew (driver, gunner, commander) do NOT count — they're operating the vehicle
// Passengers in cargo positions DO count
private _cargoUnits = [];
if (_vehicle isKindOf "Air" || _vehicle isKindOf "Car" || _vehicle isKindOf "Tank" || _vehicle isKindOf "Ship") then {
    {
        // Check if this unit is a passenger (not driver/gunner/commander)
        private _role = assignedVehicleRole _x;
        if (count _role > 0) then {
            if ((_role select 0) == "cargo") then {
                _usedSlots = _usedSlots + 1;
            };
        };
    } forEach (crew _vehicle);
};

[_usedSlots, _maxSlots, true]
