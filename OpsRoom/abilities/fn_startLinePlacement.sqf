/*
    OpsRoom_fnc_startLinePlacement
    
    Enters line placement mode.
    First click sets start, mouse shows preview line, second click confirms end.
    Objects placed evenly along the line at lineSpacing intervals.
    
    Parameters:
        0: STRING - Build ID from OpsRoom_Buildables
*/

params [["_buildId", "", [""]]];

if (_buildId == "") exitWith {};

private _buildData = OpsRoom_Buildables get _buildId;
if (isNil "_buildData") exitWith { systemChat "Build: Unknown item" };

private _className = _buildData get "className";
private _displayName = _buildData get "displayName";
private _cost = _buildData get "cost";
private _buildTime = _buildData getOrDefault ["buildTime", 10];
private _lineSpacing = _buildData getOrDefault ["lineSpacing", 3];
private _isMine = _buildData getOrDefault ["isMine", false];

// Store line build state
missionNamespace setVariable ["OpsRoom_Build_Active", true];
missionNamespace setVariable ["OpsRoom_Build_State", "LINE_START"];
missionNamespace setVariable ["OpsRoom_Build_Id", _buildId];
missionNamespace setVariable ["OpsRoom_Build_ClassName", _className];
missionNamespace setVariable ["OpsRoom_Build_DisplayName", _displayName];
missionNamespace setVariable ["OpsRoom_Build_Cost", _cost];
missionNamespace setVariable ["OpsRoom_Build_Time", _buildTime];
missionNamespace setVariable ["OpsRoom_Build_LineSpacing", _lineSpacing];
missionNamespace setVariable ["OpsRoom_Build_IsMine", _isMine];
missionNamespace setVariable ["OpsRoom_Build_LineStart", [0,0,0]];
missionNamespace setVariable ["OpsRoom_Build_LineEnd", [0,0,0]];
missionNamespace setVariable ["OpsRoom_Build_LinePreviews", []];

systemChat format ["Build Line: %1 — CLICK to set start point, RIGHT CLICK to cancel", _displayName];

// Draw3D handler
private _drawEH = addMissionEventHandler ["Draw3D", {
    if !(missionNamespace getVariable ["OpsRoom_Build_Active", false]) exitWith {
        removeMissionEventHandler ["Draw3D", _thisEventHandler];
    };
    
    private _state = missionNamespace getVariable ["OpsRoom_Build_State", ""];
    
    if (_state == "LINE_START") then {
        private _mousePos = getMousePosition;
        private _cursorPos = screenToWorld _mousePos;
        if (count _cursorPos >= 2) then {
            drawIcon3D ["", [0.2, 0.6, 1, 0.9], _cursorPos vectorAdd [0,0,2], 0, 0, 0,
                "CLICK to set START of line", 2, 0.04, "PuristaMedium", "center", true];
        };
    };
    
    if (_state == "LINE_END") then {
        private _startPos = missionNamespace getVariable ["OpsRoom_Build_LineStart", [0,0,0]];
        private _mousePos = getMousePosition;
        private _cursorPos = screenToWorld _mousePos;
        
        if (count _cursorPos >= 2 && count _startPos >= 2) then {
            // Draw the line
            private _startDraw = _startPos vectorAdd [0, 0, 0.5];
            private _endDraw = _cursorPos vectorAdd [0, 0, 0.5];
            drawLine3D [_startDraw, _endDraw, [0.2, 0.6, 1, 0.6]];
            
            // Calculate count and cost
            private _dist = _startPos distance2D _cursorPos;
            private _spacing = missionNamespace getVariable ["OpsRoom_Build_LineSpacing", 3];
            private _count = (floor (_dist / _spacing)) max 1;
            private _cost2 = missionNamespace getVariable ["OpsRoom_Build_Cost", []];
            private _name = missionNamespace getVariable ["OpsRoom_Build_DisplayName", ""];
            
            // Build total cost string
            private _totalCostStr = "";
            {
                _x params ["_res", "_amt"];
                private _total = _amt * _count;
                if (_totalCostStr != "") then { _totalCostStr = _totalCostStr + ", " };
                _totalCostStr = _totalCostStr + format ["%1x %2", _total, _res];
            } forEach _cost2;
            
            // Draw count and cost info
            private _midPoint = [
                ((_startPos select 0) + (_cursorPos select 0)) / 2,
                ((_startPos select 1) + (_cursorPos select 1)) / 2,
                0
            ];
            drawIcon3D ["", [0.2, 0.6, 1, 0.9], _midPoint vectorAdd [0,0,3], 0, 0, 0,
                format ["%1x %2 (%3) — CLICK to confirm", _count, _name, _totalCostStr],
                2, 0.04, "PuristaMedium", "center", true];
            
            // Manage preview objects along the line
            private _className = missionNamespace getVariable ["OpsRoom_Build_ClassName", ""];
            private _oldPreviews = missionNamespace getVariable ["OpsRoom_Build_LinePreviews", []];
            private _lineDir = (_startPos getDir _cursorPos) + 90;
            if (_lineDir >= 360) then { _lineDir = _lineDir - 360 };
            
            // Delete old previews if count changed
            if (count _oldPreviews != _count) then {
                { if (!isNull _x) then { deleteVehicle _x } } forEach _oldPreviews;
                
                // Create new preview objects
                private _newPreviews = [];
                for "_i" from 0 to (_count - 1) do {
                    private _frac = if (_count > 1) then { _i / (_count - 1) } else { 0.5 };
                    private _objPos = [
                        ((_startPos select 0) + ((_cursorPos select 0) - (_startPos select 0)) * _frac),
                        ((_startPos select 1) + ((_cursorPos select 1) - (_startPos select 1)) * _frac),
                        0.3
                    ];
                    private _prev = createVehicle [_className, _objPos, [], 0, "CAN_COLLIDE"];
                    _prev setPosATL _objPos;
                    _prev setDir _lineDir;
                    _prev enableSimulationGlobal false;
                    _prev allowDamage false;
                    _newPreviews pushBack _prev;
                };
                missionNamespace setVariable ["OpsRoom_Build_LinePreviews", _newPreviews];
            } else {
                // Same count — just update positions and direction
                for "_i" from 0 to (_count - 1) do {
                    if (_i < count _oldPreviews) then {
                        private _prev = _oldPreviews select _i;
                        if (!isNull _prev) then {
                            private _frac = if (_count > 1) then { _i / (_count - 1) } else { 0.5 };
                            private _objPos = [
                                ((_startPos select 0) + ((_cursorPos select 0) - (_startPos select 0)) * _frac),
                                ((_startPos select 1) + ((_cursorPos select 1) - (_startPos select 1)) * _frac),
                                0.3
                            ];
                            _prev setPosATL _objPos;
                            _prev setDir _lineDir;
                        };
                    };
                };
            };
            
            // Draw blue circles under each preview
            {
                if (!isNull _x) then {
                    private _bPos = getPosATL _x;
                    private _pulse = 0.4 + (sin(time * 300) * 0.2);
                    for "_s" from 0 to 11 do {
                        private _a1 = (_s / 12) * 360;
                        private _a2 = ((_s + 1) / 12) * 360;
                        private _p1 = [(_bPos select 0) + 1.5 * sin _a1, (_bPos select 1) + 1.5 * cos _a1, 0.1];
                        private _p2 = [(_bPos select 0) + 1.5 * sin _a2, (_bPos select 1) + 1.5 * cos _a2, 0.1];
                        drawLine3D [_p1, _p2, [0.2, 0.6, 1, _pulse]];
                    };
                };
            } forEach (missionNamespace getVariable ["OpsRoom_Build_LinePreviews", []]);
        };
    };
}];
missionNamespace setVariable ["OpsRoom_Build_DrawEH", _drawEH];

// Mouse click handler
private _display = findDisplay 312;
if (isNull _display) exitWith { [] call OpsRoom_fnc_cancelBuildPlacement };

private _mouseEH = _display displayAddEventHandler ["MouseButtonDown", {
    params ["_display", "_button"];
    
    if (_button == 1) exitWith {
        [] call OpsRoom_fnc_cancelBuildPlacement;
    };
    
    if (_button != 0) exitWith {};
    
    private _state = missionNamespace getVariable ["OpsRoom_Build_State", ""];
    
    if (_state == "LINE_START") then {
        private _mousePos = getMousePosition;
        private _startPos = screenToWorld _mousePos;
        missionNamespace setVariable ["OpsRoom_Build_LineStart", _startPos];
        missionNamespace setVariable ["OpsRoom_Build_State", "LINE_END"];
        systemChat "Build Line: CLICK to set END of line";
    } else {
        if (_state == "LINE_END") then {
            private _startPos = missionNamespace getVariable ["OpsRoom_Build_LineStart", [0,0,0]];
            private _mousePos = getMousePosition;
            private _endPos = screenToWorld _mousePos;
            
            // Calculate objects
            private _dist = _startPos distance2D _endPos;
            private _spacing = missionNamespace getVariable ["OpsRoom_Build_LineSpacing", 3];
            private _count = (floor (_dist / _spacing)) max 1;
            private _buildId2 = missionNamespace getVariable ["OpsRoom_Build_Id", ""];
            private _cost2 = missionNamespace getVariable ["OpsRoom_Build_Cost", []];
            
            // Check total resources
            private _canAfford = true;
            {
                _x params ["_res", "_amt"];
                private _total = _amt * _count;
                private _cleanRes = _res;
                while {_cleanRes find " " != -1} do {
                    private _sp = _cleanRes find " ";
                    _cleanRes = (_cleanRes select [0, _sp]) + "_" + (_cleanRes select [_sp + 1]);
                };
                private _have = missionNamespace getVariable [format ["OpsRoom_Resource_%1", _cleanRes], 0];
                if (_have < _total) then { _canAfford = false };
            } forEach _cost2;
            
            if (!_canAfford) exitWith {
                systemChat format ["Build: Insufficient resources for %1 objects", _count];
                [] call OpsRoom_fnc_cancelBuildPlacement;
            };
            
            // Delete line previews
            private _linePreviews = missionNamespace getVariable ["OpsRoom_Build_LinePreviews", []];
            { if (!isNull _x) then { deleteVehicle _x } } forEach _linePreviews;
            missionNamespace setVariable ["OpsRoom_Build_LinePreviews", []];
            
            // Clean up placement mode
            private _drawEH2 = missionNamespace getVariable ["OpsRoom_Build_DrawEH", -1];
            if (_drawEH2 >= 0) then { removeMissionEventHandler ["Draw3D", _drawEH2] };
            private _mouseEH2 = missionNamespace getVariable ["OpsRoom_Build_MouseEH", -1];
            if (_mouseEH2 >= 0) then { _display displayRemoveEventHandler ["MouseButtonDown", _mouseEH2] };
            private _keyEH2 = missionNamespace getVariable ["OpsRoom_Build_KeyEH", -1];
            if (_keyEH2 >= 0) then { _display displayRemoveEventHandler ["KeyDown", _keyEH2] };
            
            missionNamespace setVariable ["OpsRoom_Build_Active", false];
            
            // Deduct total resources
            {
                _x params ["_res", "_amt"];
                private _total = _amt * _count;
                private _cleanRes = _res;
                while {_cleanRes find " " != -1} do {
                    private _sp = _cleanRes find " ";
                    _cleanRes = (_cleanRes select [0, _sp]) + "_" + (_cleanRes select [_sp + 1]);
                };
                private _varName = format ["OpsRoom_Resource_%1", _cleanRes];
                private _current = missionNamespace getVariable [_varName, 0];
                missionNamespace setVariable [_varName, _current - _total];
            } forEach _cost2;
            [] call OpsRoom_fnc_updateResources;
            
            // Execute line build
            private _engineers = missionNamespace getVariable ["OpsRoom_Build_Engineers", []];
            private _engineer = if (count _engineers > 0) then { _engineers select 0 } else { objNull };
            
            if (!isNull _engineer) then {
                // Direction perpendicular to the line (walls face along the line, not across it)
                private _dir = (_startPos getDir _endPos) + 90;
                if (_dir >= 360) then { _dir = _dir - 360 };
                private _positions = [];
                
                for "_i" from 0 to (_count - 1) do {
                    private _frac = if (_count > 1) then { _i / (_count - 1) } else { 0.5 };
                    private _objPos = [
                        (_startPos select 0) + ((_endPos select 0) - (_startPos select 0)) * _frac,
                        (_startPos select 1) + ((_endPos select 1) - (_startPos select 1)) * _frac,
                        0
                    ];
                    _positions pushBack _objPos;
                };
                
                [_engineer, _buildId2, _positions, _dir, _count] call OpsRoom_fnc_executeLineBuild;
            };
        };
    };
}];
missionNamespace setVariable ["OpsRoom_Build_MouseEH", _mouseEH];

// ESC key handler
private _keyEH = _display displayAddEventHandler ["KeyDown", {
    params ["_display", "_key"];
    if (_key == 1) then {
        [] call OpsRoom_fnc_cancelBuildPlacement;
        true
    } else {
        false
    };
}];
missionNamespace setVariable ["OpsRoom_Build_KeyEH", _keyEH];
