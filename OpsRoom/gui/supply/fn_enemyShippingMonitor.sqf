/*
    Enemy Shipping Monitor
    
    Periodically spawns enemy cargo ships on NAZI-owned routes.
    A route is active when both the sea lane entry AND port are NAZI-owned.
    Ships sail from origin through route waypoints to port, then despawn.
    
    Destroying enemy ships gives a resource bonus.
    
    Usage:
        [] spawn OpsRoom_fnc_enemyShippingMonitor;
*/

diag_log "[OpsRoom] Enemy shipping monitor started";

waitUntil { sleep 2; !isNil "OpsRoom_SeaLanes" && {!isNil "OpsRoom_StrategicLocations"} };

private _enemyShipNames = [
    "KMS Altmark", "KMS Doggerbank", "SS Donau", "SS Tannenberg",
    "MV Uckermark", "SS Python", "MV Nordmark", "SS Rhakotis",
    "SS Brake", "MV Charlotte Schliemann", "SS Burgenland", "SS Coburg"
];

while {true} do {
    private _interval = OpsRoom_Settings_EnemyShipInterval;
    private _waitTime = (_interval select 0) + random ((_interval select 1) - (_interval select 0));
    sleep _waitTime;
    
    // Get all active NAZI routes
    private _naziRoutes = ["NAZI"] call OpsRoom_fnc_getAvailableRoutes;
    // Each: [laneId, portLocId, laneName, portName]
    
    if (count _naziRoutes == 0) then { continue };
    
    // Pick random route
    private _route = selectRandom _naziRoutes;
    _route params ["_laneId", "_portLocId", "_laneName", "_portName"];
    
    private _laneData = OpsRoom_SeaLanes get _laneId;
    if (isNil "_laneData") then { continue };
    
    private _originPos = _laneData get "originPos";
    private _routesMap = _laneData get "routes";
    private _waypoints = _routesMap getOrDefault [_portLocId, []];
    
    private _portData = OpsRoom_StrategicLocations getOrDefault [_portLocId, createHashMap];
    private _portPos = if (count _portData > 0) then { _portData get "pos" } else { [0,0,0] };
    
    if (_portPos isEqualTo [0,0,0]) then { continue };
    
    // Build full route
    private _fullRoute = [_originPos] + _waypoints + [_portPos];
    if (count _fullRoute < 2) then { continue };
    
    // Spawn enemy ship
    private _shipClass = missionNamespace getVariable ["OpsRoom_Settings_EnemyShipClassName", "sab_nl_liberty"];
    
    private _ship = createVehicle [_shipClass, _originPos, [], 0, "NONE"];
    _ship setPos _originPos;
    
    if (count _fullRoute > 1) then {
        _ship setDir (_originPos getDir (_fullRoute select 1));
    };
    
    // Create BLUFOR crew (enemy)
    private _grp = createGroup [west, true];
    private _crew = _grp createUnit ["B_Soldier_F", _originPos, [], 0, "NONE"];
    _crew moveInDriver _ship;
    _crew setSkill 0.5;
    
    // Completely disable AI — scripted navigation
    _crew disableAI "MOVE";
    _crew disableAI "AUTOCOMBAT";
    _crew disableAI "FSM";
    _crew disableAI "TARGET";
    _crew disableAI "AUTOTARGET";
    _crew disableAI "SUPPRESSION";
    _crew disableAI "COVER";
    _crew disableAI "PATH";
    
    private _shipName = selectRandom _enemyShipNames;
    _ship setVariable ["OpsRoom_EnemyShipName", _shipName];
    _ship setVariable ["OpsRoom_IsEnemyShip", true];
    
    // Build nav waypoints (skip origin at index 0)
    private _navWps = [];
    for "_i" from 1 to (count _fullRoute - 1) do {
        _navWps pushBack (_fullRoute select _i);
    };
    
    // Scripted navigation loop — delete ship when done
    [_ship, _navWps, 8] spawn {
        params ["_ship", "_wps", "_speed"];
        private _wpIdx = 0;
        
        sleep 0.5;
        
        while {alive _ship && {_wpIdx < count _wps}} do {
            private _targetPos = _wps select _wpIdx;
            private _shipPos = getPos _ship;
            private _dist = _shipPos distance2D _targetPos;
            
            if (_dist < 80) then {
                _wpIdx = _wpIdx + 1;
            } else {
                private _dir = _shipPos getDir _targetPos;
                private _currentDir = getDir _ship;
                private _dirDiff = _dir - _currentDir;
                if (_dirDiff > 180) then { _dirDiff = _dirDiff - 360 };
                if (_dirDiff < -180) then { _dirDiff = _dirDiff + 360 };
                private _turnRate = 3;
                private _newDir = _currentDir + ((_dirDiff min _turnRate) max (-_turnRate));
                _ship setDir _newDir;
                
                private _actualSpeed = if (_dist < 200) then { _speed * 0.6 } else { _speed };
                _ship setVelocity [
                    _actualSpeed * sin _newDir,
                    _actualSpeed * cos _newDir,
                    0
                ];
            };
            
            sleep 0.5;
        };
        
        // Arrived at destination — delete ship and crew
        if (alive _ship) then {
            private _allCrew = crew _ship;
            { deleteVehicle _x } forEach _allCrew;
            deleteVehicle _ship;
        };
    };
    
    // Killed EH
    _ship addEventHandler ["Killed", {
        params ["_vehicle"];
        private _name = _vehicle getVariable ["OpsRoom_EnemyShipName", "Enemy vessel"];
        
        private _steelBonus = 5 + floor random 10;
        private _oilBonus = 3 + floor random 5;
        OpsRoom_Resource_Steel = OpsRoom_Resource_Steel + _steelBonus;
        OpsRoom_Resource_Oil = OpsRoom_Resource_Oil + _oilBonus;
        [] call OpsRoom_fnc_updateResources;
        
        ["PRIORITY", format ["%1 SUNK!", _name],
            format ["Enemy vessel %1 destroyed! Salvage: +%2 Steel, +%3 Oil.", _name, _steelBonus, _oilBonus]
        ] call OpsRoom_fnc_dispatch;
        
        systemChat format ["Enemy ship %1 sunk! +%2 Steel, +%3 Oil", _name, _steelBonus, _oilBonus];
    }];
    
    ["ROUTINE", "ENEMY SHIPPING DETECTED",
        format ["Intelligence reports enemy vessel on %1 heading for %2.", _laneName, _portName]
    ] call OpsRoom_fnc_dispatch;
    
    diag_log format ["[OpsRoom] Enemy shipping: %1 on %2 → %3", _shipName, _laneName, _portName];
};
