/*
    Cargo System - Draw3D Handler
    
    Renders in-world 3D elements for the cargo system:
    
    1. Loading/unloading progress bars above vehicles
    2. Hover highlight markers above items when browsing the cargo menu
    3. Cargo count labels above loaded vehicles in Zeus
    
    Called once at init. Runs continuously via Draw3D event handler.
    
    Usage:
        [] call OpsRoom_fnc_cargoDraw3D;
*/

// Remove existing handler if present
if (!isNil "OpsRoom_CargoDraw3D_EH") then {
    removeMissionEventHandler ["Draw3D", OpsRoom_CargoDraw3D_EH];
};

OpsRoom_CargoDraw3D_EH = addMissionEventHandler ["Draw3D", {
    // Only render in Zeus
    if (isNull findDisplay 312) exitWith {};
    
    private _camPos = getPosVisual curatorCamera;
    
    // ============================================================
    // 1. PROGRESS BARS (loading/unloading)
    // ============================================================
    
    private _completedIndices = [];
    
    {
        private _entry = _x;
        private _index = _forEachIndex;
        
        // Skip completed entries (will be cleaned up below)
        if (_entry getOrDefault ["complete", false]) then {
            _completedIndices pushBack _index;
            continue;
        };
        
        private _vehicle = _entry get "vehicle";
        private _startTime = _entry get "startTime";
        private _duration = _entry get "duration";
        private _mode = _entry get "mode";
        private _displayName = _entry get "displayName";
        
        if (isNull _vehicle || !alive _vehicle) then {
            _completedIndices pushBack _index;
            continue;
        };
        
        private _vehPos = getPosVisual _vehicle;
        private _dist = _camPos distance _vehPos;
        
        // Only draw within reasonable distance
        if (_dist > 500) then { continue };
        
        // Calculate progress
        private _elapsed = time - _startTime;
        private _progress = (_elapsed / _duration) min 1;
        
        // Draw position: above the vehicle
        private _drawPos = [_vehPos select 0, _vehPos select 1, (_vehPos select 2) + 4];
        
        // Mode-specific colours
        private _barColor = if (_mode == "loading") then {
            [0.9, 0.85, 0.3, 0.9]  // Gold for loading
        } else {
            [0.3, 0.8, 0.4, 0.9]   // Green for unloading
        };
        
        private _modeText = if (_mode == "loading") then {"LOADING"} else {"UNLOADING"};
        
        // Draw label
        private _label = format ["%1: %2", _modeText, _displayName];
        drawIcon3D [
            "",
            [0.85, 0.82, 0.74, 0.9],
            _drawPos,
            0, 0,
            0,
            _label,
            2,
            0.035,
            "PuristaMedium",
            "center",
            true
        ];
        
        // Draw progress bar background (dark)
        private _barWidth = 2.0;
        private _barHeight = 0.15;
        private _barY = (_drawPos select 2) - 0.6;
        private _barPos = [_drawPos select 0, _drawPos select 1, _barY];
        
        drawIcon3D [
            "#(argb,8,8,3)color(1,1,1,1)",
            [0.1, 0.1, 0.1, 0.7],
            _barPos,
            _barWidth,
            _barHeight,
            0,
            "",
            0,
            0.03,
            "PuristaMedium",
            "center",
            true
        ];
        
        // Draw progress bar fill
        if (_progress > 0.01) then {
            // Offset the filled portion to the left so it grows from left to right
            private _fillWidth = _barWidth * _progress;
            private _offsetX = (_barWidth - _fillWidth) * 0.3;  // Slight leftward offset
            private _fillPos = [
                (_barPos select 0) - _offsetX * (1 / (_dist max 1)),
                _barPos select 1,
                _barPos select 2
            ];
            
            drawIcon3D [
                "#(argb,8,8,3)color(1,1,1,1)",
                _barColor,
                _fillPos,
                _fillWidth,
                _barHeight,
                0,
                "",
                0,
                0.03,
                "PuristaMedium",
                "center",
                true
            ];
        };
        
        // Draw percentage text
        private _pctText = format ["%1%%", round (_progress * 100)];
        private _pctPos = [_drawPos select 0, _drawPos select 1, _barY - 0.4];
        drawIcon3D [
            "",
            _barColor,
            _pctPos,
            0, 0,
            0,
            _pctText,
            2,
            0.03,
            "PuristaMedium",
            "center",
            true
        ];
        
    } forEach OpsRoom_CargoProgress;
    
    // Clean up completed progress entries (reverse order to preserve indices)
    reverse _completedIndices;
    { OpsRoom_CargoProgress deleteAt _x } forEach _completedIndices;
    
    // ============================================================
    // 2. HOVER HIGHLIGHT (menu item preview)
    // ============================================================
    
    if (!isNil "OpsRoom_CargoHoverTargets") then {
        private _pulse = 0.6 + (sin (time * 300)) * 0.3;
        
        {
            private _hoverObj = _x;
            if (isNull _hoverObj) then { continue };
            
            private _objPos = getPosVisual _hoverObj;
            private _dist = _camPos distance _objPos;
            if (_dist > 300) then { continue };
            
            // Draw green highlight ring above the object
            private _highlightPos = [_objPos select 0, _objPos select 1, (_objPos select 2) + 2.5];
            
            drawIcon3D [
                "a3\ui_f\data\igui\cfg\simpleTasks\types\use_ca.paa",
                [0.3, 1.0, 0.3, _pulse],
                _highlightPos,
                1.2,
                1.2,
                0,
                "",
                0,
                0.03,
                "PuristaMedium",
                "center",
                true
            ];
            
            // Draw name label
            private _labelPos = [_objPos select 0, _objPos select 1, (_objPos select 2) + 3.2];
            private _objName = if (_hoverObj isKindOf "Man") then {
                name _hoverObj
            } else {
                getText (configFile >> "CfgVehicles" >> typeOf _hoverObj >> "displayName")
            };
            if (_objName == "") then { _objName = typeOf _hoverObj };
            
            drawIcon3D [
                "",
                [0.3, 1.0, 0.3, _pulse],
                _labelPos,
                0, 0,
                0,
                _objName,
                2,
                0.035,
                "PuristaMedium",
                "center",
                true
            ];
        } forEach OpsRoom_CargoHoverTargets;
    };
    
    // ============================================================
    // 3. CARGO COUNT LABELS (above loaded vehicles)
    // ============================================================
    
    // Show small cargo indicator above all vehicles that have cargo loaded
    // Uses curatorSelected to avoid iterating all vehicles — only show on selected
    private _selected = curatorSelected select 0;
    {
        private _unit = _x;
        if (_unit isKindOf "Man") then { continue };
        
        private _cargo = _unit getVariable ["OpsRoom_CargoItems", []];
        if (count _cargo == 0) then { continue };
        
        private _cap = [_unit] call OpsRoom_fnc_getCargoCapacity;
        _cap params ["_used", "_max", "_isCarrier"];
        if (!_isCarrier) then { continue };
        
        private _unitPos = getPosVisual _unit;
        private _dist = _camPos distance _unitPos;
        if (_dist > 400) then { continue };
        
        // Small cargo count label below the unit name
        private _labelPos = [_unitPos select 0, _unitPos select 1, (_unitPos select 2) + 3];
        
        drawIcon3D [
            "a3\ui_f\data\igui\cfg\simpleTasks\types\use_ca.paa",
            [0.85, 0.78, 0.55, 0.7],
            _labelPos,
            0.6,
            0.6,
            0,
            format [" %1/%2", _used, _max],
            2,
            0.028,
            "PuristaMedium",
            "left",
            true
        ];
    } forEach _selected;
}];

diag_log "[OpsRoom:Cargo] Draw3D handler initialized";
