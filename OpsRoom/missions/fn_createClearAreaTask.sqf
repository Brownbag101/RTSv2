/*
    Create Clear Area Task
    
    Creates the "Secure Landing Zone" task for Mission 1.
    Monitors area and completes when no OPFOR within radius for duration.
    
    Parameters:
        None
    
    Returns:
        STRING - Task ID
    
    Usage:
        [] call OpsRoom_fnc_createClearAreaTask;
*/

private _spawnPos = missionNamespace getVariable ["OpsRoom_Mission1_SpawnPos", getPos player];
private _taskID = "opsroom_mission1_clear";

// Create task
[
    west,
    _taskID,
    [
        "Clear all hostile forces within 500m of your position. Once secure, you can begin construction of your base of operations.",
        "Secure Landing Zone",
        ""
    ],
    _spawnPos,
    "CREATED",
    0,
    true,
    "defend"
] call BIS_fnc_taskCreate;

// Create Zeus-visible marker at spawn position
private _marker = createMarker ["opsroom_mission1_marker", _spawnPos];
_marker setMarkerType "mil_objective";
_marker setMarkerColor "ColorBLUFOR";
_marker setMarkerText "SECURE AREA";
_marker setMarkerAlpha 1;

// Create 3D marker visible in Zeus (using proven pattern)
private _marker3DPos = [_spawnPos select 0, _spawnPos select 1, (_spawnPos select 2) + 10];
diag_log format ["[OpsRoom Mission1] Creating 3D marker at: %1", _marker3DPos];

// Create marker using proper API with icon library
private _marker3DHandler = [
    "opsroom_mission1_3d",
    _marker3DPos,
    "SECURE AREA",
    OpsRoom_MarkerIcons get "objective",
    OpsRoom_MarkerColors get "blue",
    2
] call OpsRoom_fnc_create3DMarker;

// Store handler for reference
missionNamespace setVariable ["OpsRoom_Mission1_3DHandler", _marker3DHandler];

diag_log format ["[OpsRoom Mission1] Task created: %1 at %2", _taskID, _spawnPos];
systemChat "◆ NEW OBJECTIVE: Secure Landing Zone";

// Start monitoring thread
[] spawn {
    private _taskID = "opsroom_mission1_clear";
    private _spawnPos = missionNamespace getVariable ["OpsRoom_Mission1_SpawnPos", getPos player];
    private _radius = OpsRoom_Settings_Mission1_ClearRadius;
    private _checkInterval = OpsRoom_Settings_Mission1_CheckInterval;
    
    private _clearStartTime = -1;
    private _requiredClearDuration = 10; // seconds
    
    while {true} do {
        sleep _checkInterval;
        
        // Check if task still exists
        private _taskState = [_taskID] call BIS_fnc_taskState;
        if (_taskState == "SUCCEEDED" || _taskState == "") exitWith {
            diag_log "[OpsRoom Mission1] Task monitoring ended";
        };
        
        // Check if area is clear
        private _isClear = [_spawnPos, _radius] call OpsRoom_fnc_checkAreaClear;
        
        if (_isClear) then {
            // Area is clear - start/continue timer
            if (_clearStartTime < 0) then {
                _clearStartTime = time;
                diag_log "[OpsRoom Mission1] Area clear - timer started";
            } else {
                private _clearDuration = time - _clearStartTime;
                if (_clearDuration >= _requiredClearDuration) then {
                    // Task complete!
                    [_taskID, "SUCCEEDED"] call BIS_fnc_taskSetState;
                    
                    // Show custom notification (doesn't interrupt Zeus)
                    [
                        "LANDING ZONE SECURED",
                        "The 1st Essex Regiment has cleared the immediate area. You may now call in engineer support to establish your base.",
                        10
                    ] call OpsRoom_fnc_showMissionNotification;
                    
                    // Delete 2D marker
                    deleteMarker "opsroom_mission1_marker";
                    
                    // Delete 3D marker (using proper API)
                    ["opsroom_mission1_3d"] call OpsRoom_fnc_remove3DMarker;
                    
                    // Trigger Mission 2
                    [] spawn {
                        sleep 2;
                        [] call OpsRoom_fnc_createEngineersTask;
                    };
                    
                    diag_log "[OpsRoom Mission1] Task completed - triggering Mission 2";
                };
            };
        } else {
            // Area not clear - reset timer
            _clearStartTime = -1;
        };
    };
};

_taskID
