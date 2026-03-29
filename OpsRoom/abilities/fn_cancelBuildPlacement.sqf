/*
    OpsRoom_fnc_cancelBuildPlacement
    
    Cancels any active build placement mode.
    Cleans up preview objects, event handlers, and state variables.
*/

// Delete preview object
private _preview = missionNamespace getVariable ["OpsRoom_Build_Preview", objNull];
if (!isNull _preview) then { deleteVehicle _preview };

// Delete line previews if any
private _linePreviews = missionNamespace getVariable ["OpsRoom_Build_LinePreviews", []];
{ if (!isNull _x) then { deleteVehicle _x } } forEach _linePreviews;

// Remove event handlers
private _display = findDisplay 312;

private _drawEH = missionNamespace getVariable ["OpsRoom_Build_DrawEH", -1];
if (_drawEH >= 0) then { removeMissionEventHandler ["Draw3D", _drawEH] };

if (!isNull _display) then {
    private _mouseEH = missionNamespace getVariable ["OpsRoom_Build_MouseEH", -1];
    if (_mouseEH >= 0) then { _display displayRemoveEventHandler ["MouseButtonDown", _mouseEH] };
    
    private _moveEH = missionNamespace getVariable ["OpsRoom_Build_MoveEH", -1];
    if (_moveEH >= 0) then { _display displayRemoveEventHandler ["MouseMoving", _moveEH] };
    
    private _keyEH = missionNamespace getVariable ["OpsRoom_Build_KeyEH", -1];
    if (_keyEH >= 0) then { _display displayRemoveEventHandler ["KeyDown", _keyEH] };
};

// Clear all state variables
missionNamespace setVariable ["OpsRoom_Build_Active", false];
missionNamespace setVariable ["OpsRoom_Build_State", ""];
missionNamespace setVariable ["OpsRoom_Build_Preview", nil];
missionNamespace setVariable ["OpsRoom_Build_LinePreviews", nil];
missionNamespace setVariable ["OpsRoom_Build_DrawEH", nil];
missionNamespace setVariable ["OpsRoom_Build_MouseEH", nil];
missionNamespace setVariable ["OpsRoom_Build_MoveEH", nil];
missionNamespace setVariable ["OpsRoom_Build_KeyEH", nil];

systemChat "Build: Cancelled";
