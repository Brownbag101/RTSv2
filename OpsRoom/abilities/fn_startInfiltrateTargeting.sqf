/*
    OpsRoom_fnc_startInfiltrateTargeting
    
    Cursor targeting for infiltration destination.
*/

params ["_mode"];

[] call OpsRoom_fnc_closeButtonMenu;

private _unit = OpsRoom_Infiltrate_Unit;
if (isNil "_unit" || {isNull _unit}) exitWith { hint "No unit available"; };

private _display = findDisplay 312;
if (isNull _display) exitWith {};

OpsRoom_Infiltrate_Targeting_Active = true;
OpsRoom_Infiltrate_Targeting_Mode = _mode;

// Create cursor
private _cursor = _display ctrlCreate ["RscPicture", -1];
_cursor ctrlSetPosition [
    safezoneX + (safezoneW * 0.5) - 0.02,
    safezoneY + (safezoneH * 0.5) - 0.02,
    0.04, 0.04
];
_cursor ctrlSetText "a3\ui_f\data\igui\cfg\simpleTasks\types\scout_ca.paa";
_cursor ctrlSetTextColor [0.5, 0, 0.8, 1];
_cursor ctrlCommit 0;
OpsRoom_Infiltrate_Targeting_CursorCtrl = _cursor;

// EachFrame
OpsRoom_Infiltrate_Targeting_FrameHandler = addMissionEventHandler ["EachFrame", {
    private _cursor = OpsRoom_Infiltrate_Targeting_CursorCtrl;
    if (isNull _cursor) exitWith {};
    _cursor ctrlSetPosition [
        safezoneX + (safezoneW * 0.5) - 0.02,
        safezoneY + (safezoneH * 0.5) - 0.02,
        0.04, 0.04
    ];
    _cursor ctrlCommit 0;
}];

// Draw3D - path preview
OpsRoom_Infiltrate_Targeting_DrawHandler = addMissionEventHandler ["Draw3D", {
    if !(OpsRoom_Infiltrate_Targeting_Active) exitWith {};
    
    private _unit = OpsRoom_Infiltrate_Unit;
    if (isNull _unit) exitWith {};
    
    private _targetPos = screenToWorld [0.5, 0.5];
    private _unitPos = getPos _unit;
    private _mode = OpsRoom_Infiltrate_Targeting_Mode;
    
    // Dashed line from unit to target
    private _color = if (_mode == "deep") then {[0.5, 0, 0.8, 0.5]} else {[0.5, 0.5, 0.8, 0.5]};
    private _dist = _unitPos distance _targetPos;
    private _segments = (round (_dist / 10)) max 2;
    
    for "_i" from 0 to _segments - 1 do {
        if (_i mod 2 == 0) then {
            private _t1 = _i / _segments;
            private _t2 = ((_i + 1) / _segments) min 1;
            private _p1 = [
                (_unitPos select 0) + ((_targetPos select 0) - (_unitPos select 0)) * _t1,
                (_unitPos select 1) + ((_targetPos select 1) - (_unitPos select 1)) * _t1,
                ((_unitPos select 2) max (_targetPos select 2)) + 0.3
            ];
            private _p2 = [
                (_unitPos select 0) + ((_targetPos select 0) - (_unitPos select 0)) * _t2,
                (_unitPos select 1) + ((_targetPos select 1) - (_unitPos select 1)) * _t2,
                ((_unitPos select 2) max (_targetPos select 2)) + 0.3
            ];
            drawLine3D [_p1, _p2, _color];
        };
    };
    
    // Label at target
    private _modeText = if (_mode == "deep") then {"DEEP INFILTRATE"} else {"QUICK INFILTRATE"};
    drawIcon3D ["", _color vectorAdd [0, 0, 0, 0.5],
        [_targetPos select 0, _targetPos select 1, (_targetPos select 2) + 3],
        0, 0, 0, _modeText,
        2, 0.05, "PuristaBold", "center"
    ];
}];

// Left click → execute
OpsRoom_Infiltrate_Targeting_ClickHandler = _display displayAddEventHandler ["MouseButtonDown", {
    params ["_display", "_button"];
    if (_button != 0) exitWith {};
    
    private _targetPos = screenToWorld [0.5, 0.5];
    private _unit = OpsRoom_Infiltrate_Unit;
    private _mode = OpsRoom_Infiltrate_Targeting_Mode;
    
    [_unit, _targetPos, _mode] call OpsRoom_fnc_executeInfiltrate;
    [] call OpsRoom_fnc_cancelInfiltrateTargeting;
    true
}];

// ESC → cancel
OpsRoom_Infiltrate_Targeting_ESCHandler = _display displayAddEventHandler ["KeyDown", {
    params ["_display", "_key"];
    if (_key == 1) then {
        [] call OpsRoom_fnc_cancelInfiltrateTargeting;
        hint "Infiltration cancelled";
        true
    } else { false };
}];

private _modeText = if (_mode == "deep") then {"Deep"} else {"Quick"};
hint format ["%1 Infiltration\nClick destination\nESC to cancel", _modeText];
