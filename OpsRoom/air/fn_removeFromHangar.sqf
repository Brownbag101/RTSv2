/*
    Air Operations - Remove Aircraft from Hangar
    
    Removes an aircraft from the hangar pool.
    Handles wing cleanup if aircraft was assigned.
    
    Parameters:
        _hangarId  - Hangar ID to remove
        _reason    - "DESTROYED", "TRANSFERRED", "SCRAPPED" (for dispatch message)
    
    Returns:
        Boolean - true on success
*/
params ["_hangarId", ["_reason", "SCRAPPED"]];

private _entry = OpsRoom_Hangar get _hangarId;
if (isNil "_entry") exitWith {
    diag_log format ["[OpsRoom] Air: Cannot remove '%1' - not found", _hangarId];
    false
};

private _displayName = _entry get "displayName";
private _wingId = _entry get "wingId";

// Remove from wing if assigned
if (_wingId != "") then {
    private _wingData = OpsRoom_AirWings get _wingId;
    if (!isNil "_wingData") then {
        private _aircraft = _wingData get "aircraft";
        _aircraft = _aircraft - [_hangarId];
        _wingData set ["aircraft", _aircraft];
    };
};

// Delete hangar entry
OpsRoom_Hangar deleteAt _hangarId;

diag_log format ["[OpsRoom] Air: Removed %1 (%2) - %3", _displayName, _hangarId, _reason];

// Dispatch based on reason
private _dispatchPriority = switch (_reason) do {
    case "DESTROYED": { "FLASH" };
    case "TRANSFERRED": { "ROUTINE" };
    default { "ROUTINE" };
};

private _dispatchMsg = switch (_reason) do {
    case "DESTROYED": { format ["%1 destroyed. Aircraft struck from strength.", _displayName] };
    case "TRANSFERRED": { format ["%1 transferred from airfield.", _displayName] };
    default { format ["%1 scrapped and removed from inventory.", _displayName] };
};

[
    format ["Aircraft %1: %2", _reason, _displayName],
    _dispatchMsg,
    _dispatchPriority
] call OpsRoom_fnc_dispatch;

true
