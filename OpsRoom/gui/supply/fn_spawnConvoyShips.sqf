/*
    Spawn Convoy Ships
    
    Spawns physical cargo ships at the sea lane origin.
    Uses SCRIPTED MOVEMENT (setVelocity) instead of AI waypoints
    to ensure ships sail in perfect straight lines.
    
    Each ship gets a spawned navigation loop that:
    1. Points ship at current waypoint
    2. Sets velocity directly toward it
    3. Advances to next waypoint when within range
    4. Stops at the final waypoint (dock point)
    
    Ship entry in convoy: [manifest, shipObj, unloadState]
    
    Parameters:
        0: NUMBER - Convoy index in OpsRoom_ActiveConvoys
    
    Usage:
        [_convoyIndex] call OpsRoom_fnc_spawnConvoyShips;
*/

params [["_convoyIndex", -1, [0]]];

if (_convoyIndex < 0 || _convoyIndex >= count OpsRoom_ActiveConvoys) exitWith {
    diag_log "[OpsRoom] spawnConvoyShips: Invalid convoy index";
};

private _convoy = OpsRoom_ActiveConvoys select _convoyIndex;
private _convoyId = _convoy select 0;
private _codename = _convoy select 1;
private _ships = _convoy select 2;
private _seaLaneId = _convoy select 3;
private _portLocId = _convoy select 4;

private _laneData = OpsRoom_SeaLanes get _seaLaneId;
if (isNil "_laneData") exitWith {
    diag_log format ["[OpsRoom] spawnConvoyShips: Sea lane %1 not found", _seaLaneId];
};

private _originPos = _laneData get "originPos";
private _laneName = _laneData get "name";
private _routes = _laneData get "routes";
private _waypoints = _routes getOrDefault [_portLocId, []];

if (count _waypoints == 0) then {
    diag_log format ["[OpsRoom] spawnConvoyShips: No route waypoints for %1 → %2", _seaLaneId, _portLocId];
};

private _portLocData = OpsRoom_StrategicLocations getOrDefault [_portLocId, createHashMap];
private _portPos = if (count _portLocData > 0) then { _portLocData get "pos" } else { [0,0,0] };
private _portName = if (count _portLocData > 0) then { _portLocData get "name" } else { "Unknown Port" };

if (_portPos isEqualTo [0,0,0]) exitWith {
    diag_log format ["[OpsRoom] spawnConvoyShips: Port %1 position not found", _portLocId];
};

private _shipClassName = missionNamespace getVariable ["OpsRoom_Settings_ShipClassName", "sab_nl_liberty"];
private _shipSpeed = 8;  // metres per second (~15 knots, good for a Liberty Ship)

private _spawnedCount = 0;

{
    _x params ["_manifest", "_shipObj"];
    
    // Stagger spawn positions
    private _offset = _forEachIndex * 80;
    private _spawnPos = [
        (_originPos select 0) + _offset,
        (_originPos select 1),
        0
    ];
    
    // Spawn ship
    private _ship = createVehicle [_shipClassName, _spawnPos, [], 0, "NONE"];
    _ship setPos _spawnPos;
    
    // Face ship toward first waypoint
    if (count _waypoints > 0) then {
        _ship setDir (_spawnPos getDir (_waypoints select 0));
    };
    
    // Create crew — AI driver present but we override all movement via script
    private _grp = createGroup [independent, true];
    private _driver = _grp createUnit ["I_Soldier_F", [0,0,0], [], 0, "NONE"];
    _driver moveInDriver _ship;
    
    // Completely disable AI — we drive the ship ourselves
    _driver disableAI "MOVE";
    _driver disableAI "AUTOCOMBAT";
    _driver disableAI "FSM";
    _driver disableAI "TARGET";
    _driver disableAI "AUTOTARGET";
    _driver disableAI "SUPPRESSION";
    _driver disableAI "COVER";
    _driver disableAI "PATH";
    
    // Set ship variables
    private _shipName = format ["HMS %1-%2", _codename, _forEachIndex + 1];
    _ship setVariable ["OpsRoom_ShipName", _shipName];
    _ship setVariable ["OpsRoom_ConvoyId", _convoyId];
    _ship setVariable ["OpsRoom_ConvoyIndex", _convoyIndex];
    _ship setVariable ["OpsRoom_ShipIndex", _forEachIndex];
    _ship setVariable ["OpsRoom_ShipManifest", _manifest];
    _ship setVariable ["OpsRoom_PortLocId", _portLocId];
    _ship setVariable ["OpsRoom_NavActive", true];
    _ship setVariable ["OpsRoom_NavWaypointIndex", 0];
    _ship setVariable ["OpsRoom_NavWaypoints", +_waypoints];
    _ship setVariable ["OpsRoom_NavSpeed", _shipSpeed];
    
    // Initialize unload state
    private _unloadState = createHashMapFromArray [
        ["status", "sailing"],
        ["unloadIndex", 0],
        ["unloadStartTime", 0],
        ["currentItem", ""],
        ["totalItems", count _manifest],
        ["unloadedCount", 0]
    ];
    
    _x set [1, _ship];
    if (count _x < 3) then { _x pushBack _unloadState } else { _x set [2, _unloadState] };
    
    // Killed event handler
    _ship addEventHandler ["Killed", {
        params ["_vehicle"];
        _vehicle setVariable ["OpsRoom_NavActive", false];
        private _cIdx = _vehicle getVariable ["OpsRoom_ConvoyIndex", -1];
        private _sIdx = _vehicle getVariable ["OpsRoom_ShipIndex", -1];
        private _sName = _vehicle getVariable ["OpsRoom_ShipName", "Unknown vessel"];
        private _manifest = _vehicle getVariable ["OpsRoom_ShipManifest", []];
        [_cIdx, _sIdx, _sName, _manifest] call OpsRoom_fnc_onShipDestroyed;
    }];
    
    // ============================================================
    // SCRIPTED NAVIGATION LOOP — replaces AI waypoints entirely
    // Ship sails in perfect straight lines between waypoints
    // ============================================================
    [_ship, _shipSpeed] spawn {
        params ["_ship", "_speed"];
        
        waitUntil { sleep 0.5; !isNull _ship && {alive _ship} };
        
        while {alive _ship && {_ship getVariable ["OpsRoom_NavActive", false]}} do {
            private _wps = _ship getVariable ["OpsRoom_NavWaypoints", []];
            private _wpIdx = _ship getVariable ["OpsRoom_NavWaypointIndex", 0];
            private _spd = _ship getVariable ["OpsRoom_NavSpeed", _speed];
            
            if (_wpIdx >= count _wps) exitWith {
                // All waypoints reached — stop the ship
                _ship setVelocity [0, 0, 0];
                _ship setVariable ["OpsRoom_NavActive", false];
                diag_log format ["[OpsRoom] Ship %1: All waypoints reached, stopping", _ship getVariable ["OpsRoom_ShipName", "?"]];
            };
            
            private _targetPos = _wps select _wpIdx;
            private _shipPos = getPos _ship;
            private _dist = _shipPos distance2D _targetPos;
            
            // Check if close enough to advance to next waypoint
            // Use 80m for intermediate waypoints, but the convoyMonitor
            // handles the final dock teleport at 200m
            if (_dist < 80) then {
                _ship setVariable ["OpsRoom_NavWaypointIndex", _wpIdx + 1];
                diag_log format ["[OpsRoom] Ship %1: Reached waypoint %2, advancing", _ship getVariable ["OpsRoom_ShipName", "?"], _wpIdx + 1];
            } else {
                // Calculate direction to target
                private _dir = _shipPos getDir _targetPos;
                
                // Smoothly rotate ship toward target (lerp direction)
                private _currentDir = getDir _ship;
                private _dirDiff = _dir - _currentDir;
                // Normalise to -180..180
                if (_dirDiff > 180) then { _dirDiff = _dirDiff - 360 };
                if (_dirDiff < -180) then { _dirDiff = _dirDiff + 360 };
                
                // Turn rate: max 3 degrees per tick (smooth turning for a large ship)
                private _turnRate = 3;
                private _newDir = _currentDir + ((_dirDiff min _turnRate) max (-_turnRate));
                _ship setDir _newDir;
                
                // Set velocity in the facing direction
                // Slow down when approaching waypoint for smoother turns
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
    
    _spawnedCount = _spawnedCount + 1;
    diag_log format ["[OpsRoom] Convoy %1: Ship %2 spawned at %3 (scripted nav, %4 waypoints)", _codename, _forEachIndex + 1, _spawnPos, count _waypoints];
} forEach _ships;

// Update convoy status
_convoy set [7, "sailing"];
_convoy set [8, _spawnedCount];

["PRIORITY", format ["CONVOY %1 UNDERWAY", _codename],
    format ["Convoy %1 has entered %2. %3 ship(s) en route to %4.", _codename, _laneName, _spawnedCount, _portName]
] call OpsRoom_fnc_dispatch;

systemChat format ["Convoy %1: %2 ships sailing via %3 to %4", _codename, _spawnedCount, _laneName, _portName];
diag_log format ["[OpsRoom] Convoy %1 spawned: %2 ships on %3 → %4", _codename, _spawnedCount, _seaLaneId, _portLocId];
