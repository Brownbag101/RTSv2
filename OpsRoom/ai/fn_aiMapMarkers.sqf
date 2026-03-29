/*
    fn_aiMapMarkers
    
    Updates map markers for active AI commander groups.
    Gated by Command Intelligence level.
    
    At 60%+: Shows generic "Enemy Movement" markers
    At 80%+: Shows template name and direction
    At 100%: Shows exact group composition and destination
    
    Called from init.sqf as a background loop:
        [] spawn OpsRoom_fnc_aiMapMarkers;
*/

// Don't start multiple monitors
if (!isNil "OpsRoom_AI_MapMarkersRunning" && {OpsRoom_AI_MapMarkersRunning}) exitWith {};
OpsRoom_AI_MapMarkersRunning = true;

// Track created markers for cleanup
if (isNil "OpsRoom_AI_MapMarkerNames") then {
    OpsRoom_AI_MapMarkerNames = [];
};

diag_log "[OpsRoom] AI Map Markers monitor started";

while {OpsRoom_AI_MapMarkersRunning} do {
    
    private _intel = if (!isNil "OpsRoom_AI_IntelLevel") then { OpsRoom_AI_IntelLevel } else { 0 };
    
    // Clean up old markers
    {
        if (markerType _x != "") then { deleteMarker _x };
    } forEach OpsRoom_AI_MapMarkerNames;
    OpsRoom_AI_MapMarkerNames = [];
    
    // Below 60%: no map markers for enemy movements
    if (_intel < 60 || isNil "OpsRoom_AI_ActiveGroups") then {
        sleep 10;
        continue;
    };
    
    // Create markers for each active group
    {
        private _grpData = _x;
        private _grp = _grpData get "group";
        private _leader = leader _grp;
        
        if (!alive _leader) then { continue };
        
        private _pos = getPosATL _leader;
        private _targetPos = _grpData getOrDefault ["targetPos", [0,0,0]];
        private _templateName = _grpData getOrDefault ["templateName", "Enemy Group"];
        private _targetName = _grpData getOrDefault ["targetName", "Unknown"];
        private _missionType = _grpData getOrDefault ["missionType", ""];
        private _alive = {alive _x} count (units _grp);
        
        // Create position marker
        private _markerName = format ["opsroom_ai_grp_%1", _forEachIndex];
        private _marker = createMarker [_markerName, _pos];
        
        // Arrow marker pointing toward destination
        _marker setMarkerType "mil_arrow";
        _marker setMarkerColor "ColorOPFOR";
        _marker setMarkerSize [0.6, 0.6];
        
        if (!(_targetPos isEqualTo [0,0,0])) then {
            _marker setMarkerDir (_pos getDir _targetPos);
        };
        
        // Label depends on intel level
        private _label = if (_intel >= 100) then {
            format ["%1 (%2) -> %3 [%4]", _templateName, _alive, _targetName, toUpper _missionType]
        } else {
            if (_intel >= 80) then {
                format ["%1 -> %2", _templateName, _targetName]
            } else {
                "Enemy Movement"
            };
        };
        
        _marker setMarkerText _label;
        _marker setMarkerAlpha 0.8;
        
        OpsRoom_AI_MapMarkerNames pushBack _markerName;
        
        // At 80%+ intel, also show a line from group to destination
        if (_intel >= 80 && !(_targetPos isEqualTo [0,0,0])) then {
            private _lineMarkerName = format ["opsroom_ai_grp_%1_line", _forEachIndex];
            private _lineMarker = createMarker [_lineMarkerName, _pos];
            _lineMarker setMarkerShape "RECTANGLE";
            _lineMarker setMarkerColor "ColorOPFOR";
            _lineMarker setMarkerAlpha 0.3;
            
            // Calculate size and direction for the line
            private _dist = _pos distance2D _targetPos;
            _lineMarker setMarkerSize [15, _dist / 2];
            _lineMarker setMarkerDir (_pos getDir _targetPos);
            
            // Position at midpoint between group and target
            private _midPos = _pos vectorAdd ((_targetPos vectorDiff _pos) vectorMultiply 0.5);
            _lineMarkerName setMarkerPos _midPos;
            
            OpsRoom_AI_MapMarkerNames pushBack _lineMarkerName;
        };
        
    } forEach OpsRoom_AI_ActiveGroups;
    
    sleep 10;  // Update every 10 seconds
};
