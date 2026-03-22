/*
    OpsRoom_fnc_createMissionIntro
    
    Creates a cinematic fade-in intro sequence for missions
    Uses layer system to avoid hiding HUD elements
    
    Parameters:
        _missionTitle - Mission title text
        _missionDesc - Mission description text
        _fadeDuration - Duration of fade-in (default: 10 seconds)
*/

params [
    ["_missionTitle", "MISSION BRIEFING", [""]],
    ["_missionDesc", "", [""]],
    ["_fadeDuration", 30, [0]]
];

// Wait for Zeus display and ensure UI is hidden
waitUntil {!isNull (findDisplay 312)};
sleep 0.5; // Give Zeus UI hide function time to complete

// Create black screen overlay on a separate layer (doesn't affect HUD)
private _layer = "OpsRoom_BlackScreen" cutRsc ["RscTitleDisplayEmpty", "PLAIN"];
private _blackDisplay = uiNamespace getVariable "RscTitleDisplayEmpty";

// Full-screen black overlay
private _blackBG = _blackDisplay ctrlCreate ["RscText", -1];
_blackBG ctrlSetPosition [safezoneX, safezoneY, safezoneW, safezoneH];
_blackBG ctrlSetBackgroundColor [0, 0, 0, 1];
_blackBG ctrlCommit 0;

// Fade out the black screen
_blackBG ctrlSetFade 1;
_blackBG ctrlCommit _fadeDuration;

// Show mission text after partial fade
sleep (_fadeDuration * 0.5);

// Create text display on another layer
private _textLayer = "OpsRoom_IntroText" cutRsc ["RscTitleDisplayEmpty", "PLAIN"];
private _textDisplay = uiNamespace getVariable "RscTitleDisplayEmpty";

// Background for text
private _bg = _textDisplay ctrlCreate ["RscText", -1];
_bg ctrlSetPosition [
    safezoneX + (safezoneW * 0.25),
    safezoneY + (safezoneH * 0.35),
    safezoneW * 0.5,
    safezoneH * 0.3
];
_bg ctrlSetBackgroundColor [0.1, 0.08, 0.05, 0.9];
_bg ctrlCommit 0;

// Mission title
private _title = _textDisplay ctrlCreate ["RscStructuredText", -1];
_title ctrlSetPosition [
    safezoneX + (safezoneW * 0.27),
    safezoneY + (safezoneH * 0.38),
    safezoneW * 0.46,
    safezoneH * 0.08
];
_title ctrlSetStructuredText parseText format [
    "<t align='center' size='2.0' font='PuristaBold' color='#D4C8A8'>%1</t>",
    _missionTitle
];
_title ctrlCommit 0;

// Mission description
if (_missionDesc != "") then {
    private _desc = _textDisplay ctrlCreate ["RscStructuredText", -1];
    _desc ctrlSetPosition [
        safezoneX + (safezoneW * 0.28),
        safezoneY + (safezoneH * 0.48),
        safezoneW * 0.44,
        safezoneH * 0.15
    ];
    _desc ctrlSetStructuredText parseText format [
        "<t align='center' size='1.2' font='PuristaLight' color='#B8AE94'>%1</t>",
        _missionDesc
    ];
    _desc ctrlCommit 0;
};

// Hold for a few seconds
sleep 4;

// Fade out text
_bg ctrlSetFade 1;
_title ctrlSetFade 1;
_bg ctrlCommit 1.5;
_title ctrlCommit 1.5;

sleep 2;

// Clean up both layers
"OpsRoom_BlackScreen" cutText ["", "PLAIN"];
"OpsRoom_IntroText" cutText ["", "PLAIN"];

diag_log "[OpsRoom] Mission intro sequence complete";
