/*
    Convoy Draw3D
    
    Adds a Draw3D event handler that shows status labels above
    convoy ships in Zeus view. Matches the air wing Draw3D pattern.
    
    Labels show: Convoy codename | status (En Route / Unloading X / Waiting / Returning)
    
    Called once at init. Runs continuously via Draw3D event.
    
    Usage:
        [] call OpsRoom_fnc_convoyDraw3D;
*/

if (!isNil "OpsRoom_ConvoyDraw3D_EH") then {
    removeMissionEventHandler ["Draw3D", OpsRoom_ConvoyDraw3D_EH];
};

OpsRoom_ConvoyDraw3D_EH = addMissionEventHandler ["Draw3D", {
    // Only draw in Zeus
    if (isNull findDisplay 312) exitWith {};
    if (isNil "OpsRoom_ActiveConvoys") exitWith {};
    
    private _camPos = getPosVisual curatorCamera;
    
    {
        _x params ["_convoyId", "_codename", "_ships"];
        private _convoyStatus = _x select 7;
        
        // Skip ordered convoys (no physical ships yet)
        if (_convoyStatus == "ordered") then { continue };
        
        {
            _x params ["_manifest", "_shipObj"];
            
            if (isNull _shipObj || {!alive _shipObj}) then { continue };
            
            private _pos = getPosVisual _shipObj;
            private _dist = _camPos distance _pos;
            
            // Only draw within 10km
            if (_dist > 10000) then { continue };
            
            // Get ship unload state
            private _state = if (count _x > 2) then { _x select 2 } else { createHashMap };
            if (isNil "_state" || {typeName _state != "HASHMAP"}) then { _state = createHashMap };
            
            private _shipStatus = _state getOrDefault ["status", "sailing"];
            private _currentItem = _state getOrDefault ["currentItem", ""];
            private _unloadedCount = _state getOrDefault ["unloadedCount", 0];
            private _totalItems = _state getOrDefault ["totalItems", count _manifest];
            
            // Build status label
            private _statusLabel = switch (_shipStatus) do {
                case "sailing":   { "En Route" };
                case "unloading": {
                    if (_currentItem != "") then {
                        format ["Unloading %1 (%2/%3)", _currentItem, _unloadedCount + 1, _totalItems]
                    } else {
                        format ["Unloading (%1/%2)", _unloadedCount + 1, _totalItems]
                    };
                };
                case "waiting":   { "Waiting for Dock Space" };
                case "returning": { "Returning" };
                case "arrived":   { "Docked" };
                default           { _shipStatus };
            };
            
            // Colour by status
            private _color = switch (_shipStatus) do {
                case "sailing":   { [0.3, 0.8, 0.3, 0.9] };
                case "unloading": { [0.9, 0.8, 0.2, 0.9] };
                case "waiting":   { [0.9, 0.5, 0.2, 0.9] };
                case "returning": { [0.5, 0.5, 0.8, 0.9] };
                default           { [1, 1, 1, 0.8] };
            };
            
            // Ship icon
            private _markerPos = _pos vectorAdd [0, 0, 10];
            drawIcon3D [
                "\A3\ui_f\data\map\vehicleicons\iconShip_ca.paa",
                _color,
                _markerPos,
                1.0,
                1.0,
                0,
                "",
                0,
                0.03,
                "PuristaMedium",
                "center"
            ];
            
            // Label below icon
            private _labelPos = _pos vectorAdd [0, 0, 6];
            drawIcon3D [
                "",
                _color,
                _labelPos,
                0,
                0,
                0,
                format ["Convoy %1 | %2", _codename, _statusLabel],
                1,
                0.025,
                "PuristaLight",
                "center"
            ];
        } forEach _ships;
    } forEach OpsRoom_ActiveConvoys;
}];

diag_log "[OpsRoom] Convoy: Draw3D markers initialized";
