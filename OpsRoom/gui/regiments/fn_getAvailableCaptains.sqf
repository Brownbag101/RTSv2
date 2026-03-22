/*
    Get Available Captains
    
    Returns array of units that:
    - Have rank of Captain
    - Are not already commanding a group
    - Are alive
    - Are not the player
    - Are either: in this regiment already, OR are Zeus-editable and not in any regiment
    
    Parameters:
        0: STRING - Regiment ID
    
    Returns:
        Array of unit objects
    
    Usage:
        private _captains = ["regiment_1"] call OpsRoom_fnc_getAvailableCaptains;
*/

params [
    ["_regimentId", "", [""]]
];

private _availableCaptains = [];

diag_log format ["[OpsRoom] === Getting available Captains for regiment: %1 ===", _regimentId];

// Get regiment data
private _regimentData = OpsRoom_Regiments get _regimentId;
if (isNil "_regimentData") exitWith {
    diag_log "[OpsRoom] ERROR: Regiment data not found!";
    []
};

// Get all groups in this regiment
private _groupIds = _regimentData get "groups";
diag_log format ["[OpsRoom] Regiment has %1 groups: %2", count _groupIds, _groupIds];

// Get all units in all groups of this regiment
private _regimentUnits = [];
{
    private _groupId = _x;
    private _groupData = OpsRoom_Groups get _groupId;
    if (!isNil "_groupData") then {
        private _units = _groupData get "units";
        _regimentUnits append _units;
        diag_log format ["[OpsRoom] Group %1 has %2 units", _groupId, count _units];
        {
            diag_log format ["[OpsRoom]   - %1 (rank: %2, rankId: %3)", name _x, rank _x, rankId _x];
        } forEach _units;
    } else {
        diag_log format ["[OpsRoom] WARNING: Group %1 data not found!", _groupId];
    };
} forEach _groupIds;

diag_log format ["[OpsRoom] Total units in regiment: %1", count _regimentUnits];

// Get all currently assigned group COs in this regiment
private _assignedCOs = [];
{
    private _groupData = OpsRoom_Groups get _x;
    if (!isNil "_groupData") then {
        private _co = _groupData get "commandingOfficer";
        if (!isNull _co) then {
            _assignedCOs pushBack _co;
            diag_log format ["[OpsRoom] Group CO: %1", name _co];
        };
    };
} forEach _groupIds;

diag_log format ["[OpsRoom] Total assigned COs: %1", count _assignedCOs];

// Filter for available Captains IN THIS REGIMENT
{
    private _unit = _x;
    
    diag_log format ["[OpsRoom] Checking unit: %1 (rank: %2, rankId: %3)", name _unit, rank _unit, rankId _unit];
    
    // Skip player unit
    if (_unit == player) then {
        diag_log format ["[OpsRoom]   SKIP: Is player"];
        continue;
    };
    
    // Check rank (Captain = 4)
    if (rankId _unit == 4) then {
        diag_log format ["[OpsRoom]   PASS: Is Captain"];
        
        // Check not already a group CO
        if (_unit in _assignedCOs) then {
            diag_log format ["[OpsRoom]   SKIP: Already a group CO"];
        } else {
            diag_log format ["[OpsRoom]   PASS: Not a CO"];
            
            // Check alive
            if (alive _unit) then {
                diag_log format ["[OpsRoom]   PASS: Is alive"];
                _availableCaptains pushBack _unit;
                diag_log format ["[OpsRoom]   ADDED to available Captains!"];
            } else {
                diag_log format ["[OpsRoom]   SKIP: Is dead"];
            };
        };
    } else {
        diag_log format ["[OpsRoom]   SKIP: Not a Captain (rankId: %1)", rankId _unit];
    };
} forEach _regimentUnits;

diag_log format ["[OpsRoom] === Found %1 available Captains ===", count _availableCaptains];

_availableCaptains
