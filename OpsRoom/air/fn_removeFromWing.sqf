/*
    Air Operations - Remove Aircraft from Wing
    
    Removes an aircraft from its current wing assignment.
    Aircraft must be hangared (not airborne) to be removed.
    
    Parameters:
        _hangarId  - Hangar ID of aircraft
    
    Returns:
        Boolean - true on success
*/
params ["_hangarId"];

private _entry = OpsRoom_Hangar get _hangarId;
if (isNil "_entry") exitWith {
    diag_log format ["[OpsRoom] Air: Cannot remove '%1' - not in hangar", _hangarId];
    false
};

private _wingId = _entry get "wingId";
if (_wingId == "") exitWith {
    systemChat format ["%1 is not assigned to any wing", _entry get "displayName"];
    false
};

// Can't remove if airborne
if ((_entry get "status") == "AIRBORNE") exitWith {
    systemChat format ["%1 is airborne - cannot remove from wing", _entry get "displayName"];
    false
};

// Remove from wing's aircraft list
private _wing = OpsRoom_AirWings get _wingId;
if (!isNil "_wing") then {
    private _aircraft = _wing get "aircraft";
    _aircraft = _aircraft - [_hangarId];
    _wing set ["aircraft", _aircraft];
    
    // If this was the last aircraft, clear mission
    if (count _aircraft == 0) then {
        _wing set ["mission", ""];
        _wing set ["missionTarget", []];
        _wing set ["status", "STANDBY"];
    };
};

// Clear wing assignment
_entry set ["wingId", ""];

diag_log format ["[OpsRoom] Air: Removed %1 from wing %2", _entry get "displayName", _wingId];
systemChat format ["%1 removed from wing", _entry get "displayName"];

true
