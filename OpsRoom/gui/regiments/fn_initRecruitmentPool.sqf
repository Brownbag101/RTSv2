/*
    Initialize Recruitment Pool
    
    Generates initial recruit pool based on current manpower.
    Pool size matches manpower count.
    
    Usage:
        [] call OpsRoom_fnc_initRecruitmentPool;
*/

// Clear existing pool
OpsRoom_RecruitPool = [];

// Get current manpower
private _manpower = if (isNil "OpsRoom_Resource_Manpower") then {5} else {OpsRoom_Resource_Manpower};

// Generate recruits
for "_i" from 0 to (_manpower - 1) do {
    private _recruit = [] call OpsRoom_fnc_generateRecruit;
    OpsRoom_RecruitPool pushBack _recruit;
};

diag_log format ["[OpsRoom] Recruitment pool initialized with %1 recruits", count OpsRoom_RecruitPool];
