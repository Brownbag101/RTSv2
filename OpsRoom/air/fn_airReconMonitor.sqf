/*
    Air Operations - Aerial Reconnaissance Monitor
    
    Handles two distinct recon behaviours:
    
    1. ENEMY MOVEMENT SPOTTING (recon_spotting mission)
       - Aircraft circles at medium altitude (300m)
       - Reveals enemies to Zeus in real-time
       - Altitude is periodically clamped to prevent AI climbing
       - Feeds into existing fog of war visibility system
    
    2. PHOTO RECON (recon_photo_high / recon_photo_low missions)
       - Aircraft flies a straight-line pass over target area
       - "Photographs" strategic locations within scan radius
       - Stores results on wing data — NOT applied until landing
       - See fn_photoReconMonitor for the scanning logic
    
    Called once at init from fn_initHangar. Runs continuously.
*/

// Remove existing handler if present
if (!isNil "OpsRoom_AirRecon_Handle") then {
    terminate OpsRoom_AirRecon_Handle;
};

OpsRoom_AirRecon_Handle = [] spawn {
    // Wait for air system to be ready
    waitUntil { sleep 1; !isNil "OpsRoom_AirWings" };
    
    while { true } do {
        sleep 10;  // Check every 10 seconds
        
        {
            private _wingId = _x;
            private _wingData = _y;
            
            private _status = _wingData get "status";
            private _mission = _wingData get "mission";
            
            // Only process airborne wings
            if (_status != "AIRBORNE") then { continue };
            
            // ============================================================
            // ENEMY MOVEMENT SPOTTING
            // ============================================================
            if (_mission == "recon_spotting") then {
                
                private _spawnedObjects = _wingData get "spawnedObjects";
                private _wingName = _wingData get "name";
                
                // Initialize known enemies if needed
                if (isNil "OpsRoom_KnownEnemies") then {
                    OpsRoom_KnownEnemies = [];
                };
                
                {
                    private _obj = _x;
                    if !(_obj isKindOf "Air") then { continue };
                    if (!alive _obj) then { continue };
                    
                    // === ALTITUDE CLAMP ===
                    // Prevent ARMA AI from climbing indefinitely during loiter
                    private _currentAlt = (getPosATL _obj) select 2;
                    private _targetAlt = 300;
                    
                    if (_currentAlt > _targetAlt + 50) then {
                        // Force altitude correction
                        _obj flyInHeight _targetAlt;
                        
                        // If way too high, use velocity correction
                        if (_currentAlt > _targetAlt + 150) then {
                            private _vel = velocity _obj;
                            _obj setVelocity [_vel select 0, _vel select 1, -5];
                        };
                    };
                    
                    // === SCAN FOR ENEMIES ===
                    private _scanPos = getPos _obj;
                    private _scanRadius = 1200;  // 1.2km spotting radius
                    
                    private _nearUnits = _scanPos nearEntities [["CAManBase", "LandVehicle", "StaticWeapon", "Ship"], _scanRadius];
                    private _newContacts = 0;
                    
                    {
                        private _enemy = _x;
                        if (!alive _enemy) then { continue };
                        
                        private _enemySide = side _enemy;
                        if (_enemySide == independent || _enemySide == civilian) then { continue };
                        
                        // Check not already known
                        private _alreadyKnown = false;
                        {
                            if ((_x select 0) isEqualTo _enemy) exitWith { _alreadyKnown = true };
                        } forEach OpsRoom_KnownEnemies;
                        
                        if (!_alreadyKnown) then {
                            // Reveal to Zeus via existing system
                            [_enemy, "Aerial Spotting"] call OpsRoom_fnc_revealEnemy;
                            _newContacts = _newContacts + 1;
                        };
                    } forEach _nearUnits;
                    
                    if (_newContacts > 0) then {
                        ["PRIORITY", format ["SPOTTING: %1", _wingName],
                            format ["%1 reports %2 new enemy contact(s) in target area.", _wingName, _newContacts]
                        ] call OpsRoom_fnc_dispatch;
                        
                        systemChat format ["%1: %2 new contacts spotted", _wingName, _newContacts];
                        diag_log format ["[OpsRoom] Air Recon Spotting: %1 spotted %2 contacts", _wingName, _newContacts];
                    };
                    
                    // === INTEL GATHERING on nearby strategic locations ===
                    {
                        private _locId = _x;
                        private _locData = _y;
                        private _locPos = _locData get "pos";
                        private _locStatus = _locData getOrDefault ["status", ""];
                        
                        if (_locStatus == "friendly") then { continue };
                        
                        private _dist = _scanPos distance2D _locPos;
                        if (_dist < _scanRadius) then {
                            private _currentIntel = _locData get "intelPercent";
                            // Aerial spotting: +3% per tick, capped at 44% (tier 2)
                            private _gain = 3;
                            private _cap = 44;
                            private _newIntel = ((_currentIntel + _gain) min _cap);
                            
                            if (_newIntel > _currentIntel) then {
                                _locData set ["intelPercent", _newIntel];
                                _locData set ["intelTier", [_newIntel] call OpsRoom_fnc_getIntelLevel];
                                _locData set ["lastUpdated", time];
                                
                                if !(_locData get "discovered") then {
                                    _locData set ["discovered", true];
                                    ["PRIORITY", "AERIAL CONTACT",
                                        format ["%1 has detected a location near grid %2!", _wingName, mapGridPosition _locPos],
                                        _locPos
                                    ] call OpsRoom_fnc_dispatch;
                                };
                                
                                OpsRoom_StrategicLocations set [_locId, _locData];
                                [_locId] call OpsRoom_fnc_updateMapMarkers;
                            };
                        };
                    } forEach OpsRoom_StrategicLocations;
                } forEach _spawnedObjects;
            };
            
            // ============================================================
            // SEA LANE PATROL — same spotting logic as recon_spotting
            // ============================================================
            if (_mission == "sealane_patrol") then {
                
                private _spawnedObjects = _wingData get "spawnedObjects";
                private _wingName = _wingData get "name";
                
                if (isNil "OpsRoom_KnownEnemies") then {
                    OpsRoom_KnownEnemies = [];
                };
                
                {
                    private _obj = _x;
                    if !(_obj isKindOf "Air") then { continue };
                    if (!alive _obj) then { continue };
                    
                    // Altitude clamp
                    private _currentAlt = (getPosATL _obj) select 2;
                    private _targetAlt = 250;
                    if (_currentAlt > _targetAlt + 50) then {
                        _obj flyInHeight _targetAlt;
                        if (_currentAlt > _targetAlt + 150) then {
                            private _vel = velocity _obj;
                            _obj setVelocity [_vel select 0, _vel select 1, -5];
                        };
                    };
                    
                    // Scan for enemies (ships + ground units)
                    private _scanPos = getPos _obj;
                    private _scanRadius = 1500;  // Wider scan for sea patrol
                    
                    private _nearUnits = _scanPos nearEntities [["CAManBase", "LandVehicle", "StaticWeapon", "Ship"], _scanRadius];
                    private _newContacts = 0;
                    
                    {
                        private _enemy = _x;
                        if (!alive _enemy) then { continue };
                        
                        private _enemySide = side _enemy;
                        if (_enemySide == independent || _enemySide == civilian) then { continue };
                        
                        private _alreadyKnown = false;
                        {
                            if ((_x select 0) isEqualTo _enemy) exitWith { _alreadyKnown = true };
                        } forEach OpsRoom_KnownEnemies;
                        
                        if (!_alreadyKnown) then {
                            [_enemy, "Sea Lane Patrol"] call OpsRoom_fnc_revealEnemy;
                            _newContacts = _newContacts + 1;
                        };
                    } forEach _nearUnits;
                    
                    if (_newContacts > 0) then {
                        ["PRIORITY", format ["SEA PATROL: %1", _wingName],
                            format ["%1 reports %2 new contact(s) along shipping lane.", _wingName, _newContacts]
                        ] call OpsRoom_fnc_dispatch;
                        
                        systemChat format ["%1: %2 new contacts spotted along sea lane", _wingName, _newContacts];
                        diag_log format ["[OpsRoom] Sea Lane Patrol: %1 spotted %2 contacts", _wingName, _newContacts];
                    };
                    
                    // === INTEL GATHERING on nearby strategic locations ===
                    {
                        private _locId = _x;
                        private _locData = _y;
                        private _locPos = _locData get "pos";
                        private _locStatus = _locData getOrDefault ["status", ""];
                        
                        if (_locStatus == "friendly") then { continue };
                        
                        private _dist = _scanPos distance2D _locPos;
                        if (_dist < _scanRadius) then {
                            private _currentIntel = _locData get "intelPercent";
                            // Sea lane patrol: +2% per tick, capped at 44% (tier 2)
                            private _gain = 2;
                            private _cap = 44;
                            private _newIntel = ((_currentIntel + _gain) min _cap);
                            
                            if (_newIntel > _currentIntel) then {
                                _locData set ["intelPercent", _newIntel];
                                _locData set ["intelTier", [_newIntel] call OpsRoom_fnc_getIntelLevel];
                                _locData set ["lastUpdated", time];
                                
                                if !(_locData get "discovered") then {
                                    _locData set ["discovered", true];
                                    ["PRIORITY", "SEA PATROL CONTACT",
                                        format ["%1 has detected a location near grid %2!", _wingName, mapGridPosition _locPos],
                                        _locPos
                                    ] call OpsRoom_fnc_dispatch;
                                };
                                
                                OpsRoom_StrategicLocations set [_locId, _locData];
                                [_locId] call OpsRoom_fnc_updateMapMarkers;
                            };
                        };
                    } forEach OpsRoom_StrategicLocations;
                } forEach _spawnedObjects;
            };
            
            // Photo recon altitude clamp (same as spotting but different altitudes)
            if (_mission == "recon_photo_high" || _mission == "recon_photo_low") then {
                private _spawnedObjects = _wingData get "spawnedObjects";
                private _targetAlt = if (_mission == "recon_photo_high") then { 500 } else { 300 };
                
                {
                    private _obj = _x;
                    if !(_obj isKindOf "Air") then { continue };
                    if (!alive _obj) then { continue };
                    
                    private _currentAlt = (getPosATL _obj) select 2;
                    if (_currentAlt > _targetAlt + 50) then {
                        _obj flyInHeight _targetAlt;
                    };
                } forEach _spawnedObjects;
            };
            
        } forEach OpsRoom_AirWings;
    };
};

diag_log "[OpsRoom] Air: Aerial recon monitor initialized";
