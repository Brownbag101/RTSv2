/*
    Air Operations - Assign Aircraft to Wing
    
    Assigns a hangared aircraft (with pilot) to an air wing.
    
    Parameters:
        _hangarId  - Hangar ID of aircraft
        _wingId    - Wing ID to assign to
    
    Returns:
        Boolean - true on success
*/
params ["_hangarId", "_wingId"];

// Validate hangar entry
private _entry = OpsRoom_Hangar get _hangarId;
if (isNil "_entry") exitWith {
    diag_log format ["[OpsRoom] Air: Cannot assign '%1' - not in hangar", _hangarId];
    false
};

// Validate wing
private _wing = OpsRoom_AirWings get _wingId;
if (isNil "_wing") exitWith {
    diag_log format ["[OpsRoom] Air: Cannot assign to '%1' - wing not found", _wingId];
    false
};

// Check aircraft isn't already assigned elsewhere
private _currentWing = _entry get "wingId";
if (_currentWing != "") exitWith {
    systemChat format ["%1 is already assigned to a wing", _entry get "displayName"];
    false
};

// Check wing isn't full
private _aircraft = _wing get "aircraft";
if (count _aircraft >= OpsRoom_Settings_MaxWingSize) exitWith {
    systemChat format ["Wing is full (%1/%2 aircraft)", count _aircraft, OpsRoom_Settings_MaxWingSize];
    false
};

// Check aircraft type is compatible with wing type
private _wingType = _wing get "wingType";
private _wingTypeData = OpsRoom_WingTypes get _wingType;
private _allowedTypes = _wingTypeData get "allowedAircraftTypes";
private _aircraftType = _entry get "aircraftType";

if !(_aircraftType in _allowedTypes) exitWith {
    systemChat format ["%1 cannot be assigned to a %2 wing", _entry get "displayName", _wingTypeData get "displayName"];
    false
};

// Check aircraft status
if ((_entry get "status") != "HANGARED") exitWith {
    systemChat format ["%1 must be hangared to assign", _entry get "displayName"];
    false
};

// Assign
_aircraft pushBack _hangarId;
_wing set ["aircraft", _aircraft];
_entry set ["wingId", _wingId];

diag_log format ["[OpsRoom] Air: Assigned %1 to %2", _entry get "displayName", _wing get "name"];

systemChat format ["%1 assigned to %2", _entry get "displayName", _wing get "name"];

true
