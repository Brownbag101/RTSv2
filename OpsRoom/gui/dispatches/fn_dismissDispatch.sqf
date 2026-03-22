/*
    fn_dismissDispatch
    
    Removes the current dispatch popup from Zeus display.
    Marks as dismissed. Checks queue for next message.
    
    Called by DISMISS button click or auto-dismiss timer.
*/

// Get Zeus display
private _display = findDisplay 312;
if (isNull _display) exitWith {
    OpsRoom_DispatchPopupActive = false;
};

// Mark current dispatch as dismissed + read
if (!isNil "OpsRoom_CurrentDispatch") then {
    OpsRoom_CurrentDispatch set ["dismissed", true];
    OpsRoom_CurrentDispatch set ["read", true];
    
    // Decrement unread count
    OpsRoom_DispatchUnread = (OpsRoom_DispatchUnread - 1) max 0;
    [] call OpsRoom_fnc_updateDispatchBadge;
};

// Slide-out animation (move controls off-screen right)
private _slideOutX = safezoneX + safezoneW + 0.01;
private _allIDCs = [12000, 12001, 12002, 12003, 12004, 12005, 12010, 12011];
{
    private _ctrl = _display displayCtrl _x;
    if (!isNull _ctrl) then {
        private _pos = ctrlPosition _ctrl;
        _ctrl ctrlSetPosition [_slideOutX + (_pos select 0) - (safezoneX + safezoneW - 0.22 * safezoneW - 0.01 * safezoneW), _pos select 1, _pos select 2, _pos select 3];
        _ctrl ctrlCommit 0.2;  // Fast slide-out
    };
} forEach _allIDCs;

// Delete controls after animation
[] spawn {
    sleep 0.25;
    
    private _disp = findDisplay 312;
    if (!isNull _disp) then {
        for "_idc" from 12000 to 12019 do {
            private _ctrl = _disp displayCtrl _idc;
            if (!isNull _ctrl) then { ctrlDelete _ctrl };
        };
    };
    
    OpsRoom_DispatchPopupActive = false;
    OpsRoom_CurrentDispatch = nil;
    
    // Check queue for next dispatch
    if (count OpsRoom_DispatchQueue > 0) then {
        private _next = OpsRoom_DispatchQueue deleteAt 0;
        sleep 0.5;  // Brief pause between messages
        [_next] spawn OpsRoom_fnc_showDispatchPopup;
    };
};
