/*
    fn_updateDispatchBadge
    
    Updates the DISPATCHES button (9203) text to show unread count.
    Shows "DISPATCHES (3)" when there are unread messages.
*/

private _display = findDisplay 312;
if (isNull _display) exitWith {};

private _btn = _display displayCtrl 9203;
if (isNull _btn) exitWith {};

if (OpsRoom_DispatchUnread > 0) then {
    _btn ctrlSetText format ["DISPATCHES (%1)", OpsRoom_DispatchUnread];
    // Highlight the button background when there are unread
    private _bg = _display displayCtrl 9202;
    if (!isNull _bg) then {
        _bg ctrlSetBackgroundColor [0.55, 0.45, 0.25, 0.95];
    };
} else {
    _btn ctrlSetText "DISPATCHES";
    // Reset background to normal
    private _bg = _display displayCtrl 9202;
    if (!isNull _bg) then {
        _bg ctrlSetBackgroundColor [0.40, 0.35, 0.25, 0.85];
    };
};
