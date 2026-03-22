/*
    OpsRoom_fnc_cancelAirStrikeTargeting
    
    Cleanup: removes cursor, handlers, and all targeting globals.
    Handles both TGT and FAH phases.
*/

// Remove cursor control
if (!isNil "OpsRoom_AirStrike_Targeting_CursorCtrl") then {
    ctrlDelete OpsRoom_AirStrike_Targeting_CursorCtrl;
    OpsRoom_AirStrike_Targeting_CursorCtrl = nil;
};

// Remove Draw3D handler
if (!isNil "OpsRoom_AirStrike_Targeting_DrawHandler") then {
    removeMissionEventHandler ["Draw3D", OpsRoom_AirStrike_Targeting_DrawHandler];
    OpsRoom_AirStrike_Targeting_DrawHandler = nil;
};

// Remove EachFrame handler
if (!isNil "OpsRoom_AirStrike_Targeting_FrameHandler") then {
    removeMissionEventHandler ["EachFrame", OpsRoom_AirStrike_Targeting_FrameHandler];
    OpsRoom_AirStrike_Targeting_FrameHandler = nil;
};

// Remove MouseButtonDown handler
if (!isNil "OpsRoom_AirStrike_Targeting_ClickHandler") then {
    private _display = findDisplay 312;
    if (!isNull _display) then {
        _display displayRemoveEventHandler ["MouseButtonDown", OpsRoom_AirStrike_Targeting_ClickHandler];
    };
    OpsRoom_AirStrike_Targeting_ClickHandler = nil;
};

// Remove KeyDown handler
if (!isNil "OpsRoom_AirStrike_Targeting_ESCHandler") then {
    private _display = findDisplay 312;
    if (!isNull _display) then {
        _display displayRemoveEventHandler ["KeyDown", OpsRoom_AirStrike_Targeting_ESCHandler];
    };
    OpsRoom_AirStrike_Targeting_ESCHandler = nil;
};

// Clear all state — original + new phase variables
OpsRoom_AirStrike_Targeting_Active = nil;
OpsRoom_AirStrike_Targeting_Phase = nil;
OpsRoom_AirStrike_Targeting_AttackType = nil;
OpsRoom_AirStrike_Targeting_TargetPos = nil;
OpsRoom_AirStrike_Targeting_ApproachPos = nil;
OpsRoom_AirStrike_MinFAHDistance = nil;
OpsRoom_AirStrike_Unit = nil;
OpsRoom_AirStrike_Available = nil;
