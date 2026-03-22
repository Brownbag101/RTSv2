/*
    OpsRoom_fnc_airStrike_returnToLoiter
    
    After completing an attack run, decides what to do next:
    
    - If the wing has an ACTIVE SCHEDULE: triggers auto-RTB via landWing
      so the full cycle completes (launch → strike → RTB → land → reschedule).
      Same pattern as photo recon auto-RTB.
    
    - If no schedule (manual strike): returns aircraft to loiter position
      so the player can order additional strikes if needed.
    
    Parameters:
        0: OBJECT - aircraft vehicle
        1: GROUP  - aircraft pilot group
*/

params ["_aircraft", "_group"];

if (!alive _aircraft) exitWith {};

// Find which wing this aircraft belongs to
private _hangarId = _aircraft getVariable ["OpsRoom_HangarId", ""];
private _wingId = _aircraft getVariable ["OpsRoom_WingId", ""];

if (_wingId == "") exitWith {
    // No wing — just let them fly free
    diag_log "[OpsRoom] AirStrike: Aircraft has no wing assignment, skipping loiter return";
};

private _wingData = OpsRoom_AirWings get _wingId;
if (isNil "_wingData") exitWith {};

private _status = _wingData get "status";
if (_status != "AIRBORNE") exitWith {};

// === SCHEDULED STRIKE: Auto-RTB instead of loitering ===
// If this wing has a schedule (even one-shot that already set enabled=false after launch),
// trigger landWing for the whole wing.
// This completes the automated cycle: launch → strike → RTB → land → reschedule.
// Manual (non-scheduled) strikes skip this and return to loiter as before.
// We check for a valid missionId rather than "enabled" because the scheduler
// sets enabled=false for one-shot missions immediately after launch (before the
// strike even begins), and for interval missions the timing can race.
private _schedule = _wingData getOrDefault ["schedule", createHashMap];
private _scheduledMission = _schedule getOrDefault ["missionId", ""];
if (_scheduledMission != "") then {
    private _wingName = _wingData get "name";
    systemChat format ["%1: Strike complete. Returning to base.", _wingName];
    diag_log format ["[OpsRoom] AirStrike: %1 has active schedule — triggering auto-RTB instead of loiter", _wingId];
    
    // Small delay for egress to clear the target area before RTB
    sleep 5;
    [_wingId] call OpsRoom_fnc_landWing;
    // exitWith from the whole function — don't fall through to loiter logic
};
// Check if we exited above (SQF quirk: exitWith inside then-block doesn't exit the function)
// Re-check: if wing is no longer AIRBORNE (landWing changed status to RTB), we're done
if ((_wingData get "status") != "AIRBORNE") exitWith {
    diag_log format ["[OpsRoom] AirStrike: %1 RTB initiated by scheduler, skipping loiter return", _wingId];
};

// === MANUAL STRIKE: Return to loiter for potential follow-up runs ===
// Get the wing's current mission and target
private _mission = _wingData get "mission";
private _targetPos = _wingData get "missionTarget";

// If no target position, use default loiter
if (count _targetPos == 0) then {
    private _runwayPos = getMarkerPos "OpsRoom_runway";
    private _runwayDir = markerDir "OpsRoom_runway";
    if (markerType "OpsRoom_loiter_default" != "") then {
        _targetPos = getMarkerPos "OpsRoom_loiter_default";
    } else {
        _targetPos = _runwayPos vectorAdd [3000 * sin _runwayDir, 3000 * cos _runwayDir, 0];
    };
};

// Get mission parameters for waypoint config
private _missionParams = if (_mission != "") then {
    OpsRoom_AirMissionTypes getOrDefault [_mission, createHashMap]
} else {
    createHashMap
};

private _altitude = _missionParams getOrDefault ["altitude", 300];
private _speed = _missionParams getOrDefault ["speed", "NORMAL"];
private _combatMode = _missionParams getOrDefault ["combatMode", "GREEN"];
private _behaviour = _missionParams getOrDefault ["behaviour", "AWARE"];
private _wpType = _missionParams getOrDefault ["waypointType", "LOITER"];
private _loiterRadius = _missionParams getOrDefault ["loiterRadius", 1000];

// Clear any existing waypoints
while {count waypoints _group > 0} do {
    deleteWaypoint [_group, 0];
};

// Re-issue loiter waypoint
private _wp = _group addWaypoint [_targetPos, 0];
_wp setWaypointType _wpType;
_wp setWaypointSpeed _speed;
_wp setWaypointBehaviour _behaviour;
_wp setWaypointCombatMode _combatMode;

if (_wpType == "LOITER") then {
    _wp setWaypointLoiterType "CIRCLE_L";
    _wp setWaypointLoiterRadius _loiterRadius;
};

_aircraft flyInHeight _altitude;

// Re-disable targeting (stays passive unless on a combat mission)
{ _x disableAI "TARGET"; _x disableAI "AUTOTARGET" } forEach (units _group);

systemChat format ["%1 returning to station", getText (configFile >> "CfgVehicles" >> typeOf _aircraft >> "displayName")];

diag_log format ["[OpsRoom] AirStrike: %1 returning to loiter at %2", typeOf _aircraft, _targetPos];
