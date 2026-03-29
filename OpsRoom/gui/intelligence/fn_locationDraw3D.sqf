/*
    fn_locationDraw3D
    
    Draw3D loop for strategic location indicators.
    
    Shows (when Zeus camera is within range):
        - Location name and type above the position
        - Capture progress bar (when contested)
        - Capture radius circle on the ground
        - Owner colour coding (blue = British, red = enemy, yellow = contested)
    
    Called from init.sqf:
        [] call OpsRoom_fnc_locationDraw3D;
*/

// Prevent duplicates
if (!isNil "OpsRoom_LocationDraw3DRunning" && {OpsRoom_LocationDraw3DRunning}) exitWith {};
OpsRoom_LocationDraw3DRunning = true;

addMissionEventHandler ["Draw3D", {
    
    if (isNil "OpsRoom_StrategicLocations") exitWith {};
    
    // Camera position
    private _camPos = if (!isNull findDisplay 312) then { getPos curatorCamera } else { getPosATL player };
    
    {
        private _locId = _x;
        private _locData = _y;
        
        private _pos = _locData get "pos";
        private _dist = _camPos distance _pos;
        
        // Only render within 2000m of camera
        if (_dist > 2000) then { continue };
        
        private _name = _locData get "name";
        private _type = _locData get "type";
        private _owner = _locData getOrDefault ["owner", "NAZI"];
        private _status = _locData get "status";
        private _contested = _locData getOrDefault ["contested", false];
        private _captureProgress = _locData getOrDefault ["captureProgress", 0];
        private _captureRadius = _locData getOrDefault ["captureRadius", 200];
        
        // Skip destroyed locations (show faded)
        private _alpha = if (_status == "destroyed") then { 0.3 } else { 0.8 };
        
        // Colour based on owner
        private _color = switch (_owner) do {
            case "BRITISH": { [0.3, 0.5, 1.0, _alpha] };   // Blue
            case "NAZI":    { [0.9, 0.2, 0.2, _alpha] };   // Red
            case "NEUTRAL": { [0.6, 0.6, 0.6, _alpha] };   // Grey
            default         { [0.9, 0.2, 0.2, _alpha] };
        };
        
        if (_contested) then {
            // Pulsing yellow when contested
            private _pulse = 0.6 + (sin (time * 200) * 0.4);
            _color = [1.0, 0.9, 0.1, _pulse];
        };
        
        // ========================================
        // FLAG ICON (only for discovered locations)
        // ========================================
        private _discovered = _locData getOrDefault ["discovered", false];
        
        if (_discovered) then {
            private _flagPos = _pos vectorAdd [0, 0, 12];
            
            // Choose flag texture based on owner
            private _flagIcon = if (_status == "destroyed") then {
                "\A3\ui_f\data\map\markers\military\destroy_CA.paa"
            } else {
                if (_owner == "BRITISH") then {
                    "\A3\Data_F\Flags\flag_uk_CO.paa"
                } else {
                    "\A3\Data_F\Flags\flag_red_CO.paa"
                };
            };
            
            // Flag colour tint
            private _flagColor = if (_status == "destroyed") then {
                [0.5, 0.5, 0.5, _alpha * 0.7]
            } else {
                if (_contested) then {
                    // Pulsing yellow when contested
                    private _pulse = 0.6 + (sin (time * 200) * 0.4);
                    [1, 0.9, 0.2, _pulse]
                } else {
                    [1, 1, 1, _alpha]
                };
            };
            
            drawIcon3D [
                _flagIcon,
                _flagColor,
                _flagPos,
                1.2, 1.2, 0,
                "",
                0, 0
            ];
        };
        
        // ========================================
        // LOCATION NAME LABEL
        // ========================================
        private _labelPos = _pos vectorAdd [0, 0, 8];
        
        private _typeData = OpsRoom_LocationTypes getOrDefault [_type, createHashMap];
        private _typeName = if (count _typeData > 0) then { _typeData get "displayName" } else { _type };
        
        private _labelText = if (_status == "destroyed") then {
            format ["[DESTROYED] %1", _name]
        } else {
            format ["%1 (%2)", _name, _typeName]
        };
        
        // Add building health info if friendly and damaged
        if (_status == "friendly") then {
            private _bTotal = _locData getOrDefault ["buildingsTotal", 0];
            private _bAlive = _locData getOrDefault ["buildingsAlive", 0];
            if (_bTotal > 0 && {_bAlive < _bTotal}) then {
                _labelText = format ["%1 [Buildings: %2/%3]", _labelText, _bAlive, _bTotal];
            };
        };
        
        // Scale text size based on distance
        private _textSize = if (_dist < 500) then { 0.04 } else { 0.03 };
        
        drawIcon3D [
            "",
            _color,
            _labelPos,
            0, 0, 0,
            _labelText,
            2, _textSize, "PuristaBold", "center", true
        ];
        
        // ========================================
        // CAPTURE PROGRESS BAR (when contested or in progress)
        // ========================================
        if (_captureProgress > 0 && _status != "destroyed") then {
            private _barPos = _pos vectorAdd [0, 0, 6.5];
            
            // Background bar (dark)
            private _bgWidth = 1.5;
            drawIcon3D [
                "\A3\ui_f\data\igui\cfg\simpletasks\types\use_ca.paa",
                [0.1, 0.1, 0.1, 0.6],
                _barPos,
                _bgWidth, 0.15, 0,
                "",
                0, 0
            ];
            
            // Progress bar (coloured by attacker)
            private _captureDir = _locData getOrDefault ["captureDirection", "none"];
            private _progressColor = if (_captureDir == "british") then {
                [0.3, 0.5, 1.0, 0.9]
            } else {
                [0.9, 0.2, 0.2, 0.9]
            };
            
            private _fillWidth = _bgWidth * (_captureProgress / 100);
            drawIcon3D [
                "\A3\ui_f\data\igui\cfg\simpletasks\types\use_ca.paa",
                _progressColor,
                _barPos,
                _fillWidth, 0.15, 0,
                "",
                0, 0
            ];
            
            // Progress text
            private _progressPos = _pos vectorAdd [0, 0, 5.5];
            drawIcon3D [
                "",
                [1, 1, 1, 0.9],
                _progressPos,
                0, 0, 0,
                format ["Capturing: %1%%", round _captureProgress],
                2, 0.03, "PuristaMedium", "center", true
            ];
        };
        
        // ========================================
        // CAPTURE RADIUS CIRCLE (only within 1000m)
        // ========================================
        if (_dist < 1000 && _status != "destroyed") then {
            private _segments = 36;  // Circle segments
            private _circleColor = +_color;
            _circleColor set [3, 0.25];  // Low alpha for the circle
            
            for "_s" from 0 to (_segments - 1) do {
                private _angle1 = (_s / _segments) * 360;
                private _angle2 = ((_s + 1) / _segments) * 360;
                
                private _p1 = _pos vectorAdd [
                    _captureRadius * sin _angle1,
                    _captureRadius * cos _angle1,
                    0.5
                ];
                private _p2 = _pos vectorAdd [
                    _captureRadius * sin _angle2,
                    _captureRadius * cos _angle2,
                    0.5
                ];
                
                drawLine3D [_p1, _p2, _circleColor];
            };
        };
        
    } forEach OpsRoom_StrategicLocations;
}];

diag_log "[OpsRoom] Location Draw3D initialized";
