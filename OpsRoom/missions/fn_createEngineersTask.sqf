/*
    Create Engineers Task (Mission 2 Placeholder)
    
    Creates the "Call in Engineers" task for Mission 2.
    This is a placeholder - completion conditions to be implemented later.
    
    Parameters:
        None
    
    Returns:
        STRING - Task ID
    
    Usage:
        [] call OpsRoom_fnc_createEngineersTask;
*/

private _taskID = "opsroom_mission2_engineers";
private _spawnPos = missionNamespace getVariable ["OpsRoom_Mission1_SpawnPos", getPos player];

// Create task
[
    west,
    _taskID,
    [
        "Request engineer support from command. Engineers will be able to construct and repair buildings for your forward operating base.",
        "Call in Engineers",
        ""
    ],
    _spawnPos,
    "CREATED",
    0,
    true,
    "engineer"
] call BIS_fnc_taskCreate;

diag_log format ["[OpsRoom Mission2] Task created: %1", _taskID];
systemChat "◆ NEW OBJECTIVE: Call in Engineers";

// Placeholder - no completion conditions yet
// Future: Will spawn engineer units and buildings system

_taskID
