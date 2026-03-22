/*
    OpsRoom_fnc_openAirStrikeMapPicker
    
    Opens the Ops Map in two-click mode for ordering air strikes
    from the Air Operations panel.
    
    Click 1: Set target position (TGT)
    Click 2: Set approach direction (FAH) — must be 1500m+ from target
    
    Parameters:
        _callback   - Code block called with [_targetPos, _approachPos] on success
        _title      - Title text for the picker
        _cancelCode - Code block called if player cancels
    
    Usage:
        [{
            params ["_tgtPos", "_fahPos"];
            systemChat format ["Target: %1, Approach: %2", _tgtPos, _fahPos];
        }, "ORDER STRIKE", { hint "Cancelled" }] call OpsRoom_fnc_openAirStrikeMapPicker;
*/
params ["_callback", ["_title", "ORDER AIR STRIKE"], ["_cancelCode", {}]];

// Store state globally
OpsRoom_AirStrikeMap_Callback = _callback;
OpsRoom_AirStrikeMap_CancelCode = _cancelCode;
OpsRoom_AirStrikeMap_Active = true;
OpsRoom_AirStrikeMap_Phase = "TGT";
OpsRoom_AirStrikeMap_TargetPos = [];
OpsRoom_AirStrikeMap_MinDistance = OpsRoom_Settings_MinFAHDistance;

// Markers for visualisation on the Ops Map
OpsRoom_AirStrikeMap_Markers = [];

// Create the dialog (reuses the Ops Map dialog)
createDialog "OpsRoom_OpsMapDialog";
waitUntil {!isNull findDisplay 8010};

private _display = findDisplay 8010;

// Get the map control
private _mapCtrl = _display displayCtrl 11500;

// Centre map
if (!isNull _mapCtrl) then {
    private _worldSize = worldSize;
    private _centre = [_worldSize / 2, _worldSize / 2];
    _mapCtrl ctrlMapAnimAdd [0.5, 0.05, _centre];
    ctrlMapAnimCommit _mapCtrl;
};

// Draw sea lanes on the map
[_mapCtrl] call OpsRoom_fnc_drawSeaLanes;

// Set status bar
private _statusCtrl = _display displayCtrl 11501;
if (!isNull _statusCtrl) then {
    _statusCtrl ctrlSetStructuredText parseText format [
        "<t align='center' color='#FF8844'>%1</t>  <t align='center'>— Click the map to designate the TARGET position.</t>",
        _title
    ];
};

// Hide refresh button
private _refreshBtn = _display displayCtrl 11503;
if (!isNull _refreshBtn) then {
    _refreshBtn ctrlShow false;
};

// Override map click handler — two-phase
_mapCtrl ctrlRemoveAllEventHandlers "MouseButtonClick";

_mapCtrl ctrlAddEventHandler ["MouseButtonClick", {
    params ["_ctrl", "_button", "_xPos", "_yPos"];
    
    if (_button != 0) exitWith {};
    if !(OpsRoom_AirStrikeMap_Active) exitWith {};
    
    private _worldPos = _ctrl ctrlMapScreenToWorld [_xPos, _yPos];
    if (_worldPos isEqualTo [0,0]) exitWith {};
    
    private _phase = OpsRoom_AirStrikeMap_Phase;
    
    if (_phase == "TGT") then {
        // Phase 1: Store target, create marker, advance to FAH
        OpsRoom_AirStrikeMap_TargetPos = _worldPos;
        
        // Create target marker on map
        private _tgtMarker = createMarkerLocal ["OpsRoom_AirStrikeMap_TGT", _worldPos];
        _tgtMarker setMarkerTypeLocal "mil_destroy";
        _tgtMarker setMarkerColorLocal "ColorRed";
        _tgtMarker setMarkerTextLocal "TARGET";
        _tgtMarker setMarkerSizeLocal [0.8, 0.8];
        OpsRoom_AirStrikeMap_Markers pushBack _tgtMarker;
        
        // Create minimum distance ring
        private _ringMarker = createMarkerLocal ["OpsRoom_AirStrikeMap_Ring", _worldPos];
        _ringMarker setMarkerShapeLocal "ELLIPSE";
        _ringMarker setMarkerBrushLocal "Border";
        _ringMarker setMarkerColorLocal "ColorOrange";
        _ringMarker setMarkerSizeLocal [OpsRoom_AirStrikeMap_MinDistance, OpsRoom_AirStrikeMap_MinDistance];
        OpsRoom_AirStrikeMap_Markers pushBack _ringMarker;
        
        OpsRoom_AirStrikeMap_Phase = "FAH";
        
        // Update status bar
        private _display = ctrlParent _ctrl;
        private _statusCtrl = _display displayCtrl 11501;
        if (!isNull _statusCtrl) then {
            _statusCtrl ctrlSetStructuredText parseText (
                "<t align='center' color='#FF8844'>TARGET SET</t>  <t align='center'>— Now click the APPROACH DIRECTION (outside orange ring, 1500m+ from target). Aircraft will fly FROM this point.</t>"
            );
        };
    } else {
        // Phase 2: Validate distance, store approach, execute
        private _tgtPos = OpsRoom_AirStrikeMap_TargetPos;
        private _dist = _worldPos distance2D _tgtPos;
        private _minDist = OpsRoom_AirStrikeMap_MinDistance;
        
        if (_dist < _minDist) exitWith {
            systemChat format ["Too close! Approach must be %1m+ from target. Currently: %2m", _minDist, round _dist];
        };
        
        // Valid — create approach marker and direction line
        private _fahMarker = createMarkerLocal ["OpsRoom_AirStrikeMap_FAH", _worldPos];
        _fahMarker setMarkerTypeLocal "mil_start";
        _fahMarker setMarkerColorLocal "ColorGreen";
        _fahMarker setMarkerTextLocal "APPROACH";
        _fahMarker setMarkerSizeLocal [0.6, 0.6];
        OpsRoom_AirStrikeMap_Markers pushBack _fahMarker;
        
        // Direction line marker from approach to target
        private _midPoint = [
            ((_worldPos select 0) + (_tgtPos select 0)) / 2,
            ((_worldPos select 1) + (_tgtPos select 1)) / 2
        ];
        private _lineMarker = createMarkerLocal ["OpsRoom_AirStrikeMap_Line", _midPoint];
        _lineMarker setMarkerShapeLocal "RECTANGLE";
        _lineMarker setMarkerBrushLocal "SolidFull";
        _lineMarker setMarkerColorLocal "ColorGreen";
        private _lineLength = (_worldPos distance2D _tgtPos) / 2;
        _lineMarker setMarkerSizeLocal [10, _lineLength];
        _lineMarker setMarkerDirLocal (_worldPos getDir _tgtPos);
        OpsRoom_AirStrikeMap_Markers pushBack _lineMarker;
        
        // Deactivate and close
        OpsRoom_AirStrikeMap_Active = false;
        
        // Short delay to show the markers before closing
        [_worldPos] spawn {
            params ["_fahPos"];
            sleep 0.5;
            { deleteMarkerLocal _x } forEach OpsRoom_AirStrikeMap_Markers;
            OpsRoom_AirStrikeMap_Markers = [];
            closeDialog 0;
            private _tgtPos = OpsRoom_AirStrikeMap_TargetPos;
            [_tgtPos, _fahPos] call OpsRoom_AirStrikeMap_Callback;
        };
    };
}];

// Handle dialog close (Back / ESC) as cancel
_display displayAddEventHandler ["Unload", {
    if (OpsRoom_AirStrikeMap_Active) then {
        OpsRoom_AirStrikeMap_Active = false;
        
        // Clean up markers
        { deleteMarkerLocal _x } forEach OpsRoom_AirStrikeMap_Markers;
        OpsRoom_AirStrikeMap_Markers = [];
        
        hint "";
        [] call OpsRoom_AirStrikeMap_CancelCode;
    };
}];

diag_log format ["[OpsRoom] Air Strike Map picker opened: %1", _title];
