/*
    Air Operations - Reassign Airborne Mission
    
    Clears existing waypoints on all spawned aircraft in an airborne wing
    and issues new waypoints to the new target position with new mission params.
    
    Parameters:
        _wingId - Wing ID (must be AIRBORNE)
    
    Returns:
        Boolean - true on success
*/
params ["_wingId"];

private _wingData = OpsRoom_AirWings get _wingId;
if (isNil "_wingData") exitWith {
    systemChat "Wing not found";
    false
};

private _wingName = _wingData get "name";
private _status = _wingData get "status";

// Must be airborne
if (_status != "AIRBORNE") exitWith {
    systemChat format ["%1 is not airborne", _wingName];
    false
};

private _mission = _wingData get "mission";
private _targetPos = _wingData get "missionTarget";
private _spawnedObjects = _wingData get "spawnedObjects";

if (count _targetPos == 0) exitWith {
    systemChat format ["%1 has no target position set", _wingName];
    false
};

// Get mission parameters
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

// Get mission display name
private _missionLabel = if (_mission != "") then {
    private _mData = OpsRoom_AirMissionTypes getOrDefault [_mission, createHashMap];
    _mData getOrDefault ["displayName", _mission]
} else {
    "Staging"
};

// Clear old target marker
private _oldMarker = _wingData getOrDefault ["loiterMarker", ""];
if (_oldMarker != "" && {markerType _oldMarker != ""}) then {
    deleteMarker _oldMarker;
};

// Create new marker at target
private _markerName = format ["air_target_%1", _wingId];
private _marker = createMarker [_markerName, _targetPos];
_marker setMarkerType "mil_objective";
_marker setMarkerColor "ColorGreen";
_marker setMarkerText format ["%1: %2", _wingName, _missionLabel];
_marker setMarkerSize [0.7, 0.7];
_wingData set ["loiterMarker", _markerName];

// Reassign waypoints on all spawned aircraft
{
    private _obj = _x;
    if (!(_obj isKindOf "Air")) then { continue };
    if (!alive _obj) then { continue };
    
    private _driver = driver _obj;
    if (isNull _driver) then { continue };
    
    private _group = group _driver;
    
    // Clear all existing waypoints
    while {count waypoints _group > 0} do {
        deleteWaypoint [_group, 0];
    };
    
    // Add new waypoint to target
    private _wp = _group addWaypoint [_targetPos, 0];
    _wp setWaypointType _wpType;
    _wp setWaypointSpeed _speed;
    _wp setWaypointBehaviour _behaviour;
    _wp setWaypointCombatMode _combatMode;
    
    if (_wpType == "LOITER") then {
        _wp setWaypointLoiterType "CIRCLE_L";
        _wp setWaypointLoiterRadius _loiterRadius;
    };
    
    // Set flight altitude
    _obj flyInHeight _altitude;
    
} forEach _spawnedObjects;

// Dispatch
["PRIORITY", format ["%1: New orders", _wingName],
    format ["%1 redirected to %2. Aircraft adjusting course.", _wingName, _missionLabel]
] call OpsRoom_fnc_dispatch;

systemChat format ["%1 redirected to %2", _wingName, _missionLabel];

diag_log format ["[OpsRoom] Air: Wing %1 reassigned to %2 at %3", _wingId, _mission, _targetPos];

true
