/*
    Air Operations - Repair, Rearm, Refuel Aircraft
    
    Restores aircraft condition in the hangar.
    Costs resources based on how much needs restoring.
    
    Parameters:
        _hangarId  - Hangar ID
        _action    - "repair", "rearm", "refuel", or "all"
    
    Returns:
        Boolean - true on success
*/
params ["_hangarId", ["_action", "all"]];

private _entry = OpsRoom_Hangar get _hangarId;
if (isNil "_entry") exitWith {
    diag_log format ["[OpsRoom] Air: Cannot service '%1' - not found", _hangarId];
    false
};

// Can only service hangared aircraft
if ((_entry get "status") != "HANGARED") exitWith {
    systemChat "Aircraft must be in hangar to service";
    false
};

private _displayName = _entry get "displayName";
private _changed = false;

// Repair
if (_action == "repair" || _action == "all") then {
    private _damage = _entry get "damage";
    if (_damage > 0) then {
        // Cost: 1 Steel + 1 Aluminium per 25% damage
        private _repairUnits = ceil (_damage / 0.25);
        private _steelCost = _repairUnits;
        private _alumCost = _repairUnits;
        
        if (OpsRoom_Resource_Steel >= _steelCost && OpsRoom_Resource_Aluminium >= _alumCost) then {
            OpsRoom_Resource_Steel = OpsRoom_Resource_Steel - _steelCost;
            OpsRoom_Resource_Aluminium = OpsRoom_Resource_Aluminium - _alumCost;
            _entry set ["damage", 0];
            _changed = true;
            systemChat format ["%1 repaired. Cost: %2 Steel, %3 Aluminium", _displayName, _steelCost, _alumCost];
        } else {
            systemChat format ["Insufficient resources to repair %1", _displayName];
        };
    };
};

// Rearm
if (_action == "rearm" || _action == "all") then {
    private _ammo = _entry get "ammo";
    if (_ammo < 1) then {
        // Cost: 1 Steel per 25% ammo needed
        private _rearmUnits = ceil ((1 - _ammo) / 0.25);
        private _steelCost = _rearmUnits;
        
        if (OpsRoom_Resource_Steel >= _steelCost) then {
            OpsRoom_Resource_Steel = OpsRoom_Resource_Steel - _steelCost;
            _entry set ["ammo", 1];
            _changed = true;
            systemChat format ["%1 rearmed. Cost: %2 Steel", _displayName, _steelCost];
        } else {
            systemChat format ["Insufficient resources to rearm %1", _displayName];
        };
    };
};

// Refuel
if (_action == "refuel" || _action == "all") then {
    private _fuel = _entry get "fuel";
    if (_fuel < 1) then {
        // Cost: 1 Fuel per 25% fuel needed
        private _refuelUnits = ceil ((1 - _fuel) / 0.25);
        
        if (OpsRoom_Resource_Fuel >= _refuelUnits) then {
            OpsRoom_Resource_Fuel = OpsRoom_Resource_Fuel - _refuelUnits;
            _entry set ["fuel", 1];
            _changed = true;
            systemChat format ["%1 refuelled. Cost: %2 Fuel", _displayName, _refuelUnits];
        } else {
            systemChat format ["Insufficient fuel to refuel %1", _displayName];
        };
    };
};

if (_changed) then {
    [] call OpsRoom_fnc_updateResources;
};

_changed
