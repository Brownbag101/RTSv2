/*
    Air Operations - Mission Scheduler
    
    Background loop that checks all wings for scheduled missions.
    Uses IN-GAME TIME (daytime) not real-world time.
    
    Two scheduling modes:
        1. Delay/Interval: "launch in X minutes, repeat every Y minutes" (in-game time)
        2. Fixed hour: "launch at 0600 every day" (in-game clock)
    
    When a wing is STANDBY and has a schedule due, validates fuel/pilots/crew
    and auto-launches. After landing, repeating schedules are rescheduled
    by fn_landWing.
    
    Called once at init. Runs continuously.
*/

if (!isNil "OpsRoom_Scheduler_Handle") then {
    terminate OpsRoom_Scheduler_Handle;
};

OpsRoom_Scheduler_Handle = [] spawn {
    waitUntil { sleep 1; !isNil "OpsRoom_AirWings" };
    
    diag_log "[OpsRoom] Air: Mission scheduler started (in-game time mode)";
    
    while { true } do {
        sleep 15;  // Check every 15 real seconds
        
        private _currentHour = daytime;  // In-game time (0.0 - 23.99)
        
        {
            private _wingId = _x;
            private _wingData = _y;
            
            private _status = _wingData get "status";
            if (_status != "STANDBY") then { continue };
            
            private _schedule = _wingData getOrDefault ["schedule", createHashMap];
            if (count _schedule == 0) then { continue };
            
            private _enabled = _schedule getOrDefault ["enabled", false];
            if (!_enabled) then { continue };
            
            // Determine if it's time to launch
            private _shouldLaunch = false;
            private _launchAtHour = _schedule getOrDefault ["launchAtHour", -1];
            
            if (_launchAtHour >= 0) then {
                // Fixed hour mode: launch when in-game clock passes the target hour
                // Check within a 0.15 hour window (~9 in-game minutes) to account for check interval
                private _diff = _currentHour - _launchAtHour;
                if (_diff < 0) then { _diff = _diff + 24 };
                
                // Only launch if we're within the window AND haven't already launched this cycle
                private _lastLaunchDay = _schedule getOrDefault ["lastLaunchDay", -1];
                private _currentDay = floor (time / 86400);  // Rough day counter
                
                if (_diff >= 0 && _diff < 0.15 && _currentDay != _lastLaunchDay) then {
                    _shouldLaunch = true;
                    _schedule set ["lastLaunchDay", _currentDay];
                };
            } else {
                // Delay/interval mode: nextLaunchTime is in daytime hours
                private _nextLaunch = _schedule getOrDefault ["nextLaunchTime", -1];
                if (_nextLaunch < 0) then { continue };
                
                // Handle day wraparound (e.g. scheduled at 23:00, now it's 01:00)
                private _diff = _currentHour - _nextLaunch;
                if (_diff < -12) then { _diff = _diff + 24 };
                
                if (_diff >= 0) then {
                    _shouldLaunch = true;
                };
            };
            
            if (!_shouldLaunch) then { continue };
            
            // It's go time — validate
            private _wingName = _wingData get "name";
            private _missionId = _schedule get "missionId";
            private _target = _schedule get "target";
            private _aircraftIds = _wingData get "aircraft";
            
            diag_log format ["[OpsRoom] Scheduler: %1 — launch due at %2 (mission: %3)", _wingName, _currentHour, _missionId];
            
            // Must have aircraft — auto-cancel schedule if wing is empty
            if (count _aircraftIds == 0) then {
                _schedule set ["enabled", false];
                ["PRIORITY", format ["SCHEDULE CANCELLED: %1", _wingName],
                    "All aircraft lost. Automated schedule cancelled."
                ] call OpsRoom_fnc_dispatch;
                diag_log format ["[OpsRoom] Scheduler: %1 — no aircraft, schedule auto-cancelled", _wingName];
                continue;
            };
            
            // Check fuel
            private _fuelCost = (count _aircraftIds) * OpsRoom_Settings_FuelPerSortie;
            if (OpsRoom_Resource_Fuel < _fuelCost) then {
                ["ROUTINE", format ["SCHEDULE: %1", _wingName],
                    format ["Sortie delayed — insufficient fuel. Need %1, have %2.", _fuelCost, OpsRoom_Resource_Fuel]
                ] call OpsRoom_fnc_dispatch;
                continue;
            };
            
            // Check pilots and crew — also clean dead assignments
            private _crewReady = true;
            {
                private _entry = OpsRoom_Hangar get _x;
                if (!isNil "_entry") then {
                    private _pilot = _entry getOrDefault ["assignedPilot", objNull];
                    if (isNull _pilot || {!alive _pilot}) then {
                        // Clear dead pilot assignment
                        _entry set ["assignedPilot", objNull];
                        _entry set ["pilotName", ""];
                        _crewReady = false;
                        diag_log format ["[OpsRoom] Scheduler: Cleared dead pilot from %1", _entry get "displayName"];
                    };
                    
                    private _crewReq = _entry getOrDefault ["crewRequired", 0];
                    private _crew = (_entry getOrDefault ["assignedCrew", []]) select { alive _x };
                    _entry set ["assignedCrew", _crew];  // Clean dead crew
                    if (count _crew < _crewReq) then { _crewReady = false };
                };
            } forEach _aircraftIds;
            
            if (!_crewReady) then {
                // Count consecutive crew failures to avoid spamming
                private _crewFails = _schedule getOrDefault ["crewFailCount", 0];
                _crewFails = _crewFails + 1;
                _schedule set ["crewFailCount", _crewFails];
                
                if (_crewFails >= 3) then {
                    // Auto-cancel after 3 consecutive failures
                    _schedule set ["enabled", false];
                    ["PRIORITY", format ["SCHEDULE CANCELLED: %1", _wingName],
                        "Pilot or crew unavailable after multiple attempts. Schedule cancelled. Assign new crew and reschedule."
                    ] call OpsRoom_fnc_dispatch;
                } else {
                    ["ROUTINE", format ["SCHEDULE: %1", _wingName],
                        "Sortie delayed — pilot or crew not available."
                    ] call OpsRoom_fnc_dispatch;
                };
                continue;
            };
            // Reset crew fail counter on successful check
            _schedule set ["crewFailCount", 0];
            
            // Check aircraft condition
            private _allReady = true;
            {
                private _entry = OpsRoom_Hangar get _x;
                if (!isNil "_entry") then {
                    if ((_entry get "fuel") < 0.2) then { _allReady = false };
                    if ((_entry get "damage") > 0.8) then { _allReady = false };
                };
            } forEach _aircraftIds;
            
            if (!_allReady) then {
                ["ROUTINE", format ["SCHEDULE: %1", _wingName],
                    "Sortie delayed — aircraft require fuel or repair."
                ] call OpsRoom_fnc_dispatch;
                continue;
            };
            
            // All checks passed — set mission and launch
            systemChat format ["[SCHEDULER] %1: Launching scheduled sortie", _wingName];
            
            _wingData set ["mission", _missionId];
            _wingData set ["missionTarget", _target];
            
            // Create target marker
            private _missionData = OpsRoom_AirMissionTypes getOrDefault [_missionId, createHashMap];
            private _missionName = _missionData getOrDefault ["displayName", _missionId];
            
            private _markerName = format ["air_target_%1", _wingId];
            if (markerType _markerName != "") then { deleteMarker _markerName };
            private _marker = createMarker [_markerName, _target];
            _marker setMarkerType "mil_objective";
            _marker setMarkerColor "ColorGreen";
            _marker setMarkerText format ["%1: %2", _wingName, _missionName];
            _marker setMarkerSize [0.7, 0.7];
            _wingData set ["loiterMarker", _markerName];
            
            // Small delay to let mission data settle
            sleep 0.5;
            
            // Handle strike missions
            private _isStrike = _missionData getOrDefault ["isStrike", false];
            if (_isStrike) then {
                private _fahPos = _schedule getOrDefault ["fahPos", []];
                private _attackType = _missionData get "attackType";
                [_wingId] call OpsRoom_fnc_launchWing;
                [_wingId, _target, _attackType, _fahPos] spawn {
                    params ["_wId", "_tgt", "_atkType", "_fah"];
                    
                    // Wait for wing to be airborne
                    waitUntil { sleep 5;
                        private _wd = OpsRoom_AirWings get _wId;
                        if (isNil "_wd") exitWith { true };
                        (_wd get "status") == "AIRBORNE"
                    };
                    
                    // Wait for aircraft to reach target area (within 3km)
                    // Use a generous altitude check too — must be above 50m
                    private _timeout = time + 600;
                    waitUntil { sleep 5;
                        if (time > _timeout) exitWith { true };
                        private _wd = OpsRoom_AirWings get _wId;
                        if (isNil "_wd") exitWith { true };
                        if ((_wd get "status") != "AIRBORNE") exitWith { true };
                        private _so = _wd get "spawnedObjects";
                        private _ready = false;
                        {
                            if (_x isKindOf "Air" && {alive _x}) then {
                                if ((_x distance2D _tgt) < 3000 && {(getPosATL _x) select 2 > 50}) exitWith {
                                    _ready = true;
                                };
                            };
                        } forEach _so;
                        _ready
                    };
                    
                    // Verify wing still valid
                    private _wd2 = OpsRoom_AirWings get _wId;
                    if (isNil "_wd2") exitWith {};
                    if ((_wd2 get "status") != "AIRBORNE") exitWith {};
                    
                    sleep 2;
                    
                    // Call executeAirStrike with wing filter — same as manual flow
                    diag_log format ["[OpsRoom] Scheduler: Aircraft at target, executing %1 for %2", _atkType, _wId];
                    [objNull, _tgt, _atkType, _fah, _wId] call OpsRoom_fnc_executeAirStrike;
                };
            } else {
                [_wingId] call OpsRoom_fnc_launchWing;
            };
            
            ["PRIORITY", format ["SCHEDULED: %1", _wingName],
                format ["%1 auto-launched for %2 sortie.", _wingName, _missionName]
            ] call OpsRoom_fnc_dispatch;
            
            // One-shot delay mode: disable schedule
            if (_launchAtHour < 0 && {(_schedule getOrDefault ["interval", 0]) == 0}) then {
                _schedule set ["enabled", false];
            };
            
        } forEach OpsRoom_AirWings;
    };
};

diag_log "[OpsRoom] Air: Mission scheduler initialized";
