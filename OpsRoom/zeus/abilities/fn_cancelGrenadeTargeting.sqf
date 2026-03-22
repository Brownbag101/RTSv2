/*
    OpsRoom_fnc_cancelGrenadeTargeting
    
    Cleans up grenade targeting mode
    - Removes cursor
    - Removes event handlers
    - Clears global variables
*/

// Remove cursor control
private _cursor = OpsRoom_GrenadeTargeting_CursorCtrl;
if (!isNull _cursor) then {
    ctrlDelete _cursor;
};

// Remove EachFrame handler
private _frameHandler = OpsRoom_GrenadeTargeting_FrameHandler;
if (!isNil "_frameHandler" && _frameHandler != -1) then {
    removeMissionEventHandler ["EachFrame", _frameHandler];
};

// Remove click handler
private _display = findDisplay 312;
if (!isNull _display) then {
    private _clickHandler = OpsRoom_GrenadeTargeting_ClickHandler;
    if (!isNil "_clickHandler" && _clickHandler != -1) then {
        _display displayRemoveEventHandler ["MouseButtonDown", _clickHandler];
    };
    
    // Remove ESC handler
    private _escHandler = OpsRoom_GrenadeTargeting_ESCHandler;
    if (!isNil "_escHandler" && _escHandler != -1) then {
        _display displayRemoveEventHandler ["KeyDown", _escHandler];
    };
};

// Clear global variables
OpsRoom_GrenadeTargeting_Active = nil;
OpsRoom_GrenadeTargeting_Unit = nil;
OpsRoom_GrenadeTargeting_Type = nil;
OpsRoom_GrenadeTargeting_CursorCtrl = nil;
OpsRoom_GrenadeTargeting_FrameHandler = nil;
OpsRoom_GrenadeTargeting_ClickHandler = nil;
OpsRoom_GrenadeTargeting_ESCHandler = nil;

diag_log "[OpsRoom] Grenade targeting mode cancelled";
