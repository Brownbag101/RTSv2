/*
    OpsRoom_fnc_cancelInfiltrateTargeting
    
    Cleanup all infiltrate targeting state.
*/

if (!isNil "OpsRoom_Infiltrate_Targeting_CursorCtrl") then {
    ctrlDelete OpsRoom_Infiltrate_Targeting_CursorCtrl;
    OpsRoom_Infiltrate_Targeting_CursorCtrl = nil;
};

if (!isNil "OpsRoom_Infiltrate_Targeting_FrameHandler") then {
    removeMissionEventHandler ["EachFrame", OpsRoom_Infiltrate_Targeting_FrameHandler];
    OpsRoom_Infiltrate_Targeting_FrameHandler = nil;
};

if (!isNil "OpsRoom_Infiltrate_Targeting_DrawHandler") then {
    removeMissionEventHandler ["Draw3D", OpsRoom_Infiltrate_Targeting_DrawHandler];
    OpsRoom_Infiltrate_Targeting_DrawHandler = nil;
};

if (!isNil "OpsRoom_Infiltrate_Targeting_ClickHandler") then {
    private _display = findDisplay 312;
    if (!isNull _display) then {
        _display displayRemoveEventHandler ["MouseButtonDown", OpsRoom_Infiltrate_Targeting_ClickHandler];
    };
    OpsRoom_Infiltrate_Targeting_ClickHandler = nil;
};

if (!isNil "OpsRoom_Infiltrate_Targeting_ESCHandler") then {
    private _display = findDisplay 312;
    if (!isNull _display) then {
        _display displayRemoveEventHandler ["KeyDown", OpsRoom_Infiltrate_Targeting_ESCHandler];
    };
    OpsRoom_Infiltrate_Targeting_ESCHandler = nil;
};

OpsRoom_Infiltrate_Targeting_Active = nil;
OpsRoom_Infiltrate_Targeting_Mode = nil;
OpsRoom_Infiltrate_Unit = nil;
