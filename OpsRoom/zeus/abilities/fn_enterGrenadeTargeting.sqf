/*
    OpsRoom_fnc_enterGrenadeTargeting
    
    Enters targeting mode with custom cursor and arc preview
    - Shows crosshair (green if in range, red if too far)
    - Draws throw arc preview starting AT GROUND LEVEL
    - Waits for left click to throw
    - ESC to cancel
    
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

// Create cursor overlay
private _cursor = _display ctrlCreate ["RscPicture", -1];
_cursor ctrlSetPosition [
    safezoneX + (safezoneW * 0.5) - 0.02,
    safezoneY + (safezoneH * 0.5) - 0.02,
    0.04,
    0.04
];
_cursor ctrlSetText "a3\ui_f\data\igui\cfg\cursors\attack_ca.paa";
_cursor ctrlCommit 0;
OpsRoom_GrenadeTargeting_CursorCtrl = _cursor;

// Get grenade throw range (typical: 40m for HE, 50m for smoke)
private _maxRange = 40;
if (_grenadeType in ["SmokeShell", "SmokeShellRed", "SmokeShellGreen", "SmokeShellYellow", 
                     "SmokeShellPurple", "SmokeShellBlue", "SmokeShellOrange"]) then {
    _maxRange = 50;
};

// Add per-frame handler for cursor updates and arc drawing
OpsRoom_GrenadeTargeting_FrameHandler = addMissionEventHandler ["EachFrame", {
    private _unit = OpsRoom_GrenadeTargeting_Unit;
    private _cursor = OpsRoom_GrenadeTargeting_CursorCtrl;
    
    if (isNull _unit || isNull _cursor) exitWith {};
    
    // Get cursor world position
    private _cursorPos = screenToWorld [0.5, 0.5];
    
    // Get unit's X/Y position
    private _unitPosATL = getPosATL _unit;
    private _unitX = _unitPosATL select 0;
    private _unitY = _unitPosATL select 1;
    
    // For VR map specifically, just use Z=0 (actual ground level visually)
    // This works because VR terrain is at 2m ASL but we want visual ground (0 ASL)
    private _unitPos = [_unitX, _unitY, 0];
    
    // Calculate distance
    private _distance = _unit distance2D _cursorPos;
    private _maxRange = 40;
    private _grenadeType = OpsRoom_GrenadeTargeting_Type;
    
    if (_grenadeType in ["SmokeShell", "SmokeShellRed", "SmokeShellGreen", "SmokeShellYellow", 
                         "SmokeShellPurple", "SmokeShellBlue", "SmokeShellOrange"]) then {
        _maxRange = 50;
    };
    
    // Update cursor color
    if (_distance <= _maxRange) then {
        _cursor ctrlSetTextColor [0, 1, 0, 1]; // Green
    } else {
        _cursor ctrlSetTextColor [1, 0, 0, 1]; // Red
    };
    
    // Draw throw arc
    private _arc = [_unitPos, _cursorPos, _distance <= _maxRange] call OpsRoom_fnc_calculateGrenadeArc;
    
    // Draw arc lines
    for "_i" from 0 to (count _arc - 2) do {
        private _p1 = _arc select _i;
        private _p2 = _arc select (_i + 1);
        
        if (_distance <= _maxRange) then {
            drawLine3D [_p1, _p2, [0, 1, 0, 0.8]]; // Green line
        } else {
            drawLine3D [_p1, _p2, [1, 0, 0, 0.8]]; // Red line
        };
    };
    
    // Draw impact marker
    if (count _arc > 0) then {
        private _impactPos = _arc select (count _arc - 1);
        drawIcon3D [
            "a3\ui_f\data\map\markers\military\destroy_ca.paa",
            if (_distance <= _maxRange) then {[0, 1, 0, 0.8]} else {[1, 0, 0, 0.8]},
            _impactPos,
            1,
            1,
            0,
            "",
            0,
            0.03,
            "PuristaMedium",
            "center"
        ];
    };
}];

// Add mouse click handler
OpsRoom_GrenadeTargeting_ClickHandler = _display displayAddEventHandler ["MouseButtonDown", {
    params ["_display", "_button", "_xPos", "_yPos", "_shift", "_ctrl", "_alt"];
    
    // Only respond to left click
    if (_button != 0) exitWith {};
    
    private _unit = OpsRoom_GrenadeTargeting_Unit;
    private _grenadeType = OpsRoom_GrenadeTargeting_Type;
    
    if (isNull _unit) exitWith {};
    
    // Get target position
    private _targetPos = screenToWorld [0.5, 0.5];
    
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

// Add ESC handler to cancel
OpsRoom_GrenadeTargeting_ESCHandler = _display displayAddEventHandler ["KeyDown", {
    params ["_display", "_key", "_shift", "_ctrl", "_alt"];
    
    // ESC key = 1
    if (_key == 1) then {
        call OpsRoom_fnc_cancelGrenadeTargeting;
        hint "Grenade targeting cancelled";
        true // Consume the key
    } else {
        false
    };
}];

systemChat "Grenade targeting mode active - Click to throw, ESC to cancel";
diag_log format ["[OpsRoom] Entered grenade targeting mode: %1", _grenadeType];
