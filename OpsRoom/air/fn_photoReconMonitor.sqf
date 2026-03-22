/*
    Air Operations - Photo Reconnaissance Monitor
    
    Runs while photo recon wings are airborne (LOITER waypoints).
    
    Jobs:
    1. Scan: Photographs strategic locations within range as aircraft circle
    2. Altitude clamp: Periodically forces flyInHeight to prevent climbing
    3. Auto-RTB: After aircraft has been near target for a set time, triggers
       landWing automatically (out-and-back sortie pattern)
    
    Scan radius:
        recon_photo_high: 2000m, +10% per location
        recon_photo_low:  800m, +30% per location
    
    Called once at init. Runs continuously.
*/

if (!isNil "OpsRoom_PhotoRecon_Handle") then {
    terminate OpsRoom_PhotoRecon_Handle;
};

OpsRoom_PhotoRecon_Handle = [] spawn {
    waitUntil { sleep 1; !isNil "OpsRoom_AirWings" };
    
    while { true } do {
        sleep 8;
        
        private _wingIds = keys OpsRoom_AirWings;
        
        {
            private _wingId = _x;
            private _wingData = OpsRoom_AirWings getOrDefault [_wingId, createHashMap];
            if (count _wingData == 0) then { continue };
            
            private _status = _wingData get "status";
            private _mission = _wingData get "mission";
            
            if (_status != "AIRBORNE") then { continue };
            if (_mission != "recon_photo_high" && _mission != "recon_photo_low") then { continue };
            
            private _spawnedObjects = _wingData get "spawnedObjects";
            private _wingName = _wingData get "name";
            private _missionTarget = _wingData getOrDefault ["missionTarget", []];
            
            if (count _missionTarget == 0) then { continue };
            
            private _scanRadius = if (_mission == "recon_photo_high") then { 2000 } else { 800 };
            private _intelGain = if (_mission == "recon_photo_high") then { 10 } else { 30 };
            private _targetAlt = if (_mission == "recon_photo_high") then { 500 } else { 300 };
            
            private _photoIntel = _wingData getOrDefault ["photoIntel", createHashMap];
            
            // ============================================
            // SCAN + ALTITUDE CLAMP
            // ============================================
            
            private _anyNearTarget = false;
            
            {
                private _obj = _x;
                if !(_obj isKindOf "Air") then { continue };
                if (!alive _obj) then { continue };
                
                private _acPos = getPos _obj;
                
                // Altitude clamp — prevent climbing
                private _currentAlt = (getPosATL _obj) select 2;
                if (_currentAlt > _targetAlt + 50) then {
                    _obj flyInHeight _targetAlt;
                    
                    // Strong correction if way too high
                    if (_currentAlt > _targetAlt + 150) then {
                        private _vel = velocity _obj;
                        _obj setVelocity [_vel select 0, _vel select 1, -3];
                    };
                };
                
                // Check if near target
                if (_acPos distance2D _missionTarget < _scanRadius + 500) then {
                    _anyNearTarget = true;
                };
                
                // Photograph locations
                {
                    private _locId = _x;
                    private _locData = _y;
                    private _locPos = _locData get "pos";
                    private _dist = _acPos distance2D _locPos;
                    
                    if (_dist < _scanRadius) then {
                        private _existingGain = _photoIntel getOrDefault [_locId, 0];
                        
                        if (_intelGain > _existingGain) then {
                            _photoIntel set [_locId, _intelGain];
                            
                            if !(_locData get "discovered") then {
                                _locData set ["discovered", true];
                                OpsRoom_StrategicLocations set [_locId, _locData];
                            };
                            
                            if (_existingGain == 0) then {
                                private _locName = _locData get "name";
                                systemChat format ["%1: Photographing %2", _wingName, _locName];
                                diag_log format ["[OpsRoom] Photo Recon: %1 photographed %2 (+%3%%)", _wingName, _locId, _intelGain];
                            };
                        };
                    };
                } forEach OpsRoom_StrategicLocations;
                
            } forEach _spawnedObjects;
            
            _wingData set ["photoIntel", _photoIntel];
            
            // ============================================
            // AUTO-RTB: after 60s near target, head home
            // ============================================
            
            // Track when aircraft first arrived near target
            if (_anyNearTarget) then {
                private _arrivalTime = _wingData getOrDefault ["reconArrivalTime", 0];
                if (_arrivalTime == 0) then {
                    _wingData set ["reconArrivalTime", time];
                    systemChat format ["%1: On station. Photographing target area.", _wingName];
                } else {
                    // Been near target for 60 seconds? RTB
                    if (time - _arrivalTime > 60) then {
                        systemChat format ["%1: Photo pass complete. Returning to base.", _wingName];
                        diag_log format ["[OpsRoom] Photo Recon: %1 time on station complete, triggering RTB", _wingId];
                        _wingData set ["reconArrivalTime", 0];
                        [_wingId] call OpsRoom_fnc_landWing;
                    };
                };
            };
            
        } forEach _wingIds;
    };
};

diag_log "[OpsRoom] Air: Photo recon monitor initialized";
