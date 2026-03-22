/*
    Initialize Sea Lanes
    
    Scans editor markers for sea lane routes with per-port waypoints.
    
    Each sea lane entry point (opsroom_sealane_X) is a capturable strategic location.
    Each entry point has route waypoints to each port:
        opsroom_sealane_1_port_1_wp_1, _wp_2, etc. → Route from entry 1 to port 1
        opsroom_sealane_1_port_2_wp_1, _wp_2, etc. → Route from entry 1 to port 2
    
    A route is ACTIVE when:
        - The sea lane entry point is owned by the faction
        - The destination port is owned by the same faction
        - A waypoint set exists for that entry→port combination
    
    Usage:
        [] call OpsRoom_fnc_initSeaLanes;
*/

OpsRoom_SeaLanes = createHashMap;
OpsRoom_ActiveConvoys = [];
OpsRoom_ConvoyNextID = 1;
OpsRoom_CargoShips = 0;
OpsRoom_UsedCodenames = [];

// --- Collect all port numbers from strategic locations ---
private _portNumbers = [];  // [[portNum, locId], ...]
{
    private _locId = _x;
    private _locData = _y;
    if ((_locData get "type") == "port") then {
        private _markerName = _locData get "markerName";
        private _parts = _markerName splitString "_";
        if (count _parts >= 3) then {
            private _portNum = _parts select 2;
            _portNumbers pushBack [_portNum, _locId];
        };
    };
} forEach OpsRoom_StrategicLocations;

diag_log format ["[OpsRoom] Sea Lanes: Found %1 ports for route scanning", count _portNumbers];

// --- SCAN SEA LANES ---
for "_i" from 1 to 10 do {
    private _originMarker = format ["opsroom_sealane_%1", _i];
    private _originPos = getMarkerPos _originMarker;
    if (_originPos select 0 == 0 && _originPos select 1 == 0) then { continue };
    
    // Get name from settings or auto-generate
    private _names = missionNamespace getVariable ["OpsRoom_Settings_SeaLaneNames", ["Channel Route", "Atlantic Route", "Mediterranean Route"]];
    private _name = if (_i <= count _names) then { _names select (_i - 1) } else { format ["Sea Lane %1", _i] };
    
    private _laneId = format ["sealane_%1", _i];
    private _originLocId = format ["loc_sealane_%1", _i];
    
    // Scan per-port routes
    private _routes = createHashMap;
    
    {
        _x params ["_portNum", "_portLocId"];
        
        private _waypoints = [];
        for "_w" from 1 to 30 do {
            private _wpMarker = format ["opsroom_sealane_%1_port_%2_wp_%3", _i, _portNum, _w];
            private _wpPos = getMarkerPos _wpMarker;
            if (_wpPos select 0 == 0 && _wpPos select 1 == 0) then { break };
            _waypoints pushBack _wpPos;
            _wpMarker setMarkerAlpha 0;
        };
        
        if (count _waypoints > 0) then {
            _routes set [_portLocId, _waypoints];
            
            private _portData = OpsRoom_StrategicLocations getOrDefault [_portLocId, createHashMap];
            private _portName = if (count _portData > 0) then { _portData get "name" } else { format ["Port %1", _portNum] };
            
            diag_log format ["[OpsRoom] Sea Lane %1 → %2: %3 waypoints", _name, _portName, count _waypoints];
        };
    } forEach _portNumbers;
    
    if (count _routes == 0) then {
        systemChat format ["WARNING: Sea lane '%1' has no port routes! Place markers: opsroom_sealane_%2_port_X_wp_1", _name, _i];
        diag_log format ["[OpsRoom] WARNING: Sea lane %1 has no routes to any port", _name];
    };
    
    OpsRoom_SeaLanes set [_laneId, createHashMapFromArray [
        ["id", _laneId],
        ["name", _name],
        ["laneNumber", _i],
        ["originMarker", _originMarker],
        ["originPos", _originPos],
        ["originLocId", _originLocId],
        ["routes", _routes]
    ]];
    
    _originMarker setMarkerAlpha 0;
    
    systemChat format ["Convoy: Registered '%1' (%2 port routes)", _name, count _routes];
};

// --- SCAN PER-PORT DELIVERY MARKERS ---
OpsRoom_PortDeliveryMarkers = createHashMap;

{
    _x params ["_portNum", "_portLocId"];
    
    private _portMarkers = createHashMapFromArray [
        ["vehicle", []],
        ["ammo", []],
        ["weapons", []],
        ["equipment", []]
    ];
    
    {
        private _category = _x;
        for "_s" from 1 to 5 do {
            private _marker = format ["OpsRoom_delivery_%1_%2_%3", _category, _portNum, _s];
            private _pos = getMarkerPos _marker;
            if !(_pos select 0 == 0 && _pos select 1 == 0) then {
                (_portMarkers get _category) pushBack _pos;
                _marker setMarkerAlpha 0;
            };
        };
    } forEach ["vehicle", "ammo", "weapons", "equipment"];
    
    OpsRoom_PortDeliveryMarkers set [_portLocId, _portMarkers];
    
    private _totalSlots = 0;
    { _totalSlots = _totalSlots + count (_portMarkers get _x) } forEach ["vehicle", "ammo", "weapons", "equipment"];
    
    if (_totalSlots > 0) then {
        private _portData = OpsRoom_StrategicLocations getOrDefault [_portLocId, createHashMap];
        private _pName = if (count _portData > 0) then { _portData get "name" } else { _portLocId };
        diag_log format ["[OpsRoom] Port %1: %2 delivery slots", _pName, _totalSlots];
    };
} forEach _portNumbers;

// --- HELPER: Get owner of a sea lane entry point ---
OpsRoom_fnc_getSeaLaneOwner = {
    params ["_laneId"];
    private _laneData = OpsRoom_SeaLanes getOrDefault [_laneId, createHashMap];
    if (count _laneData == 0) exitWith { "UNKNOWN" };
    private _originLocId = _laneData get "originLocId";
    private _locData = OpsRoom_StrategicLocations getOrDefault [_originLocId, createHashMap];
    if (count _locData == 0) exitWith { "UNKNOWN" };
    _locData getOrDefault ["owner", "NAZI"]
};

// --- HELPER: Get port owner ---
OpsRoom_fnc_getPortOwner = {
    params ["_portLocId"];
    private _locData = OpsRoom_StrategicLocations getOrDefault [_portLocId, createHashMap];
    if (count _locData == 0) exitWith { "UNKNOWN" };
    _locData getOrDefault ["owner", "NAZI"]
};

// --- HELPER: Get available routes for a faction ---
// Returns: [[laneId, portLocId, laneName, portName], ...]
OpsRoom_fnc_getAvailableRoutes = {
    params ["_faction"];
    private _results = [];
    {
        private _laneId = _x;
        private _laneData = _y;
        private _laneOwner = [_laneId] call OpsRoom_fnc_getSeaLaneOwner;
        if (_laneOwner != _faction) then { continue };
        
        private _laneName = _laneData get "name";
        private _routes = _laneData get "routes";
        
        {
            private _portLocId = _x;
            private _portOwner = [_portLocId] call OpsRoom_fnc_getPortOwner;
            if (_portOwner != _faction) then { continue };
            
            private _portData = OpsRoom_StrategicLocations getOrDefault [_portLocId, createHashMap];
            if ((_portData getOrDefault ["status", ""]) == "destroyed") then { continue };
            private _portName = if (count _portData > 0) then { _portData get "name" } else { "Unknown" };
            
            _results pushBack [_laneId, _portLocId, _laneName, _portName];
        } forEach (keys _routes);
    } forEach OpsRoom_SeaLanes;
    _results
};

// --- HELPER: Get all friendly ports ---
OpsRoom_fnc_getFriendlyPorts = {
    private _ports = [];
    {
        private _locId = _x;
        private _locData = _y;
        if ((_locData get "type") == "port") then {
            if ((_locData getOrDefault ["owner", "NAZI"]) == "BRITISH") then {
                if ((_locData getOrDefault ["status", ""]) != "destroyed") then {
                    _ports pushBack [_locId, _locData get "name", _locData get "pos"];
                };
            };
        };
    } forEach OpsRoom_StrategicLocations;
    _ports
};

// --- HELPER: Get all enemy ports ---
OpsRoom_fnc_getEnemyPorts = {
    private _ports = [];
    {
        private _locId = _x;
        private _locData = _y;
        if ((_locData get "type") == "port") then {
            if ((_locData getOrDefault ["owner", "NAZI"]) == "NAZI") then {
                if ((_locData getOrDefault ["status", ""]) != "destroyed") then {
                    _ports pushBack [_locId, _locData get "name", _locData get "pos"];
                };
            };
        };
    } forEach OpsRoom_StrategicLocations;
    _ports
};

systemChat format ["Convoy: %1 sea lanes registered", count OpsRoom_SeaLanes];
diag_log format ["[OpsRoom] Sea lanes initialized: %1 total", count OpsRoom_SeaLanes];
