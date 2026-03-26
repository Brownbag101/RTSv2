/*
    Cargo System - Load Cargo
    
    Loads a specific item onto a vehicle with a timed progress bar.
    Progress is displayed via the Draw3D handler (OpsRoom_CargoProgress).
    
    Parameters:
        0: OBJECT  - Vehicle to load into
        1: ARRAY   - Item data [object, className, displayName, weight, isUnit]
    
    Usage:
        [_vehicle, _itemData] call OpsRoom_fnc_loadCargo;
*/

params [["_vehicle", objNull], ["_itemData", []]];

if (isNull _vehicle) exitWith { diag_log "[OpsRoom:Cargo] loadCargo: null vehicle" };
if (count _itemData == 0) exitWith { diag_log "[OpsRoom:Cargo] loadCargo: empty item data" };

_itemData params ["_obj", "_className", "_displayName", "_weight", "_isUnit"];

if (isNull _obj) exitWith { hint "Item no longer exists" };

// Double-check capacity
private _cap = [_vehicle] call OpsRoom_fnc_getCargoCapacity;
_cap params ["_usedSlots", "_maxSlots", "_isCarrier"];

if (!_isCarrier) exitWith { hint "Vehicle cannot carry cargo" };
if ((_usedSlots + _weight) > _maxSlots) exitWith {
    hint format ["Not enough space! Need %1 slot(s), only %2 free", _weight, _maxSlots - _usedSlots];
};

// Check the item isn't already loaded
if (!isNull (_obj getVariable ["OpsRoom_LoadedIn", objNull])) exitWith {
    hint "Item is already loaded in a vehicle";
};

private _vehName = getText (configFile >> "CfgVehicles" >> typeOf _vehicle >> "displayName");
private _loadTime = missionNamespace getVariable ["OpsRoom_Settings_CargoLoadTime", 4];

// Store the starting positions for movement check
private _startPos = getPos _vehicle;

// Add progress entry for Draw3D rendering
private _progressEntry = createHashMapFromArray [
    ["vehicle", _vehicle],
    ["object", _obj],
    ["displayName", _displayName],
    ["startTime", time],
    ["duration", _loadTime],
    ["mode", "loading"],
    ["complete", false],
    ["cancelled", false]
];
OpsRoom_CargoProgress pushBack _progressEntry;

diag_log format ["[OpsRoom:Cargo] Loading '%1' onto %2 (%3s)", _displayName, _vehName, _loadTime];

// Spawn the timed loading process
[_vehicle, _obj, _displayName, _weight, _isUnit, _loadTime, _startPos, _progressEntry] spawn {
    params ["_vehicle", "_obj", "_displayName", "_weight", "_isUnit", "_loadTime", "_startPos", "_progressEntry"];
    
    private _startTime = time;
    
    // Wait for load timer, checking for cancellation conditions
    while {time < _startTime + _loadTime} do {
        // Cancel if vehicle destroyed
        if (!alive _vehicle) exitWith {
            _progressEntry set ["cancelled", true];
            hint "Loading cancelled — vehicle destroyed!";
        };
        
        // Cancel if item destroyed/gone
        if (isNull _obj || {!alive _obj && !_isUnit}) exitWith {
            _progressEntry set ["cancelled", true];
            hint "Loading cancelled — item no longer exists!";
        };
        
        // Cancel if vehicle moved too far
        if (_vehicle distance _startPos > 5) exitWith {
            _progressEntry set ["cancelled", true];
            hint "Loading cancelled — vehicle moved!";
        };
        
        sleep 0.1;
    };
    
    // Check if cancelled
    if (_progressEntry getOrDefault ["cancelled", false]) exitWith {
        _progressEntry set ["complete", true];
        diag_log format ["[OpsRoom:Cargo] Loading cancelled: %1", _displayName];
    };
    
    // ============================================================
    // LOADING COMPLETE — hide object and store in vehicle
    // ============================================================
    
    // For units: disable AI completely but KEEP them in their ARMA group
    // This preserves the regiment/group structure in OpsRoom_Groups
    if (_isUnit) then {
        // Store the ARMA group for reference (NOT for group transfer)
        _obj setVariable ["OpsRoom_OriginalGroup", group _obj, true];
        
        // Force out of any vehicle first
        if (vehicle _obj != _obj) then {
            moveOut _obj;
        };
        
        // Disable all AI behaviour — prevents auto-GetIn, wandering, etc.
        _obj disableAI "ALL";
        _obj setCaptive true;
        
        // Cancel any existing orders/waypoints
        doStop _obj;
        
        // Mark as cargo-loaded so other systems (detach/reattach) can skip them
        _obj setVariable ["OpsRoom_IsCargoLoaded", true, true];
    };
    
    // Hide the object — use hideObjectGlobal + move underground for reliability
    _obj hideObjectGlobal true;
    _obj enableSimulation false;
    _obj setPosASL [0, 0, -100];  // Move underground as belt-and-braces
    _obj setVariable ["OpsRoom_LoadedIn", _vehicle, true];
    
    // Add to vehicle's cargo array
    private _cargo = _vehicle getVariable ["OpsRoom_CargoItems", []];
    _cargo pushBack [_obj, typeOf _obj, _displayName, _weight, _isUnit];
    _vehicle setVariable ["OpsRoom_CargoItems", _cargo, true];
    
    // Attach destroyed handler if this is the first cargo item
    if (count _cargo == 1) then {
        _vehicle addEventHandler ["Killed", {
            params ["_vehicle"];
            [_vehicle] call OpsRoom_fnc_cargoDestroyedHandler;
        }];
        _vehicle setVariable ["OpsRoom_CargoKilledEH", true, true];
    };
    
    // Mark progress complete
    _progressEntry set ["complete", true];
    
    // Update capacity display
    private _cap = [_vehicle] call OpsRoom_fnc_getCargoCapacity;
    _cap params ["_used", "_max"];
    
    private _vehName = getText (configFile >> "CfgVehicles" >> typeOf _vehicle >> "displayName");
    
    hint format ["Loaded: %1\n%2 cargo: %3/%4", _displayName, _vehName, _used, _max];
    
    // Force refresh cargo display icons
    [_vehicle, true] call OpsRoom_fnc_updateCargoDisplay;
    
    diag_log format ["[OpsRoom:Cargo] Loaded '%1' onto %2 (%3/%4 slots)", _displayName, _vehName, _used, _max];
};
