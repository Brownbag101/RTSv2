/*
    OpsRoom_fnc_startTimebombTargeting
    
    Enter cursor targeting mode for timebomb placement.
    Shows crosshair, distance line, range indicator.
*/

params ["_fuseTime"];

[] call OpsRoom_fnc_closeButtonMenu;

private _unit = OpsRoom_Timebomb_Unit;
if (isNil "_unit" || {isNull _unit}) exitWith { hint "No unit available"; };

private _display = findDisplay 312;
if (isNull _display) exitWith {};

// Store targeting state
OpsRoom_Timebomb_Targeting_Active = true;
OpsRoom_Timebomb_Targeting_FuseTime = _fuseTime;
OpsRoom_Timebomb_MaxDistance = 100;

// Create crosshair cursor
private _cursor = _display ctrlCreate ["RscPicture", -1];
_cursor ctrlSetPosition [
    safezoneX + (safezoneW * 0.5) - 0.02,
    safezoneY + (safezoneH * 0.5) - 0.02,
    0.04, 0.04
];
_cursor ctrlSetText "\A3\ui_f\data\IGUI\Cfg\SimpleTasks\types\destroy_ca.paa";
_cursor ctrlSetTextColor [1, 0.3, 0, 1];
_cursor ctrlCommit 0;
OpsRoom_Timebomb_Targeting_CursorCtrl = _cursor;

// EachFrame keeps cursor centered
OpsRoom_Timebomb_Targeting_FrameHandler = addMissionEventHandler ["EachFrame", {
    private _cursor = OpsRoom_Timebomb_Targeting_CursorCtrl;
    if (isNull _cursor) exitWith {};
    _cursor ctrlSetPosition [
        safezoneX + (safezoneW * 0.5) - 0.02,
        safezoneY + (safezoneH * 0.5) - 0.02,
        0.04, 0.04
    ];
    _cursor ctrlCommit 0;
}];

// Draw3D handler for distance line and range check
OpsRoom_Timebomb_Targeting_DrawHandler = addMissionEventHandler ["Draw3D", {
    if !(OpsRoom_Timebomb_Targeting_Active) exitWith {};
    
    private _unit = OpsRoom_Timebomb_Unit;
    if (isNull _unit) exitWith {};
    
    private _targetPos = screenToWorld [0.5, 0.5];
    private _unitPos = getPos _unit;
    private _dist = _unitPos distance _targetPos;
    private _maxDist = OpsRoom_Timebomb_MaxDistance;
    
    // Colour based on range
    private _color = if (_dist <= _maxDist) then {[0, 1, 0, 0.6]} else {[1, 0, 0, 0.6]};
    
    // Line from unit to target
    drawLine3D [
        _unitPos vectorAdd [0,0,1],
        _targetPos vectorAdd [0,0,0.1],
        _color
    ];
    
    // Distance text at midpoint
    private _midPos = [
        ((_unitPos select 0) + (_targetPos select 0)) / 2,
        ((_unitPos select 1) + (_targetPos select 1)) / 2,
        (((_unitPos select 2) + (_targetPos select 2)) / 2) + 2
    ];
    
    drawIcon3D ["", _color, _midPos, 0, 0, 0,
        format ["%1m", round _dist], 2, 0.05, "PuristaBold", "center"
    ];
    
    // Explosion radius preview at target
    if (_dist <= _maxDist) then {
        private _radius = 10;
        private _segments = 16;
        for "_i" from 0 to _segments do {
            private _a1 = (_i / _segments) * 360;
            private _a2 = ((_i + 1) / _segments) * 360;
            drawLine3D [
                [(_targetPos select 0) + (_radius * cos _a1), (_targetPos select 1) + (_radius * sin _a1), (_targetPos select 2) + 0.1],
                [(_targetPos select 0) + (_radius * cos _a2), (_targetPos select 1) + (_radius * sin _a2), (_targetPos select 2) + 0.1],
                [1, 0.3, 0, 0.5]
            ];
        };
    };
}];

// Left click → execute
OpsRoom_Timebomb_Targeting_ClickHandler = _display displayAddEventHandler ["MouseButtonDown", {
    params ["_display", "_button"];
    if (_button != 0) exitWith {};
    
    private _targetPos = screenToWorld [0.5, 0.5];
    private _unit = OpsRoom_Timebomb_Unit;
    private _dist = (getPos _unit) distance _targetPos;
    
    // Range check
    if (_dist > OpsRoom_Timebomb_MaxDistance) exitWith {
        hint format ["Too far! Maximum range is %1m\nCurrent distance: %2m", OpsRoom_Timebomb_MaxDistance, round _dist];
    };
    
    private _fuseTime = OpsRoom_Timebomb_Targeting_FuseTime;
    
    [_unit, _targetPos, _fuseTime] call OpsRoom_fnc_executeTimebomb;
    [] call OpsRoom_fnc_cancelTimebombTargeting;
    true
}];

// ESC → cancel
OpsRoom_Timebomb_Targeting_ESCHandler = _display displayAddEventHandler ["KeyDown", {
    params ["_display", "_key"];
    if (_key == 1) then {
        [] call OpsRoom_fnc_cancelTimebombTargeting;
        hint "Timebomb placement cancelled";
        true
    } else { false };
}];

// Format fuse time for display
private _fuseText = if (_fuseTime < 60) then {
    format ["%1 seconds", _fuseTime]
} else {
    if (_fuseTime < 3600) then {
        format ["%1 minutes", floor(_fuseTime / 60)]
    } else {
        format ["%1 hours", floor(_fuseTime / 3600)]
    };
};

hint format ["Click position to place bomb\nFuse: %1\nMax range: %2m\nESC to cancel", _fuseText, OpsRoom_Timebomb_MaxDistance];
