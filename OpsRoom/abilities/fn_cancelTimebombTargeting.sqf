/*
    OpsRoom_fnc_cancelTimebombTargeting
    
    Cleanup all timebomb targeting state.
*/

// Remove cursor
if (!isNil "OpsRoom_Timebomb_Targeting_CursorCtrl") then {
    ctrlDelete OpsRoom_Timebomb_Targeting_CursorCtrl;
    OpsRoom_Timebomb_Targeting_CursorCtrl = nil;
};

// Remove EachFrame handler
if (!isNil "OpsRoom_Timebomb_Targeting_FrameHandler") then {
    removeMissionEventHandler ["EachFrame", OpsRoom_Timebomb_Targeting_FrameHandler];
    OpsRoom_Timebomb_Targeting_FrameHandler = nil;
};

// Remove Draw3D handler
if (!isNil "OpsRoom_Timebomb_Targeting_DrawHandler") then {
    removeMissionEventHandler ["Draw3D", OpsRoom_Timebomb_Targeting_DrawHandler];
    OpsRoom_Timebomb_Targeting_DrawHandler = nil;
};

// Remove MouseButtonDown handler
if (!isNil "OpsRoom_Timebomb_Targeting_ClickHandler") then {
    private _display = findDisplay 312;
    if (!isNull _display) then {
        _display displayRemoveEventHandler ["MouseButtonDown", OpsRoom_Timebomb_Targeting_ClickHandler];
    };
    OpsRoom_Timebomb_Targeting_ClickHandler = nil;
};

// Remove KeyDown handler
if (!isNil "OpsRoom_Timebomb_Targeting_ESCHandler") then {
    private _display = findDisplay 312;
    if (!isNull _display) then {
        _display displayRemoveEventHandler ["KeyDown", OpsRoom_Timebomb_Targeting_ESCHandler];
    };
    OpsRoom_Timebomb_Targeting_ESCHandler = nil;
};

// Clear state
OpsRoom_Timebomb_Targeting_Active = nil;
OpsRoom_Timebomb_Targeting_FuseTime = nil;
OpsRoom_Timebomb_Unit = nil;
