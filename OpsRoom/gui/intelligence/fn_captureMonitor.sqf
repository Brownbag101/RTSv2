/*
    fn_captureMonitor
    
    Background loop checking force balance at all strategic locations.
    Runs every 10 seconds. Determines contested state, capture progress,
    and ownership flips.
    
    Capture Rules:
        - Attackers must outnumber defenders 2:1 to make progress
        - 1:1 to 2:1 ratio = CONTESTED (no progress change)
        - Defenders regain superiority = progress bleeds back (half speed)
        - 100% progress = ownership flips
        - Only counts alive infantry ("Man" class) within capture radius
    
    On ownership flip:
        - FLASH dispatch if British location lost to enemy
        - PRIORITY dispatch if location captured by British
        - Intel resets to 50% when British location falls to enemy
        - Status field updated for intel card display
*/

// Don't start multiple monitors
if (!isNil "OpsRoom_CaptureMonitorRunning" && {OpsRoom_CaptureMonitorRunning}) exitWith {
    systemChat "Capture Monitor already running";
};

OpsRoom_CaptureMonitorRunning = true;

private _tickInterval = 10;  // seconds between checks
private _playerSide = side player;

systemChat format ["Capture: Monitor started (%1s cycle)", _tickInterval];
diag_log "[OpsRoom] Capture monitor started";

while {OpsRoom_CaptureMonitorRunning} do {
    
    {
        private _locId = _x;
        private _locData = _y;
        
        // Skip destroyed locations
        if ((_locData get "status") != "destroyed") then {
        
        private _pos = _locData get "pos";
        private _owner = _locData getOrDefault ["owner", "NAZI"];
        private _radius = _locData getOrDefault ["captureRadius", 200];
        private _captureTime = _locData getOrDefault ["captureTime", 300];
        private _progress = _locData getOrDefault ["captureProgress", 0];
        private _name = _locData get "name";
        
        // Count alive units by side within radius
        private _nearUnits = _pos nearEntities ["Man", _radius];
        
        private _britishCount = 0;
        private _naziCount = 0;
        
        {
            if (alive _x) then {
                private _unitSide = side group _x;
                if (_unitSide == _playerSide) then {
                    _britishCount = _britishCount + 1;
                } else {
                    if (_unitSide != civilian) then {
                        _naziCount = _naziCount + 1;
                    };
                };
            };
        } forEach _nearUnits;
        
        // Determine situation
        private _attackerCount = 0;
        private _defenderCount = 0;
        private _attackDirection = "none";  // who is attacking
        
        if (_owner == "BRITISH") then {
            // British own it — Nazis attack
            _attackerCount = _naziCount;
            _defenderCount = _britishCount;
            _attackDirection = "nazi";
        } else {
            // Nazi/Neutral own it — British attack
            _attackerCount = _britishCount;
            _defenderCount = _naziCount;
            _attackDirection = "british";
        };
        
        private _wasContested = _locData getOrDefault ["contested", false];
        private _oldProgress = _progress;
        private _newContested = false;
        private _progressChanged = false;
        
        // Nobody here or only one side
        if (_attackerCount == 0 && _defenderCount == 0) then {
            // Empty — progress bleeds towards 0 slowly
            if (_progress > 0) then {
                private _bleed = (_tickInterval / _captureTime) * 100 * 0.25;
                _progress = (_progress - _bleed) max 0;
                _progressChanged = true;
            };
            _newContested = false;
        } else {
            if (_attackerCount == 0) then {
                // Defenders only — progress bleeds back fast
                if (_progress > 0) then {
                    private _bleed = (_tickInterval / _captureTime) * 100 * 0.5;
                    _progress = (_progress - _bleed) max 0;
                    _progressChanged = true;
                };
                _newContested = false;
            } else {
                if (_defenderCount == 0) then {
                    // Attackers only, no defenders — fast capture (double rate)
                    private _gain = (_tickInterval / _captureTime) * 100 * 2.0;
                    _progress = (_progress + _gain) min 100;
                    _progressChanged = true;
                    _newContested = true;
                } else {
                    // Both sides present
                    private _ratio = _attackerCount / (_defenderCount max 1);
                    
                    if (_ratio >= 2.0) then {
                        // 2:1+ attackers — progress advances
                        // Scale rate with ratio: 2:1 = base, 3:1 = 1.5x, 4:1+ = 2x
                        private _rateMultiplier = ((_ratio - 2.0) * 0.5 + 1.0) min 2.0;
                        private _gain = (_tickInterval / _captureTime) * 100 * _rateMultiplier;
                        _progress = (_progress + _gain) min 100;
                        _progressChanged = true;
                    } else {
                        if (_ratio < 0.5) then {
                            // Defenders have 2:1+ — progress bleeds back
                            private _bleed = (_tickInterval / _captureTime) * 100 * 0.5;
                            _progress = (_progress - _bleed) max 0;
                            _progressChanged = true;
                        };
                        // else: 0.5 to 2.0 ratio — stalemate, no progress change
                    };
                    
                    _newContested = true;
                };
            };
        };
        
        // ========================================
        // OWNERSHIP FLIP CHECK
        // ========================================
        if (_progress >= 100) then {
            private _oldOwner = _owner;
            private _newOwner = if (_attackDirection == "british") then { "BRITISH" } else { "NAZI" };
            
            _locData set ["owner", _newOwner];
            _locData set ["previousOwner", _oldOwner];
            _locData set ["capturedTime", time];
            _locData set ["captureProgress", 0];
            _locData set ["captureDirection", "none"];
            _locData set ["contested", false];
            _progress = 0;
            _newContested = false;
            
            // Update status field for intel card
            if (_newOwner == "BRITISH") then {
                _locData set ["status", "friendly"];
                
                // PRIORITY dispatch — location secured
                ["PRIORITY", "LOCATION SECURED", format ["%1 has been captured by British forces!", _name], _pos] call OpsRoom_fnc_dispatch;
                
                diag_log format ["[OpsRoom] CAPTURED: %1 is now BRITISH (was %2)", _name, _oldOwner];
            } else {
                _locData set ["status", "enemy"];
                
                // FLASH dispatch — location lost
                ["FLASH", "LOCATION LOST", format ["%1 has fallen to the enemy!", _name], _pos] call OpsRoom_fnc_dispatch;
                
                // Intel reset to 50% when British location falls
                private _oldIntel = _locData get "intelPercent";
                _locData set ["intelPercent", 50];
                _locData set ["intelTier", [50] call OpsRoom_fnc_getIntelLevel];
                
                diag_log format ["[OpsRoom] LOST: %1 is now NAZI (was %2). Intel reset: %3%% → 50%%", _name, _oldOwner, round _oldIntel];
            };
            
            // Update map marker immediately
            OpsRoom_StrategicLocations set [_locId, _locData];
            [_locId] call OpsRoom_fnc_updateMapMarkers;
        } else {
        
        // ========================================
        // UPDATE STATE (only if no flip this tick)
        // ========================================
        if (_progressChanged) then {
            _locData set ["captureProgress", _progress];
            _locData set ["captureDirection", if (_progress > 0) then { _attackDirection } else { "none" }];
        };
        
        // Contested state change — dispatch on first contest
        if (_newContested != _wasContested) then {
            _locData set ["contested", _newContested];
            
            if (_newContested && _progress > 5) then {
                // Just became contested
                if (_owner == "BRITISH") then {
                    ["FLASH", "LOCATION UNDER ATTACK", format ["%1 is under enemy attack!", _name], _pos] call OpsRoom_fnc_dispatch;
                } else {
                    ["ROUTINE", "ENGAGEMENT", format ["Forces engaging at %1", _name], _pos] call OpsRoom_fnc_dispatch;
                };
            };
        };
        
        // Update in global hashmap
        OpsRoom_StrategicLocations set [_locId, _locData];
        
        // Update marker if progress changed significantly or contested changed
        if (_progressChanged || (_newContested != _wasContested)) then {
            [_locId] call OpsRoom_fnc_updateMapMarkers;
        };
        
        }; // end else (no flip)
        }; // end if not destroyed
    } forEach OpsRoom_StrategicLocations;
    
    sleep _tickInterval;
};
