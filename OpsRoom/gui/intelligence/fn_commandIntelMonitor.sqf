/*
    fn_commandIntelMonitor
    
    Background loop that manages the Command Intelligence level over time.
    
    Every in-game hour equivalent:
        - Decays temp bonus by OpsRoom_AI_IntelDecayRate
        - Checks for newly captured locations and grants one-time boosts
        - Recalculates effective intel level
        - Logs intel state changes to dispatch (if notable)
    
    Called from init.sqf:
        [] spawn OpsRoom_fnc_commandIntelMonitor;
*/

// Don't start multiple monitors
if (!isNil "OpsRoom_CommandIntelMonitorRunning" && {OpsRoom_CommandIntelMonitorRunning}) exitWith {
    systemChat "Command Intel Monitor already running";
};

OpsRoom_CommandIntelMonitorRunning = true;

private _lastDecayTime = daytime;
private _decayIntervalHours = 1;  // Decay every 1 in-game hour
private _lastIntelLevel = [] call OpsRoom_fnc_getCommandIntelLevel;

systemChat format ["Command Intel: Monitor started (level: %1%%)", round _lastIntelLevel];
diag_log "[OpsRoom] Command Intel monitor started";

while {OpsRoom_CommandIntelMonitorRunning} do {
    
    // ========================================
    // CHECK FOR NEWLY CAPTURED LOCATIONS
    // ========================================
    {
        private _locId = _x;
        private _locData = _y;
        private _owner = _locData getOrDefault ["owner", "NAZI"];
        
        // If British now owns it and we haven't logged the intel boost
        if (_owner == "BRITISH" && !(_locId in OpsRoom_AI_IntelCaptureLog)) then {
            OpsRoom_AI_IntelCaptureLog pushBack _locId;
            
            // Grant temp intel boost
            private _boost = OpsRoom_AI_IntelPerCapture;
            OpsRoom_AI_IntelTempBonus = OpsRoom_AI_IntelTempBonus + _boost;
            
            private _name = _locData get "name";
            diag_log format ["[OpsRoom] Command Intel: +%1%% from capturing %2. Temp bonus now: %3%%",
                _boost, _name, OpsRoom_AI_IntelTempBonus];
            
            // Check for document capture bonus (locations with radios that were intact)
            private _radio = _locData getOrDefault ["radioObject", objNull];
            if (!isNull _radio && alive _radio) then {
                // Intact radio = captured enemy communications equipment
                private _docBonus = 3;
                OpsRoom_AI_IntelTempBonus = OpsRoom_AI_IntelTempBonus + _docBonus;
                
                ["PRIORITY", "DOCUMENTS CAPTURED",
                    format ["Enemy radio equipment captured intact at %1. Intelligence analysts are reviewing communications logs. (+%2%% intel)", _name, _boost + _docBonus],
                    _locData get "pos"
                ] call OpsRoom_fnc_dispatch;
            } else {
                ["ROUTINE", "INTELLIGENCE UPDATE",
                    format ["Capture of %1 has provided frontline intelligence on enemy dispositions. (+%2%% intel)", _name, _boost],
                    _locData get "pos"
                ] call OpsRoom_fnc_dispatch;
            };
        };
        
        // If location was recaptured by enemy, remove from capture log
        // (so capturing it again gives another boost)
        if (_owner == "NAZI" && (_locId in OpsRoom_AI_IntelCaptureLog)) then {
            OpsRoom_AI_IntelCaptureLog = OpsRoom_AI_IntelCaptureLog - [_locId];
        };
        
    } forEach OpsRoom_StrategicLocations;
    
    // ========================================
    // DECAY TEMP BONUS
    // ========================================
    private _elapsed = daytime - _lastDecayTime;
    if (_elapsed < 0) then { _elapsed = _elapsed + 24 };  // Midnight rollover
    
    if (_elapsed >= _decayIntervalHours) then {
        _lastDecayTime = daytime;
        
        if (OpsRoom_AI_IntelTempBonus > 0) then {
            private _decay = OpsRoom_AI_IntelDecayRate;
            OpsRoom_AI_IntelTempBonus = (OpsRoom_AI_IntelTempBonus - _decay) max 0;
            diag_log format ["[OpsRoom] Command Intel: Temp bonus decayed by %1%%. Now: %2%%", _decay, OpsRoom_AI_IntelTempBonus];
        };
    };
    
    // ========================================
    // RECALCULATE EFFECTIVE LEVEL
    // ========================================
    private _currentLevel = [] call OpsRoom_fnc_getCommandIntelLevel;
    
    // Log significant changes
    private _diff = _currentLevel - _lastIntelLevel;
    if (abs _diff >= 5) then {
        if (_diff > 0) then {
            diag_log format ["[OpsRoom] Command Intel: Level increased to %1%%", round _currentLevel];
        } else {
            diag_log format ["[OpsRoom] Command Intel: Level decreased to %1%%", round _currentLevel];
        };
        _lastIntelLevel = _currentLevel;
    };
    
    sleep 30;  // Check every 30 real seconds
};
