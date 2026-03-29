/*
    fn_aiSpawnAirGroup
    
    Spawns enemy aircraft at an airfield for the AI Commander.
    Aircraft spawn on the ground at the airfield location position
    (near the hangar/apron area). ARMA AI handles taxi and takeoff.
    
    Parameters:
        0: STRING - Template key (e.g. "fighter_patrol", "bomber_strike")
        1: STRING - Spawn location ID (must be an airfield)
        2: ARRAY  - Target position [x,y,z]
        3: STRING - Mission type ("air_patrol", "air_strike")
    
    Returns: HASHMAP with:
        "group"     - The created pilot group
        "aircraft"  - Array of spawned aircraft objects
*/

params [
    ["_templateKey", "", [""]],
    ["_spawnLocId", "", [""]],
    ["_targetPos", [0,0,0], [[]]],
    ["_missionType", "air_patrol", [""]]
];

private _result = createHashMapFromArray [
    ["group", grpNull],
    ["aircraft", []]
];

if (_templateKey == "" || _spawnLocId == "") exitWith { _result };

private _template = OpsRoom_AI_GroupTemplates getOrDefault [_templateKey, createHashMap];
if (count _template == 0) exitWith { _result };

private _locData = OpsRoom_StrategicLocations getOrDefault [_spawnLocId, createHashMap];
if (count _locData == 0) exitWith { _result };

private _spawnPos = _locData get "pos";
private _aircraftDefs = _template getOrDefault ["aircraft", []];
private _templateName = _template get "name";

if (count _aircraftDefs == 0) exitWith {
    diag_log format ["[OpsRoom] aiSpawnAirGroup: Template '%1' has no aircraft defined", _templateKey];
    _result
};

// Create pilot group on WEST (enemy)
private _grp = createGroup [west, true];
_grp setGroupIdGlobal [_templateName];

private _spawnedAircraft = [];
private _index = 0;

// Find the direction from airfield to target for initial heading
private _spawnDir = _spawnPos getDir _targetPos;

{
    _x params ["_className", "_count"];
    
    for "_i" from 1 to _count do {
        // Stagger spawn positions on the ground near the airfield
        // Offset each aircraft along the apron to prevent collision
        private _offset = _index * 30;
        private _acPos = _spawnPos getPos [20 + _offset, _spawnDir + 90];
        
        // Spawn on the ground — ARMA AI will taxi and take off
        private _vehicle = createVehicle [_className, _acPos, [], 0, "NONE"];
        _vehicle setPos _acPos;
        _vehicle setDir _spawnDir;
        
        // Create pilot
        private _pilot = _grp createUnit ["B_Pilot_F", [0,0,0], [], 0, "NONE"];
        _pilot moveInDriver _vehicle;
        _pilot setSkill 0.7;
        
        // Fill turret seats with gunners if needed
        private _turrets = fullCrew [_vehicle, "turret", true];
        {
            _x params ["_unit", "_role", "_cargoIndex", "_turretPath"];
            if (isNull _unit) then {
                private _gunner = _grp createUnit ["B_Soldier_F", [0,0,0], [], 0, "NONE"];
                _gunner moveInTurret [_vehicle, _turretPath];
                _gunner setSkill 0.6;
            };
        } forEach _turrets;
        
        // Tag as AI commander managed
        _vehicle setVariable ["OpsRoom_AI_Managed", true, true];
        _vehicle setVariable ["OpsRoom_AI_TemplateKey", _templateKey, true];
        _vehicle setVariable ["OpsRoom_AI_IsEnemyAircraft", true, true];
        
        // Killed EH
        _vehicle addEventHandler ["Killed", {
            params ["_vehicle"];
            private _tKey = _vehicle getVariable ["OpsRoom_AI_TemplateKey", "Unknown"];
            ["PRIORITY", "ENEMY AIRCRAFT DOWN",
                format ["Enemy %1 shot down!", getText (configFile >> "CfgVehicles" >> typeOf _vehicle >> "displayName")],
                getPosATL _vehicle
            ] call OpsRoom_fnc_dispatch;
            diag_log format ["[OpsRoom] AI Air: Enemy aircraft destroyed (%1)", _tKey];
        }];
        
        _spawnedAircraft pushBack _vehicle;
        _index = _index + 1;
    };
} forEach _aircraftDefs;

// Configure group behaviour
_grp setCombatMode "RED";
_grp setBehaviourStrong "AWARE";

// Set waypoints — aircraft will taxi, take off, then follow waypoints
private _cruiseAlt = 300;

switch (_missionType) do {
    case "air_patrol": {
        // Patrol: fly to target, loiter, cycle back
        private _wp1 = _grp addWaypoint [_targetPos, 0];
        _wp1 setWaypointType "LOITER";
        _wp1 setWaypointSpeed "NORMAL";
        _wp1 setWaypointBehaviour "AWARE";
        _wp1 setWaypointCombatMode "RED";
        _wp1 setWaypointLoiterType "CIRCLE_L";
        _wp1 setWaypointLoiterRadius 1500;
        
        // Return leg
        private _wp2 = _grp addWaypoint [_spawnPos, 0];
        _wp2 setWaypointType "MOVE";
        _wp2 setWaypointSpeed "NORMAL";
        
        // Cycle
        private _wp3 = _grp addWaypoint [_targetPos, 0];
        _wp3 setWaypointType "CYCLE";
    };
    
    case "air_strike": {
        // Strike: SAD at target
        private _wp1 = _grp addWaypoint [_targetPos, 0];
        _wp1 setWaypointType "SAD";
        _wp1 setWaypointSpeed "FULL";
        _wp1 setWaypointBehaviour "COMBAT";
        _wp1 setWaypointCombatMode "RED";
        
        // RTB after strike
        private _wp2 = _grp addWaypoint [_spawnPos, 0];
        _wp2 setWaypointType "MOVE";
        _wp2 setWaypointSpeed "NORMAL";
        _wp2 setWaypointBehaviour "AWARE";
    };
    
    default {
        private _wp1 = _grp addWaypoint [_targetPos, 0];
        _wp1 setWaypointType "LOITER";
        _wp1 setWaypointSpeed "NORMAL";
        _wp1 setWaypointLoiterType "CIRCLE_L";
        _wp1 setWaypointLoiterRadius 1500;
    };
};

// Set flight altitude for when airborne
{ (vehicle _x) flyInHeight _cruiseAlt } forEach (units _grp);

// Tag group
_grp setVariable ["OpsRoom_AI_Managed", true, true];
_grp setVariable ["OpsRoom_AI_TemplateKey", _templateKey, true];
_grp setVariable ["OpsRoom_AI_IsAirGroup", true, true];

diag_log format ["[OpsRoom] aiSpawnAirGroup: Spawned '%1' (%2 aircraft) on ground at %3",
    _templateName, count _spawnedAircraft, _locData get "name"];

_result set ["group", _grp];
_result set ["aircraft", _spawnedAircraft];

_result
