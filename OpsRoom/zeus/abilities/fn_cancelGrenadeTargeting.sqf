/*
    OpsRoom_fnc_cancelGrenadeTargeting
    
    Cleans up grenade targeting mode
    - Removes Draw3D handler
    - Removes input event handlers
    - Clears global variables
*/

// Deactivate first (Draw3D self-removes on next frame)
OpsRoom_GrenadeTargeting_Active = nil;

// Remove Draw3D handler
private _drawEH = OpsRoom_GrenadeTargeting_DrawEH;
if (!isNil "_drawEH" && {_drawEH >= 0}) then {
    removeMissionEventHandler ["Draw3D", _drawEH];
};

// Remove click and key handlers
private _display = findDisplay 312;
if (!isNull _display) then {
    private _clickHandler = OpsRoom_GrenadeTargeting_ClickHandler;
    if (!isNil "_clickHandler" && {_clickHandler >= 0}) then {
        _display displayRemoveEventHandler ["MouseButtonDown", _clickHandler];
    };
    
    private _escHandler = OpsRoom_GrenadeTargeting_ESCHandler;
    if (!isNil "_escHandler" && {_escHandler >= 0}) then {
        _display displayRemoveEventHandler ["KeyDown", _escHandler];
    };
};

// Clear global variables
OpsRoom_GrenadeTargeting_Unit = nil;
OpsRoom_GrenadeTargeting_Type = nil;
OpsRoom_GrenadeTargeting_DrawEH = nil;
OpsRoom_GrenadeTargeting_ClickHandler = nil;
OpsRoom_GrenadeTargeting_ESCHandler = nil;

diag_log "[OpsRoom] Grenade targeting mode cancelled";
