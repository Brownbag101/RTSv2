/*
    OpsRoom_fnc_enterGrenadeTargeting
    
    Enters targeting mode with cursor-follow preview (matches build menu UX).
    - Mouse cursor drives target position via screenToWorld(getMousePosition)
    - Draw3D renders arc preview, range circle, and impact marker at cursor
    - Green if in range, red if too far
    - Left click to throw, ESC/RMB to cancel
    
    Params:
        _unit - Unit who will throw
        _grenadeType - Magazine classname
*/

params ["_unit", "_grenadeType"];

// Close any menu
call OpsRoom_fnc_closeButtonMenu;

private _display = findDisplay 312;
if (isNull _display) exitWith {};

// Mark targeting as active
OpsRoom_GrenadeTargeting_Active = true;
OpsRoom_GrenadeTargeting_Unit = _unit;
OpsRoom_GrenadeTargeting_Type = _grenadeType;

// Get grenade throw range (typical: 40m for HE, 50m for smoke)
private _maxRange = 40;
if (_grenadeType in ["SmokeShell", "SmokeShellRed", "SmokeShellGreen", "SmokeShellYellow", 
                     "SmokeShellPurple", "SmokeShellBlue", "SmokeShellOrange"]) then {
    _maxRange = 50;
};

// Draw3D handler — cursor-follow targeting with arc preview
OpsRoom_GrenadeTargeting_DrawEH = addMissionEventHandler ["Draw3D", {
    if !(OpsRoom_GrenadeTargeting_Active isEqualTo true) exitWith {
        removeMissionEventHandler ["Draw3D", _thisEventHandler];
    };
    
    private _unit = OpsRoom_GrenadeTargeting_Unit;
    if (isNull _unit) exitWith {};
    
    // Get cursor world position from mouse
    private _mousePos = getMousePosition;
    private _cursorPos = screenToWorld _mousePos;
    _cursorPos set [2, 0];
    
    // Unit ground position
    private _unitPosATL = getPosATL _unit;
    private _unitPos = [_unitPosATL select 0, _unitPosATL select 1, 0];
    
    // Calculate distance and range check
    private _distance = _unit distance2D _cursorPos;
    private _maxRange = 40;
    private _grenadeType = OpsRoom_GrenadeTargeting_Type;
    
    if (_grenadeType in ["SmokeShell", "SmokeShellRed", "SmokeShellGreen", "SmokeShellYellow", 
                         "SmokeShellPurple", "SmokeShellBlue", "SmokeShellOrange"]) then {
        _maxRange = 50;
    };
    
    private _inRange = _distance <= _maxRange;
    private _color = if (_inRange) then {[0, 1, 0, 0.8]} else {[1, 0, 0, 0.8]};
    
    // Draw targeting circle at cursor position
    private _pulse = 0.5 + (sin(time * 300) * 0.3);
    private _circleColor = if (_inRange) then {[0, 1, 0, _pulse]} else {[1, 0, 0, _pulse]};
    private _segments = 24;
    private _circleRadius = 2;
    for "_s" from 0 to (_segments - 1) do {
        private _a1 = (_s / _segments) * 360;
        private _a2 = ((_s + 1) / _segments) * 360;
        private _p1 = _cursorPos vectorAdd [_circleRadius * sin _a1, _circleRadius * cos _a1, 0.1];
        private _p2 = _cursorPos vectorAdd [_circleRadius * sin _a2, _circleRadius * cos _a2, 0.1];
        drawLine3D [_p1, _p2, _circleColor];
    };
    
    // Draw label above cursor
    private _rangeText = if (_inRange) then {
        format ["GRENADE — %.0fm — CLICK to throw", _distance]
    } else {
        format ["TOO FAR — %.0fm / %.0fm", _distance, _maxRange]
    };
    drawIcon3D ["", _color, _cursorPos vectorAdd [0,0,3], 0, 0, 0,
        _rangeText, 2, 0.04, "PuristaMedium", "center", true];
    drawIcon3D ["", [1,1,1,0.5], _cursorPos vectorAdd [0,0,2.3], 0, 0, 0,
        "RMB / ESC to cancel", 2, 0.03, "PuristaMedium", "center", true];
    
    // Draw throw arc
    private _arc = [_unitPos, _cursorPos, _inRange] call OpsRoom_fnc_calculateGrenadeArc;
    
    for "_i" from 0 to (count _arc - 2) do {
        private _p1 = _arc select _i;
        private _p2 = _arc select (_i + 1);
        drawLine3D [_p1, _p2, _color];
    };
    
    // Draw impact marker
    if (count _arc > 0) then {
        private _impactPos = _arc select (count _arc - 1);
        drawIcon3D [
            "a3\ui_f\data\map\markers\military\destroy_ca.paa",
            _color,
            _impactPos,
            1, 1, 0, "", 0, 0.03, "PuristaMedium", "center"
        ];
    };
}];

// Mouse click handler
OpsRoom_GrenadeTargeting_ClickHandler = _display displayAddEventHandler ["MouseButtonDown", {
    params ["_display", "_button", "_xPos", "_yPos", "_shift", "_ctrl", "_alt"];
    
    // Right click = cancel
    if (_button == 1) exitWith {
        call OpsRoom_fnc_cancelGrenadeTargeting;
        hint "Grenade targeting cancelled";
        true
    };
    
    // Only respond to left click
    if (_button != 0) exitWith {};
    
    private _unit = OpsRoom_GrenadeTargeting_Unit;
    private _grenadeType = OpsRoom_GrenadeTargeting_Type;
    
    if (isNull _unit) exitWith {};
    
    // Get target position from mouse cursor
    private _targetPos = screenToWorld (getMousePosition);
    
    // Check range
    private _distance = _unit distance2D _targetPos;
    private _maxRange = 40;
    
    if (_grenadeType in ["SmokeShell", "SmokeShellRed", "SmokeShellGreen", "SmokeShellYellow", 
                         "SmokeShellPurple", "SmokeShellBlue", "SmokeShellOrange"]) then {
        _maxRange = 50;
    };
    
    if (_distance > _maxRange) exitWith {
        hint format ["Target too far! (%.0fm / %.0fm)", _distance, _maxRange];
    };
    
    // Execute throw
    [_unit, _grenadeType, _targetPos] call OpsRoom_fnc_throwGrenade;
    
    // Cleanup
    call OpsRoom_fnc_cancelGrenadeTargeting;
    
    true // Consume the click
}];

// ESC key handler to cancel
OpsRoom_GrenadeTargeting_ESCHandler = _display displayAddEventHandler ["KeyDown", {
    params ["_display", "_key"];
    
    if (_key == 1) then {
        call OpsRoom_fnc_cancelGrenadeTargeting;
        hint "Grenade targeting cancelled";
        true
    } else {
        false
    };
}];

systemChat "Grenade targeting — move mouse to aim, LEFT CLICK to throw, RIGHT CLICK / ESC to cancel";
diag_log format ["[OpsRoom] Entered grenade targeting mode (cursor-follow): %1", _grenadeType];
