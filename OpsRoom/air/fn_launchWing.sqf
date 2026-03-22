/*
    Air Operations - Launch Wing
    
    Spawns all aircraft in a wing at the runway marker, creates AI pilots,
    assigns initial waypoint to loiter point, and lets ARMA handle takeoff.
    
    Parameters:
        _wingId - Wing ID to launch
    
    Returns:
        Boolean - true if launch initiated
*/
params ["_wingId"];

private _wingData = OpsRoom_AirWings get _wingId;
if (isNil "_wingData") exitWith {
    systemChat "Wing not found";
    false
};

private _wingName = _wingData get "name";
private _status = _wingData get "status";

// Can only launch from STANDBY
if (_status != "STANDBY") exitWith {
    systemChat format ["%1 is %2 - cannot launch", _wingName, _status];
    false
};

private _aircraftIds = _wingData get "aircraft";
if (count _aircraftIds == 0) exitWith {
    systemChat format ["%1 has no aircraft assigned", _wingName];
    false
};

// Check runway marker exists
if (markerType "OpsRoom_runway" == "") exitWith {
    systemChat "No OpsRoom_runway marker placed in editor";
    false
};

// Validate all aircraft: fuel > 20%, damage < 80%, pilot assigned
private _failedChecks = [];
{
    private _entry = OpsRoom_Hangar get _x;
    if (!isNil "_entry") then {
        if ((_entry get "fuel") < 0.2) then {
            _failedChecks pushBack format ["%1: low fuel", _entry get "displayName"];
        };
        if ((_entry get "damage") > 0.8) then {
            _failedChecks pushBack format ["%1: too damaged", _entry get "displayName"];
        };
        // Check pilot is assigned (clean dead pilots)
        private _assignedPilot = _entry getOrDefault ["assignedPilot", objNull];
        if (!isNull _assignedPilot && {!alive _assignedPilot}) then {
            // Pilot is dead — clear assignment
            _entry set ["assignedPilot", objNull];
            _entry set ["pilotName", ""];
            _assignedPilot = objNull;
            diag_log format ["[OpsRoom] Air: Cleared dead pilot from %1", _entry get "displayName"];
        };
        if (isNull _assignedPilot) then {
            _failedChecks pushBack format ["%1: no pilot assigned", _entry get "displayName"];
        };
        // Check crew is full (for multi-crew aircraft)
        private _crewRequired = _entry getOrDefault ["crewRequired", 0];
        private _assignedCrew = _entry getOrDefault ["assignedCrew", []];
        // Clean dead crew
        _assignedCrew = _assignedCrew select { alive _x };
        _entry set ["assignedCrew", _assignedCrew];
        if (count _assignedCrew < _crewRequired) then {
            _failedChecks pushBack format ["%1: crew incomplete (%2/%3)", _entry get "displayName", count _assignedCrew, _crewRequired];
        };
    };
} forEach _aircraftIds;

if (count _failedChecks > 0) exitWith {
    systemChat format ["Launch aborted: %1", _failedChecks joinString ", "];
    false
};

// Check fuel resources
private _fuelCost = (count _aircraftIds) * OpsRoom_Settings_FuelPerSortie;
if (OpsRoom_Resource_Fuel < _fuelCost) exitWith {
    systemChat format ["Insufficient fuel. Need %1, have %2", _fuelCost, OpsRoom_Resource_Fuel];
    false
};

// Deduct fuel
OpsRoom_Resource_Fuel = OpsRoom_Resource_Fuel - _fuelCost;
[] call OpsRoom_fnc_updateResources;

// Set wing status
_wingData set ["status", "LAUNCHING"];

// Delete preview aircraft if any
if (!isNull OpsRoom_HangarPreview) then {
    deleteVehicle OpsRoom_HangarPreview;
    OpsRoom_HangarPreview = objNull;
};

// Get spawn and loiter positions
private _runwayPos = getMarkerPos "OpsRoom_runway";
private _runwayDir = markerDir "OpsRoom_runway";

// Determine loiter point - use mission target if set, otherwise default
private _loiterPos = _wingData get "missionTarget";
if (count _loiterPos == 0) then {
    // Check for default loiter marker, otherwise offset from runway
    if (markerType "OpsRoom_loiter_default" != "") then {
        _loiterPos = getMarkerPos "OpsRoom_loiter_default";
    } else {
        // 3km in front of runway direction
        _loiterPos = _runwayPos vectorAdd [3000 * sin _runwayDir, 3000 * cos _runwayDir, 0];
    };
};

// Get mission params for waypoint configuration
private _mission = _wingData get "mission";
private _missionParams = if (_mission != "") then {
    OpsRoom_AirMissionTypes getOrDefault [_mission, createHashMap]
} else {
    createHashMap
};

private _altitude = _missionParams getOrDefault ["altitude", 300];
private _speed = _missionParams getOrDefault ["speed", "NORMAL"];
private _combatMode = _missionParams getOrDefault ["combatMode", "YELLOW"];
private _behaviour = _missionParams getOrDefault ["behaviour", "AWARE"];
private _wpType = _missionParams getOrDefault ["waypointType", "LOITER"];
private _loiterRadius = _missionParams getOrDefault ["loiterRadius", 1000];

// Dispatch notification
["PRIORITY", format ["%1 launching", _wingName],
    format ["%1 aircraft preparing for takeoff.", count _aircraftIds]
] call OpsRoom_fnc_dispatch;

// Spawn aircraft sequentially
private _spawnedObjects = [];

[_wingId, _aircraftIds, _runwayPos, _runwayDir, _loiterPos, _altitude, _speed, _combatMode, _behaviour, _wpType, _loiterRadius, _spawnedObjects] spawn {
    params ["_wingId", "_aircraftIds", "_runwayPos", "_runwayDir", "_loiterPos", "_altitude", "_speed", "_combatMode", "_behaviour", "_wpType", "_loiterRadius", "_spawnedObjects"];
    
    private _wingData = OpsRoom_AirWings get _wingId;
    if (isNil "_wingData") exitWith {};
    
    {
        private _hangarId = _x;
        private _entry = OpsRoom_Hangar get _hangarId;
        
        if (!isNil "_entry") then {
            private _className = _entry get "className";
            private _displayName = _entry get "displayName";
            
            // Spawn aircraft at staggered position along runway (Fix #5: prevent collision)
            private _spawnOffset = _forEachIndex * 30;  // 30m spacing per aircraft
            private _spawnPos = _runwayPos vectorAdd [_spawnOffset * sin _runwayDir, _spawnOffset * cos _runwayDir, 0];
            
            private _vehicle = createVehicle [_className, _spawnPos, [], 0, "NONE"];
            _vehicle setPos _spawnPos;
            _vehicle setDir _runwayDir;
            
            // Apply aircraft state
            _vehicle setFuel (_entry get "fuel");
            _vehicle setDamage (_entry get "damage");
            
            // Prevent aircraft from moving until crew boards
            _vehicle setFuel 0;
            _vehicle engineOn false;
            
            // Create pilot group (for waypoints after takeoff)
            private _pilotGroup = createGroup [independent, true];
            private _pilot = objNull;
            
            // Get assigned pilot
            private _assignedPilotUnit = _entry getOrDefault ["assignedPilot", objNull];
            
            if (!isNull _assignedPilotUnit && {alive _assignedPilotUnit}) then {
                _pilot = _assignedPilotUnit;
                [_pilot] joinSilent _pilotGroup;
                _pilot setUnitAbility OpsRoom_Settings_PilotSkill;
                _entry set ["pilotName", name _pilot];
                
                // Remove from Zeus editable (player shouldn't directly control pilots)
                private _curator = getAssignedCuratorLogic player;
                if (!isNull _curator) then {
                    _curator removeCuratorEditableObjects [[_pilot], false];
                };
                
                // Order pilot to RUN to aircraft and get in
                _pilot setSpeedMode "FULL";
                _pilot doMove _spawnPos;
            } else {
                // Fallback: create AI pilot (should not happen due to launch validation)
                _pilot = _pilotGroup createUnit ["I_Pilot_F", _spawnPos, [], 0, "NONE"];
                _pilot moveInDriver _vehicle;
                _pilot setUnitAbility OpsRoom_Settings_PilotSkill;
                _entry set ["pilotName", name _pilot];
            };
            
            // Board assigned crew into turret seats
            private _assignedCrew = _entry getOrDefault ["assignedCrew", []];
            private _crewToBoard = [];  // [unit, turretPath]
            private _turrets = fullCrew [_vehicle, "", true];
            private _crewIndex = 0;
            {
                _x params ["_unit", "_role", "_cargoIndex", "_turretPath", "_isPersonTurret"];
                if (_role != "driver" && {_role != "cargo"} && {isNull _unit}) then {
                    private _crewman = objNull;
                    
                    // Use assigned crew if available
                    if (_crewIndex < count _assignedCrew) then {
                        _crewman = _assignedCrew select _crewIndex;
                        _crewIndex = _crewIndex + 1;
                        
                        if (!isNull _crewman && {alive _crewman}) then {
                            [_crewman] joinSilent _pilotGroup;
                            _crewman setUnitAbility OpsRoom_Settings_PilotSkill;
                        } else {
                            _crewman = objNull;  // Dead crew — will be handled below
                        };
                    };
                    
                    // Fallback: should not happen with launch validation, but safety net
                    if (isNull _crewman) then {
                        _crewman = _pilotGroup createUnit ["I_Pilot_F", [0,0,0], [], 0, "NONE"];
                        _crewman setUnitAbility OpsRoom_Settings_PilotSkill;
                    };
                    
                    _spawnedObjects pushBack _crewman;
                    
                    // Order crew to run to aircraft
                    _crewman setSpeedMode "FULL";
                    _crewman doMove _spawnPos;
                    _crewToBoard pushBack [_crewman, _turretPath];
                    
                    // Remove from Zeus editable
                    private _curator2 = getAssignedCuratorLogic player;
                    if (!isNull _curator2) then {
                        _curator2 removeCuratorEditableObjects [[_crewman], false];
                    };
                };
            } forEach _turrets;
            
            // Wait for pilot to reach the aircraft (timeout 30s)
            private _boardTimeout = diag_tickTime + 30;
            if (!isNull _assignedPilotUnit && {alive _assignedPilotUnit}) then {
                waitUntil {
                    sleep 0.3;
                    (_pilot distance _vehicle < 10) || (diag_tickTime > _boardTimeout) || (!alive _pilot)
                };
                
                // Small pause for ARMA to settle the unit position
                sleep 0.2;
                
                // Clear any pending doMove then board immediately
                if (alive _pilot) then {
                    _pilot doWatch objNull;
                    _pilot doFollow _pilot;
                    sleep 0.1;
                    _pilot moveInDriver _vehicle;
                };
            };
            
            // Wait for crew to reach and board (timeout 30s from now)
            _boardTimeout = diag_tickTime + 30;
            {
                _x params ["_crewUnit", "_turretPath"];
                waitUntil {
                    sleep 0.3;
                    (_crewUnit distance _vehicle < 10) || (diag_tickTime > _boardTimeout) || (!alive _crewUnit)
                };
                sleep 0.2;
                if (alive _crewUnit) then {
                    _crewUnit doWatch objNull;
                    _crewUnit doFollow _crewUnit;
                    sleep 0.1;
                    _crewUnit moveInTurret [_vehicle, _turretPath];
                };
            } forEach _crewToBoard;
            
            // Restore fuel now that everyone is on board
            _vehicle setFuel (_entry get "fuel");
            
            // Disable targeting by default — only engage if fired upon
            // Exception: scramble missions need full targeting to engage enemy aircraft
            private _mission = (OpsRoom_AirWings get _wingId) getOrDefault ["mission", ""];
            if (_mission != "scramble") then {
                { _x disableAI "TARGET"; _x disableAI "AUTOTARGET" } forEach (units _pilotGroup);
            } else {
                diag_log format ["[OpsRoom] Air: Scramble — targeting AI ENABLED for %1", _displayName];
            };
            
            // Check if this is a sea lane patrol — use sequential waypoints along the lane
            private _missionFull = (OpsRoom_AirWings get _wingId) getOrDefault ["mission", ""];
            private _mParamsFull = OpsRoom_AirMissionTypes getOrDefault [_missionFull, createHashMap];
            private _isSeaLanePatrol = _mParamsFull getOrDefault ["isSeaLanePatrol", false];
            
            if (_isSeaLanePatrol) then {
                // Find the closest sea lane to the mission target
                private _bestLane = "";
                private _bestDist = 999999;
                {
                    private _lData = _y;
                    private _oPos = _lData get "originPos";
                    private _d = _loiterPos distance2D _oPos;
                    if (_d < _bestDist) then { _bestDist = _d; _bestLane = _x };
                } forEach OpsRoom_SeaLanes;
                
                private _laneData = OpsRoom_SeaLanes getOrDefault [_bestLane, createHashMap];
                
                if (count _laneData > 0) then {
                    private _slOriginPos = _laneData get "originPos";
                    private _routesMap = _laneData get "routes";
                    
                    // Collect ALL route waypoints from all port routes for this lane
                    // Aircraft patrols the entire lane area by visiting all route waypoints
                    private _allWaypoints = [];
                    {
                        private _portWps = _y;
                        { if !(_x in _allWaypoints) then { _allWaypoints pushBack _x } } forEach _portWps;
                    } forEach _routesMap;
                    
                    // Build patrol route: origin → all unique waypoints
                    private _fullRoute = [_slOriginPos] + _allWaypoints;
                    
                    if (count _fullRoute >= 2) then {
                        // Create sequential MOVE waypoints
                        {
                            private _slWp = _pilotGroup addWaypoint [_x, 0];
                            _slWp setWaypointType "MOVE";
                            _slWp setWaypointSpeed _speed;
                            _slWp setWaypointBehaviour _behaviour;
                            _slWp setWaypointCombatMode _combatMode;
                        } forEach _fullRoute;
                        
                        // CYCLE waypoint to loop the patrol
                        private _cycleWp = _pilotGroup addWaypoint [_slOriginPos, 0];
                        _cycleWp setWaypointType "CYCLE";
                        _cycleWp setWaypointSpeed _speed;
                        _cycleWp setWaypointBehaviour _behaviour;
                        
                        diag_log format ["[OpsRoom] Air: Sea lane patrol for %1 on %2 (%3 waypoints)", _displayName, _bestLane, count _fullRoute];
                    } else {
                        // Only origin, no waypoints — loiter at origin
                        private _wp = _pilotGroup addWaypoint [_slOriginPos, 0];
                        _wp setWaypointType "LOITER";
                        _wp setWaypointSpeed _speed;
                        _wp setWaypointBehaviour _behaviour;
                        _wp setWaypointCombatMode _combatMode;
                        _wp setWaypointLoiterType "CIRCLE_L";
                        _wp setWaypointLoiterRadius _loiterRadius;
                    };
                } else {
                    // Fallback to loiter if no lane found
                    private _wp = _pilotGroup addWaypoint [_loiterPos, 0];
                    _wp setWaypointType "LOITER";
                    _wp setWaypointSpeed _speed;
                    _wp setWaypointBehaviour _behaviour;
                    _wp setWaypointCombatMode _combatMode;
                    _wp setWaypointLoiterType "CIRCLE_L";
                    _wp setWaypointLoiterRadius _loiterRadius;
                };
            } else {
                // Standard waypoint (loiter, SAD, MOVE, etc.)
                private _wp = _pilotGroup addWaypoint [_loiterPos, 0];
                _wp setWaypointType _wpType;
                _wp setWaypointSpeed _speed;
                _wp setWaypointBehaviour _behaviour;
                _wp setWaypointCombatMode _combatMode;
                
                if (_wpType == "LOITER") then {
                    _wp setWaypointLoiterType "CIRCLE_L";
                    _wp setWaypointLoiterRadius _loiterRadius;
                };
            };
            
            // Set flight altitude and ensure engine starts
            _vehicle flyInHeight _altitude;
            _vehicle engineOn true;
            
            // Prevent AI ejection — disable all flee/eject AI behaviours
            // and add GetOut EH that forces crew back in immediately
            {
                _x disableAI "AUTOCOMBAT";
                _x disableAI "FSM";
                _x disableAI "COVER";
                _x disableAI "SUPPRESSION";
            } forEach (units _pilotGroup);
            
            // Nuclear option: GetOut event handler — if anyone exits, force them back in
            _vehicle addEventHandler ["GetOut", {
                params ["_vehicle", "_role", "_unit", "_turret"];
                if (!alive _vehicle) exitWith {};  // Don't re-board destroyed aircraft
                if (_vehicle getVariable ["OpsRoom_LandingInProgress", false]) exitWith {};  // Allow exit during landing recovery
                
                diag_log format ["[OpsRoom] Air: EJECT BLOCKED — %1 tried to exit %2 (role: %3)", name _unit, typeOf _vehicle, _role];
                
                // Force them back in on next frame
                [_unit, _vehicle, _role, _turret] spawn {
                    params ["_unit", "_vehicle", "_role", "_turret"];
                    sleep 0.01;
                    if (!alive _unit || !alive _vehicle) exitWith {};
                    if (_role == "driver") then {
                        _unit moveInDriver _vehicle;
                    } else {
                        if (count _turret > 0) then {
                            _unit moveInTurret [_vehicle, _turret];
                        } else {
                            _unit moveInDriver _vehicle;
                        };
                    };
                    diag_log format ["[OpsRoom] Air: Forced %1 back into %2", name _unit, typeOf _vehicle];
                };
            }];
            
            diag_log format ["[OpsRoom] Air: Anti-eject protection on %1", _displayName];
            
            // Track spawned objects
            _spawnedObjects pushBack _vehicle;
            _spawnedObjects pushBack _pilot;
            
            // Fix #1: Killed event handler — remove destroyed aircraft from wing
            _vehicle setVariable ["OpsRoom_HangarId", _hangarId];
            _vehicle setVariable ["OpsRoom_WingId", _wingId];
            _vehicle addEventHandler ["Killed", {
                params ["_vehicle"];
                private _hId = _vehicle getVariable ["OpsRoom_HangarId", ""];
                private _wId = _vehicle getVariable ["OpsRoom_WingId", ""];
                
                if (_hId != "") then {
                    private _entry = OpsRoom_Hangar get _hId;
                    if (!isNil "_entry") then {
                        private _dName = _entry get "displayName";
                        _entry set ["status", "DESTROYED"];
                        _entry set ["damage", 1];
                        
                        ["FLASH", format ["Aircraft lost: %1", _dName],
                            format ["%1 shot down. Aircraft destroyed.", _dName]
                        ] call OpsRoom_fnc_dispatch;
                        
                        diag_log format ["[OpsRoom] Air: %1 (%2) destroyed in flight", _dName, _hId];
                    };
                };
                
                // Remove from wing's aircraft list
                if (_wId != "") then {
                    private _wData = OpsRoom_AirWings get _wId;
                    if (!isNil "_wData") then {
                        private _acList = _wData get "aircraft";
                        _acList = _acList - [_hId];
                        _wData set ["aircraft", _acList];
                        
                        // Also remove from spawnedObjects
                        private _so = _wData get "spawnedObjects";
                        _so = _so - [_vehicle];
                        // Remove crew too
                        { _so = _so - [_x] } forEach (crew _vehicle);
                        _wData set ["spawnedObjects", _so];
                        
                        // Remove from hangar entirely (skip dispatch — we already sent one above)
                        OpsRoom_Hangar deleteAt _hId;
                        
                        // If no aircraft left in wing, reset wing to STANDBY
                        if (count _acList == 0) then {
                            private _wName = _wData get "name";
                            
                            // Delete all remaining spawned objects (dead crew etc)
                            { if (!isNull _x) then { deleteVehicle _x } } forEach (_wData get "spawnedObjects");
                            
                            // Clean up markers
                            private _marker = _wData getOrDefault ["loiterMarker", ""];
                            if (_marker != "" && {markerType _marker != ""}) then { deleteMarker _marker };
                            private _fb = format ["air_target_%1", _wId];
                            if (markerType _fb != "") then { deleteMarker _fb };
                            
                            _wData set ["status", "STANDBY"];
                            _wData set ["spawnedObjects", []];
                            _wData set ["mission", ""];
                            _wData set ["missionTarget", []];
                            _wData set ["loiterMarker", ""];
                            _wData set ["autoRTB_triggered", false];
                            
                            ["FLASH", format ["%1 wiped out", _wName],
                                format ["All aircraft in %1 destroyed. Wing returned to standby.", _wName]
                            ] call OpsRoom_fnc_dispatch;
                            
                            diag_log format ["[OpsRoom] Air: Wing %1 all aircraft destroyed, reset to STANDBY", _wId];
                        };
                    };
                };
            }];
            
            // Update hangar entry status
            _entry set ["status", "AIRBORNE"];
            _entry set ["sortieCount", (_entry get "sortieCount") + 1];
            
            systemChat format ["%1 rolling for takeoff", _displayName];
            
            // Wait before spawning next aircraft
            sleep OpsRoom_Settings_LaunchInterval;
            
            // Wait for runway to clear before spawning next aircraft
            if (_forEachIndex < (count _aircraftIds - 1)) then {
                private _nextOffset = (_forEachIndex + 1) * 30;
                private _nextSpawnPos = _runwayPos vectorAdd [_nextOffset * sin _runwayDir, _nextOffset * cos _runwayDir, 0];
                private _clearTimeout = diag_tickTime + 60;
                private _blocked = true;
                while {_blocked && diag_tickTime < _clearTimeout} do {
                    private _nearby = _nextSpawnPos nearObjects ["Air", 40];
                    if (count _nearby == 0) then {
                        _blocked = false;
                    } else {
                        systemChat "Runway occupied, holding next aircraft...";
                        sleep 3;
                    };
                };
                if (_blocked) then {
                    systemChat "Runway clear timeout — spawning next aircraft";
                };
            };
        };
    } forEach _aircraftIds;
    
    // All aircraft spawned - update wing status
    _wingData set ["status", "AIRBORNE"];
    _wingData set ["spawnedObjects", _spawnedObjects];
    _wingData set ["launchTime", time];
    
    private _wingName = _wingData get "name";
    
    ["PRIORITY", format ["%1 airborne", _wingName],
        format ["All aircraft on station. %1 aircraft airborne.", count _aircraftIds]
    ] call OpsRoom_fnc_dispatch;
    
    systemChat format ["%1 - all aircraft airborne", _wingName];
    
    diag_log format ["[OpsRoom] Air: Wing %1 fully launched, %2 objects spawned", _wingId, count _spawnedObjects];
    
    // Start scramble combat monitor for aggressive dogfighting
    private _mission = _wingData getOrDefault ["mission", ""];
    if (_mission == "scramble") then {
        sleep 5; // Let aircraft get airborne and settle
        [_wingId] call OpsRoom_fnc_scrambleCombatMonitor;
        diag_log format ["[OpsRoom] Air: Scramble combat monitor started for %1", _wingId];
    };
};

true
