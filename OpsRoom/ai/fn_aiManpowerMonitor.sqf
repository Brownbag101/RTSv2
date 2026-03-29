/*
    fn_aiManpowerMonitor
    
    Hooks into the existing enemy shipping system.
    When an enemy cargo ship arrives at an enemy port,
    increments the AI commander's manpower pool.
    
    This runs as a background loop checking OpsRoom_EnemyShipsArrived
    (a counter incremented by the existing enemy shipping monitor).
    
    Called from init.sqf:
        [] spawn OpsRoom_fnc_aiManpowerMonitor;
*/

// Don't start multiple monitors
if (!isNil "OpsRoom_AI_ManpowerMonitorRunning" && {OpsRoom_AI_ManpowerMonitorRunning}) exitWith {
    systemChat "AI Manpower Monitor already running";
};

OpsRoom_AI_ManpowerMonitorRunning = true;

// Initialize counter if not set
if (isNil "OpsRoom_AI_EnemyShipsProcessed") then {
    OpsRoom_AI_EnemyShipsProcessed = 0;
};

if (isNil "OpsRoom_EnemyShipsArrived") then {
    OpsRoom_EnemyShipsArrived = 0;
};

systemChat "AI Manpower: Monitor started";
diag_log "[OpsRoom] AI Manpower monitor started";

while {OpsRoom_AI_ManpowerMonitorRunning} do {
    
    // Check if new enemy ships have arrived since last check
    private _totalArrived = OpsRoom_EnemyShipsArrived;
    private _processed = OpsRoom_AI_EnemyShipsProcessed;
    
    if (_totalArrived > _processed) then {
        private _newShips = _totalArrived - _processed;
        private _gain = _newShips * OpsRoom_AI_ManpowerPerShip;
        
        OpsRoom_AI_Manpower = OpsRoom_AI_Manpower + _gain;
        OpsRoom_AI_EnemyShipsProcessed = _totalArrived;
        
        diag_log format ["[OpsRoom] AI Manpower: +%1 from %2 enemy ship(s). Total: %3",
            _gain, _newShips, OpsRoom_AI_Manpower];
        
        ["ROUTINE", "ENEMY RESUPPLY", format ["Enemy shipping detected — estimated %1 reinforcements received.", _gain], [0,0,0]] call OpsRoom_fnc_dispatch;
    };
    
    sleep 30;  // Check every 30 seconds
};
