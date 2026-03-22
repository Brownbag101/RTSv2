/*
    Air Operations - Draw3D Markers for Airborne Wings
    
    Adds a Draw3D event handler that shows markers above
    airborne wing aircraft in Zeus view. Shows wing name,
    mission type, and aircraft icon.
    
    Called once at init. Runs continuously via Draw3D event.
*/

// Remove existing handler if present
if (!isNil "OpsRoom_AirDraw3D_EH") then {
    removeMissionEventHandler ["Draw3D", OpsRoom_AirDraw3D_EH];
};

OpsRoom_AirDraw3D_EH = addMissionEventHandler ["Draw3D", {
    // Only draw in Zeus
    if (isNull findDisplay 312) exitWith {};
    
    private _camPos = getPosVisual curatorCamera;
    
    {
        private _wingId = _x;
        private _wingData = _y;
        
        private _status = _wingData get "status";
        if (_status != "AIRBORNE" && _status != "LAUNCHING" && _status != "RTB") then { continue };
        
        private _wingName = _wingData get "name";
        private _mission = _wingData get "mission";
        private _spawnedObjects = _wingData get "spawnedObjects";
        
        // Get mission display name
        private _missionTarget = _wingData getOrDefault ["missionTarget", []];
        private _missionLabel = if (_mission != "") then {
            private _mData = OpsRoom_AirMissionTypes getOrDefault [_mission, createHashMap];
            _mData getOrDefault ["displayName", _mission]
        } else { _status };
        
        // Status-specific labels
        if (_status == "LAUNCHING") then {
            // Check if crew are still boarding (aircraft on ground, low speed)
            private _anyBoarding = false;
            {
                if (_x isKindOf "Air" && {alive _x}) then {
                    if (speed _x < 5 && {(getPosATL _x) select 2 < 10}) then {
                        _anyBoarding = true;
                    };
                };
            } forEach _spawnedObjects;
            
            if (_anyBoarding) then {
                _missionLabel = "Crew Boarding";
            } else {
                _missionLabel = "Taking Off";
            };
        };
        
        // Check if aircraft are near their loiter point
        if (_status == "AIRBORNE" && {count _missionTarget > 0} && {count _spawnedObjects > 0}) then {
            private _firstAC = objNull;
            { if (_x isKindOf "Air" && {alive _x}) exitWith { _firstAC = _x } } forEach _spawnedObjects;
            if (!isNull _firstAC && {(_firstAC distance2D _missionTarget) < 2000}) then {
                _missionLabel = _missionLabel + " | At Loiter";
            };
        };
        
        // Colour based on status
        private _color = switch (_status) do {
            case "AIRBORNE": { [0.4, 0.8, 0.4, 0.9] };
            case "LAUNCHING": { [0.8, 0.8, 0.3, 0.9] };
            case "RTB": { [0.8, 0.5, 0.2, 0.9] };
            default { [1, 1, 1, 0.8] };
        };
        
        // Draw marker above each aircraft in the wing
        {
            private _obj = _x;
            if (!(_obj isKindOf "Air")) then { continue };
            if (!alive _obj) then { continue };
            
            private _pos = getPosVisual _obj;
            private _dist = _camPos distance _pos;
            
            // Only draw within 10km
            if (_dist > 10000) then { continue };
            
            private _markerPos = _pos vectorAdd [0, 0, 15];
            
            // Draw aircraft icon
            drawIcon3D [
                "\A3\ui_f\data\map\vehicleicons\iconplane_ca.paa",
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
            
            // Draw label below icon (wing name + mission)
            private _labelPos = _pos vectorAdd [0, 0, 10];
            drawIcon3D [
                "",
                _color,
                _labelPos,
                0,
                0,
                0,
                format ["%1 | %2", _wingName, _missionLabel],
                1,
                0.025,
                "PuristaLight",
                "center"
            ];
        } forEach _spawnedObjects;
    } forEach OpsRoom_AirWings;
}];

diag_log "[OpsRoom] Air: Draw3D markers initialized";
