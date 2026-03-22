/*
    fn_openDispatchLog
    
    Opens the dispatch log dialog showing all received messages.
    Populates the list and wires up buttons.
*/

createDialog "OpsRoom_DispatchLogDialog";
waitUntil {!isNull findDisplay 8020};

private _display = findDisplay 8020;

// Wire Mark All Read button
private _markReadBtn = _display displayCtrl 12101;
_markReadBtn ctrlAddEventHandler ["ButtonClick", {
    // Mark all as read
    {
        _x set ["read", true];
    } forEach OpsRoom_Dispatches;
    
    OpsRoom_DispatchUnread = 0;
    [] call OpsRoom_fnc_updateDispatchBadge;
    
    // Refresh the list
    [] call OpsRoom_fnc_populateDispatchLog;
}];

// Wire Focus button (initially hidden until dispatch selected)
private _focusBtn = _display displayCtrl 12105;
_focusBtn ctrlShow false;

// Populate the list
[] call OpsRoom_fnc_populateDispatchLog;
