/*
    OpsRoom_fnc_cancelReconTargeting
    
    Cleanup all recon targeting state.
*/

if (!isNil "OpsRoom_Recon_Targeting_CursorCtrl") then {
    ctrlDelete OpsRoom_Recon_Targeting_CursorCtrl;
    OpsRoom_Recon_Targeting_CursorCtrl = nil;
};

if (!isNil "OpsRoom_Recon_Targeting_FrameHandler") then {
    removeMissionEventHandler ["EachFrame", OpsRoom_Recon_Targeting_FrameHandler];
    OpsRoom_Recon_Targeting_FrameHandler = nil;
};

if (!isNil "OpsRoom_Recon_Targeting_DrawHandler") then {
    removeMissionEventHandler ["Draw3D", OpsRoom_Recon_Targeting_DrawHandler];
    OpsRoom_Recon_Targeting_DrawHandler = nil;
};

if (!isNil "OpsRoom_Recon_Targeting_ClickHandler") then {
    private _display = findDisplay 312;
    if (!isNull _display) then {
        _display displayRemoveEventHandler ["MouseButtonDown", OpsRoom_Recon_Targeting_ClickHandler];
    };
    OpsRoom_Recon_Targeting_ClickHandler = nil;
};

if (!isNil "OpsRoom_Recon_Targeting_ESCHandler") then {
    private _display = findDisplay 312;
    if (!isNull _display) then {
        _display displayRemoveEventHandler ["KeyDown", OpsRoom_Recon_Targeting_ESCHandler];
    };
    OpsRoom_Recon_Targeting_ESCHandler = nil;
};

OpsRoom_Recon_Targeting_Active = nil;
OpsRoom_Recon_Targeting_Radius = nil;
OpsRoom_Recon_Unit = nil;
