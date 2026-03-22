/*
    Draw Sea Lanes on Ops Map
    
    Draws each route (entry→port) as a separate thick polyline.
    Colour determined by ownership of BOTH the entry point AND the port:
        - Both BRITISH → solid blue (active friendly route)
        - Both NAZI → solid red (active enemy route)
        - Mixed/neutral → dashed grey (blocked)
    
    Also draws active convoy ship positions.
    
    Parameters:
        0: CONTROL - The map control
    
    Usage:
        [_mapCtrl] call OpsRoom_fnc_drawSeaLanes;
*/

params [["_mapCtrl", controlNull, [controlNull]]];

if (isNull _mapCtrl) exitWith {};

_mapCtrl ctrlAddEventHandler ["Draw", {
    params ["_ctrl"];
    
    if (isNil "OpsRoom_SeaLanes") exitWith {};
    
    // === DRAW SEA LANE ROUTES ===
    {
        private _laneData = _y;
        private _originPos = _laneData get "originPos";
        private _name = _laneData get "name";
        private _laneId = _laneData get "id";
        private _routes = _laneData get "routes";
        
        private _laneOwner = [_laneId] call OpsRoom_fnc_getSeaLaneOwner;
        
        // Draw each route to each port
        {
            private _portLocId = _x;
            private _waypoints = _y;
            
            private _portOwner = [_portLocId] call OpsRoom_fnc_getPortOwner;
            
            // Get port position for the final line segment
            private _portData = OpsRoom_StrategicLocations getOrDefault [_portLocId, createHashMap];
            private _portPos = if (count _portData > 0) then { _portData get "pos" } else { [0,0,0] };
            private _portName = if (count _portData > 0) then { _portData get "name" } else { "?" };
            
            if (_portPos isEqualTo [0,0,0]) then { continue };
            
            // Determine route colour
            private _active = false;
            private _color = [0.5, 0.5, 0.5, 0.3];
            private _labelColor = [0.6, 0.6, 0.6, 0.5];
            private _tag = "[BLOCKED]";
            
            if (_laneOwner == "BRITISH" && _portOwner == "BRITISH") then {
                _color = [0.2, 0.5, 0.9, 0.7];
                _labelColor = [0.3, 0.6, 1.0, 0.9];
                _active = true;
                _tag = "[ACTIVE]";
            };
            if (_laneOwner == "NAZI" && _portOwner == "NAZI") then {
                _color = [0.8, 0.2, 0.2, 0.6];
                _labelColor = [1.0, 0.3, 0.3, 0.8];
                _active = true;
                _tag = "[ENEMY]";
            };
            
            // Build route: origin → waypoints (last wp is the dock point, no land pos)
            private _route = [_originPos] + _waypoints;
            
            if (count _route < 2) then { continue };
            
            // Draw thick lines (5 parallel offsets)
            for "_i" from 0 to (count _route - 2) do {
                private _from = _route select _i;
                private _to = _route select (_i + 1);
                
                private _dx = (_to select 0) - (_from select 0);
                private _dy = (_to select 1) - (_from select 1);
                private _len = sqrt (_dx * _dx + _dy * _dy);
                if (_len < 1) then { continue };
                
                private _px = -_dy / _len;
                private _py = _dx / _len;
                
                {
                    private _offset = _x;
                    private _fromOff = [(_from select 0) + _px * _offset, (_from select 1) + _py * _offset];
                    private _toOff = [(_to select 0) + _px * _offset, (_to select 1) + _py * _offset];
                    _ctrl drawLine [_fromOff, _toOff, _color];
                } forEach [-60, -30, 0, 30, 60];
            };
            
            // Waypoint dots
            { _ctrl drawIcon ["\A3\ui_f\data\map\markers\military\dot_ca.paa", _labelColor, _x, 10, 10, 0, "", 0] } forEach _waypoints;
            
            // Label at midpoint of route
            private _midIdx = floor ((count _route) / 2);
            private _midPos = _route select _midIdx;
            
            _ctrl drawIcon [
                "\A3\ui_f\data\map\markers\military\dot_ca.paa",
                _labelColor,
                _midPos,
                18, 18, 0,
                format ["%1 → %2 %3", _name, _portName, _tag],
                1, 0.030,
                "PuristaBold", "right"
            ];
        } forEach _routes;
        
        // Draw anchor icon at entry point origin
        private _entryColor = switch (_laneOwner) do {
            case "BRITISH": { [0.3, 0.6, 1.0, 0.9] };
            case "NAZI":    { [1.0, 0.3, 0.3, 0.8] };
            default         { [0.6, 0.6, 0.6, 0.6] };
        };
        
        _ctrl drawIcon [
            "\A3\ui_f\data\map\markers\military\start_ca.paa",
            _entryColor,
            _originPos,
            28, 28, 0,
            _name,
            1, 0.035,
            "PuristaBold", "right"
        ];
    } forEach OpsRoom_SeaLanes;
    
    // === ACTIVE CONVOY POSITIONS ===
    if (!isNil "OpsRoom_ActiveConvoys") then {
        {
            private _convoy = _x;
            private _codename = _convoy select 1;
            private _ships = _convoy select 2;
            private _status = _convoy select 7;
            
            if (_status == "ordered") then { continue };
            
            {
                _x params ["_manifest", "_shipObj"];
                if (isNull _shipObj || {!alive _shipObj}) then { continue };
                
                private _state = if (count _x > 2) then { _x select 2 } else { createHashMap };
                if (isNil "_state" || {typeName _state != "HASHMAP"}) then { _state = createHashMap };
                private _shipStatus = _state getOrDefault ["status", "sailing"];
                
                private _iconColor = switch (_shipStatus) do {
                    case "sailing":   { [0.3, 0.8, 0.3, 0.9] };
                    case "unloading": { [0.9, 0.8, 0.2, 0.9] };
                    case "waiting":   { [0.9, 0.5, 0.2, 0.9] };
                    case "returning": { [0.5, 0.5, 0.8, 0.9] };
                    default           { [0.3, 0.8, 0.3, 0.9] };
                };
                
                _ctrl drawIcon [
                    "\A3\ui_f\data\map\vehicleicons\iconShip_ca.paa",
                    _iconColor,
                    getPos _shipObj,
                    28, 28,
                    getDir _shipObj,
                    format ["Convoy %1", _codename],
                    1, 0.032,
                    "PuristaBold", "right"
                ];
            } forEach _ships;
        } forEach OpsRoom_ActiveConvoys;
    };
}];

diag_log "[OpsRoom] Sea lane map draw handler added";
