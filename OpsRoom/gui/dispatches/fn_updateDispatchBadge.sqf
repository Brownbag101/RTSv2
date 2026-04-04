/*
    fn_updateDispatchBadge
    
    Updates the DISPATCHES button (9203) tooltip to show unread count.
    Brightens the icon when there are unread messages.
*/

private _display = findDisplay 312;
if (isNull _display) exitWith {};

private _btn = _display displayCtrl 9203;
if (isNull _btn) exitWith {};

private _pic = _display displayCtrl 9212;

if (OpsRoom_DispatchUnread > 0) then {
    // Update tooltip with unread count
    _btn ctrlSetTooltip format ["Dispatches - %1 unread message(s)", OpsRoom_DispatchUnread];
    // Brighten icon to draw attention
    if (!isNull _pic) then {
        _pic ctrlSetTextColor [1.0, 0.85, 0.3, 1.0]; // Gold tint
    };
} else {
    _btn ctrlSetTooltip "Dispatches - View signals and messages";
    // Reset icon to normal
    if (!isNull _pic) then {
        _pic ctrlSetTextColor [1.0, 1.0, 1.0, 1.0];
    };
};
