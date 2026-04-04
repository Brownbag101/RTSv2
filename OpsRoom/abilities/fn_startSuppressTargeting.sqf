/*
    OpsRoom_fnc_startSuppressTargeting
    
    Enters cursor-follow targeting mode for suppression (matches build menu UX).
    Mouse cursor drives target position via screenToWorld(getMousePosition).
    Draw3D renders orange targeting reticle at cursor.
    Left click to confirm, RMB/ESC to cancel.
    
    Parameters:
        0: NUMBER - Duration in seconds (-1 for endless)
*/

params ["_duration"];

// Close the menu after selection
[] call OpsRoom_fnc_closeButtonMenu;

private _units = OpsRoom_SuppressUnits;
if (isNil "_units" || {_units isEqualTo []}) exitWith {
    hint "No units available for suppression";
};

private _display = findDisplay 312;
if (isNull _display) exitWith {
    hint "Zeus display not found";
};

// Store data globally
OpsRoom_SuppressTargeting_Active = true;
OpsRoom_SuppressTargeting_Units = _units;
OpsRoom_SuppressTargeting_Duration = _duration;

// Draw3D handler — cursor-follow targeting reticle
OpsRoom_SuppressTargeting_DrawEH = addMissionEventHandler ["Draw3D", {
    if !(OpsRoom_SuppressTargeting_Active isEqualTo true) exitWith {
        removeMissionEventHandler ["Draw3D", _thisEventHandler];
    };
    
    private _units = OpsRoom_SuppressTargeting_Units;
    if (isNil "_units" || {_units isEqualTo []}) exitWith {};
    
    // Get cursor world position from mouse
    private _mousePos = getMousePosition;
    private _cursorPos = screenToWorld _mousePos;
    _cursorPos set [2, 0];
    
    // Draw orange pulsing targeting circle at cursor
    private _pulse = 0.5 + (sin(time * 300) * 0.3);
    private _segments = 24;
    private _circleRadius = 3;
    for "_s" from 0 to (_segments - 1) do {
        private _a1 = (_s / _segments) * 360;
        private _a2 = ((_s + 1) / _segments) * 360;
        private _p1 = _cursorPos vectorAdd [_circleRadius * sin _a1, _circleRadius * cos _a1, 0.1];
        private _p2 = _cursorPos vectorAdd [_circleRadius * sin _a2, _circleRadius * cos _a2, 0.1];
        drawLine3D [_p1, _p2, [1, 0.5, 0, _pulse]];
    };
    
    // Draw crosshair lines through centre
    private _chSize = 1.5;
    drawLine3D [
        _cursorPos vectorAdd [-_chSize, 0, 0.1],
        _cursorPos vectorAdd [_chSize, 0, 0.1],
        [1, 0.5, 0, 0.7]
    ];
    drawLine3D [
        _cursorPos vectorAdd [0, -_chSize, 0.1],
        _cursorPos vectorAdd [0, _chSize, 0.1],
        [1, 0.5, 0, 0.7]
    ];
    
    // Draw label above cursor
    private _durationText = if (OpsRoom_SuppressTargeting_Duration < 0) then {
        "UNTIL OUT OF AMMO"
    } else {
        format ["%1s", OpsRoom_SuppressTargeting_Duration]
    };
    drawIcon3D ["", [1, 0.5, 0, 0.9], _cursorPos vectorAdd [0,0,3.5], 0, 0, 0,
        format ["SUPPRESS (%1) — CLICK to target", _durationText], 2, 0.04, "PuristaMedium", "center", true];
    drawIcon3D ["", [1,1,1,0.5], _cursorPos vectorAdd [0,0,2.8], 0, 0, 0,
        format ["%1 unit(s) ready — RMB / ESC to cancel", count _units], 2, 0.03, "PuristaMedium", "center", true];
    
    // Draw lines from each unit to cursor position
    {
        private _unitPos = getPosATL _x;
        _unitPos set [2, (_unitPos select 2) + 1];
        drawLine3D [_unitPos, _cursorPos vectorAdd [0,0,0.5], [1, 0.5, 0, 0.3]];
    } forEach _units;
}];

// Mouse click handler
OpsRoom_SuppressTargeting_ClickHandler = _display displayAddEventHandler ["MouseButtonDown", {
    params ["_display", "_button"];
    
    // Right click = cancel
    if (_button == 1) exitWith {
        [] call OpsRoom_fnc_cancelSuppressTargeting;
        hint "Suppression targeting cancelled";
        true
    };
    
    // Only respond to left click
    if (_button != 0) exitWith {};
    
    private _units = OpsRoom_SuppressTargeting_Units;
    private _duration = OpsRoom_SuppressTargeting_Duration;
    
    if (isNil "_units" || {_units isEqualTo []}) exitWith {};
    
    // Get target position from mouse cursor
    private _targetPos = screenToWorld (getMousePosition);
    
    // Execute suppression
    [_units, _targetPos, _duration] call OpsRoom_fnc_executeSuppression;
    
    // Cleanup
    [] call OpsRoom_fnc_cancelSuppressTargeting;
    
    true // Consume the click
}];

// ESC key handler to cancel
OpsRoom_SuppressTargeting_ESCHandler = _display displayAddEventHandler ["KeyDown", {
    params ["_display", "_key"];
    
    if (_key == 1) then {
        [] call OpsRoom_fnc_cancelSuppressTargeting;
        hint "Suppression targeting cancelled";
        true
    } else {
        false
    };
}];

systemChat format ["Suppression targeting — move mouse to aim, LEFT CLICK to target, RIGHT CLICK / ESC to cancel (%1 units)", count _units];
