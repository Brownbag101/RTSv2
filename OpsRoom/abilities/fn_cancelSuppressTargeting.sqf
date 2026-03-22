/*
    Author: OpsRoom
    Description: Cancel suppression targeting mode and cleanup
    
    Returns:
        Nothing
*/

// Remove cursor
if (!isNil "OpsRoom_SuppressTargeting_CursorCtrl") then {
    ctrlDelete OpsRoom_SuppressTargeting_CursorCtrl;
    OpsRoom_SuppressTargeting_CursorCtrl = nil;
};

// Remove frame handler
if (!isNil "OpsRoom_SuppressTargeting_FrameHandler") then {
    removeMissionEventHandler ["EachFrame", OpsRoom_SuppressTargeting_FrameHandler];
    OpsRoom_SuppressTargeting_FrameHandler = nil;
};

// Remove click handler
if (!isNil "OpsRoom_SuppressTargeting_ClickHandler") then {
    private _display = findDisplay 312;
    if (!isNull _display) then {
        _display displayRemoveEventHandler ["MouseButtonDown", OpsRoom_SuppressTargeting_ClickHandler];
    };
    OpsRoom_SuppressTargeting_ClickHandler = nil;
};

// Remove ESC handler
if (!isNil "OpsRoom_SuppressTargeting_ESCHandler") then {
    private _display = findDisplay 312;
    if (!isNull _display) then {
        _display displayRemoveEventHandler ["KeyDown", OpsRoom_SuppressTargeting_ESCHandler];
    };
    OpsRoom_SuppressTargeting_ESCHandler = nil;
};

// Clear data
OpsRoom_SuppressTargeting_Active = nil;
OpsRoom_SuppressTargeting_Units = nil;
OpsRoom_SuppressTargeting_Duration = nil;
OpsRoom_SuppressUnits = nil;
