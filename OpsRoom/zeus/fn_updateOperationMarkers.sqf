/*
    fn_updateOperationMarkers
    
    Shows Draw3D markers at operation target locations when units
    assigned to that operation are selected in Zeus.
    
    Also shows a small text above each selected unit indicating
    their assigned operation.
    
    Called on every selection change from the unified Zeus monitor.
    
    Parameters:
        0: ARRAY - Currently selected units
    
    Uses:
        - OpsRoom_fnc_create3DMarker / remove3DMarker for target markers
        - OpsRoom_fnc_getServiceRecord for unit operation assignment
        - OpsRoom_Operations for operation data
        - OpsRoom_StrategicLocations for target position
    
    Marker naming:
        Target markers: "opmarker_[opId]"
        Unit markers:   "opunit_[unitKey]"
*/

params [["_selected", [], [[]]]];

// Remove ALL previous operation markers using tracked list
private _existingMarkers = missionNamespace getVariable ["OpsRoom_OpMarkerIds", []];
{
    [_x] call OpsRoom_fnc_remove3DMarker;
} forEach _existingMarkers;
missionNamespace setVariable ["OpsRoom_OpMarkerIds", []];

// If nothing selected, we're done (markers cleared)
if (count _selected == 0) exitWith {};

// Collect active operations from selected units
private _activeOps = createHashMap;  // opId → opData
private _unitOps = [];               // [unit, opId] pairs

{
    private _unit = _x;
    if (alive _unit) then {
    
    // Get service record
    private _record = OpsRoom_UnitServiceRecords getOrDefault [str _unit, createHashMap];
    private _opId = _record getOrDefault ["currentOperation", ""];
    
    if (_opId != "") then {
        // Check operation exists and is active
        private _opData = OpsRoom_Operations getOrDefault [_opId, createHashMap];
        if (count _opData > 0 && {(_opData get "status") == "active"}) then {
            _activeOps set [_opId, _opData];
            _unitOps pushBack [_unit, _opId];
        };
    };
    }; // end alive check
} forEach _selected;

// No operations found — nothing to show
if (count _activeOps == 0) exitWith {};

// ========================================
// CREATE TARGET MARKERS (one per operation)
// ========================================
{
    private _opId = _x;
    private _opData = _y;
    
    private _opName = _opData get "name";
    private _taskType = _opData getOrDefault ["taskType", ""];
    private _targetId = _opData getOrDefault ["targetId", ""];
    private _targetName = _opData getOrDefault ["targetName", "Unknown"];
    
    // Get target position from strategic location
    private _targetPos = [];
    if (_targetId != "") then {
        private _locData = OpsRoom_StrategicLocations getOrDefault [_targetId, createHashMap];
        if (count _locData > 0) then {
            private _pos = _locData get "pos";
            _targetPos = [_pos select 0, _pos select 1, (_pos select 2) + 15];  // Elevated for visibility
        };
    };
    
    if (count _targetPos > 0) then {
    
    // Choose icon based on task type
    private _icon = "\A3\ui_f\data\map\markers\military\objective_CA.paa";
    private _color = [0.9, 0.85, 0.4, 1];  // Gold
    
    switch (toLower _taskType) do {
        case "capture": {
            _icon = "\A3\ui_f\data\map\markers\military\flag_CA.paa";
            _color = [0.3, 0.8, 0.3, 1];  // Green
        };
        case "destroy": {
            _icon = "\A3\ui_f\data\map\markers\military\destroy_CA.paa";
            _color = [0.9, 0.2, 0.2, 1];  // Red
        };
        case "reconnoitre"; 
        case "recon": {
            _icon = "\A3\ui_f\data\map\markers\military\unknown_CA.paa";
            _color = [0.4, 0.7, 1, 1];  // Blue
        };
        case "sabotage": {
            _icon = "\A3\ui_f\data\map\markers\military\destroy_CA.paa";
            _color = [0.9, 0.6, 0.1, 1];  // Orange
        };
        case "raid": {
            _icon = "\A3\ui_f\data\map\markers\military\destroy_CA.paa";
            _color = [0.9, 0.4, 0.1, 1];  // Dark orange
        };
    };
    
    // Build label text
    private _label = format ["Op: %1 — %2", toUpper _opName, toUpper _taskType];
    private _progress = _opData getOrDefault ["progress", 0];
    if (_progress > 0) then {
        _label = format ["%1 (%2%%)", _label, round _progress];
    };
    
    // Create the marker
    private _markerId = format ["opmarker_%1", _opId];
    [_markerId, _targetPos, _label, _icon, _color, 2.5] call OpsRoom_fnc_create3DMarker;
    
    // Track for cleanup
    private _tracked = missionNamespace getVariable ["OpsRoom_OpMarkerIds", []];
    _tracked pushBack _markerId;
    missionNamespace setVariable ["OpsRoom_OpMarkerIds", _tracked];
    
    }; // end targetPos check
} forEach _activeOps;

// Unit labels removed — target marker only is sufficient
