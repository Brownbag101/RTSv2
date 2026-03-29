/*
    fn_initLocationBuildings
    
    For each strategic location, scans for the nearest map buildings
    and binds them to the location. Buildings are made Zeus-editable.
    
    If ALL bound buildings are destroyed, the location status becomes "destroyed".
    
    Building count comes from locationTypes.sqf "buildingCount" key.
    Buildings are only made Zeus-editable for friendly (British) locations.
    Enemy locations: buildings exist but are not editable until captured.
    
    Called from init.sqf after initStrategicLocations.
*/

if (isNil "OpsRoom_StrategicLocations") exitWith {
    systemChat "Location Buildings: No locations loaded";
};

// Building counts now come from locationTypes.sqf via "buildingCount" key
// Falls back to 2 if not defined

private _totalBuildings = 0;

{
    private _locId = _x;
    private _locData = _y;
    private _pos = _locData get "pos";
    private _type = _locData get "type";
    private _radius = _locData getOrDefault ["captureRadius", 200];
    
    // Skip sealane entries and stores (no physical buildings)
    if (_type in ["sealane", "stores"]) then { continue };
    
    // How many buildings to grab (from location type data)
    private _typeData = OpsRoom_LocationTypes getOrDefault [_type, createHashMap];
    private _maxBuildings = _typeData getOrDefault ["buildingCount", 2];
    
    // Scan for nearby buildings (ARMA map objects)
    // Search radius is the capture radius + 50m buffer
    private _searchRadius = _radius + 50;
    private _nearBuildings = nearestObjects [_pos, ["House", "Building"], _searchRadius];
    
    // Filter to actual buildings (exclude lampposts, piers, fences, signs etc)
    private _excludePatterns = ["Lamp", "PowerLine", "Pier", "Buoy", "Fence", "Wall_L",
        "Bench", "Sign_", "Billboard", "Garbage", "Misc_", "Post_",
        "Addon_", "WaterTank", "Shed_small", "GarbageBags", "Junkpile",
        "BackAlley", "Calvary", "Cross_", "Stone_"];
    
    _nearBuildings = _nearBuildings select {
        private _typeName = typeOf _x;
        // Must start with "Land_" and not match any exclude pattern
        if (_typeName find "Land_" != 0) then {
            false
        } else {
            private _excluded = false;
            { if (_typeName find _x >= 0) then { _excluded = true } } forEach _excludePatterns;
            !_excluded
        }
    };
    
    // Take the closest N buildings
    _nearBuildings = _nearBuildings select [0, _maxBuildings min count _nearBuildings];
    
    if (count _nearBuildings == 0) then {
        diag_log format ["[OpsRoom] Buildings: No buildings found near %1 (%2)", _locData get "name", _type];
        _locData set ["buildings", []];
        _locData set ["buildingsTotal", 0];
        OpsRoom_StrategicLocations set [_locId, _locData];
        continue;
    };
    
    // Store building references
    _locData set ["buildings", _nearBuildings];
    _locData set ["buildingsTotal", count _nearBuildings];
    _locData set ["buildingsAlive", count _nearBuildings];
    OpsRoom_StrategicLocations set [_locId, _locData];
    
    // Buildings at friendly locations get replaced with spawned mission objects
    // on capture via fn_toggleLocationBuildings. At init we just register them.
    // If the location is already British-owned, do the replacement now.
    private _owner = _locData getOrDefault ["owner", "NAZI"];
    if (_owner == "BRITISH") then {
        // Deferred — wait for curator to exist, then toggle
        [_locId] spawn {
            params ["_lid"];
            waitUntil { sleep 1; !isNull (getAssignedCuratorLogic player) };
            sleep 1;
            [_lid, "add"] call OpsRoom_fnc_toggleLocationBuildings;
        };
    };
    
    // Add Killed/Destroyed event handler to each building
    {
        private _building = _x;
        _building setVariable ["OpsRoom_LocationId", _locId];
        _building setVariable ["OpsRoom_IsLocationBuilding", true];
        
        _building addEventHandler ["Killed", {
            params ["_building"];
            private _locId = _building getVariable ["OpsRoom_LocationId", ""];
            if (_locId == "") exitWith {};
            
            private _locData = OpsRoom_StrategicLocations getOrDefault [_locId, createHashMap];
            if (count _locData == 0) exitWith {};
            
            // Recount alive buildings
            private _buildings = _locData getOrDefault ["buildings", []];
            private _aliveCount = {!isNull _x && {alive _x && {damage _x < 1}}} count _buildings;
            _locData set ["buildingsAlive", _aliveCount];
            
            private _name = _locData get "name";
            private _total = _locData getOrDefault ["buildingsTotal", 0];
            
            diag_log format ["[OpsRoom] Buildings: Building destroyed at %1 (%2/%3 remaining)", _name, _aliveCount, _total];
            
            if (_aliveCount == 0) then {
                // ALL buildings destroyed — location is destroyed
                _locData set ["status", "destroyed"];
                OpsRoom_StrategicLocations set [_locId, _locData];
                
                // Update map marker
                [_locId] call OpsRoom_fnc_updateMapMarkers;
                
                ["FLASH", "LOCATION DESTROYED",
                    format ["%1 has been completely destroyed! All structures levelled.", _name],
                    _locData get "pos"
                ] call OpsRoom_fnc_dispatch;
                
                diag_log format ["[OpsRoom] Buildings: %1 DESTROYED — all buildings gone", _name];
            } else {
                // Some buildings left — dispatch warning
                if (_aliveCount == 1) then {
                    ["PRIORITY", "LOCATION CRITICAL",
                        format ["%1 is critically damaged! Only 1 structure remaining.", _name],
                        _locData get "pos"
                    ] call OpsRoom_fnc_dispatch;
                };
            };
            
            OpsRoom_StrategicLocations set [_locId, _locData];
        }];
    } forEach _nearBuildings;
    
    _totalBuildings = _totalBuildings + count _nearBuildings;
    
} forEach OpsRoom_StrategicLocations;

systemChat format ["Location Buildings: %1 buildings bound to strategic locations", _totalBuildings];
diag_log format ["[OpsRoom] Buildings: %1 total buildings bound across all locations", _totalBuildings];
