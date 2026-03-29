/*
    fn_aiSpawnNavalGroup
    
    Spawns enemy patrol boats at a port for the AI Commander.
    Boats use scripted velocity navigation (same as convoy ships)
    because ARMA AI boat pathfinding is unreliable.
    
    Patrol boats follow sea lane waypoints, attacking player ships
    and convoys they encounter.
    
    Parameters:
        0: STRING - Template key (e.g. "patrol_boat", "torpedo_boat")
        1: STRING - Spawn location ID (must be a port)
        2: ARRAY  - Patrol target position [x,y,z] (general area)
        3: STRING - Mission type ("naval_patrol", "naval_attack")
    
    Returns: HASHMAP with:
        "group"  - The created group
        "boats"  - Array of spawned boat objects
*/

params [
    ["_templateKey", "", [""]],
    ["_spawnLocId", "", [""]],
    ["_targetPos", [0,0,0], [[]]],
    ["_missionType", "naval_patrol", [""]]
];

private _result = createHashMapFromArray [
    ["group", grpNull],
    ["boats", []]
];

if (_templateKey == "" || _spawnLocId == "") exitWith { _result };

private _template = OpsRoom_AI_GroupTemplates getOrDefault [_templateKey, createHashMap];
if (count _template == 0) exitWith { _result };

private _locData = OpsRoom_StrategicLocations getOrDefault [_spawnLocId, createHashMap];
if (count _locData == 0) exitWith { _result };

private _spawnPos = _locData get "pos";
private _boatClass = _template getOrDefault ["boat", "sab_nl_schnellboot"];
private _boatCount = _template getOrDefault ["boatCount", 1];
private _templateName = _template get "name";

// Create group on WEST (enemy)
private _grp = createGroup [west, true];
_grp setGroupIdGlobal [_templateName];

private _spawnedBoats = [];
private _boatNames = [
    "S-13", "S-26", "S-38", "S-54", "S-67", "S-100",
    "S-112", "S-130", "S-145", "S-168", "S-177", "S-204"
];

for "_i" from 0 to (_boatCount - 1) do {
    // Offset spawn so boats don't stack
    private _offset = _i * 30;
    private _boatPos = _spawnPos getPos [50 + _offset, _spawnPos getDir _targetPos];
    
    // Ensure spawn is in water (nudge if needed)
    if (!surfaceIsWater _boatPos) then {
        // Try further from shore
        _boatPos = _spawnPos getPos [150 + _offset, _spawnPos getDir _targetPos];
    };
    
    private _boat = createVehicle [_boatClass, _boatPos, [], 0, "NONE"];
    _boat setPos _boatPos;
    _boat setDir (_spawnPos getDir _targetPos);
    
    // Create crew
    private _driver = _grp createUnit ["B_Soldier_F", [0,0,0], [], 0, "NONE"];
    _driver moveInDriver _boat;
    _driver setSkill 0.6;
    
    // Disable AI movement — we use scripted velocity
    _driver disableAI "MOVE";
    _driver disableAI "PATH";
    
    // Fill turrets
    private _turrets = fullCrew [_boat, "turret", true];
    {
        _x params ["_unit", "_role", "_cargoIndex", "_turretPath"];
        if (isNull _unit) then {
            private _gunner = _grp createUnit ["B_Soldier_F", [0,0,0], [], 0, "NONE"];
            _gunner moveInTurret [_boat, _turretPath];
            _gunner setSkill 0.6;
        };
    } forEach _turrets;
    
    // Tag
    private _boatName = selectRandom _boatNames;
    _boat setVariable ["OpsRoom_AI_Managed", true, true];
    _boat setVariable ["OpsRoom_AI_IsEnemyBoat", true, true];
    _boat setVariable ["OpsRoom_AI_BoatName", _boatName, true];
    
    // Killed EH
    _boat addEventHandler ["Killed", {
        params ["_vehicle"];
        private _name = _vehicle getVariable ["OpsRoom_AI_BoatName", "Enemy vessel"];
        ["PRIORITY", format ["ENEMY %1 SUNK", _name],
            format ["Enemy patrol boat %1 destroyed!", _name],
            getPosATL _vehicle
        ] call OpsRoom_fnc_dispatch;
        diag_log format ["[OpsRoom] AI Naval: Enemy boat %1 destroyed", _name];
    }];
    
    _spawnedBoats pushBack _boat;
};

// Tag group
_grp setVariable ["OpsRoom_AI_Managed", true, true];
_grp setVariable ["OpsRoom_AI_IsNavalGroup", true, true];

// ========================================
// SCRIPTED NAVIGATION
// ========================================
// Build patrol route: port → target area → back to port → cycle
// Use sea lane waypoints if available, otherwise direct nav

private _patrolWaypoints = [];

// Try to find a sea lane connected to this port for route waypoints
if (!isNil "OpsRoom_SeaLanes") then {
    {
        private _laneData = _y;
        private _routesMap = _laneData getOrDefault ["routes", createHashMap];
        
        // Check if this port has waypoints on any sea lane
        {
            private _portLocId = _x;
            private _wps = _y;
            if (_portLocId == _spawnLocId && count _wps > 0) then {
                // Use these waypoints for patrol route
                _patrolWaypoints = +_wps;  // Copy
            };
        } forEach _routesMap;
        
        if (count _patrolWaypoints > 0) exitWith {};
    } forEach OpsRoom_SeaLanes;
};

// If no sea lane waypoints, create a simple out-and-back route
if (count _patrolWaypoints == 0) then {
    // Intermediate point between port and target
    private _midPoint = _spawnPos vectorAdd ((_targetPos vectorDiff _spawnPos) vectorMultiply 0.5);
    _patrolWaypoints = [_midPoint, _targetPos];
};

// Start navigation for each boat
{
    private _boat = _x;
    
    [_boat, _spawnPos, _patrolWaypoints, _missionType] spawn {
        params ["_boat", "_homePos", "_waypoints", "_missionType"];
        
        private _speed = 12;  // Fast patrol boat speed
        private _wpIdx = 0;
        private _returning = false;
        private _fullRoute = _waypoints + [_homePos];  // Outbound + return
        
        sleep 1 + (random 3);  // Stagger departures
        
        while {alive _boat} do {
            if (_wpIdx >= count _fullRoute) then {
                // Completed patrol — cycle back to start
                _wpIdx = 0;
                _returning = false;
            };
            
            private _targetWp = _fullRoute select _wpIdx;
            private _boatPos = getPos _boat;
            private _dist = _boatPos distance2D _targetWp;
            
            if (_dist < 100) then {
                _wpIdx = _wpIdx + 1;
            } else {
                // Navigate toward waypoint
                private _dir = _boatPos getDir _targetWp;
                private _currentDir = getDir _boat;
                private _dirDiff = _dir - _currentDir;
                if (_dirDiff > 180) then { _dirDiff = _dirDiff - 360 };
                if (_dirDiff < -180) then { _dirDiff = _dirDiff + 360 };
                private _turnRate = 4;  // Faster turn rate than cargo ships
                private _newDir = _currentDir + ((_dirDiff min _turnRate) max (-_turnRate));
                _boat setDir _newDir;
                
                private _actualSpeed = if (_dist < 200) then { _speed * 0.5 } else { _speed };
                _boat setVelocity [
                    _actualSpeed * sin _newDir,
                    _actualSpeed * cos _newDir,
                    0
                ];
            };
            
            sleep 0.5;
        };
    };
} forEach _spawnedBoats;

diag_log format ["[OpsRoom] aiSpawnNavalGroup: Spawned '%1' (%2 boats) at %3",
    _templateName, count _spawnedBoats, _locData get "name"];

_result set ["group", _grp];
_result set ["boats", _spawnedBoats];

_result
