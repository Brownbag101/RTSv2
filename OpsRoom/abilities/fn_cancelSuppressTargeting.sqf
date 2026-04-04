/*
    OpsRoom_fnc_cancelSuppressTargeting
    
    Cleans up suppression targeting mode
    - Removes Draw3D handler
    - Removes input event handlers
    - Clears global variables
*/

// Deactivate first (Draw3D self-removes on next frame)
OpsRoom_SuppressTargeting_Active = nil;

// Remove Draw3D handler
if (!isNil "OpsRoom_SuppressTargeting_DrawEH") then {
    removeMissionEventHandler ["Draw3D", OpsRoom_SuppressTargeting_DrawEH];
    OpsRoom_SuppressTargeting_DrawEH = nil;
};

// Remove click and key handlers
private _display = findDisplay 312;
if (!isNull _display) then {
    if (!isNil "OpsRoom_SuppressTargeting_ClickHandler") then {
        _display displayRemoveEventHandler ["MouseButtonDown", OpsRoom_SuppressTargeting_ClickHandler];
        OpsRoom_SuppressTargeting_ClickHandler = nil;
    };
    
    if (!isNil "OpsRoom_SuppressTargeting_ESCHandler") then {
        _display displayRemoveEventHandler ["KeyDown", OpsRoom_SuppressTargeting_ESCHandler];
        OpsRoom_SuppressTargeting_ESCHandler = nil;
    };
};

// Clear data
OpsRoom_SuppressTargeting_Units = nil;
OpsRoom_SuppressTargeting_Duration = nil;
OpsRoom_SuppressUnits = nil;

diag_log "[OpsRoom] Suppression targeting mode cancelled";
