/*
    Create New Group
    
    Creates a new group within a regiment with the specified commanding officer.
    The CO becomes the only member of the new group initially.
    Group is named sequentially (1st, 2nd, 3rd Essex Regiment).
    
    Parameters:
        0: STRING - Regiment ID
        1: OBJECT - Commanding Officer (Captain)
    
    Returns:
        STRING - New group ID
    
    Usage:
        private _groupId = ["regiment_1", captainJones] call OpsRoom_fnc_createGroup;
*/

params [
    ["_regimentId", "", [""]],
    ["_commandingOfficer", objNull, [objNull]]
];

if (_regimentId == "") exitWith {
    diag_log "[OpsRoom] ERROR: Cannot create group - no regiment ID provided";
    "";
};

if (isNull _commandingOfficer) exitWith {
    diag_log "[OpsRoom] ERROR: Cannot create group - no CO provided";
    "";
};

// Get regiment data
private _regimentData = OpsRoom_Regiments get _regimentId;
if (isNil "_regimentData") exitWith {
    diag_log "[OpsRoom] ERROR: Cannot create group - regiment not found";
    "";
};

// Generate unique group ID
private _groupId = format ["group_%1", OpsRoom_NextGroupID];
OpsRoom_NextGroupID = OpsRoom_NextGroupID + 1;

// Determine group number (1st, 2nd, 3rd, etc.)
private _groupIds = _regimentData get "groups";
private _groupNumber = (count _groupIds) + 1;

// Extract regiment short name
private _regimentName = _regimentData get "name";
private _shortName = _regimentName;
_shortName = _shortName splitString " " select {_x != "The" && _x != "Regiment"};
_shortName = _shortName joinString " ";

// Create group name: "2nd Essex Regiment"
private _groupName = format ["%1%2 %3 Regiment", 
    _groupNumber,
    switch (_groupNumber) do {
        case 1: {"st"};
        case 2: {"nd"};
        case 3: {"rd"};
        default {"th"};
    },
    _shortName
];

// STEP 1: Remove Captain from their old OpsRoom group's unit list
if (!isNull _commandingOfficer) then {
    {
        private _oldGroupData = _y;
        private _oldGroupUnits = _oldGroupData get "units";
        
        if (_commandingOfficer in _oldGroupUnits) then {
            _oldGroupUnits = _oldGroupUnits - [_commandingOfficer];
            _oldGroupData set ["units", _oldGroupUnits];
            
            private _oldGroupId = _oldGroupData get "id";
            OpsRoom_Groups set [_oldGroupId, _oldGroupData];
            
            diag_log format ["[OpsRoom] Removed %1 from old group %2 (now has %3 units)", 
                name _commandingOfficer, _oldGroupId, count _oldGroupUnits];
        };
    } forEach OpsRoom_Groups;
};

// STEP 2: Create new group data with Captain
private _groupData = createHashMapFromArray [
    ["id", _groupId],
    ["name", _groupName],
    ["regimentId", _regimentId],
    ["commandingOfficer", _commandingOfficer],
    ["units", [_commandingOfficer]], // CO is the only initial member
    ["dateFormed", date]
];

OpsRoom_Groups set [_groupId, _groupData];

// Add group to regiment's group list
_groupIds pushBack _groupId;
_regimentData set ["groups", _groupIds];
OpsRoom_Regiments set [_regimentId, _regimentData];

// STEP 3: Move Captain to a new ARMA group
if (!isNull _commandingOfficer) then {
    // Create a new ARMA group
    private _newGroup = createGroup [side _commandingOfficer, true];
    
    // Move Captain to the new group
    [_commandingOfficer] joinSilent _newGroup;
    
    // Rename the new group
    _newGroup setGroupIdGlobal [_groupName];
    
    diag_log format ["[OpsRoom] Moved %1 to new ARMA group", name _commandingOfficer];
    diag_log format ["[OpsRoom] Renamed new ARMA group to: %1", _groupName];
};

// Debug output
diag_log format ["[OpsRoom] Created group: %1 (ID: %2)", _groupName, _groupId];
diag_log format ["[OpsRoom] Group CO: %1", name _commandingOfficer];
diag_log format ["[OpsRoom] Group has %1 unit", count (_groupData get "units")];

// Return group ID
_groupId
