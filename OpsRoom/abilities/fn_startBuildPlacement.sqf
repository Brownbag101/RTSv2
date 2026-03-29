/*
    OpsRoom_fnc_startBuildPlacement
    
    Enters single-object placement mode.
    Ghost preview follows cursor. First click places, second click sets direction.
    
    Parameters:
        0: STRING - Build ID from OpsRoom_Buildables
    
    State machine:
        POSITIONING -> click -> ROTATING -> click -> BUILD
        ESC/RMB at any point -> CANCEL
*/

params [["_buildId", "", [""]]];

if (_buildId == "") exitWith {};

private _buildData = OpsRoom_Buildables get _buildId;
if (isNil "_buildData") exitWith { systemChat "Build: Unknown item" };

private _className = _buildData get "className";
private _displayName = _buildData get "displayName";
private _cost = _buildData get "cost";
private _buildTime = _buildData getOrDefault ["buildTime", 10];
private _isMine = _buildData getOrDefault ["isMine", false];

// Check resources before entering placement
private _canAfford = true;
{
    _x params ["_res", "_amt"];
    private _cleanRes = _res;
    while {_cleanRes find " " != -1} do {
        private _sp = _cleanRes find " ";
        _cleanRes = (_cleanRes select [0, _sp]) + "_" + (_cleanRes select [_sp + 1]);
    };
    private _have = missionNamespace getVariable [format ["OpsRoom_Resource_%1", _cleanRes], 0];
    if (_have < _amt) then { _canAfford = false };
} forEach _cost;

if (!_canAfford) exitWith {
    systemChat format ["Build: Insufficient resources for %1", _displayName];
};

// Store build state
missionNamespace setVariable ["OpsRoom_Build_Active", true];
missionNamespace setVariable ["OpsRoom_Build_State", "POSITIONING"];
missionNamespace setVariable ["OpsRoom_Build_Id", _buildId];
missionNamespace setVariable ["OpsRoom_Build_ClassName", _className];
missionNamespace setVariable ["OpsRoom_Build_DisplayName", _displayName];
missionNamespace setVariable ["OpsRoom_Build_Cost", _cost];
missionNamespace setVariable ["OpsRoom_Build_Time", _buildTime];
missionNamespace setVariable ["OpsRoom_Build_IsMine", _isMine];
missionNamespace setVariable ["OpsRoom_Build_Preview", objNull];
missionNamespace setVariable ["OpsRoom_Build_Pos", [0,0,0]];
missionNamespace setVariable ["OpsRoom_Build_Dir", 0];

// Create preview object — raised 0.3m above ground to show it's a preview
private _preview = createVehicle [_className, [0,0,0], [], 0, "CAN_COLLIDE"];
_preview enableSimulationGlobal false;
_preview allowDamage false;
missionNamespace setVariable ["OpsRoom_Build_Preview", _preview];

systemChat format ["Build: Place %1 — LEFT CLICK to position, RIGHT CLICK to cancel", _displayName];

// Draw3D handler for preview tracking + instructions
private _drawEH = addMissionEventHandler ["Draw3D", {
    if !(missionNamespace getVariable ["OpsRoom_Build_Active", false]) exitWith {
        removeMissionEventHandler ["Draw3D", _thisEventHandler];
    };
    
    private _state = missionNamespace getVariable ["OpsRoom_Build_State", ""];
    private _preview = missionNamespace getVariable ["OpsRoom_Build_Preview", objNull];
    
    if (_state == "POSITIONING") then {
        // Move preview to cursor position (use mouse position from display)
        private _mousePos = getMousePosition;
        private _cursorPos = screenToWorld _mousePos;
        if (count _cursorPos >= 2) then {
            _cursorPos set [2, 0];
            // Raise preview slightly above ground
            private _raisedPos = [_cursorPos select 0, _cursorPos select 1, 0.3];
            _preview setPosATL _raisedPos;
            missionNamespace setVariable ["OpsRoom_Build_Pos", _cursorPos];
            
            // Draw blue pulsing circle on ground under preview
            private _pulse = 0.5 + (sin(time * 300) * 0.3);
            private _segments = 24;
            private _circleRadius = 3;
            for "_s" from 0 to (_segments - 1) do {
                private _a1 = (_s / _segments) * 360;
                private _a2 = ((_s + 1) / _segments) * 360;
                private _p1 = _cursorPos vectorAdd [_circleRadius * sin _a1, _circleRadius * cos _a1, 0.1];
                private _p2 = _cursorPos vectorAdd [_circleRadius * sin _a2, _circleRadius * cos _a2, 0.1];
                drawLine3D [_p1, _p2, [0.2, 0.6, 1, _pulse]];
            };
            
            // Draw label
            private _name = missionNamespace getVariable ["OpsRoom_Build_DisplayName", ""];
            drawIcon3D ["", [0.2, 0.6, 1, 0.9], _cursorPos vectorAdd [0,0,4], 0, 0, 0,
                format ["%1 — CLICK to place", _name], 2, 0.04, "PuristaMedium", "center", true];
            drawIcon3D ["", [0.2, 0.6, 1, 0.7], _cursorPos vectorAdd [0,0,3.3], 0, 0, 0,
                "[PREVIEW]", 2, 0.03, "PuristaMedium", "center", true];
        };
    };
    
    if (_state == "ROTATING") then {
        // Calculate direction from placed object to current cursor
        private _pos = missionNamespace getVariable ["OpsRoom_Build_Pos", [0,0,0]];
        private _mousePos = getMousePosition;
        private _cursorWorld = screenToWorld _mousePos;
        
        // Direction from object to cursor
        private _dir = _pos getDir _cursorWorld;
        missionNamespace setVariable ["OpsRoom_Build_Dir", _dir];
        
        // Update preview rotation
        if (!isNull _preview) then {
            _preview setDir _dir;
        };
        
        // Draw direction arrow
        private _arrowEnd = _pos vectorAdd [5 * sin _dir, 5 * cos _dir, 0.5];
        private _arrowStart = _pos vectorAdd [0, 0, 0.5];
        drawLine3D [_arrowStart, _arrowEnd, [0.2, 0.6, 1, 0.8]];
        
        // Blue circle still visible
        private _pulse = 0.5 + (sin(time * 300) * 0.3);
        for "_s" from 0 to 23 do {
            private _a1 = (_s / 24) * 360;
            private _a2 = ((_s + 1) / 24) * 360;
            private _p1 = _pos vectorAdd [3 * sin _a1, 3 * cos _a1, 0.1];
            private _p2 = _pos vectorAdd [3 * sin _a2, 3 * cos _a2, 0.1];
            drawLine3D [_p1, _p2, [0.2, 0.6, 1, _pulse]];
        };
        
        drawIcon3D ["", [0.2, 0.6, 1, 0.9], _pos vectorAdd [0,0,4], 0, 0, 0,
            "POINT MOUSE to set direction — CLICK to confirm", 2, 0.04, "PuristaMedium", "center", true];
    };
}];
missionNamespace setVariable ["OpsRoom_Build_DrawEH", _drawEH];

// Mouse click handler on Zeus display
private _display = findDisplay 312;
if (isNull _display) exitWith { [] call OpsRoom_fnc_cancelBuildPlacement };

private _mouseEH = _display displayAddEventHandler ["MouseButtonDown", {
    params ["_display", "_button", "_xPos", "_yPos"];
    
    if !(_button in [0, 1]) exitWith {};  // Only LMB (0) and RMB (1)
    
    // Right click = cancel
    if (_button == 1) exitWith {
        [] call OpsRoom_fnc_cancelBuildPlacement;
    };
    
    // Left click
    private _state = missionNamespace getVariable ["OpsRoom_Build_State", ""];
    
    if (_state == "POSITIONING") then {
        // Lock position, enter rotation mode
        missionNamespace setVariable ["OpsRoom_Build_State", "ROTATING"];
        missionNamespace setVariable ["OpsRoom_Build_Dir", 0];
        systemChat "Build: Move mouse to rotate, LEFT CLICK to confirm direction";
    } else {
        if (_state == "ROTATING") then {
            // Confirm build
            private _pos = missionNamespace getVariable ["OpsRoom_Build_Pos", [0,0,0]];
            private _dir = missionNamespace getVariable ["OpsRoom_Build_Dir", 0];
            
            // Clean up placement mode (but don't delete — execute build will handle)
            private _preview = missionNamespace getVariable ["OpsRoom_Build_Preview", objNull];
            if (!isNull _preview) then { deleteVehicle _preview };
            
            // Remove handlers
            private _drawEH2 = missionNamespace getVariable ["OpsRoom_Build_DrawEH", -1];
            if (_drawEH2 >= 0) then { removeMissionEventHandler ["Draw3D", _drawEH2] };
            
            private _mouseEH2 = missionNamespace getVariable ["OpsRoom_Build_MouseEH", -1];
            if (_mouseEH2 >= 0) then { _display displayRemoveEventHandler ["MouseButtonDown", _mouseEH2] };
            
            private _moveEH2 = missionNamespace getVariable ["OpsRoom_Build_MoveEH", -1];
            if (_moveEH2 >= 0) then { _display displayRemoveEventHandler ["MouseMoving", _moveEH2] };
            
            private _keyEH2 = missionNamespace getVariable ["OpsRoom_Build_KeyEH", -1];
            if (_keyEH2 >= 0) then { _display displayRemoveEventHandler ["KeyDown", _keyEH2] };
            
            missionNamespace setVariable ["OpsRoom_Build_Active", false];
            
            // Execute the build
            private _buildId2 = missionNamespace getVariable ["OpsRoom_Build_Id", ""];
            private _engineers = missionNamespace getVariable ["OpsRoom_Build_Engineers", []];
            private _engineer = if (count _engineers > 0) then { _engineers select 0 } else { objNull };
            
            if (!isNull _engineer) then {
                [_engineer, _buildId2, _pos, _dir] call OpsRoom_fnc_executeBuild;
            };
        };
    };
}];
missionNamespace setVariable ["OpsRoom_Build_MouseEH", _mouseEH];

// MouseMoving no longer needed — rotation calculated in Draw3D from cursor direction
missionNamespace setVariable ["OpsRoom_Build_MoveEH", -1];

// ESC key handler
private _keyEH = _display displayAddEventHandler ["KeyDown", {
    params ["_display", "_key"];
    if (_key == 1) then {  // ESC
        [] call OpsRoom_fnc_cancelBuildPlacement;
        true  // Consume the key
    } else {
        false
    };
}];
missionNamespace setVariable ["OpsRoom_Build_KeyEH", _keyEH];
