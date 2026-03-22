/*
    Operations Room - Create Date/Time Display
    
    Creates the date and time display in the top-left of Zeus interface.
    Shows real game date and time from mission settings.
*/

private _zeusDisplay = findDisplay 312;
if (isNull _zeusDisplay) exitWith {};

// Background
private _bg = _zeusDisplay ctrlCreate ["RscText", 9320];
_bg ctrlSetPosition [
    safezoneX + 0.01,
    safezoneY + 0.01,
    0.25,
    0.04
];
_bg ctrlSetBackgroundColor [0.40, 0.35, 0.25, 0.85];
_bg ctrlCommit 0;

// Date/Time text
private _text = _zeusDisplay ctrlCreate ["RscStructuredText", 9321];
_text ctrlSetPosition [
    safezoneX + 0.015,
    safezoneY + 0.015,
    0.24,
    0.03
];
_text ctrlSetBackgroundColor [0, 0, 0, 0];
_text ctrlCommit 0;

// Store reference for updates
uiNamespace setVariable ["OpsRoom_DateTime_Ctrl", _text];
