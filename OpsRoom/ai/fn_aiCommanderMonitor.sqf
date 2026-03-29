/*
    fn_aiCommanderMonitor
    
    Main AI Commander decision loop.
    Runs every OpsRoom_AI_TurnInterval in-game hours.
    
    Each turn:
        1. Count enemy-held barracks → determine max active groups
        2. Scan strategic locations for situations needing response
        3. Prioritise targets (counter-attack > reinforce > garrison > patrol)
        4. Spawn and deploy groups within manpower budget
        5. Log all decisions to enemy intel dispatch
    
    Radio alarms bypass the turn timer — handled by fn_radioCallback.
    
    Called from init.sqf:
        [] spawn OpsRoom_fnc_aiCommanderMonitor;
*/

// Don't start multiple monitors
if (!isNil "OpsRoom_AI_MonitorRunning" && {OpsRoom_AI_MonitorRunning}) exitWith {
    systemChat "AI Commander: Monitor already running";
};

OpsRoom_AI_MonitorRunning = true;

// Track active AI commander groups
if (isNil "OpsRoom_AI_ActiveGroups") then {
    OpsRoom_AI_ActiveGroups = [];
};

// Track which locations have been lost (for counter-attack detection)
if (isNil "OpsRoom_AI_KnownOwnership") then {
    OpsRoom_AI_KnownOwnership = createHashMap;
    // Snapshot initial ownership
    {
        OpsRoom_AI_KnownOwnership set [_x, (_y get "owner")];
    } forEach OpsRoom_StrategicLocations;
};

private _turnInterval = OpsRoom_AI_TurnInterval;  // in-game hours

systemChat format ["AI Commander: Monitor started (turn every %1 in-game hrs)", _turnInterval];
diag_log "[OpsRoom] AI Commander monitor started";

// Log to dispatch
["ROUTINE", "ENEMY COMMAND", "Enemy commander has established command and control.", [0,0,0]] call OpsRoom_fnc_dispatch;

// Wait one full turn before first action (let mission settle)
private _lastTurnTime = daytime;

while {OpsRoom_AI_MonitorRunning} do {
    
    // Wait for next turn
    private _elapsed = daytime - _lastTurnTime;
    // Handle midnight rollover (daytime resets at 24)
    if (_elapsed < 0) then { _elapsed = _elapsed + 24 };
    
    if (_elapsed < _turnInterval) then {
        sleep 10;  // Check every 10 real seconds
        continue;
    };
    
    _lastTurnTime = daytime;
    
    diag_log "[OpsRoom] AI Commander: === TURN START ===";
    
    // ========================================
    // 1. CLEANUP DEAD GROUPS
    // ========================================
    private _aliveGroups = [];
    {
        private _grpData = _x;
        private _grp = _grpData get "group";
        private _alive = {alive _x} count (units _grp);
        
        if (_alive > 0) then {
            _aliveGroups pushBack _grpData;
        } else {
            private _templateName = _grpData getOrDefault ["templateName", "Unknown"];
            private _targetName = _grpData getOrDefault ["targetName", "Unknown"];
            diag_log format ["[OpsRoom] AI Commander: Group '%1' heading to %2 eliminated", _templateName, _targetName];
            ["ROUTINE", "ENEMY LOSSES", format ["Enemy %1 en route to %2 has been destroyed.", _templateName, _targetName], _grpData getOrDefault ["targetPos", [0,0,0]]] call OpsRoom_fnc_dispatch;
        };
    } forEach OpsRoom_AI_ActiveGroups;
    OpsRoom_AI_ActiveGroups = _aliveGroups;
    
    // ========================================
    // 2. CALCULATE MAX ACTIVE GROUPS
    // ========================================
    // Dynamic group cap based on all enemy-held locations
    //   Base: 2
    //   +1 per barracks, motorpool, airfield, HQ
    //   +2 per port
    //   +0.5 per town/village (floored)
    private _groupBonus = 0;
    private _enemyBarracks = 0;
    private _settlementCount = 0;
    {
        private _locData = _y;
        private _owner = _locData getOrDefault ["owner", "NAZI"];
        if (_owner != "NAZI") then { continue };
        if ((_locData get "status") == "destroyed") then { continue };
        
        private _type = _locData get "type";
        switch (_type) do {
            case "barracks":  { _groupBonus = _groupBonus + 1; _enemyBarracks = _enemyBarracks + 1; };
            case "motorpool": { _groupBonus = _groupBonus + 1; };
            case "port":      { _groupBonus = _groupBonus + 2; };
            case "airfield":  { _groupBonus = _groupBonus + 1; };
            case "hq":        { _groupBonus = _groupBonus + 1; };
            case "town":      { _settlementCount = _settlementCount + 1; };
            case "village":   { _settlementCount = _settlementCount + 1; };
        };
    } forEach OpsRoom_StrategicLocations;
    _groupBonus = _groupBonus + (floor (_settlementCount / 2));
    
    private _maxGroups = OpsRoom_AI_BaseMaxGroups + _groupBonus;
    private _availableSlots = _maxGroups - (count OpsRoom_AI_ActiveGroups);
    private _manpower = OpsRoom_AI_Manpower;
    
    diag_log format ["[OpsRoom] AI Commander: Manpower=%1, ActiveGroups=%2/%3, LocBonus=%4, Barracks=%5, Slots=%6",
        _manpower, count OpsRoom_AI_ActiveGroups, _maxGroups, _groupBonus, _enemyBarracks, _availableSlots];
    
    // ========================================
    // 3. ASSESS STRATEGIC SITUATION
    // ========================================
    private _tasks = [];  // [[priority, missionType, locId, locName, locPos], ...]
    
    {
        private _locId = _x;
        private _locData = _y;
        private _owner = _locData getOrDefault ["owner", "NAZI"];
        private _prevKnownOwner = OpsRoom_AI_KnownOwnership getOrDefault [_locId, "NAZI"];
        private _status = _locData get "status";
        private _name = _locData get "name";
        private _pos = _locData get "pos";
        private _type = _locData get "type";
        private _contested = _locData getOrDefault ["contested", false];
        
        // Skip destroyed locations
        if (_status == "destroyed") then { continue };
        
        // Skip locations the AI shouldn't care about
        if (_type in ["sealane", "stores", "checkpoint"]) then { continue };
        
        // COUNTER-ATTACK: Was NAZI, now BRITISH → recapture
        if (_prevKnownOwner == "NAZI" && _owner == "BRITISH") then {
            _tasks pushBack [OpsRoom_AI_Priority_CounterAttack, "counter_attack", _locId, _name, _pos];
            diag_log format ["[OpsRoom] AI Commander: COUNTER-ATTACK needed - %1 lost to British", _name];
        };
        
        // REINFORCE: Enemy location being contested
        if (_owner == "NAZI" && _contested) then {
            // Check not already being reinforced
            private _alreadyTargeted = OpsRoom_AI_ActiveGroups findIf {(_x get "targetLocId") == _locId} != -1;
            if (!_alreadyTargeted) then {
                _tasks pushBack [OpsRoom_AI_Priority_Reinforce, "reinforce", _locId, _name, _pos];
                diag_log format ["[OpsRoom] AI Commander: REINFORCE needed - %1 contested", _name];
            };
        };
        
        // GARRISON: Enemy location with no defenders
        if (_owner == "NAZI" && !_contested) then {
            private _nearUnits = _pos nearEntities ["Man", _locData getOrDefault ["captureRadius", 200]];
            private _defenders = _nearUnits select {side group _x != side player && alive _x};
            private _alreadyTargeted = OpsRoom_AI_ActiveGroups findIf {(_x get "targetLocId") == _locId} != -1;
            if (count _defenders == 0 && !_alreadyTargeted) then {
                // Only garrison important locations
                if (_type in ["town", "village", "port", "airfield", "barracks", "hq", "factory", "motorpool", "fuel_depot", "ammo_dump"]) then {
                    _tasks pushBack [OpsRoom_AI_Priority_Garrison, "garrison", _locId, _name, _pos];
                    diag_log format ["[OpsRoom] AI Commander: GARRISON needed - %1 undefended", _name];
                };
            };
        };
        
        // Update known ownership snapshot
        OpsRoom_AI_KnownOwnership set [_locId, _owner];
        
    } forEach OpsRoom_StrategicLocations;
    
    // ========================================
    // 3b. ASSESS AIR & NAVAL OPPORTUNITIES
    // ========================================
    // Check for enemy airfields — can launch air patrols/strikes
    private _enemyAirfields = 0;
    private _enemyPorts = 0;
    {
        private _locData = _y;
        private _owner = _locData getOrDefault ["owner", "NAZI"];
        if (_owner != "NAZI") then { continue };
        if ((_locData get "status") == "destroyed") then { continue };
        
        private _type = _locData get "type";
        if (_type == "airfield") then { _enemyAirfields = _enemyAirfields + 1 };
        if (_type == "port") then { _enemyPorts = _enemyPorts + 1 };
    } forEach OpsRoom_StrategicLocations;
    
    // Air patrol: if enemy has airfields, consider air missions
    // Only launch if player has airborne wings (something to fight) or player-held locations to strike
    if (_enemyAirfields > 0 && _manpower >= 4) then {
        // Count British-held locations as potential strike targets
        private _britishLocations = [];
        {
            if ((_y getOrDefault ["owner", "NAZI"]) == "BRITISH") then {
                _britishLocations pushBack [_x, _y];
            };
        } forEach OpsRoom_StrategicLocations;
        
        // 50% chance each turn to consider air mission (don't spam)
        if (random 1 > 0.5) then {
            if (count _britishLocations > 0) then {
                // Pick a British location to strike
                private _target = selectRandom _britishLocations;
                (_target select 1) params [["_pos", [0,0,0]], ["_name", "Unknown"]];
                private _tPos = (_target select 1) get "pos";
                private _tName = (_target select 1) get "name";
                _tasks pushBack [5, "air_strike", "", _tName, _tPos];
                diag_log format ["[OpsRoom] AI Commander: AIR STRIKE considered against %1", _tName];
            } else {
                // No British targets — fly patrol over own territory
                private _patrolLoc = selectRandom (values OpsRoom_StrategicLocations select {(_x getOrDefault ["owner", "NAZI"]) == "NAZI"});
                if (!isNil "_patrolLoc") then {
                    _tasks pushBack [2, "air_patrol", "", _patrolLoc get "name", _patrolLoc get "pos"];
                };
            };
        };
    };
    
    // Naval patrol: if enemy has ports, consider naval missions
    if (_enemyPorts > 0 && _manpower >= 3) then {
        if (random 1 > 0.6) then {
            // Patrol near a random enemy port or sea lane
            private _naziPorts = [];
            {
                if ((_y getOrDefault ["owner", "NAZI"]) == "NAZI" && (_y get "type") == "port") then {
                    _naziPorts pushBack [_x, _y];
                };
            } forEach OpsRoom_StrategicLocations;
            
            if (count _naziPorts > 0) then {
                private _portPair = selectRandom _naziPorts;
                private _portData = _portPair select 1;
                _tasks pushBack [2, "naval_patrol", _portPair select 0, _portData get "name", _portData get "pos"];
                diag_log format ["[OpsRoom] AI Commander: NAVAL PATROL considered from %1", _portData get "name"];
            };
        };
    };
    
    // ========================================
    // 4. SORT BY PRIORITY (highest first)
    // ========================================
    _tasks sort false;  // Descending by first element (priority)
    
    diag_log format ["[OpsRoom] AI Commander: %1 tasks identified", count _tasks];
    
    // ========================================
    // 5. DEPLOY GROUPS
    // ========================================
    // Count high-priority tasks (counter-attack + reinforce)
    private _highPriorityCount = {(_x select 0) >= OpsRoom_AI_Priority_Reinforce} count _tasks;
    // Reserve up to 2 slots for high-priority tasks (won't be used by garrison/patrol)
    private _reservedSlots = _highPriorityCount min 2;
    
    {
        _x params ["_priority", "_missionType", "_locId", "_locName", "_locPos"];
        
        // Check budget — garrison/patrol can't use reserved slots
        private _effectiveSlots = if (_missionType in ["garrison", "patrol"]) then {
            _availableSlots - _reservedSlots
        } else {
            _availableSlots
        };
        
        if (_effectiveSlots <= 0) then {
            if (_availableSlots <= 0) exitWith {
                diag_log "[OpsRoom] AI Commander: No group slots available";
            };
            diag_log format ["[OpsRoom] AI Commander: Skipping %1 (%2) - slots reserved for higher priority", _locName, _missionType];
            continue;
        };
        
        // Select template
        private _templateList = OpsRoom_AI_TemplatesByMission getOrDefault [_missionType, ["rifle_section"]];
        private _templateKey = selectRandom _templateList;
        private _template = OpsRoom_AI_GroupTemplates getOrDefault [_templateKey, createHashMap];
        
        if (count _template == 0) then { continue };
        
        private _cost = _template get "manpower";
        
        if (_manpower < _cost) then {
            diag_log format ["[OpsRoom] AI Commander: Insufficient manpower (%1) for %2 (costs %3)", _manpower, _templateKey, _cost];
            continue;
        };
        
        // Find spawn location
        private _spawnType = _template get "spawnType";
        private _spawnLocId = [_spawnType, _locPos] call OpsRoom_fnc_aiFindSpawnLocation;
        
        if (_spawnLocId == "") then {
            diag_log format ["[OpsRoom] AI Commander: No %1 available to spawn %2", _spawnType, _templateKey];
            continue;
        };
        
        // Route to correct spawn function based on template type
        private _spawnResult = createHashMap;
        private _grp = grpNull;
        
        if (_spawnType == "airfield") then {
            // AIR GROUP — use air spawner
            _spawnResult = [_templateKey, _spawnLocId, _locPos, _missionType] call OpsRoom_fnc_aiSpawnAirGroup;
            _grp = _spawnResult getOrDefault ["group", grpNull];
        } else {
            if (_spawnType == "port" && _missionType in ["naval_patrol", "naval_attack"]) then {
                // NAVAL GROUP — use naval spawner
                _spawnResult = [_templateKey, _spawnLocId, _locPos, _missionType] call OpsRoom_fnc_aiSpawnNavalGroup;
                _grp = _spawnResult getOrDefault ["group", grpNull];
            } else {
                // GROUND GROUP — use infantry/vehicle spawner
                _spawnResult = [_templateKey, _spawnLocId] call OpsRoom_fnc_aiSpawnGroup;
                _grp = _spawnResult getOrDefault ["group", grpNull];
                
                // Send ground group to target
                if (!isNull _grp) then {
                    [_grp, _locPos, _missionType] call OpsRoom_fnc_aiMoveGroup;
                };
            };
        };
        
        if (isNull _grp) then {
            diag_log format ["[OpsRoom] AI Commander: Failed to spawn %1", _templateKey];
            continue;
        };
        
        // Deduct manpower
        _manpower = _manpower - _cost;
        OpsRoom_AI_Manpower = _manpower;
        
        // Track the group
        private _grpData = createHashMapFromArray [
            ["group", _grp],
            ["templateKey", _templateKey],
            ["templateName", _template get "name"],
            ["missionType", _missionType],
            ["targetLocId", _locId],
            ["targetName", _locName],
            ["targetPos", _locPos],
            ["spawnTime", daytime],
            ["spawnLocId", _spawnLocId]
        ];
        OpsRoom_AI_ActiveGroups pushBack _grpData;
        _availableSlots = _availableSlots - 1;
        
        // Release a reserved slot if this was a high-priority mission
        if (_missionType in ["counter_attack", "reinforce"]) then {
            _reservedSlots = (_reservedSlots - 1) max 0;
        };
        
        // Dispatch log
        private _spawnLocData = OpsRoom_StrategicLocations getOrDefault [_spawnLocId, createHashMap];
        private _spawnName = if (count _spawnLocData > 0) then { _spawnLocData get "name" } else { "Unknown" };
        
        private _missionLabel = switch (_missionType) do {
            case "counter_attack": { "COUNTER-ATTACK" };
            case "reinforce": { "REINFORCEMENT" };
            case "garrison": { "GARRISON DEPLOYMENT" };
            case "patrol": { "PATROL" };
            case "air_patrol": { "AIR PATROL" };
            case "air_strike": { "AIR STRIKE" };
            case "naval_patrol": { "NAVAL PATROL" };
            case "naval_attack": { "NAVAL ATTACK" };
            default { "DEPLOYMENT" };
        };
        
        ["PRIORITY", format ["ENEMY %1", _missionLabel],
            format ["Enemy %1 dispatched from %2 heading toward %3.", _template get "name", _spawnName, _locName],
            _locPos
        ] call OpsRoom_fnc_dispatch;
        
        diag_log format ["[OpsRoom] AI Commander: Deployed %1 from %2 -> %3 (%4). Manpower remaining: %5",
            _templateKey, _spawnName, _locName, _missionType, _manpower];
        
    } forEach _tasks;
    
    // ========================================
    // 6. INTEL-GATED TURN SUMMARY
    // ========================================
    // At 80%+ intel, dispatch a summary of what the AI commander did this turn
    private _intelLevel = if (!isNil "OpsRoom_AI_IntelLevel") then { OpsRoom_AI_IntelLevel } else { 0 };
    
    if (_intelLevel >= 80 && count _tasks > 0) then {
        private _deployedCount = 0;
        {
            if (_x select 0 >= OpsRoom_AI_Priority_Garrison) then { _deployedCount = _deployedCount + 1 };
        } forEach _tasks;
        
        if (_intelLevel >= 100) then {
            // Full visibility — exact info
            ["ULTRA", "ENEMY COMMAND INTERCEPT",
                format ["ULTRA decrypt: Enemy commander assessed %1 situations this turn. Manpower reserves: %2. Active groups: %3/%4.",
                    count _tasks, OpsRoom_AI_Manpower, count OpsRoom_AI_ActiveGroups, _maxGroups],
                [0,0,0]
            ] call OpsRoom_fnc_dispatch;
        } else {
            // 80-99% — good but not perfect
            ["ULTRA", "ENEMY SIGNALS INTERCEPT",
                format ["Intercepted enemy command traffic suggests %1 new deployments ordered this cycle.",
                    _deployedCount],
                [0,0,0]
            ] call OpsRoom_fnc_dispatch;
        };
    };
    
    diag_log "[OpsRoom] AI Commander: === TURN END ===";
};
