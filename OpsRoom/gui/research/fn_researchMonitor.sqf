/*
    Research Monitor
    
    Background loop that checks research timers.
    Runs every 10 seconds. Completes research when timer expires.
    
    Usage:
        [] spawn OpsRoom_fnc_researchMonitor;
*/

diag_log "[OpsRoom] Research monitor started";

while {true} do {
    private _activeResearch = missionNamespace getVariable ["OpsRoom_ResearchInProgress", []];
    
    if (count _activeResearch > 0) then {
        _activeResearch params ["_itemId", "_startTime", "_duration"];
        
        private _elapsed = time - _startTime;
        private _totalTime = _duration * 60;  // Convert minutes to seconds
        
        if (_elapsed >= _totalTime) then {
            // Research complete
            [_itemId] call OpsRoom_fnc_completeResearch;
        };
    };
    
    sleep 10;
};
