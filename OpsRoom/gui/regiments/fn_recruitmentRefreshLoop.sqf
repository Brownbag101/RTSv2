/*
    Recruitment Refresh Loop
    
    Periodically checks and refreshes recruit pool based on manpower.
    Runs continuously in background.
    
    Usage:
        [] spawn OpsRoom_fnc_recruitmentRefreshLoop;
*/

while {true} do {
    sleep OpsRoom_Settings_RecruitmentRefreshInterval;
    
    // Check if pool needs refresh
    private _currentManpower = if (isNil "OpsRoom_Resource_Manpower") then {5} else {OpsRoom_Resource_Manpower};
    private _currentPoolSize = count OpsRoom_RecruitPool;
    
    // If manpower exceeds pool size, add recruits
    if (_currentManpower > _currentPoolSize) then {
        private _needed = _currentManpower - _currentPoolSize;
        
        for "_i" from 0 to (_needed - 1) do {
            private _recruit = [] call OpsRoom_fnc_generateRecruit;
            OpsRoom_RecruitPool pushBack _recruit;
        };
        
        systemChat format ["[RECRUITMENT] %1 new recruit(s) available", _needed];
        diag_log format ["[OpsRoom] Recruitment pool refreshed: +%1 recruits", _needed];
    };
};
