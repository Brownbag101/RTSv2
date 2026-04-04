/*
    OpsRoom_fnc_cancelArtilleryTargeting
    
    Cleans up artillery targeting mode
    - Removes Draw3D handler
    - Removes input event handlers
    - Clears global variables (except target data needed by round menu)
*/

// Deactivate first (Draw3D self-removes on next frame)
OpsRoom_ArtilleryTargeting_Active = nil;

// Remove Draw3D handler
if (!isNil "OpsRoom_ArtilleryTargeting_DrawEH") then {
    removeMissionEventHandler ["Draw3D", OpsRoom_ArtilleryTargeting_DrawEH];
    OpsRoom_ArtilleryTargeting_DrawEH = nil;
};

// Remove click and key handlers
private _display = findDisplay 312;
if (!isNull _display) then {
    if (!isNil "OpsRoom_ArtilleryTargeting_ClickHandler") then {
        _display displayRemoveEventHandler ["MouseButtonDown", OpsRoom_ArtilleryTargeting_ClickHandler];
        OpsRoom_ArtilleryTargeting_ClickHandler = nil;
    };
    
    if (!isNil "OpsRoom_ArtilleryTargeting_ESCHandler") then {
        _display displayRemoveEventHandler ["KeyDown", OpsRoom_ArtilleryTargeting_ESCHandler];
        OpsRoom_ArtilleryTargeting_ESCHandler = nil;
    };
};

// Clear targeting-phase variables
// NOTE: Do NOT clear TargetPos, GunsInRange, AmmoType, GunName, AmmoName here
// — they are needed by the round count menu / executeArtillery
OpsRoom_ArtilleryTargeting_Guns = nil;
OpsRoom_ArtilleryTargeting_VehType = nil;

diag_log "[OpsRoom] Artillery targeting mode cancelled";
