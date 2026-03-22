/*
    Air Operations - Assign Crew to Aircraft
    
    Assigns an air gunner (unit with "airCrew" qualification) to a hangar aircraft's crew.
    Multiple crew can be assigned (one per turret seat).
    
    Parameters:
        _hangarId  - Hangar ID of aircraft
        _unit      - Unit object to assign as crew
    
    Returns:
        Boolean - true on success
*/
params ["_hangarId", "_unit"];

private _entry = OpsRoom_Hangar get _hangarId;
if (isNil "_entry") exitWith {
    systemChat "Aircraft not found in hangar";
    false
};

if (isNull _unit || !alive _unit) exitWith {
    systemChat "Invalid or dead unit";
    false
};

// Check airCrew qualification
private _qualifications = _unit getVariable ["OpsRoom_Qualifications", []];
if !("airCrew" in _qualifications) exitWith {
    systemChat format ["%1 does not have Air Gunner qualification", name _unit];
    false
};

// Check aircraft is hangared
if ((_entry get "status") != "HANGARED") exitWith {
    systemChat "Aircraft must be in hangar to assign crew";
    false
};

// Check crew not full
private _assignedCrew = _entry getOrDefault ["assignedCrew", []];
private _crewRequired = _entry getOrDefault ["crewRequired", 0];
if (count _assignedCrew >= _crewRequired) exitWith {
    systemChat format ["Aircraft crew is full (%1/%2)", count _assignedCrew, _crewRequired];
    false
};

// Check unit isn't already assigned to another aircraft
{
    private _otherEntry = _y;
    private _otherCrew = _otherEntry getOrDefault ["assignedCrew", []];
    if (_unit in _otherCrew) exitWith {
        systemChat format ["%1 is already assigned to %2", name _unit, _otherEntry get "displayName"];
        _hangarId = "";
    };
    if ((_otherEntry getOrDefault ["assignedPilot", objNull]) isEqualTo _unit) exitWith {
        systemChat format ["%1 is assigned as pilot on %2", name _unit, _otherEntry get "displayName"];
        _hangarId = "";
    };
} forEach OpsRoom_Hangar;

if (_hangarId == "") exitWith { false };

// Assign
_assignedCrew pushBack _unit;
_entry set ["assignedCrew", _assignedCrew];

private _displayName = _entry get "displayName";
systemChat format ["%1 assigned as crew on %2 (%3/%4)", name _unit, _displayName, count _assignedCrew, _crewRequired];

diag_log format ["[OpsRoom] Air: %1 assigned as crew on %2 (%3)", name _unit, _displayName, _hangarId];

true
