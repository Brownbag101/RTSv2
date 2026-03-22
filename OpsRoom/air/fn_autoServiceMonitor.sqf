/*
    Air Operations - Auto Service Monitor
    
    Background loop that automatically repairs, rearms, and refuels
    HANGARED aircraft when the corresponding toggle is enabled.
    
    Checks every 30 seconds (configurable via OpsRoom_Settings_AutoServiceInterval).
    Only services aircraft that need it. Costs resources as normal.
    
    Toggles:
        OpsRoom_AutoRepair  - Auto-repair damaged aircraft
        OpsRoom_AutoRearm   - Auto-rearm aircraft with low ammo
        OpsRoom_AutoRefuel  - Auto-refuel aircraft with low fuel
    
    Called once at init. Runs continuously.
*/

// Initialize toggles if not set
if (isNil "OpsRoom_AutoRepair") then { OpsRoom_AutoRepair = false };
if (isNil "OpsRoom_AutoRearm") then { OpsRoom_AutoRearm = false };
if (isNil "OpsRoom_AutoRefuel") then { OpsRoom_AutoRefuel = false };

if (!isNil "OpsRoom_AutoService_Handle") then {
    terminate OpsRoom_AutoService_Handle;
};

OpsRoom_AutoService_Handle = [] spawn {
    waitUntil { sleep 1; !isNil "OpsRoom_Hangar" };
    
    diag_log "[OpsRoom] Air: Auto-service monitor started";
    
    private _interval = if (!isNil "OpsRoom_Settings_AutoServiceInterval") then {
        OpsRoom_Settings_AutoServiceInterval
    } else {
        30
    };
    
    while { true } do {
        sleep _interval;
        
        // Skip if all toggles are off
        if (!OpsRoom_AutoRepair && !OpsRoom_AutoRearm && !OpsRoom_AutoRefuel) then { continue };
        
        private _serviced = 0;
        
        {
            private _hangarId = _x;
            private _entry = _y;
            
            // Only service hangared aircraft
            if ((_entry get "status") != "HANGARED") then { continue };
            
            // Auto-repair
            if (OpsRoom_AutoRepair && {(_entry get "damage") > 0}) then {
                private _result = [_hangarId, "repair"] call OpsRoom_fnc_repairAircraft;
                if (_result) then { _serviced = _serviced + 1 };
            };
            
            // Auto-rearm
            if (OpsRoom_AutoRearm && {(_entry get "ammo") < 1}) then {
                private _result = [_hangarId, "rearm"] call OpsRoom_fnc_repairAircraft;
                if (_result) then { _serviced = _serviced + 1 };
            };
            
            // Auto-refuel
            if (OpsRoom_AutoRefuel && {(_entry get "fuel") < 1}) then {
                private _result = [_hangarId, "refuel"] call OpsRoom_fnc_repairAircraft;
                if (_result) then { _serviced = _serviced + 1 };
            };
            
        } forEach OpsRoom_Hangar;
        
        if (_serviced > 0) then {
            diag_log format ["[OpsRoom] Auto-service: %1 service action(s) performed", _serviced];
        };
    };
};

diag_log "[OpsRoom] Air: Auto-service monitor initialized";
