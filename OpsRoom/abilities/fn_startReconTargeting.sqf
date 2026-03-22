/*
    OpsRoom_fnc_startReconTargeting
    
    Enter cursor targeting mode for reconnaissance.
    Shows scan radius preview circle at cursor position.
*/

params ["_scanRadius"];

[] call OpsRoom_fnc_closeButtonMenu;

private _unit = OpsRoom_Recon_Unit;
if (isNil "_unit" || {isNull _unit}) exitWith { hint "No unit available"; };

private _display = findDisplay 312;
if (isNull _display) exitWith {};

// Store state
OpsRoom_Recon_Targeting_Active = true;
OpsRoom_Recon_Targeting_Radius = _scanRadius;

// Create cursor
private _cursor = _display ctrlCreate ["RscPicture", -1];
_cursor ctrlSetPosition [
    safezoneX + (safezoneW * 0.5) - 0.02,
    safezoneY + (safezoneH * 0.5) - 0.02,
    0.04, 0.04
];
_cursor ctrlSetText "a3\ui_f\data\igui\cfg\simpleTasks\types\scout_ca.paa";
_cursor ctrlSetTextColor [0, 0.8, 1, 1];
_cursor ctrlCommit 0;
OpsRoom_Recon_Targeting_CursorCtrl = _cursor;

// EachFrame - cursor tracking
OpsRoom_Recon_Targeting_FrameHandler = addMissionEventHandler ["EachFrame", {
    private _cursor = OpsRoom_Recon_Targeting_CursorCtrl;
    if (isNull _cursor) exitWith {};
    _cursor ctrlSetPosition [
        safezoneX + (safezoneW * 0.5) - 0.02,
        safezoneY + (safezoneH * 0.5) - 0.02,
        0.04, 0.04
    ];
    _cursor ctrlCommit 0;
}];

// Draw3D - scan radius preview
OpsRoom_Recon_Targeting_DrawHandler = addMissionEventHandler ["Draw3D", {
    if !(OpsRoom_Recon_Targeting_Active) exitWith {};
    
    private _targetPos = screenToWorld [0.5, 0.5];
    private _radius = OpsRoom_Recon_Targeting_Radius;
    
    // Draw scan radius circle
    private _segments = 24;
    for "_i" from 0 to _segments do {
        private _a1 = (_i / _segments) * 360;
        private _a2 = ((_i + 1) / _segments) * 360;
        drawLine3D [
            [(_targetPos select 0) + (_radius * cos _a1), (_targetPos select 1) + (_radius * sin _a1), (_targetPos select 2) + 0.1],
            [(_targetPos select 0) + (_radius * cos _a2), (_targetPos select 1) + (_radius * sin _a2), (_targetPos select 2) + 0.1],
            [0, 0.8, 1, 0.4]
        ];
    };
    
    // Label
    drawIcon3D ["", [0, 0.8, 1, 1],
        [_targetPos select 0, _targetPos select 1, (_targetPos select 2) + 3],
        0, 0, 0,
        format ["RECON - %1m radius", _radius],
        2, 0.05, "PuristaBold", "center"
    ];
}];

// Left click → execute
OpsRoom_Recon_Targeting_ClickHandler = _display displayAddEventHandler ["MouseButtonDown", {
    params ["_display", "_button"];
    if (_button != 0) exitWith {};
    
    private _targetPos = screenToWorld [0.5, 0.5];
    private _unit = OpsRoom_Recon_Unit;
    private _radius = OpsRoom_Recon_Targeting_Radius;
    
    [_unit, _targetPos, _radius] call OpsRoom_fnc_executeReconnoitre;
    [] call OpsRoom_fnc_cancelReconTargeting;
    true
}];

// ESC → cancel
OpsRoom_Recon_Targeting_ESCHandler = _display displayAddEventHandler ["KeyDown", {
    params ["_display", "_key"];
    if (_key == 1) then {
        [] call OpsRoom_fnc_cancelReconTargeting;
        hint "Reconnaissance cancelled";
        true
    } else { false };
}];

hint format ["Click position for recon observation\nScan radius: %1m\nESC to cancel", _scanRadius];
