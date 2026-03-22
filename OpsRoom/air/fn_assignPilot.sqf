/*
    Air Operations - Assign Pilot to Aircraft
    
    Assigns a trained pilot (unit with "pilot" qualification) to a hangar aircraft.
    The pilot's name is stored and displayed in wing/hangar GUIs.
    The physical unit is NOT moved — they stay with their regiment.
    Only the name and reference are stored on the hangar entry.
    
    Parameters:
        _hangarId  - Hangar ID of aircraft
        _unit      - Unit object to assign as pilot
    
    Returns:
        Boolean - true on success
*/
params ["_hangarId", "_unit"];

// Validate hangar entry
private _entry = OpsRoom_Hangar get _hangarId;
if (isNil "_entry") exitWith {
    systemChat "Aircraft not found in hangar";
    false
};

// Validate unit
if (isNull _unit || !alive _unit) exitWith {
    systemChat "Invalid or dead unit";
    false
};

// Check pilot qualification
private _qualifications = _unit getVariable ["OpsRoom_Qualifications", []];
if !("pilot" in _qualifications) exitWith {
    systemChat format ["%1 does not have Pilot Training qualification", name _unit];
    false
};

// Check aircraft is hangared
if ((_entry get "status") != "HANGARED") exitWith {
    systemChat "Aircraft must be in hangar to assign a pilot";
    false
};

// Check unit isn't already assigned to another aircraft
{
    private _otherEntry = _y;
    if ((_otherEntry getOrDefault ["assignedPilot", objNull]) isEqualTo _unit) exitWith {
        systemChat format ["%1 is already assigned to %2", name _unit, _otherEntry get "displayName"];
        _hangarId = "";  // Flag failure
    };
} forEach OpsRoom_Hangar;

if (_hangarId == "") exitWith { false };

// Assign pilot
_entry set ["assignedPilot", _unit];
_entry set ["assignedPilotName", name _unit];
_entry set ["pilotName", name _unit];

private _displayName = _entry get "displayName";
systemChat format ["%1 assigned as pilot of %2", name _unit, _displayName];

diag_log format ["[OpsRoom] Air: %1 assigned as pilot of %2 (%3)", name _unit, _displayName, _hangarId];

true
