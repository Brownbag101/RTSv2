/*
    Production Monitor
    
    Background loop that checks all factory timers.
    When a cycle completes:
      - Adds batch to warehouse
      - Deducts resources for next batch (if affordable)
      - Restarts cycle (continuous production)
      - If can't afford next batch, stops factory
    
    Runs every 10 seconds.
    
    Usage:
        [] spawn OpsRoom_fnc_productionMonitor;
*/

diag_log "[OpsRoom] Production monitor started";

while {true} do {
    private _factories = missionNamespace getVariable ["OpsRoom_Factories", []];
    
    {
        private _factory = _x;
        private _producing = _factory get "producing";
        
        if (_producing != "") then {
            private _startTime = _factory get "startTime";
            private _cycleTime = _factory get "cycleTime";
            private _elapsed = time - _startTime;
            private _totalSecs = _cycleTime * 60;
            
            if (_elapsed >= _totalSecs) then {
                // Cycle complete — add to warehouse
                private _itemData = OpsRoom_EquipmentDB get _producing;
                
                if (!isNil "_itemData") then {
                    private _batchSize = _itemData get "batchSize";
                    private _itemName = _itemData get "displayName";
                    private _buildCost = _itemData get "buildCost";
                    
                    // Aircraft go directly to hangar, not warehouse
                    if ((_itemData getOrDefault ["category", ""]) == "Aircraft") then {
                        for "_i" from 1 to _batchSize do {
                            [_producing] call OpsRoom_fnc_addToHangar;
                        };
                        ["ROUTINE", "PRODUCTION COMPLETE", format ["%1 produced %2. Delivered to hangar.", _factory get "name", _itemName]] call OpsRoom_fnc_dispatch;
                    } else {
                        // Naval items (cargo ships) go directly to fleet pool
                        if ((_itemData getOrDefault ["spawnType", ""]) == "naval") then {
                            OpsRoom_CargoShips = (missionNamespace getVariable ["OpsRoom_CargoShips", 0]) + _batchSize;
                            ["PRIORITY", "SHIP COMMISSIONED",
                                format ["%1 completed construction of %2. Added to convoy fleet pool. Total ships: %3", _factory get "name", _itemName, OpsRoom_CargoShips]
                            ] call OpsRoom_fnc_dispatch;
                            systemChat format ["Ship commissioned! Fleet pool: %1", OpsRoom_CargoShips];
                            diag_log format ["[OpsRoom] Naval: %1 commissioned via %2 (total fleet: %3)", _itemName, _factory get "name", OpsRoom_CargoShips];
                        } else {
                            // Add to warehouse
                            private _currentStock = OpsRoom_Warehouse getOrDefault [_producing, 0];
                            OpsRoom_Warehouse set [_producing, _currentStock + _batchSize];
                            ["ROUTINE", "PRODUCTION COMPLETE", format ["%1 produced %2x %3. Warehouse: %4 total", _factory get "name", _batchSize, _itemName, _currentStock + _batchSize]] call OpsRoom_fnc_dispatch;
                        };
                    };
                    
                    // Check if we can afford next batch
                    private _canAffordNext = true;
                    {
                        _x params ["_resName", "_amount"];
                        private _cleanName = _resName;
                        while {_cleanName find " " != -1} do {
                            private _spacePos = _cleanName find " ";
                            _cleanName = (_cleanName select [0, _spacePos]) + "_" + (_cleanName select [_spacePos + 1]);
                        };
                        private _varName = format ["OpsRoom_Resource_%1", _cleanName];
                        private _have = missionNamespace getVariable [_varName, 0];
                        if (_have < _amount) then { _canAffordNext = false };
                    } forEach _buildCost;
                    
                    if (_canAffordNext && (_factory get "continuous")) then {
                        // Deduct resources for next batch
                        {
                            _x params ["_resName", "_amount"];
                            private _cleanName = _resName;
                            while {_cleanName find " " != -1} do {
                                private _spacePos = _cleanName find " ";
                                _cleanName = (_cleanName select [0, _spacePos]) + "_" + (_cleanName select [_spacePos + 1]);
                            };
                            private _varName = format ["OpsRoom_Resource_%1", _cleanName];
                            private _have = missionNamespace getVariable [_varName, 0];
                            missionNamespace setVariable [_varName, _have - _amount];
                            call compile format ["%1 = %2;", _varName, _have - _amount];
                        } forEach _buildCost;
                        
                        [] call OpsRoom_fnc_updateResources;
                        
                        // Restart cycle
                        _factory set ["startTime", time];
                        _factories set [_forEachIndex, _factory];
                        missionNamespace setVariable ["OpsRoom_Factories", _factories];
                        
                        diag_log format ["[OpsRoom] %1: Next batch started for %2", _factory get "name", _producing];
                    } else {
                        // Can't afford — stop factory
                        _factory set ["producing", ""];
                        _factory set ["startTime", 0];
                        _factory set ["cycleTime", 0];
                        _factories set [_forEachIndex, _factory];
                        missionNamespace setVariable ["OpsRoom_Factories", _factories];
                        
                        ["PRIORITY", "PRODUCTION HALTED", format ["%1 halted: insufficient resources for %2", _factory get "name", _itemName]] call OpsRoom_fnc_dispatch;
                        
                        diag_log format ["[OpsRoom] %1: Production halted - can't afford next batch", _factory get "name"];
                    };
                };
            };
        };
    } forEach _factories;
    
    sleep 10;
};
