/*
    Air Operations - Land Wing
    
    Orders all aircraft in a wing to return to base.
    LAND waypoint on runway marker - ARMA handles the approach and landing.
    After landing, aircraft are despawned and returned to hangar pool.
    
    Parameters:
        _wingId - Wing ID to land
    
    Returns:
        Boolean - true if RTB initiated
*/
params ["_wingId"];

private _wingData = OpsRoom_AirWings get _wingId;
if (isNil "_wingData") exitWith {
    systemChat "Wing not found";
    false
};

private _wingName = _wingData get "name";
private _status = _wingData get "status";

// Can only land from AIRBORNE
if (_status != "AIRBORNE") exitWith {
    systemChat format ["%1 is %2 - cannot land", _wingName, _status];
    false
};

// Check runway marker
if (markerType "OpsRoom_runway" == "") exitWith {
    systemChat "No OpsRoom_runway marker placed";
    false
};

private _runwayPos = getMarkerPos "OpsRoom_runway";
private _spawnedObjects = _wingData get "spawnedObjects";
private _aircraftIds = _wingData get "aircraft";

// Set wing status
_wingData set ["status", "RTB"];

// Disable air follow camera if tracking an aircraft in this wing
if (!isNil "OpsRoom_AirFollowCameraActive" && {OpsRoom_AirFollowCameraActive}) then {
    private _so = _wingData get "spawnedObjects";
    if (!isNull OpsRoom_AirFollowCameraTarget && {OpsRoom_AirFollowCameraTarget in _so}) then {
        OpsRoom_AirFollowCameraActive = false;
        OpsRoom_AirFollowCameraTarget = objNull;
        systemChat "Air follow camera: DISABLED (wing RTB)";
    };
};

// Dispatch
["PRIORITY", format ["%1 returning to base", _wingName],
    format ["%1 ordered to RTB. Aircraft inbound.", _wingName]
] call OpsRoom_fnc_dispatch;

// Issue RTB waypoints to all spawned aircraft
// Two-phase: MOVE to our runway area first, then land command on arrival
// This prevents ARMA from landing at the nearest enemy airfield
{
    private _obj = _x;
    if (_obj isKindOf "Air" && {alive _obj}) then {
        private _driver = driver _obj;
        if (!isNull _driver) then {
            private _group = group _driver;
            
            // Clear existing waypoints
            while {count waypoints _group > 0} do {
                deleteWaypoint [_group, 0];
            };
            
            // Waypoint 1: Fly to our runway area
            private _wp = _group addWaypoint [_runwayPos, 0];
            _wp setWaypointType "MOVE";
            _wp setWaypointSpeed "NORMAL";
            _wp setWaypointBehaviour "CARELESS";
            _wp setWaypointCombatMode "BLUE";
            
            // Reduce altitude for approach
            _obj flyInHeight 200;
        };
    };
} forEach _spawnedObjects;

// Monitor approach — issue land command only when aircraft are near OUR runway
[_spawnedObjects, _runwayPos] spawn {
    params ["_objs", "_rwyPos"];
    private _landed = [];
    while { count _landed < ({_x isKindOf "Air" && alive _x} count _objs) } do {
        {
            if (_x isKindOf "Air" && {alive _x} && {!(_x in _landed)}) then {
                if ((_x distance2D _rwyPos) < 1500) then {
                    _x land "LAND";
                    _x flyInHeight 100;
                    _landed pushBack _x;
                };
            };
        } forEach _objs;
        sleep 3;
    };
};

systemChat format ["%1 returning to base", _wingName];

// Monitor landing and clean up
[_wingId, _spawnedObjects, _aircraftIds, _runwayPos] spawn {
    params ["_wingId", "_spawnedObjects", "_aircraftIds", "_runwayPos"];
    
    private _wingData = OpsRoom_AirWings get _wingId;
    if (isNil "_wingData") exitWith {};
    
    private _wingName = _wingData get "name";
    
    // Wait for aircraft to land or timeout after 5 minutes
    private _timeout = time + 300;
    private _allLanded = false;
    
    while {!_allLanded && time < _timeout} do {
        _allLanded = true;
        
        {
            private _obj = _x;
            if (_obj isKindOf "Air" && {alive _obj}) then {
                // Check if aircraft has landed (speed near zero and near ground)
                private _speed = speed _obj;
                private _altAGL = (getPosATL _obj) select 2;
                
                if (_speed > 5 || _altAGL > 5) then {
                    _allLanded = false;
                };
            };
        } forEach _spawnedObjects;
        
        sleep 3;
    };
    
    // Short delay after landing
    sleep 5;
    
    // Update hangar entries - recover fuel/ammo state from live aircraft
    private _objIndex = 0;
    {
        private _hangarId = _x;
        private _entry = OpsRoom_Hangar get _hangarId;
        
        if (!isNil "_entry") then {
            // Find corresponding spawned aircraft
            private _vehicle = objNull;
            {
                if (_x isKindOf "Air") then {
                    _vehicle = _x;
                };
            } forEach (_spawnedObjects select [_objIndex, 2]);
            
            if (!isNull _vehicle && alive _vehicle) then {
                // Recover state from live aircraft
                _entry set ["fuel", fuel _vehicle];
                _entry set ["damage", damage _vehicle];
                _entry set ["status", "HANGARED"];
            } else {
                // Aircraft destroyed in flight
                _entry set ["status", "DESTROYED"];
                _entry set ["damage", 1];
                
                ["FLASH", format ["Aircraft lost: %1", _entry get "displayName"],
                    format ["%1 from %2 did not return.", _entry get "displayName", _wingName]
                ] call OpsRoom_fnc_dispatch;
            };
            
            _objIndex = _objIndex + 2;  // Skip pilot object
        };
    } forEach _aircraftIds;
    
    // Disable anti-eject protection so crew can be extracted
    {
        if (_x isKindOf "Air" && {alive _x}) then {
            _x setVariable ["OpsRoom_LandingInProgress", true];
        };
    } forEach _spawnedObjects;
    
    // Return assigned pilot AND crew units to ready point before deleting
    private _readyPos = if (markerType "OpsRoom_pilot_ready" != "") then {
        getMarkerPos "OpsRoom_pilot_ready"
    } else {
        if (markerType "OpsRoom_hangar" != "") then {
            getMarkerPos "OpsRoom_hangar"
        } else {
            _runwayPos
        };
    };
    
    {
        private _hId = _x;
        private _entry = OpsRoom_Hangar get _hId;
        if (!isNil "_entry") then {
            // Recover pilot
            private _assignedPilot = _entry getOrDefault ["assignedPilot", objNull];
            if (!isNull _assignedPilot && {alive _assignedPilot}) then {
                if (vehicle _assignedPilot != _assignedPilot) then { moveOut _assignedPilot };
                _assignedPilot setPos _readyPos;
                private _pilotGrp = createGroup [independent, true];
                [_assignedPilot] joinSilent _pilotGrp;
                _spawnedObjects = _spawnedObjects - [_assignedPilot];
                diag_log format ["[OpsRoom] Air: Pilot %1 returned to ready point", name _assignedPilot];
            };
            
            // Recover assigned crew
            private _assignedCrew = _entry getOrDefault ["assignedCrew", []];
            {
                if (!isNull _x && {alive _x}) then {
                    if (vehicle _x != _x) then { moveOut _x };
                    _x setPos (_readyPos vectorAdd [random 3 - 1.5, random 3 - 1.5, 0]);
                    private _crewGrp = createGroup [independent, true];
                    [_x] joinSilent _crewGrp;
                    _spawnedObjects = _spawnedObjects - [_x];
                    diag_log format ["[OpsRoom] Air: Crew %1 returned to ready point", name _x];
                };
            } forEach _assignedCrew;
        };
    } forEach _aircraftIds;
    
    // Delete all remaining spawned objects (aircraft + AI crew)
    {
        if (!isNull _x) then {
            deleteVehicle _x;
        };
    } forEach _spawnedObjects;
    
    // Calculate flight hours for this sortie
    private _launchTime = _wingData getOrDefault ["launchTime", time];
    private _flightMinutes = (time - _launchTime) / 60;
    private _flightHours = _flightMinutes / 60;
    
    // Add flight hours to each aircraft
    {
        private _entry = OpsRoom_Hangar get _x;
        if (!isNil "_entry") then {
            private _currentHours = _entry getOrDefault ["flightHours", 0];
            _entry set ["flightHours", _currentHours + _flightHours];
        };
    } forEach _aircraftIds;
    
    // Process photo recon intel if applicable
    private _mission = _wingData getOrDefault ["mission", ""];
    if (_mission == "recon_photo_high" || _mission == "recon_photo_low") then {
        [_wingId] call OpsRoom_fnc_processReconPhotos;
    };
    
    // Clean up target marker (Fix #11: ensure both naming patterns are cleaned)
    private _markerName = _wingData getOrDefault ["loiterMarker", ""];
    if (_markerName != "" && {markerType _markerName != ""}) then {
        deleteMarker _markerName;
    };
    // Fallback: also try the standard naming pattern
    private _fallbackMarker = format ["air_target_%1", _wingId];
    if (_fallbackMarker != _markerName && {markerType _fallbackMarker != ""}) then {
        deleteMarker _fallbackMarker;
    };
    
    // Reschedule repeating missions before resetting (in-game time)
    private _schedule = _wingData getOrDefault ["schedule", createHashMap];
    if (count _schedule > 0 && {_schedule getOrDefault ["enabled", false]}) then {
        private _interval = _schedule getOrDefault ["interval", 0];
        private _launchAtHour = _schedule getOrDefault ["launchAtHour", -1];
        
        if (_interval > 0) then {
            // Interval mode: next launch = now + interval (in daytime hours)
            private _intervalHours = _interval / 3600;
            private _nextHour = daytime + _intervalHours;
            if (_nextHour >= 24) then { _nextHour = _nextHour - 24 };
            _schedule set ["nextLaunchTime", _nextHour];
            
            private _missionId = _schedule get "missionId";
            private _mData = OpsRoom_AirMissionTypes getOrDefault [_missionId, createHashMap];
            private _mName = _mData getOrDefault ["displayName", _missionId];
            private _mins = round (_interval / 60);
            private _nextH = floor _nextHour;
            private _nextM = round ((_nextHour - _nextH) * 60);
            private _nextHStr = if (_nextH < 10) then { format ["0%1", _nextH] } else { str _nextH };
            private _nextMStr = if (_nextM < 10) then { format ["0%1", _nextM] } else { str _nextM };
            ["ROUTINE", format ["SCHEDULE: %1", _wingName],
                format ["%1 next %2 sortie in %3 min (at %4:%5).", _wingName, _mName, _mins, _nextHStr, _nextMStr]
            ] call OpsRoom_fnc_dispatch;
            diag_log format ["[OpsRoom] Scheduler: %1 rescheduled — next launch at daytime %2 (interval: %3 min)", _wingId, _nextHour, _mins];
        };
        // Fixed hour mode: no reschedule needed — scheduler checks clock daily
    } else {
        // One-shot or disabled schedule: clear the schedule entirely
        // so manual strikes on this wing don't incorrectly trigger auto-RTB
        if (count _schedule > 0 && {!(_schedule getOrDefault ["enabled", false])}) then {
            _wingData set ["schedule", createHashMap];
            diag_log format ["[OpsRoom] Scheduler: %1 one-shot schedule cleared after landing", _wingId];
        };
    };
    
    // Reset wing status
    _wingData set ["status", "STANDBY"];
    _wingData set ["spawnedObjects", []];
    _wingData set ["mission", ""];
    _wingData set ["missionTarget", []];
    _wingData set ["loiterMarker", ""];
    _wingData set ["autoRTB_triggered", false];
    
    // Remove destroyed aircraft from wing
    private _survivingAircraft = [];
    {
        private _entry = OpsRoom_Hangar get _x;
        if (!isNil "_entry") then {
            if ((_entry get "status") != "DESTROYED") then {
                _survivingAircraft pushBack _x;
            } else {
                // Remove destroyed aircraft from hangar
                [_x, "DESTROYED"] call OpsRoom_fnc_removeFromHangar;
            };
        };
    } forEach _aircraftIds;
    _wingData set ["aircraft", _survivingAircraft];
    
    ["ROUTINE", format ["%1 landed", _wingName],
        format ["%1 has returned to base. %2 aircraft recovered.", _wingName, count _survivingAircraft]
    ] call OpsRoom_fnc_dispatch;
    
    systemChat format ["%1 - all aircraft recovered", _wingName];
    
    diag_log format ["[OpsRoom] Air: Wing %1 landed, %2 survived", _wingId, count _survivingAircraft];
};

true
