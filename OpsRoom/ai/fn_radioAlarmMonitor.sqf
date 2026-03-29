/*
    fn_radioAlarmMonitor
    
    Background loop monitoring enemy locations for combat.
    When garrison units enter COMBAT behaviour, selects the nearest
    alive enemy unit to the radio and sends them to it.
    
    Shows Draw3D marker on the running radioman.
    If the unit reaches the radio, triggers fn_radioCallback.
    If the unit is killed, no alarm is sent.
    
    Each location can only trigger ONE radio alarm.
    Once sent (or radio destroyed), that location is done.
    
    Called from init.sqf:
        [] spawn OpsRoom_fnc_radioAlarmMonitor;
*/

// Don't start multiple monitors
if (!isNil "OpsRoom_RadioMonitorRunning" && {OpsRoom_RadioMonitorRunning}) exitWith {
    systemChat "Radio Monitor already running";
};

OpsRoom_RadioMonitorRunning = true;

// Track active radiomen (for Draw3D)
if (isNil "OpsRoom_AI_ActiveRadiomen") then {
    OpsRoom_AI_ActiveRadiomen = [];
};

systemChat "AI Radio: Alarm monitor started";
diag_log "[OpsRoom] Radio alarm monitor started";

while {OpsRoom_RadioMonitorRunning} do {
    
    {
        private _locId = _x;
        private _locData = _y;
        
        // Skip if alarm already sent for this location
        if (_locData getOrDefault ["radioAlarmSent", false]) then { continue };
        
        // Skip non-enemy locations
        if ((_locData getOrDefault ["owner", "NAZI"]) != "NAZI") then { continue };
        
        // Check radio exists and is alive
        private _radio = _locData getOrDefault ["radioObject", objNull];
        if (isNull _radio || !alive _radio) then {
            // Radio destroyed — mark as done (no alarm possible)
            _locData set ["radioAlarmSent", true];
            OpsRoom_StrategicLocations set [_locId, _locData];
            if (!isNull _radio && !alive _radio) then {
                diag_log format ["[OpsRoom] Radio: Radio at %1 destroyed — no alarm possible", _locData get "name"];
            };
            continue;
        };
        
        // Scan for enemy units in combat near this location
        private _pos = _locData get "pos";
        private _radius = _locData getOrDefault ["captureRadius", 200];
        private _nearUnits = _pos nearEntities ["Man", _radius];
        private _enemyUnits = _nearUnits select {
            alive _x &&
            side group _x != side player &&
            side group _x != civilian &&
            !(_x getVariable ["OpsRoom_AI_IsRadioman", false])
        };
        
        // Check if any enemy unit is in COMBAT or AWARE behaviour
        // (editor-placed units may not flip straight to COMBAT)
        private _inCombat = false;
        {
            if (behaviour _x in ["COMBAT", "AWARE"]) exitWith { _inCombat = true };
        } forEach _enemyUnits;
        
        // Also trigger if the location is contested (capture in progress)
        if (!_inCombat) then {
            if (_locData getOrDefault ["contested", false]) then {
                _inCombat = true;
            };
        };
        
        if (!_inCombat) then { continue };
        
        // COMBAT DETECTED — find nearest unit to radio
        private _radioPos = getPosATL _radio;
        private _maxRunDist = OpsRoom_AI_RadioMaxRunDistance;
        
        // Filter to units close enough to reach radio
        private _candidates = _enemyUnits select {
            (getPosATL _x) distance2D _radioPos < _maxRunDist
        };
        
        if (count _candidates == 0) then { continue };
        
        // Sort by distance to radio
        _candidates = _candidates apply {[(getPosATL _x) distance2D _radioPos, _x]};
        _candidates sort true;
        private _radioman = (_candidates select 0) select 1;
        
        // Mark as radioman
        _radioman setVariable ["OpsRoom_AI_IsRadioman", true, true];
        
        // Mark location alarm as in progress
        _locData set ["radioAlarmSent", true];
        OpsRoom_StrategicLocations set [_locId, _locData];
        
        // Track for Draw3D
        OpsRoom_AI_ActiveRadiomen pushBack [_radioman, _locId, _locData get "name"];
        
        diag_log format ["[OpsRoom] Radio: Combat at %1! Radioman selected, running to radio (%2m away)",
            _locData get "name", round ((getPosATL _radioman) distance2D _radioPos)];
        
        // Send the radioman to the radio (async)
        [_radioman, _radio, _locId, _locData get "name", _radioPos] spawn {
            params ["_unit", "_radio", "_locId", "_locName", "_radioPos"];
            
            // Clear current orders and run to radio
            private _grp = group _unit;
            
            // Don't mess with the whole group — just this unit
            // doMove sends just the individual unit
            _unit doMove _radioPos;
            _unit setUnitPos "UP";  // Stand and run
            _unit setSpeedMode "FULL";
            
            // Wait for unit to reach radio or die
            private _timeout = 60;  // Max 60 seconds to reach radio
            private _reached = false;
            
            while {_timeout > 0} do {
                if (!alive _unit) exitWith {
                    diag_log format ["[OpsRoom] Radio: Radioman at %1 killed before reaching radio!", _locName];
                    ["PRIORITY", "RADIOMAN DOWN", format ["Enemy radioman at %1 eliminated before reaching the radio!", _locName], _radioPos] call OpsRoom_fnc_dispatch;
                };
                
                if (!alive _radio) exitWith {
                    diag_log format ["[OpsRoom] Radio: Radio at %1 destroyed while radioman was en route!", _locName];
                    ["PRIORITY", "RADIO DESTROYED", format ["Radio at %1 has been destroyed!", _locName], _radioPos] call OpsRoom_fnc_dispatch;
                };
                
                if ((getPosATL _unit) distance2D _radioPos < 3) exitWith {
                    _reached = true;
                };
                
                sleep 1;
                _timeout = _timeout - 1;
            };
            
            // Remove from active radiomen draw3D list
            OpsRoom_AI_ActiveRadiomen = OpsRoom_AI_ActiveRadiomen select {
                alive (_x select 0) && (_x select 1) != _locId
            };
            
            if (_reached) then {
                // Unit reached the radio — start transmission
                [_unit, _radio, _locId, _locName, _radioPos] call OpsRoom_fnc_radioCallback;
            } else {
                if (alive _unit && alive _radio) then {
                    // Timed out — unit couldn't reach radio (probably suppressed)
                    diag_log format ["[OpsRoom] Radio: Radioman at %1 timed out reaching radio", _locName];
                    _unit setVariable ["OpsRoom_AI_IsRadioman", false, true];
                };
            };
        };
        
    } forEach OpsRoom_StrategicLocations;
    
    sleep 5;  // Check every 5 seconds
};
