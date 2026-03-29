/*
    fn_aiMoveGroup
    
    Sends an AI commander group to a target position via road march.
    
    Movement logic:
        1. Find nearest road to group's current position
        2. Add MOVE waypoint to that road
        3. Find nearest road to target position
        4. Add MOVE waypoint along road to target approach
        5. Final waypoint: SAD (Search and Destroy) at target
    
    For motorised groups: uses vehicle, speed mode NORMAL
    For infantry: speed mode FULL (double time march)
    
    Parameters:
        0: GROUP  - The group to move
        1: ARRAY  - Target position [x,y,z]
        2: STRING - Mission type ("counter_attack", "reinforce", "garrison", "patrol")
*/

params [
    ["_grp", grpNull, [grpNull]],
    ["_targetPos", [0,0,0], [[]]],
    ["_missionType", "garrison", [""]]
];

if (isNull _grp) exitWith {
    diag_log "[OpsRoom] aiMoveGroup: Null group";
};

// Clear any existing waypoints
while {count waypoints _grp > 0} do {
    deleteWaypoint [_grp, 0];
};

private _startPos = getPosATL (leader _grp);

// Determine if motorised (has vehicle)
private _hasVehicle = false;
{
    if (vehicle _x != _x) exitWith { _hasVehicle = true };
} forEach (units _grp);

// ========================================
// WAYPOINT 1: Move to nearest road from spawn
// ========================================
private _startRoads = _startPos nearRoads 200;
if (count _startRoads > 0) then {
    // Sort by distance, pick closest
    _startRoads = _startRoads apply {[_startPos distance2D (getPos _x), getPos _x]};
    _startRoads sort true;
    private _roadPos = (_startRoads select 0) select 1;
    
    private _wp0 = _grp addWaypoint [_roadPos, 0];
    _wp0 setWaypointType "MOVE";
    _wp0 setWaypointBehaviour "SAFE";
    _wp0 setWaypointSpeed (if (_hasVehicle) then { "NORMAL" } else { "FULL" });
};

// ========================================
// WAYPOINT 2: Move along road toward target
// ========================================
// Find road segments along the route at intervals
private _dist = _startPos distance2D _targetPos;
private _dir = _startPos getDir _targetPos;
private _numIntermediateWPs = (floor (_dist / 500)) min 8;  // WP every 500m, max 8

for "_i" from 1 to _numIntermediateWPs do {
    private _fraction = _i / (_numIntermediateWPs + 1);
    private _interpPos = _startPos vectorAdd ((_targetPos vectorDiff _startPos) vectorMultiply _fraction);
    
    // Find nearest road to interpolated position
    private _roads = _interpPos nearRoads 150;
    if (count _roads > 0) then {
        private _roadPos = getPos (selectRandom _roads);
        private _wp = _grp addWaypoint [_roadPos, 0];
        _wp setWaypointType "MOVE";
        _wp setWaypointBehaviour "AWARE";
        _wp setWaypointSpeed (if (_hasVehicle) then { "NORMAL" } else { "FULL" });
    };
};

// ========================================
// WAYPOINT 3: Approach target (dismount area for motorised)
// ========================================
if (_hasVehicle) then {
    // Motorised: add dismount waypoint 200m from target
    private _dismountPos = _targetPos getPos [200, (_targetPos getDir _startPos)];
    private _dismountRoads = _dismountPos nearRoads 100;
    private _dmPos = if (count _dismountRoads > 0) then {
        getPos (selectRandom _dismountRoads)
    } else {
        _dismountPos
    };
    
    private _wpDismount = _grp addWaypoint [_dmPos, 0];
    _wpDismount setWaypointType "GETOUT";
    _wpDismount setWaypointBehaviour "AWARE";
};

// ========================================
// FINAL WAYPOINT: SAD at target
// ========================================
private _wpFinal = _grp addWaypoint [_targetPos, 0];

// Mission type determines final waypoint behaviour
switch (_missionType) do {
    case "counter_attack": {
        _wpFinal setWaypointType "SAD";
        _wpFinal setWaypointBehaviour "COMBAT";
        _wpFinal setWaypointCombatMode "RED";
        _wpFinal setWaypointSpeed "FULL";
    };
    case "reinforce": {
        _wpFinal setWaypointType "SAD";
        _wpFinal setWaypointBehaviour "COMBAT";
        _wpFinal setWaypointCombatMode "RED";
        _wpFinal setWaypointSpeed "NORMAL";
    };
    case "garrison": {
        _wpFinal setWaypointType "HOLD";
        _wpFinal setWaypointBehaviour "AWARE";
        _wpFinal setWaypointCombatMode "YELLOW";
        _wpFinal setWaypointSpeed "NORMAL";
    };
    case "patrol": {
        _wpFinal setWaypointType "LOITER";
        _wpFinal setWaypointBehaviour "SAFE";
        _wpFinal setWaypointCombatMode "YELLOW";
        _wpFinal setWaypointSpeed "LIMITED";
    };
    default {
        _wpFinal setWaypointType "MOVE";
        _wpFinal setWaypointBehaviour "AWARE";
    };
};

_grp setCurrentWaypoint [_grp, 0];

diag_log format ["[OpsRoom] aiMoveGroup: %1 moving to %2 (%3). Vehicle: %4. Distance: %5m",
    groupId _grp, _targetPos, _missionType, _hasVehicle, round (_startPos distance2D _targetPos)];
