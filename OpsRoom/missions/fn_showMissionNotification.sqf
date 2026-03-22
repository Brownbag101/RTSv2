/*
    Show Mission Notification
    
    Shows a custom mission notification that doesn't pull player out of Zeus.
    Uses titleText/titleRsc instead of HintC.
    
    Parameters:
        0: STRING - Title text
        1: STRING - Description text
        2: NUMBER - Duration in seconds (default: 8)
    
    Usage:
        ["MISSION COMPLETE", "Landing zone secured!", 10] call OpsRoom_fnc_showMissionNotification;
*/

params [
    ["_title", "", [""]],
    ["_description", "", [""]],
    ["_duration", 8, [0]]
];

// Use simpler titleText instead of BIS_fnc_typeText2 (which has parameter issues)
private _text = format [
    "<t size='1.5' color='#00FF00' font='PuristaBold' shadow='2'>%1</t><br/><br/><t size='1.0' color='#D9D5C9'>%2</t>",
    _title,
    _description
];

// Show using cutText (doesn't interrupt Zeus)
[
    parseText _text,
    [0.3, 0.3, 0.6, 0.1],
    1,
    _duration,
    0,
    0
] spawn BIS_fnc_dynamicText;

// Also play sound
playSound "taskSucceeded";

// SystemChat backup
systemChat format ["✓ %1: %2", _title, _description];

diag_log format ["[OpsRoom] Mission notification: %1 - %2", _title, _description];
