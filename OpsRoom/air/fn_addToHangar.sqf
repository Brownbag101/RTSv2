/*
    Air Operations - Add Aircraft to Hangar
    
    Adds a new aircraft to the virtual hangar pool.
    Called when aircraft are produced or supplied.
    
    Parameters:
        _equipId  - Equipment Database ID (e.g., "hurricane_mk1")
    
    Returns:
        String - Hangar ID of the new entry, or "" on failure
*/
params ["_equipId"];

// Validate equipment exists
private _itemData = OpsRoom_EquipmentDB get _equipId;
if (isNil "_itemData") exitWith {
    diag_log format ["[OpsRoom] Air: Cannot add '%1' - not in Equipment DB", _equipId];
    ""
};

// Validate it's an aircraft
if ((_itemData get "category") != "Aircraft") exitWith {
    diag_log format ["[OpsRoom] Air: '%1' is not an aircraft", _equipId];
    ""
};

// Generate hangar ID
private _hangarId = format ["hangar_%1", OpsRoom_HangarNextID];
OpsRoom_HangarNextID = OpsRoom_HangarNextID + 1;

// Create hangar entry
private _entry = createHashMapFromArray [
    ["equipId", _equipId],
    ["className", _itemData get "className"],
    ["displayName", _itemData get "displayName"],
    ["aircraftType", _itemData getOrDefault ["aircraftType", "Fighter"]],
    ["damage", 0],
    ["fuel", 1],
    ["ammo", 1],
    ["pilot", objNull],
    ["pilotName", ""],
    ["assignedCrew", []],
    ["crewRequired", 0],
    ["wingId", ""],
    ["sortieCount", 0],
    ["killsAir", 0],
    ["killsGround", 0],
    ["flightHours", 0],
    ["status", "HANGARED"]
];

// Calculate crew required from vehicle config turrets (non-driver, non-cargo)
private _className = _itemData get "className";
private _crewCount = 0;
private _fnc_countTurrets = {
    params ["_cfgPath"];
    private _turretClasses = configProperties [_cfgPath, "isClass _x", true];
    {
        // Check if this turret is a cargo/FFV turret
        private _isCargo = getNumber (_x >> "isPersonTurret");
        private _isCargoFFV = getNumber (_x >> "proxyIndex") < 0;
        if (_isCargo != 1) then {
            _crewCount = _crewCount + 1;
        };
        // Recurse sub-turrets
        if (isClass (_x >> "Turrets")) then {
            [_x >> "Turrets"] call _fnc_countTurrets;
        };
    } forEach _turretClasses;
};

private _vehicleCfg = configFile >> "CfgVehicles" >> _className;
if (isClass (_vehicleCfg >> "Turrets")) then {
    [_vehicleCfg >> "Turrets"] call _fnc_countTurrets;
};
_entry set ["crewRequired", _crewCount];

OpsRoom_Hangar set [_hangarId, _entry];

diag_log format ["[OpsRoom] Air: Added %1 to hangar as %2 (crew needed: %3)", _itemData get "displayName", _hangarId, _crewCount];

// Send dispatch
[
    format ["%1 delivered to hangar", _itemData get "displayName"],
    format ["A new %1 has been delivered to the airfield and is ready for assignment.", _itemData get "displayName"],
    "ROUTINE"
] call OpsRoom_fnc_dispatch;

_hangarId
