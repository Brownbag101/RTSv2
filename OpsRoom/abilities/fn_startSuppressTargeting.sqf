/*
    Author: OpsRoom
    Description: Start cursor targeting mode for suppression
    
    Parameters:
        0: NUMBER - Duration in seconds (-1 for endless)
    
    Returns:
        Nothing
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

// Create crosshair cursor overlay
private _cursor = _display ctrlCreate ["RscPicture", -1];
_cursor ctrlSetPosition [
    safezoneX + (safezoneW * 0.5) - 0.02,
    safezoneY + (safezoneH * 0.5) - 0.02,
    0.04,
    0.04
];
_cursor ctrlSetText "a3\ui_f\data\igui\cfg\cursors\attack_ca.paa";
_cursor ctrlSetTextColor [1, 0.5, 0, 1]; // Orange for suppress
_cursor ctrlCommit 0;
OpsRoom_SuppressTargeting_CursorCtrl = _cursor;

// Add per-frame handler for cursor (keeps it centered)
OpsRoom_SuppressTargeting_FrameHandler = addMissionEventHandler ["EachFrame", {
    private _cursor = OpsRoom_SuppressTargeting_CursorCtrl;
    if (isNull _cursor) exitWith {};
    
    // Keep cursor centered (in case display resizes)
    _cursor ctrlSetPosition [
        safezoneX + (safezoneW * 0.5) - 0.02,
        safezoneY + (safezoneH * 0.5) - 0.02,
        0.04,
        0.04
    ];
    _cursor ctrlCommit 0;
}];

// Add mouse click handler
OpsRoom_SuppressTargeting_ClickHandler = _display displayAddEventHandler ["MouseButtonDown", {
    params ["_display", "_button"];
    
    // Only respond to left click
    if (_button != 0) exitWith {};
    
    private _units = OpsRoom_SuppressTargeting_Units;
    private _duration = OpsRoom_SuppressTargeting_Duration;
    
    if (isNil "_units" || {_units isEqualTo []}) exitWith {};
    
    // Get target position at screen center
    private _targetPos = screenToWorld [0.5, 0.5];
    
    // Execute suppression
    [_units, _targetPos, _duration] call OpsRoom_fnc_executeSuppression;
    
    // Cleanup
    [] call OpsRoom_fnc_cancelSuppressTargeting;
    
    true // Consume the click
}];

// Add ESC handler to cancel
OpsRoom_SuppressTargeting_ESCHandler = _display displayAddEventHandler ["KeyDown", {
    params ["_display", "_key"];
    
    // ESC key = 1
    if (_key == 1) then {
        [] call OpsRoom_fnc_cancelSuppressTargeting;
        hint "Suppression targeting cancelled";
        true // Consume the key
    } else {
        false
    };
}];

hint "Click target position for suppression\nPress ESC to cancel";
systemChat format ["Suppression targeting mode active - %1 unit(s) ready", count _units];
