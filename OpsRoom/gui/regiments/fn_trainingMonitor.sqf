/*
    Training Monitor Loop
    
    Background loop that checks training timers and completes training when ready.
    Runs continuously throughout mission.
    
    Usage:
        [] spawn OpsRoom_fnc_trainingMonitor;
*/

while {true} do {
    sleep 10;  // Check every 10 seconds
    
    if (count OpsRoom_UnitsInTraining > 0) then {
        private _completed = [];
        
        {
            _x params ["_unit", "_courseId", "_startTime", "_duration", "_skills", "_quals"];
            
            // Check if training is complete
            private _elapsed = (time - _startTime) / 60;  // Convert to minutes
            
            if (_elapsed >= _duration) then {
                // Complete training
                [_unit, _skills, _quals] call OpsRoom_fnc_completeTraining;
                _completed pushBack _forEachIndex;
            };
            
        } forEach OpsRoom_UnitsInTraining;
        
        // Remove completed training entries (in reverse order to preserve indices)
        reverse _completed;
        {
            OpsRoom_UnitsInTraining deleteAt _x;
        } forEach _completed;
        
        // Update training display if open
        if (!isNull (findDisplay 8006)) then {
            [] call OpsRoom_fnc_updateTrainingStatusDisplay;
        };
    };
};
