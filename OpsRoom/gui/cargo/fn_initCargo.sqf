/*
    Cargo System - Initialization
    
    Builds lookup tables for cargo-capable vehicles from the equipment database.
    Also sets up the destroyed vehicle event handler for cargo drop.
    
    Creates:
        OpsRoom_CargoCarriers   - HashMap: className -> cargoSlots
        OpsRoom_CargoWeights    - HashMap: className -> slotWeight
    
    Usage:
        [] call OpsRoom_fnc_initCargo;
*/

// Build carrier lookup: ARMA className -> max cargo slots
OpsRoom_CargoCarriers = createHashMap;

// Build weight lookup: ARMA className -> how many slots this takes when loaded
OpsRoom_CargoWeights = createHashMap;

// Active cargo operations (for Draw3D progress display)
if (isNil "OpsRoom_CargoProgress") then {
    OpsRoom_CargoProgress = [];
};

// Active cargo hover highlights (array of objects to highlight)
OpsRoom_CargoHoverTargets = [];

{
    private _itemId = _x;
    private _itemData = _y;
    
    // Register cargo carriers
    private _isCarrier = _itemData getOrDefault ["cargoCarrier", false];
    if (_isCarrier) then {
        private _className = _itemData get "className";
        private _slots = _itemData getOrDefault ["cargoSlots", 4];
        OpsRoom_CargoCarriers set [_className, _slots];
        diag_log format ["[OpsRoom:Cargo] Registered carrier: %1 (%2 slots)", _className, _slots];
    };
    
    // Register cargo weights (for items that specify one)
    private _weight = _itemData getOrDefault ["cargoWeight", -1];
    if (_weight > 0) then {
        private _className = _itemData get "className";
        OpsRoom_CargoWeights set [_className, _weight];
    };
} forEach OpsRoom_EquipmentDB;

// Loadable object types for nearestObjects scanning
// These are the ARMA base classes we scan for when looking for cargo to load
OpsRoom_CargoLoadableTypes = [
    "ReammoBox_F",       // Ammo crates (A3)
    "ReammoBox",         // Ammo crates (older/mod base class)
    "ThingX",            // Generic objects (fuel barrels etc)
    "WeaponHolderSimulated",  // Dropped weapon holders
    "GroundWeaponHolder", // Ground items
    "Land_CanisterFuel_F", // Fuel canisters
    "CargoNet_01_box_F"  // Cargo net boxes
];

// Vehicle destroyed handler — drops all cargo at wreck position
// We attach this to every cargo carrier when items are loaded
OpsRoom_fnc_cargoDestroyedHandler = {
    params ["_vehicle"];
    
    private _cargo = _vehicle getVariable ["OpsRoom_CargoItems", []];
    if (count _cargo == 0) exitWith {};
    
    private _pos = getPos _vehicle;
    diag_log format ["[OpsRoom:Cargo] Vehicle destroyed with %1 cargo items — dropping at %2", count _cargo, _pos];
    
    {
        _x params ["_obj", "_type", "_name", "_weight", "_isUnit"];
        
        if (!isNull _obj) then {
            // Find clear position around wreck
            private _placed = false;
            private _attempts = 0;
            private _dropPos = _pos;
            
            while {!_placed && _attempts < 8} do {
                private _dir = _attempts * 45;
                private _testPos = [
                    (_pos select 0) + (sin _dir) * (6 + _forEachIndex * 2),
                    (_pos select 1) + (cos _dir) * (6 + _forEachIndex * 2),
                    0
                ];
                _testPos set [2, getTerrainHeightASL _testPos];
                
                private _nearby = nearestObjects [_testPos, [], 2];
                _nearby = _nearby select {_x != _vehicle && _x != _obj};
                
                if (count _nearby == 0) then {
                    _dropPos = _testPos;
                    _placed = true;
                };
                _attempts = _attempts + 1;
            };
            
            // Reveal the object
            _obj enableSimulation true;
            _obj setPosASL [_dropPos select 0, _dropPos select 1, (getTerrainHeightASL _dropPos) + 0.1];
            _obj hideObjectGlobal false;
            _obj setVariable ["OpsRoom_LoadedIn", objNull, true];
            
            // For units, re-enable AI (they never left their group)
            if (_isUnit) then {
                _obj enableSimulationGlobal true;
                {_obj enableAI _x} forEach ["MOVE", "ANIM", "TEAMSWITCH", "FSM", "AIMINGERROR", "SUPPRESSION", "CHECKVISIBLE", "COVER", "AUTOCOMBAT", "TARGET", "AUTOTARGET", "PATH"];
                _obj setCaptive false;
                _obj setVariable ["OpsRoom_IsCargoLoaded", nil];
                _obj doFollow (leader group _obj);
            };
            
            diag_log format ["[OpsRoom:Cargo] Dropped: %1 at %2", _name, _dropPos];
        };
    } forEach _cargo;
    
    // Clear cargo
    _vehicle setVariable ["OpsRoom_CargoItems", [], true];
    
    // Dispatch notification
    private _vehName = getText (configFile >> "CfgVehicles" >> typeOf _vehicle >> "displayName");
    ["PRIORITY", "CARGO LOST",
        format ["%1 destroyed! %2 cargo items dropped at wreck site.", _vehName, count _cargo]
    ] call OpsRoom_fnc_dispatch;
};

diag_log format ["[OpsRoom:Cargo] Init complete — %1 carriers registered", count OpsRoom_CargoCarriers];
