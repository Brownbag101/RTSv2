/*
    Air Operations - Aircraft Status Monitor
    
    Background monitor that checks airborne aircraft for:
    - Low fuel (< 20%) → triggers RTB for the wing
    - No ammo (all magazines empty) → triggers RTB for the wing
    
    Pairs with auto-rearm/refuel to create automated sortie cycles.
    
    Called once at init. Runs continuously.
*/

if (!isNil "OpsRoom_AircraftStatus_Handle") then {
    terminate OpsRoom_AircraftStatus_Handle;
};

OpsRoom_AircraftStatus_Handle = [] spawn {
    waitUntil { sleep 1; !isNil "OpsRoom_AirWings" };
    
    while { true } do {
        sleep 15;
        
        {
            private _wingId = _x;
            private _wingData = _y;
            
            private _status = _wingData get "status";
            if (_status != "AIRBORNE") then { continue };
            
            // Skip if auto-RTB already triggered for this wing
            if (_wingData getOrDefault ["autoRTB_triggered", false]) then { continue };
            
            private _spawnedObjects = _wingData get "spawnedObjects";
            private _wingName = _wingData get "name";
            
            private _lowFuel = false;
            private _noAmmo = false;
            
            {
                private _obj = _x;
                if !(_obj isKindOf "Air") then { continue };
                if (!alive _obj) then { continue };
                
                // === FUEL CHECK ===
                if (fuel _obj < 0.20) then {
                    _lowFuel = true;
                };
                
                // === AMMO CHECK ===
                // Get all magazine ammo counts — if total is 0, aircraft is winchester
                private _magsAmmo = magazinesAmmo _obj;
                private _totalAmmo = 0;
                {
                    _totalAmmo = _totalAmmo + (_x select 1);
                } forEach _magsAmmo;
                
                if (_totalAmmo == 0) then {
                    _noAmmo = true;
                };
                
            } forEach _spawnedObjects;
            
            // Trigger RTB if needed
            if (_lowFuel) then {
                _wingData set ["autoRTB_triggered", true];
                
                ["PRIORITY", format ["LOW FUEL: %1", _wingName],
                    format ["%1 critically low on fuel. Returning to base.", _wingName]
                ] call OpsRoom_fnc_dispatch;
                
                systemChat format ["%1: BINGO FUEL — RTB", _wingName];
                diag_log format ["[OpsRoom] Aircraft Status: %1 low fuel, triggering RTB", _wingId];
                
                [_wingId] call OpsRoom_fnc_landWing;
            };
            
            if (_noAmmo && !_lowFuel) then {
                _wingData set ["autoRTB_triggered", true];
                
                ["PRIORITY", format ["WINCHESTER: %1", _wingName],
                    format ["%1 has expended all ammunition. Returning to base.", _wingName]
                ] call OpsRoom_fnc_dispatch;
                
                systemChat format ["%1: WINCHESTER — RTB", _wingName];
                diag_log format ["[OpsRoom] Aircraft Status: %1 out of ammo, triggering RTB", _wingId];
                
                [_wingId] call OpsRoom_fnc_landWing;
            };
            
        } forEach OpsRoom_AirWings;
    };
};

diag_log "[OpsRoom] Air: Aircraft status monitor initialized";
