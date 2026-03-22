/*
    OpsRoom_fnc_startAirStrikeTargeting
    
    Two-phase cursor targeting for air strikes on Zeus display (312).
    
    Phase 1 (TGT): Player clicks terrain to set the target position.
                    Draw3D shows crosshair + "SELECT TARGET" label.
    
    Phase 2 (FAH): Player clicks terrain to set the approach direction.
                    Must be 1500m+ from target.
                    Draw3D shows target circle, 1500m radius ring,
                    and a direction arrow from approach pos to target.
    
    ESC cancels at any phase.
    
    Parameters:
        0: STRING - Attack type: "GUNS", "BOMBS", "ROCKETS", "STRAFE"
*/

params ["_attackType"];

[] call OpsRoom_fnc_closeButtonMenu;

private _unit = OpsRoom_AirStrike_Unit;
if (isNil "_unit" || {isNull _unit}) exitWith { hint "No Radio Operator available" };

private _display = findDisplay 312;
if (isNull _display) exitWith {};

// Minimum approach distance (metres) — from settings
OpsRoom_AirStrike_MinFAHDistance = OpsRoom_Settings_MinFAHDistance;

// Store targeting state
OpsRoom_AirStrike_Targeting_Active = true;
OpsRoom_AirStrike_Targeting_Phase = "TGT";
OpsRoom_AirStrike_Targeting_AttackType = _attackType;
OpsRoom_AirStrike_Targeting_TargetPos = [];
OpsRoom_AirStrike_Targeting_ApproachPos = [];

// Create crosshair cursor (centred on screen)
private _cursor = _display ctrlCreate ["RscPicture", -1];
_cursor ctrlSetPosition [
    safezoneX + (safezoneW * 0.5) - 0.02,
    safezoneY + (safezoneH * 0.5) - 0.02,
    0.04, 0.04
];
_cursor ctrlSetText "a3\ui_f\data\igui\cfg\cursors\attack_ca.paa";
_cursor ctrlSetTextColor [1, 0.3, 0, 1];
_cursor ctrlCommit 0;
OpsRoom_AirStrike_Targeting_CursorCtrl = _cursor;

// =====================
// Draw3D handler — draws different things per phase
// =====================
OpsRoom_AirStrike_Targeting_DrawHandler = addMissionEventHandler ["Draw3D", {
    if (isNil "OpsRoom_AirStrike_Targeting_Active") exitWith {};
    if !(OpsRoom_AirStrike_Targeting_Active) exitWith {};
    
    private _phase = OpsRoom_AirStrike_Targeting_Phase;
    private _type = OpsRoom_AirStrike_Targeting_AttackType;
    private _worldPos = screenToWorld [0.5, 0.5];
    
    if (_phase == "TGT") then {
        // Phase 1: Show crosshair label at cursor position
        // Small targeting circle at cursor
        private _radius = 30;
        private _segments = 16;
        for "_i" from 0 to _segments - 1 do {
            private _angle1 = (_i / _segments) * 360;
            private _angle2 = ((_i + 1) / _segments) * 360;
            private _p1 = _worldPos getPos [_radius, _angle1];
            private _p2 = _worldPos getPos [_radius, _angle2];
            _p1 set [2, 1]; _p2 set [2, 1];
            drawLine3D [_p1, _p2, [1, 0.3, 0, 0.8]];
        };
        
        drawIcon3D [
            "",
            [1, 0.3, 0, 1],
            [_worldPos select 0, _worldPos select 1, 5],
            0, 0, 0,
            format ["AIR STRIKE: %1 — SELECT TARGET", _type],
            2, 0.04, "RobotoCondensed"
        ];
    };
    
    if (_phase == "FAH") then {
        private _tgtPos = OpsRoom_AirStrike_Targeting_TargetPos;
        if (count _tgtPos == 0) exitWith {};
        
        // Draw red target circle at confirmed target
        private _radius = 50;
        private _segments = 24;
        for "_i" from 0 to _segments - 1 do {
            private _angle1 = (_i / _segments) * 360;
            private _angle2 = ((_i + 1) / _segments) * 360;
            private _p1 = _tgtPos getPos [_radius, _angle1];
            private _p2 = _tgtPos getPos [_radius, _angle2];
            _p1 set [2, 1]; _p2 set [2, 1];
            drawLine3D [_p1, _p2, [1, 0, 0, 0.9]];
        };
        
        // Draw X at target centre
        private _xSize = 15;
        private _tgtZ = 1;
        drawLine3D [
            [(_tgtPos select 0) - _xSize, (_tgtPos select 1) - _xSize, _tgtZ],
            [(_tgtPos select 0) + _xSize, (_tgtPos select 1) + _xSize, _tgtZ],
            [1, 0, 0, 0.9]
        ];
        drawLine3D [
            [(_tgtPos select 0) + _xSize, (_tgtPos select 1) - _xSize, _tgtZ],
            [(_tgtPos select 0) - _xSize, (_tgtPos select 1) + _xSize, _tgtZ],
            [1, 0, 0, 0.9]
        ];
        
        // Target label
        drawIcon3D [
            "", [1, 0, 0, 1],
            [_tgtPos select 0, _tgtPos select 1, 8],
            0, 0, 0,
            format ["TARGET: %1", _type],
            2, 0.035, "RobotoCondensed"
        ];
        
        // Draw minimum distance ring (dashed appearance via segments)
        private _minDist = OpsRoom_AirStrike_MinFAHDistance;
        private _ringSegments = 48;
        for "_i" from 0 to _ringSegments - 1 do {
            // Draw every other segment for dashed effect
            if ((_i mod 2) == 0) then {
                private _angle1 = (_i / _ringSegments) * 360;
                private _angle2 = ((_i + 1) / _ringSegments) * 360;
                private _p1 = _tgtPos getPos [_minDist, _angle1];
                private _p2 = _tgtPos getPos [_minDist, _angle2];
                _p1 set [2, 1]; _p2 set [2, 1];
                drawLine3D [_p1, _p2, [1, 0.6, 0, 0.4]];
            };
        };
        
        // Draw direction arrow from cursor position to target
        private _cursorDist = _worldPos distance2D _tgtPos;
        private _arrowColor = if (_cursorDist >= _minDist) then {
            [0.3, 1, 0.3, 0.8]  // Green — valid
        } else {
            [1, 0.3, 0.3, 0.8]  // Red — too close
        };
        
        // Arrow line: cursor → target
        private _arrowStart = [_worldPos select 0, _worldPos select 1, 2];
        private _arrowEnd = [_tgtPos select 0, _tgtPos select 1, 2];
        drawLine3D [_arrowStart, _arrowEnd, _arrowColor];
        
        // Arrowhead at target end
        private _dir = _worldPos getDir _tgtPos;
        private _headSize = 40;
        private _headL = _tgtPos getPos [_headSize, _dir + 150];
        private _headR = _tgtPos getPos [_headSize, _dir - 150];
        _headL set [2, 2]; _headR set [2, 2];
        drawLine3D [_arrowEnd, [_headL select 0, _headL select 1, 2], _arrowColor];
        drawLine3D [_arrowEnd, [_headR select 0, _headR select 1, 2], _arrowColor];
        
        // Approach label at cursor
        private _label = if (_cursorDist >= _minDist) then {
            format ["APPROACH HEADING — Click to confirm (%1m)", round _cursorDist]
        } else {
            format ["TOO CLOSE — Move further out (%1m / %2m min)", round _cursorDist, _minDist]
        };
        
        drawIcon3D [
            "", _arrowColor,
            [_worldPos select 0, _worldPos select 1, 5],
            0, 0, 0,
            _label,
            2, 0.035, "RobotoCondensed"
        ];
    };
}];

// =====================
// EachFrame: keep cursor locked to screen centre
// =====================
OpsRoom_AirStrike_Targeting_FrameHandler = addMissionEventHandler ["EachFrame", {
    private _cursor = OpsRoom_AirStrike_Targeting_CursorCtrl;
    if (isNull _cursor) exitWith {};
    _cursor ctrlSetPosition [
        safezoneX + (safezoneW * 0.5) - 0.02,
        safezoneY + (safezoneH * 0.5) - 0.02,
        0.04, 0.04
    ];
    _cursor ctrlCommit 0;
}];

// =====================
// Left click handler — two phases
// =====================
OpsRoom_AirStrike_Targeting_ClickHandler = _display displayAddEventHandler ["MouseButtonDown", {
    params ["_display", "_button"];
    if (_button != 0) exitWith {};
    
    private _worldPos = screenToWorld [0.5, 0.5];
    private _phase = OpsRoom_AirStrike_Targeting_Phase;
    
    if (_phase == "TGT") then {
        // Phase 1: Store target position, advance to FAH phase
        OpsRoom_AirStrike_Targeting_TargetPos = _worldPos;
        OpsRoom_AirStrike_Targeting_Phase = "FAH";
        
        hint "Target marked.\nNow click the APPROACH DIRECTION\n(where the aircraft will fly FROM)\nMust be 1500m+ from target.\nESC to cancel.";
        
        true
    } else {
        // Phase 2: Validate distance and execute
        private _tgtPos = OpsRoom_AirStrike_Targeting_TargetPos;
        private _dist = _worldPos distance2D _tgtPos;
        private _minDist = OpsRoom_AirStrike_MinFAHDistance;
        
        if (_dist < _minDist) exitWith {
            hint format ["Too close! Approach must be %1m+ from target.\nCurrently: %2m", _minDist, round _dist];
        };
        
        // Valid — store approach pos and execute
        OpsRoom_AirStrike_Targeting_ApproachPos = _worldPos;
        
        private _attackType = OpsRoom_AirStrike_Targeting_AttackType;
        private _unit = OpsRoom_AirStrike_Unit;
        
        [_unit, _tgtPos, _attackType, _worldPos] call OpsRoom_fnc_executeAirStrike;
        [] call OpsRoom_fnc_cancelAirStrikeTargeting;
        
        true
    };
}];

// =====================
// ESC → cancel at any phase
// =====================
OpsRoom_AirStrike_Targeting_ESCHandler = _display displayAddEventHandler ["KeyDown", {
    params ["_display", "_key"];
    if (_key == 1) then {
        [] call OpsRoom_fnc_cancelAirStrikeTargeting;
        hint "Air strike cancelled";
        true
    } else { false };
}];

hint format ["Click target position for %1\nESC to cancel", _attackType];
