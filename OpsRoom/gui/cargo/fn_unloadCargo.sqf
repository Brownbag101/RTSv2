/*
    Cargo System - Unload Cargo
    
    Unloads a specific cargo item from a vehicle with a timed progress bar.
    
    Ground vehicles: finds clear position nearby and places item.
    Aircraft in flight: drops item at aircraft altitude.
        - If "paradrop_capability" is researched: attaches a parachute
        - If not researched: item free-falls
        - Men can ONLY be dropped mid-air if they have OpsRoom_Ability_Paratrooper
        - Non-paratrooper men can only be unloaded when aircraft is on the ground
    
    Parameters:
        0: OBJECT  - Vehicle to unload from
        1: NUMBER  - Index in the vehicle's OpsRoom_CargoItems array
    
    Usage:
        [_vehicle, _cargoIndex] call OpsRoom_fnc_unloadCargo;
*/

params [["_vehicle", objNull], ["_cargoIndex", -1]];

if (isNull _vehicle) exitWith { diag_log "[OpsRoom:Cargo] unloadCargo: null vehicle" };

private _cargo = _vehicle getVariable ["OpsRoom_CargoItems", []];

if (_cargoIndex < 0 || _cargoIndex >= count _cargo) exitWith {
    hint "Invalid cargo item";
    diag_log format ["[OpsRoom:Cargo] unloadCargo: invalid index %1 (cargo count: %2)", _cargoIndex, count _cargo];
};

private _itemData = _cargo select _cargoIndex;
_itemData params ["_obj", "_className", "_displayName", "_weight", "_isUnit"];

if (isNull _obj) exitWith {
    _cargo deleteAt _cargoIndex;
    _vehicle setVariable ["OpsRoom_CargoItems", _cargo, true];
    hint "Cargo item no longer exists - removed from manifest";
};

// ============================================================
// AIR DROP CHECKS
// ============================================================

private _isAirborne = false;
if (_vehicle isKindOf "Air") then {
    private _altATL = (getPosATL _vehicle) select 2;
    if (_altATL > 10 && speed _vehicle > 5) then {
        _isAirborne = true;
    };
};

// Check if men can be dropped mid-air — block non-paratroopers
// exitWith at top scope to stop the whole function
private _blockUnload = false;
if (_isAirborne && _isUnit) then {
    if !(_obj getVariable ["OpsRoom_Ability_Paratrooper", false]) then {
        _blockUnload = true;
    };
};

if (_blockUnload) exitWith {
    hint format ["%1 is not paratrooper-qualified.\nLand the aircraft to unload this soldier.", _displayName];
};

private _vehName = getText (configFile >> "CfgVehicles" >> typeOf _vehicle >> "displayName");
private _unloadTime = missionNamespace getVariable ["OpsRoom_Settings_CargoUnloadTime", 3];

// Add progress entry for Draw3D
private _progressEntry = createHashMapFromArray [
    ["vehicle", _vehicle],
    ["object", _obj],
    ["displayName", _displayName],
    ["startTime", time],
    ["duration", _unloadTime],
    ["mode", "unloading"],
    ["complete", false],
    ["cancelled", false]
];
OpsRoom_CargoProgress pushBack _progressEntry;

diag_log format ["[OpsRoom:Cargo] Unloading '%1' from %2 (airborne: %3)", _displayName, _vehName, _isAirborne];

// Spawn the timed unloading process
[_vehicle, _obj, _displayName, _weight, _isUnit, _unloadTime, _cargoIndex, _progressEntry, _isAirborne] spawn {
    params ["_vehicle", "_obj", "_displayName", "_weight", "_isUnit", "_unloadTime", "_cargoIndex", "_progressEntry", "_isAirborne"];
    
    private _startTime = time;
    
    while {time < _startTime + _unloadTime} do {
        if (!alive _vehicle) exitWith {
            _progressEntry set ["cancelled", true];
        };
        sleep 0.1;
    };
    
    if (_progressEntry getOrDefault ["cancelled", false]) exitWith {
        _progressEntry set ["complete", true];
    };
    
    // ============================================================
    // UNLOADING COMPLETE
    // ============================================================
    
    if (_isAirborne) then {
        // ========================================
        // AIR DROP
        // ========================================
        private _dropPos = getPosASL _vehicle;
        // Offset slightly behind the aircraft
        private _vehDir = getDir _vehicle;
        _dropPos = [
            (_dropPos select 0) + (sin (_vehDir + 180)) * 15,
            (_dropPos select 1) + (cos (_vehDir + 180)) * 15,
            _dropPos select 2
        ];
        
        // Check if paradrop capability is researched
        private _hasParadrop = false;
        if (!isNil "OpsRoom_ResearchCompleted") then {
            _hasParadrop = "paradrop_capability" in OpsRoom_ResearchCompleted;
        };
        
        // Reveal the object at altitude
        _obj enableSimulation true;
        _obj setPosASL _dropPos;
        _obj hideObjectGlobal false;
        _obj setVariable ["OpsRoom_LoadedIn", objNull, true];
        
        if (_isUnit) then {
            // PARATROOPER DROP — re-enable AI explicitly per component
            _obj enableSimulationGlobal true;
            sleep 0.1;
            {_obj enableAI _x} forEach ["MOVE", "ANIM", "TEAMSWITCH", "FSM", "AIMINGERROR", "SUPPRESSION", "CHECKVISIBLE", "COVER", "AUTOCOMBAT", "TARGET", "AUTOTARGET", "PATH"];
            _obj setCaptive false;
            _obj setVariable ["OpsRoom_IsCargoLoaded", nil];
            
            // Ensure paratrooper has a parachute — replace current backpack if needed
            private _currentBP = backpack _obj;
            if (_currentBP != "B_Parachute" && _currentBP != "fow_b_uk_p37_blanco") then {
                // Unknown backpack, just add parachute
                removeBackpack _obj;
                _obj addBackpack "B_Parachute";
            } else {
                if (_currentBP == "fow_b_uk_p37_blanco") then {
                    // Para kit backpack — swap for parachute during drop
                    // Store backpack type to re-add after landing
                    _obj setVariable ["OpsRoom_StoredBackpack", _currentBP, true];
                    removeBackpack _obj;
                    _obj addBackpack "B_Parachute";
                };
                // If already B_Parachute, do nothing
            };
            
            // Monitor landing and restore backpack
            [_obj] spawn {
                params ["_u"];
                // Wait for landing
                waitUntil {sleep 0.5; !alive _u || (getPosATL _u) select 2 < 3};
                
                if (alive _u) then {
                    // Restore original backpack after landing
                    private _storedBP = _u getVariable ["OpsRoom_StoredBackpack", ""];
                    if (_storedBP != "") then {
                        sleep 2;  // Brief delay after landing
                        removeBackpack _u;
                        _u addBackpack _storedBP;
                        _u setVariable ["OpsRoom_StoredBackpack", nil];
                    };
                };
            };
            
            diag_log format ["[OpsRoom:Cargo] Paradropped %1 at altitude %2m", _displayName, round ((_dropPos select 2) - getTerrainHeightASL _dropPos)];
            
        } else {
            // CARGO DROP
            if (_hasParadrop) then {
                // Attach parachute to cargo
                private _chute = createVehicle ["B_Parachute_02_F", [0,0,0], [], 0, "FLY"];
                _chute setPosASL _dropPos;
                _obj attachTo [_chute, [0, 0, -1]];
                
                // Monitor until landed, then detach
                [_obj, _chute] spawn {
                    params ["_cargo", "_chute"];
                    
                    waitUntil {sleep 0.5; (getPosATL _cargo) select 2 < 2 || isNull _chute || !alive _chute};
                    
                    if (!isNull _cargo) then {
                        detach _cargo;
                        private _groundPos = getPos _cargo;
                        _groundPos set [2, 0];
                        _cargo setPos _groundPos;
                    };
                    
                    // Clean up parachute
                    if (!isNull _chute) then {
                        sleep 3;
                        deleteVehicle _chute;
                    };
                    
                    diag_log "[OpsRoom:Cargo] Parachute cargo landed";
                };
                
                diag_log format ["[OpsRoom:Cargo] Paradrop with chute: %1", _displayName];
                
            } else {
                // FREE FALL — no parachute, item just drops
                // Gravity and simulation handle the rest
                diag_log format ["[OpsRoom:Cargo] Free-fall drop (no paradrop research): %1", _displayName];
            };
        };
        
    } else {
        // ========================================
        // GROUND UNLOAD (existing logic)
        // ========================================
        private _vehPos = getPos _vehicle;
        private _placed = false;
        private _dropPos = _vehPos;
        private _attempts = 0;
        private _distance = 6;
        
        while {!_placed && _attempts < 12} do {
            private _dir = _attempts * 30;
            private _testPos = [
                (_vehPos select 0) + (sin _dir) * _distance,
                (_vehPos select 1) + (cos _dir) * _distance,
                0
            ];
            
            private _nearby = nearestObjects [_testPos, [], 2];
            _nearby = _nearby select {_x != _vehicle && _x != _obj};
            
            if (count _nearby == 0) then {
                _dropPos = _testPos;
                _placed = true;
            };
            
            _attempts = _attempts + 1;
        };
        
        if (!_placed) then {
            private _vehDir = getDir _vehicle;
            _dropPos = [
                (_vehPos select 0) + (sin (_vehDir + 180)) * 8,
                (_vehPos select 1) + (cos (_vehDir + 180)) * 8,
                0
            ];
        };
        
        _dropPos set [2, getTerrainHeightASL _dropPos + 0.1];
        
        _obj enableSimulation true;
        _obj setPosASL _dropPos;
        _obj hideObjectGlobal false;
        _obj setVariable ["OpsRoom_LoadedIn", objNull, true];
        
        if (_isUnit && alive _obj) then {
            // Re-enable AI explicitly per component (enableAI ALL is unreliable)
            _obj enableSimulationGlobal true;
            _obj setPosATL [_dropPos select 0, _dropPos select 1, 0];
            sleep 0.1;
            {_obj enableAI _x} forEach ["MOVE", "ANIM", "TEAMSWITCH", "FSM", "AIMINGERROR", "SUPPRESSION", "CHECKVISIBLE", "COVER", "AUTOCOMBAT", "TARGET", "AUTOTARGET", "PATH"];
            _obj setCaptive false;
            _obj setVariable ["OpsRoom_IsCargoLoaded", nil];
            
            // Give the unit a command to snap them out of any frozen state
            _obj doFollow (leader group _obj);
        };
    };
    
    // Remove from vehicle cargo
    private _cargo = _vehicle getVariable ["OpsRoom_CargoItems", []];
    private _removeIdx = _cargo findIf {(_x select 0) == _obj};
    if (_removeIdx >= 0) then {
        _cargo deleteAt _removeIdx;
    };
    _vehicle setVariable ["OpsRoom_CargoItems", _cargo, true];
    
    _progressEntry set ["complete", true];
    
    private _cap = [_vehicle] call OpsRoom_fnc_getCargoCapacity;
    _cap params ["_used", "_max"];
    
    private _vehName = getText (configFile >> "CfgVehicles" >> typeOf _vehicle >> "displayName");
    
    private _methodText = if (_isAirborne) then {"Dropped"} else {"Unloaded"};
    hint format ["%1: %2\n%3 cargo: %4/%5", _methodText, _displayName, _vehName, _used, _max];
    
    [_vehicle, true] call OpsRoom_fnc_updateCargoDisplay;
    
    diag_log format ["[OpsRoom:Cargo] %1 '%2' from %3 (%4/%5 slots)", _methodText, _displayName, _vehName, _used, _max];
};
