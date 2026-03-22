/*
    Convoy Monitor
    
    Background loop managing the convoy lifecycle:
        "ordered"    → waits for in-game time → spawns ships
        "sailing"    → monitors ship positions, checks port arrival
        "unloading"  → ships at port, unloading items one by one
        "returning"  → ships sailing back along reversed route
        "complete"   → all ships returned or accounted for
        "destroyed"  → all ships sunk
    
    Uses IN-GAME TIME (dateToNumber) for spawn delay.
    Unloading uses real-time (OpsRoom_Settings_UnloadTimePerItem seconds per item).
    
    Usage:
        [] spawn OpsRoom_fnc_convoyMonitor;
*/

diag_log "[OpsRoom] Convoy monitor started";

while {true} do {
    sleep 10;
    
    private _completedIndices = [];
    
    {
        private _convoyIndex = _forEachIndex;
        private _convoy = _x;
        private _convoyId = _convoy select 0;
        private _codename = _convoy select 1;
        private _ships = _convoy select 2;
        private _seaLaneId = _convoy select 3;
        private _portLocId = _convoy select 4;
        private _orderTime = _convoy select 5;
        private _spawnDelay = _convoy select 6;
        private _status = _convoy select 7;
        private _shipsAlive = _convoy select 8;
        
        // ============================================================
        // ORDERED — waiting for in-game time
        // ============================================================
        if (_status == "ordered") then {
            private _orderDaytime = _orderTime select 0;
            private _orderDate = _orderTime select 1;
            private _orderNum = dateToNumber _orderDate;
            private _nowNum = dateToNumber date;
            private _elapsedDays = _nowNum - _orderNum;
            private _elapsedHours = _elapsedDays * 365 * 24;
            
            if (_elapsedHours >= _spawnDelay) then {
                [_convoyIndex] call OpsRoom_fnc_spawnConvoyShips;
            };
        };
        
        // ============================================================
        // SAILING — monitor positions, check port arrival
        // ============================================================
        if (_status == "sailing") then {
            // Arrival point is the LAST route waypoint (in water), not the port land position
            private _laneDataSail = OpsRoom_SeaLanes getOrDefault [_seaLaneId, createHashMap];
            private _routesSail = if (count _laneDataSail > 0) then { _laneDataSail get "routes" } else { createHashMap };
            private _routeWps = _routesSail getOrDefault [_portLocId, []];
            private _dockPos = if (count _routeWps > 0) then { _routeWps select (count _routeWps - 1) } else {
                // Fallback to port land position if no waypoints
                private _portLocData = OpsRoom_StrategicLocations getOrDefault [_portLocId, createHashMap];
                if (count _portLocData > 0) then { _portLocData get "pos" } else { [0,0,0] }
            };
            private _portLocData = OpsRoom_StrategicLocations getOrDefault [_portLocId, createHashMap];
            private _arrivalRadius = missionNamespace getVariable ["OpsRoom_Settings_ShipArrivalRadius", 100];
            private _allAtPort = true;
            
            {
                _x params ["_manifest", "_shipObj"];
                if (isNull _shipObj || {!alive _shipObj}) then { continue };
                
                private _state = if (count _x > 2) then { _x select 2 } else { createHashMap };
                if (isNil "_state" || {typeName _state != "HASHMAP"}) then { _state = createHashMap };
                private _shipStatus = _state getOrDefault ["status", "sailing"];
                
                if (_shipStatus == "sailing") then {
                    _allAtPort = false;
                    
                    // Check if ship is within 200m of docking point
                    if (_shipObj distance2D _dockPos < 200) then {
                        // Stop scripted navigation
                        _shipObj setVariable ["OpsRoom_NavActive", false];
                        
                        // Stop all movement
                        _shipObj setVelocity [0, 0, 0];
                        
                        // Position ship at dock, facing AWAY from port (toward open water)
                        _shipObj setPos _dockPos;
                        
                        // Calculate direction away from port land position
                        private _portLandPos = _portLocData getOrDefault ["pos", _dockPos];
                        private _awayDir = _portLandPos getDir _dockPos;  // From port toward dock = away from land
                        _shipObj setDir _awayDir;
                        
                        // Begin unloading
                        _state set ["status", "unloading"];
                        _state set ["unloadIndex", 0];
                        _state set ["unloadStartTime", time];
                        _state set ["totalItems", count _manifest];
                        _state set ["unloadedCount", 0];
                        
                        private _shipName = _shipObj getVariable ["OpsRoom_ShipName", "Ship"];
                        private _portName = _portLocData getOrDefault ["name", "port"];
                        
                        ["PRIORITY", format ["%1 DOCKED", _shipName],
                            format ["%1 (Convoy %2) has arrived at %3. Beginning unloading operations.", _shipName, _codename, _portName]
                        ] call OpsRoom_fnc_dispatch;
                        
                        diag_log format ["[OpsRoom] Convoy %1: %2 teleported to dock at %3", _codename, _shipName, _dockPos];
                    };
                };
                
                if (_shipStatus != "sailing") then {
                    // Ship is at port or returning — not "still sailing"
                };
            } forEach _ships;
        };
        
        // ============================================================
        // UNLOADING — process item-by-item unloading at port
        // ============================================================
        if (_status == "sailing" || _status == "unloading") then {
            private _anyUnloading = false;
            private _anySailing = false;
            private _allDone = true;
            private _unloadTime = missionNamespace getVariable ["OpsRoom_Settings_UnloadTimePerItem", 120];
            
            private _portLocData = OpsRoom_StrategicLocations getOrDefault [_portLocId, createHashMap];
            private _portMarkers = OpsRoom_PortDeliveryMarkers getOrDefault [_portLocId, createHashMap];
            
            {
                _x params ["_manifest", "_shipObj"];
                if (isNull _shipObj || {!alive _shipObj}) then { continue };
                
                private _state = if (count _x > 2) then { _x select 2 } else { createHashMap };
                if (isNil "_state" || {typeName _state != "HASHMAP"}) then { continue };
                private _shipStatus = _state getOrDefault ["status", "sailing"];
                
                if (_shipStatus == "sailing") then { _anySailing = true; _allDone = false; continue };
                if (_shipStatus == "returning" || _shipStatus == "arrived") then { continue };
                
                _allDone = false;
                
                if (_shipStatus == "unloading" || _shipStatus == "waiting") then {
                    _anyUnloading = true;
                    
                    private _idx = _state getOrDefault ["unloadIndex", 0];
                    
                    // All items unloaded?
                    if (_idx >= count _manifest) then {
                        // Done! Start return journey
                        _state set ["status", "returning"];
                        
                        private _shipName = _shipObj getVariable ["OpsRoom_ShipName", "Ship"];
                        ["ROUTINE", format ["%1 UNLOADED", _shipName],
                            format ["%1 has completed unloading. Returning to sea.", _shipName]
                        ] call OpsRoom_fnc_dispatch;
                        
                        // Nudge ship forward (away from port) to clear any beaching
                        private _shipDir = getDir _shipObj;
                        private _nudgePos = (getPos _shipObj) vectorAdd [
                            50 * sin _shipDir,
                            50 * cos _shipDir,
                            0
                        ];
                        _shipObj setPos _nudgePos;
                        
                        // Build reversed route for return journey
                        private _laneData = OpsRoom_SeaLanes getOrDefault [_seaLaneId, createHashMap];
                        if (count _laneData > 0) then {
                            private _routesMap = _laneData get "routes";
                            private _fwdWaypoints = _routesMap getOrDefault [_portLocId, []];
                            private _originPos = _laneData get "originPos";
                            private _reversedWps = +_fwdWaypoints;
                            reverse _reversedWps;
                            
                            // Add origin as final destination
                            _reversedWps pushBack _originPos;
                            
                            // Start scripted navigation for return
                            _shipObj setVariable ["OpsRoom_NavWaypoints", _reversedWps];
                            _shipObj setVariable ["OpsRoom_NavWaypointIndex", 0];
                            _shipObj setVariable ["OpsRoom_NavSpeed", 8];
                            _shipObj setVariable ["OpsRoom_NavActive", true];
                            
                            // Spawn navigation loop for return
                            [_shipObj, 8] spawn {
                                params ["_ship", "_speed"];
                                
                                sleep 1;  // Brief pause after nudge
                                
                                while {alive _ship && {_ship getVariable ["OpsRoom_NavActive", false]}} do {
                                    private _wps = _ship getVariable ["OpsRoom_NavWaypoints", []];
                                    private _wpIdx = _ship getVariable ["OpsRoom_NavWaypointIndex", 0];
                                    private _spd = _ship getVariable ["OpsRoom_NavSpeed", _speed];
                                    
                                    if (_wpIdx >= count _wps) exitWith {
                                        _ship setVelocity [0, 0, 0];
                                        _ship setVariable ["OpsRoom_NavActive", false];
                                    };
                                    
                                    private _targetPos = _wps select _wpIdx;
                                    private _shipPos = getPos _ship;
                                    private _dist = _shipPos distance2D _targetPos;
                                    
                                    if (_dist < 80) then {
                                        _ship setVariable ["OpsRoom_NavWaypointIndex", _wpIdx + 1];
                                    } else {
                                        private _dir = _shipPos getDir _targetPos;
                                        private _currentDir = getDir _ship;
                                        private _dirDiff = _dir - _currentDir;
                                        if (_dirDiff > 180) then { _dirDiff = _dirDiff - 360 };
                                        if (_dirDiff < -180) then { _dirDiff = _dirDiff + 360 };
                                        private _turnRate = 3;
                                        private _newDir = _currentDir + ((_dirDiff min _turnRate) max (-_turnRate));
                                        _ship setDir _newDir;
                                        
                                        private _actualSpeed = if (_dist < 200) then { _spd * 0.6 } else { _spd };
                                        _ship setVelocity [
                                            _actualSpeed * sin _newDir,
                                            _actualSpeed * cos _newDir,
                                            0
                                        ];
                                    };
                                    
                                    sleep 0.5;
                                };
                            };
                        };
                        
                        diag_log format ["[OpsRoom] Convoy %1: Ship nudged and returning via scripted nav", _codename];
                        continue;
                    };
                    
                    // Currently unloading an item — check if unload time elapsed
                    private _startTime = _state getOrDefault ["unloadStartTime", 0];
                    
                    if (_startTime == 0) then {
                        // Start unloading this item
                        _state set ["unloadStartTime", time];
                        _startTime = time;
                    };
                    
                    private _elapsed = time - _startTime;
                    
                    if (_elapsed >= _unloadTime) then {
                        // This item is done unloading — deliver it
                        private _itemEntry = _manifest select _idx;
                        _itemEntry params ["_itemId", "_qty"];
                        
                        private _itemData = OpsRoom_EquipmentDB get _itemId;
                        if (!isNil "_itemData") then {
                            private _category = _itemData get "category";
                            private _spawnType = _itemData getOrDefault ["spawnType", "crate"];
                            private _className = _itemData get "className";
                            private _crateClass = _itemData getOrDefault ["crateClass", ""];
                            private _batchSize = _itemData getOrDefault ["batchSize", 1];
                            private _displayName = _itemData get "displayName";
                            
                            // Aircraft → hangar
                            if (_category == "Aircraft") then {
                                for "_i" from 1 to _qty do { [_itemId] call OpsRoom_fnc_addToHangar };
                            } else {
                                if (_spawnType == "naval") then {
                                    OpsRoom_CargoShips = OpsRoom_CargoShips + _qty;
                                } else {
                                    // Find delivery marker for this category at this port
                                    private _markerCat = switch (true) do {
                                        case (_category == "Vehicles"): { "vehicle" };
                                        case (_category == "Ammunition"): { "ammo" };
                                        case (_category == "Weapons"): { "weapons" };
                                        default { "equipment" };
                                    };
                                    
                                    private _catMarkers = _portMarkers getOrDefault [_markerCat, []];
                                    
                                    if (count _catMarkers > 0) then {
                                        // Pick a marker slot (round-robin)
                                        private _slotIdx = (_state getOrDefault ["unloadedCount", 0]) mod (count _catMarkers);
                                        private _deliveryPos = _catMarkers select _slotIdx;
                                        
                                        switch (_spawnType) do {
                                            case "crate": {
                                                for "_i" from 1 to _qty do {
                                                    private _spawnPos = _deliveryPos vectorAdd [random 2 - 1, random 2 - 1, 0];
                                                    private _crate = createVehicle [_crateClass, _spawnPos, [], 0, "NONE"];
                                                    clearWeaponCargoGlobal _crate;
                                                    clearMagazineCargoGlobal _crate;
                                                    clearItemCargoGlobal _crate;
                                                    clearBackpackCargoGlobal _crate;
                                                    if (isClass (configFile >> "CfgWeapons" >> _className)) then {
                                                        _crate addWeaponCargoGlobal [_className, _batchSize];
                                                    } else {
                                                        if (isClass (configFile >> "CfgMagazines" >> _className)) then {
                                                            _crate addMagazineCargoGlobal [_className, _batchSize];
                                                        } else {
                                                            _crate addItemCargoGlobal [_className, _batchSize];
                                                        };
                                                    };
                                                };
                                            };
                                            case "vehicle": {
                                                for "_i" from 1 to _qty do {
                                                    private _spawnPos = _deliveryPos vectorAdd [(_i - 1) * 6, 0, 0];
                                                    private _veh = createVehicle [_className, _spawnPos, [], 0, "NONE"];
                                                    _veh setDir (random 360);
                                                };
                                            };
                                            case "single": {
                                                private _holder = createVehicle ["GroundWeaponHolder", _deliveryPos, [], 0, "NONE"];
                                                if (isClass (configFile >> "CfgWeapons" >> _className)) then {
                                                    _holder addWeaponCargoGlobal [_className, _qty];
                                                } else {
                                                    if (isClass (configFile >> "CfgMagazines" >> _className)) then {
                                                        _holder addMagazineCargoGlobal [_className, _qty];
                                                    } else {
                                                        _holder addItemCargoGlobal [_className, _qty];
                                                    };
                                                };
                                            };
                                        };
                                    } else {
                                        // No delivery markers for this category — waiting for dock space
                                        _state set ["status", "waiting"];
                                        _state set ["currentItem", _itemData get "displayName"];
                                        diag_log format ["[OpsRoom] Convoy %1: No %2 markers at port %3 — waiting", _codename, _markerCat, _portLocId];
                                        continue;
                                    };
                                };
                            };
                            
                            diag_log format ["[OpsRoom] Convoy %1: Unloaded %2x %3", _codename, _qty, _displayName];
                        };
                        
                        // Move to next item
                        _state set ["unloadIndex", _idx + 1];
                        _state set ["unloadedCount", (_state getOrDefault ["unloadedCount", 0]) + 1];
                        _state set ["unloadStartTime", 0];  // Reset for next item
                        _state set ["status", "unloading"];
                        
                        // Set current item name for Draw3D
                        if (_idx + 1 < count _manifest) then {
                            private _nextItem = _manifest select (_idx + 1);
                            private _nextData = OpsRoom_EquipmentDB get (_nextItem select 0);
                            _state set ["currentItem", if (!isNil "_nextData") then { _nextData get "displayName" } else { "" }];
                        } else {
                            _state set ["currentItem", ""];
                        };
                    } else {
                        // Still unloading — update current item name for Draw3D
                        private _itemEntry = _manifest select _idx;
                        private _iData = OpsRoom_EquipmentDB get (_itemEntry select 0);
                        _state set ["currentItem", if (!isNil "_iData") then { _iData get "displayName" } else { "" }];
                    };
                };
            } forEach _ships;
            
            // Transition convoy status
            if (_anyUnloading && !_anySailing) then {
                _convoy set [7, "unloading"];
            };
        };
        
        // ============================================================
        // RETURNING — ships sailing back to origin
        // ============================================================
        if (_status == "sailing" || _status == "unloading" || _status == "returning") then {
            private _laneData = OpsRoom_SeaLanes getOrDefault [_seaLaneId, createHashMap];
            private _originPos = if (count _laneData > 0) then { _laneData get "originPos" } else { [0,0,0] };
            
            private _anyActive = false;
            
            {
                _x params ["_manifest", "_shipObj"];
                if (isNull _shipObj || {!alive _shipObj}) then { continue };
                
                private _state = if (count _x > 2) then { _x select 2 } else { createHashMap };
                if (isNil "_state" || {typeName _state != "HASHMAP"}) then { continue };
                private _shipStatus = _state getOrDefault ["status", "sailing"];
                
                if (_shipStatus == "returning") then {
                    _anyActive = true;
                    
                    // Check if ship reached origin
                    if (_shipObj distance2D _originPos < 200) then {
                        // Ship has returned — delete and return to pool
                        OpsRoom_CargoShips = OpsRoom_CargoShips + 1;
                        
                        private _shipName = _shipObj getVariable ["OpsRoom_ShipName", "Ship"];
                        
                        // Delete ship and crew
                        private _crew = crew _shipObj;
                        { deleteVehicle _x } forEach _crew;
                        deleteVehicle _shipObj;
                        
                        _x set [1, objNull];
                        _state set ["status", "arrived"];
                        
                        ["ROUTINE", format ["%1 RETURNED", _shipName],
                            format ["%1 has returned safely. Ship returned to fleet pool.", _shipName]
                        ] call OpsRoom_fnc_dispatch;
                        
                        diag_log format ["[OpsRoom] Convoy %1: %2 returned to pool", _codename, _shipName];
                    };
                };
                
                if (_shipStatus != "arrived") then { _anyActive = true };
            } forEach _ships;
            
            // Check if all ships are done
            if (!_anyActive) then {
                _convoy set [7, "complete"];
                
                ["ROUTINE", format ["CONVOY %1 COMPLETE", _codename],
                    format ["All ships in Convoy %1 have completed operations.", _codename]
                ] call OpsRoom_fnc_dispatch;
                
                _completedIndices pushBack _convoyIndex;
                diag_log format ["[OpsRoom] Convoy %1: Complete", _codename];
            };
        };
        
        // Clean up completed/destroyed
        if (_status == "complete" || _status == "destroyed") then {
            _completedIndices pushBack _convoyIndex;
        };
        
    } forEach OpsRoom_ActiveConvoys;
    
    // Remove completed convoys (reverse order)
    if (count _completedIndices > 0) then {
        _completedIndices = _completedIndices arrayIntersect _completedIndices;
        _completedIndices sort false;
        { OpsRoom_ActiveConvoys deleteAt _x } forEach _completedIndices;
    };
};
