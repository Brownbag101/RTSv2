/*
    OpsRoom_fnc_unifiedZeusMonitor
    
    Unified monitoring loop combining:
    - Selection monitoring & auto-detach (0.5s interval)
    - Selective control / waypoint blocking (0.1s interval)
    - Fog of war enemy detection (1.0s interval)
    
    Optimized with staggered updates and caching for performance.
*/

// Wait for Zeus curator to exist
waitUntil {!isNull (getAssignedCuratorLogic player)};

private _curator = getAssignedCuratorLogic player;
private _lastSelection = [];

// Frame counter for staggered updates
private _frameCounter = 0;

// Selective Control state
private _lastEnemySelected = false;

// Fog of War state
OpsRoom_KnownEnemies = [];
private _friendlyCache = [];
private _lastFriendlyUpdate = 0;
private _knowledgeCache = createHashMap;
private _lastKnowledgeUpdate = 0;

// Initialize fog of war - add friendlies immediately
if (OpsRoom_Settings_FogOfWar_Enabled) then {
    {
        if ((side _x) == (side player)) then {
            _curator addCuratorEditableObjects [[_x], false];
        } else {
            _curator removeCuratorEditableObjects [[_x], false];
        };
    } forEach allUnits;
    
    // Add empty vehicles
    {
        if (count crew _x == 0) then {
            _curator addCuratorEditableObjects [[_x], false];
        };
    } forEach vehicles;
};

systemChat "✓ Zeus unified monitor started";

while {true} do {
    private _startTime = diag_tickTime;
    
    // Get currently selected units
    private _selected = curatorSelected select 0;
    
    // ========================================
    // EVERY FRAME (0.1s): Selection & Waypoint Control
    // ========================================
    
    // Update context buttons if selection changed
    if (str _selected != str _lastSelection) then {
        [_selected] call OpsRoom_fnc_updateContextButtons;
        [_selected] call OpsRoom_fnc_updateStandardButtons;
        [_selected] call OpsRoom_fnc_updateInventoryButton;
        
        // Update operation Draw3D markers for selected units
        [_selected] call OpsRoom_fnc_updateOperationMarkers;
        
        // Close inventory if unit deselected
        if (missionNamespace getVariable ["OpsRoom_InventoryOpen", false]) then {
            private _invUnit = missionNamespace getVariable ["OpsRoom_InventoryUnit", objNull];
            if (count _selected == 0 || {!(_invUnit in _selected)}) then {
                [] call OpsRoom_fnc_closeInventory;
            };
        };
        
        // Close dossier if selecting different units in Zeus
        // (Dossier is opened from regiment menu, not Zeus selection,
        //  so we only close if user actively selects something else)
        if (missionNamespace getVariable ["OpsRoom_DossierOpen", false]) then {
            if (count _selected > 0) then {
                private _dossierUnit = missionNamespace getVariable ["OpsRoom_DossierUnit", objNull];
                if (!(_dossierUnit in _selected)) then {
                    [] call OpsRoom_fnc_closeDossier;
                };
            };
        };
        
        _lastSelection = _selected;
    };
    
    // Selective Control: Block waypoints for enemy units
    if (OpsRoom_Settings_SelectiveControl_Enabled && count _selected > 0) then {
        private _hasEnemySelected = false;
        
        {
            if ((side _x) != (side player)) then {
                _hasEnemySelected = true;
            };
        } forEach _selected;
        
        if (_hasEnemySelected) then {
            _curator setCuratorWaypointCost 999999;
            
            if (OpsRoom_Settings_SelectiveControl_ShowMessages && !_lastEnemySelected) then {
                systemChat "⚠ Enemy units selected - cannot issue orders";
                _lastEnemySelected = true;
            };
        } else {
            _curator setCuratorWaypointCost 0;
            _lastEnemySelected = false;
        };
    };
    
    // ========================================
    // EVERY 5th FRAME (0.5s): Auto-Detach System
    // ========================================
    
    if (_frameCounter % 5 == 0 && count _selected > 0) then {
        // Group selected units by their groups
        private _groupHash = createHashMap;
        {
            private _unit = _x;
            private _grp = group _unit;
            private _grpID = str _grp;
            
            if (isNil {_groupHash get _grpID}) then {
                _groupHash set [_grpID, [_grp, []]];
            };
            
            private _data = _groupHash get _grpID;
            private _arr = _data select 1;
            _arr pushBack _unit;
            
        } forEach _selected;
        
        // Check each group for auto-detach only
        {
            private _grpID = _x;
            private _data = _y;
            private _grp = _data select 0;
            private _selectedFromGroup = _data select 1;
            private _allUnitsInGroup = units _grp;
            private _groupLeader = leader _grp;
            
            // Don't process sub-teams
            private _isSubTeam = !isNil {_grp getVariable "OpsRoom_IsSubTeam"};
            if (_isSubTeam) then {continue};
            
            // Check if group is locked from auto-detach
            private _isLocked = _grp getVariable ["OpsRoom_LockedFromAutoDetach", false];
            if (_isLocked) then {
                private _isEntireGroupSelected = (count _selectedFromGroup == count _allUnitsInGroup);
                if (!_isEntireGroupSelected) then {
                    _grp setVariable ["OpsRoom_LockedFromAutoDetach", false];
                    diag_log format ["[OpsRoom] Unlocking %1 - user selecting individuals for detachment", groupId _grp];
                } else {
                    diag_log format ["[OpsRoom] Skipping %1 - locked from auto-detach (manual control)", groupId _grp];
                    continue;
                };
            };
            
            // Don't detach entire groups
            private _isEntireGroupSelected = (count _selectedFromGroup == count _allUnitsInGroup);
            if (_isEntireGroupSelected) then {continue};
            
            // Filter units that can be detached
            private _unitsToDetach = _selectedFromGroup select {
                private _unit = _x;
                
                // Check cooldown
                private _cooldown = _unit getVariable ["OpsRoom_ReattachCooldown", 0];
                if (time < _cooldown) then {
                    false  // Skip - still in cooldown
                } else {
                    // Check if not already detached
                    private _hasParent = !isNil {_unit getVariable "OpsRoom_ParentGroup"};
                    if (_hasParent) then {
                        false  // Already detached
                    } else {
                        true  // Can be detached
                    };
                };
            };
            
            // Don't detach if only leader selected
            private _isOnlyLeader = (count _unitsToDetach == 1) && 
                                   {(_unitsToDetach select 0) == _groupLeader};
            
            if (count _unitsToDetach > 0 && !_isOnlyLeader) then {
                diag_log format ["[OpsRoom] Auto-detaching %1 units from %2", count _unitsToDetach, groupId _grp];
                [_unitsToDetach] call OpsRoom_fnc_autoDetachUnits;
            };
            
        } forEach _groupHash;
    };
    
    // ========================================
    // EVERY 10th FRAME (1.0s): Fog of War
    // ========================================
    
    if (_frameCounter % 10 == 0 && OpsRoom_Settings_FogOfWar_Enabled) then {
        // Update friendly cache if needed
        if (time - _lastFriendlyUpdate > OpsRoom_Settings_FogOfWar_FriendlyCacheInterval) then {
            _friendlyCache = allUnits select {(side _x) == (side player)};
            _lastFriendlyUpdate = time;
        };
        
        // Get Zeus camera position
        private _zeusPos = [0,0,0];
        private _zeusActive = !isNull (findDisplay 312);
        if (_zeusActive) then {
            _zeusPos = getPos curatorCamera;
        };
        
        // Pre-filter enemies by distance to Zeus camera
        private _maxRadius = OpsRoom_Settings_FogOfWar_DetectionRadius max OpsRoom_Settings_FogOfWar_ZeusDirectRadius;
        private _enemyUnits = allUnits select {
            (side _x) != (side player) && 
            (side _x) != civilian &&
            (_zeusActive && {_x distance2D _zeusPos < (_maxRadius * 1.5)}) // 50% buffer
        };
        
        // Update knowledge cache if needed
        if (time - _lastKnowledgeUpdate > OpsRoom_Settings_FogOfWar_CacheUpdateInterval) then {
            _knowledgeCache = createHashMap;
            {
                private _friendly = _x;
                {
                    private _enemy = _x;
                    private _key = format ["%1_%2", _friendly, _enemy];
                    _knowledgeCache set [_key, _friendly knowsAbout _enemy];
                } forEach _enemyUnits;
            } forEach _friendlyCache;
            _lastKnowledgeUpdate = time;
        };
        
        // Check for new detections
        private _newDetections = [];
        {
            private _enemyUnit = _x;
            private _isVisible = false;
            private _detectionMethod = "None";
            
            // Skip if already known
            private _alreadyKnown = false;
            {
                if (_x select 0 == _enemyUnit) exitWith {
                    _alreadyKnown = true;
                };
            } forEach OpsRoom_KnownEnemies;
            
            if (!_alreadyKnown) then {
                // Method 1: Direct Zeus observation
                if (_zeusActive && {_enemyUnit distance2D _zeusPos < OpsRoom_Settings_FogOfWar_ZeusDirectRadius}) then {
                    _isVisible = true;
                    _detectionMethod = "Zeus observation";
                };
                
                // Method 2: Knowledge-based detection
                if (!_isVisible) then {
                    {
                        private _friendlyUnit = _x;
                        private _dist = _friendlyUnit distance2D _enemyUnit;
                        
                        if (_dist < OpsRoom_Settings_FogOfWar_DetectionRadius) then {
                            private _key = format ["%1_%2", _friendlyUnit, _enemyUnit];
                            private _knowledge = _knowledgeCache getOrDefault [_key, 0];
                            
                            if (_knowledge > OpsRoom_Settings_FogOfWar_KnowledgeThreshold) then {
                                _isVisible = true;
                                _detectionMethod = format ["Detected by %1", name _friendlyUnit];
                                break;
                            };
                        };
                    } forEach _friendlyCache;
                };
                
                // Method 3: Line of sight
                if (!_isVisible) then {
                    {
                        private _friendlyUnit = _x;
                        private _dist = _friendlyUnit distance2D _enemyUnit;
                        
                        if (_dist < (OpsRoom_Settings_FogOfWar_DetectionRadius * 0.5)) then {
                            private _canSee = [_friendlyUnit, "VIEW"] checkVisibility [eyePos _friendlyUnit, eyePos _enemyUnit];
                            if (_canSee > OpsRoom_Settings_FogOfWar_LOSThreshold) then {
                                _isVisible = true;
                                _detectionMethod = format ["Visual by %1", name _friendlyUnit];
                                break;
                            };
                        };
                    } forEach _friendlyCache;
                };
                
                // Add to new detections
                if (_isVisible) then {
                    _newDetections pushBack [_enemyUnit, _detectionMethod, time];
                };
            };
        } forEach _enemyUnits;
        
        // Process new detections
        {
            private _enemy = _x select 0;
            private _method = _x select 1;
            
            _curator addCuratorEditableObjects [[_enemy], false];
            OpsRoom_KnownEnemies pushBack _x;
            
            if (OpsRoom_Settings_FogOfWar_ShowDetections && _method != "Zeus observation") then {
                private _enemyName = if (_enemy isKindOf "CAManBase") then {
                    getText (configOf _enemy >> "displayName")
                } else {
                    getText (configOf _enemy >> "displayName")
                };
                systemChat format ["[OpsRoom] Enemy detected: %1 (%2) at %3m", 
                    _enemyName, 
                    side _enemy,
                    round(player distance _enemy)
                ];
            };
        } forEach _newDetections;
        
        // Cleanup old/null enemies
        private _toRemove = [];
        {
            private _entry = _x;
            private _enemy = _entry select 0;
            private _detectionTime = _entry select 2;
            
            if (isNull _enemy || !alive _enemy) then {
                _toRemove pushBack _forEachIndex;
            } else {
                // Remove if timeout reached and not in Zeus view
                if (time - _detectionTime > OpsRoom_Settings_FogOfWar_RemovalTimeout) then {
                    if (!(_zeusActive && {_enemy distance2D _zeusPos < OpsRoom_Settings_FogOfWar_ZeusDirectRadius})) then {
                        _curator removeCuratorEditableObjects [[_enemy], false];
                        _toRemove pushBack _forEachIndex;
                    };
                };
            };
        } forEach OpsRoom_KnownEnemies;
        
        // Remove from array (reverse order to avoid index shifting)
        _toRemove sort false;
        {
            OpsRoom_KnownEnemies deleteAt _x;
        } forEach _toRemove;
    };
    
    // Increment frame counter
    _frameCounter = _frameCounter + 1;
    
    // Adaptive sleep based on processing time
    private _elapsed = diag_tickTime - _startTime;
    private _sleepTime = (0.1 - _elapsed) max 0.05;
    sleep _sleepTime;
};
