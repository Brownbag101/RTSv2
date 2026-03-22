/*
    Create New Regiment
    
    Creates a new regiment with the specified name and commanding officer.
    The CO becomes the only member of the new regiment initially.
    
    Parameters:
        0: STRING - Regiment name
        1: OBJECT - Commanding Officer (Major)
    
    Returns:
        STRING - New regiment ID
    
    Usage:
        private _regimentId = ["The Yorkshire Regiment", majorSmith] call OpsRoom_fnc_createRegiment;
*/

params [
    ["_name", "", [""]],
    ["_commandingOfficer", objNull, [objNull]]
];

if (_name == "") exitWith {
    diag_log "[OpsRoom] ERROR: Cannot create regiment - no name provided";
    "";
};

if (isNull _commandingOfficer) exitWith {
    diag_log "[OpsRoom] ERROR: Cannot create regiment - no CO provided";
    "";
};

// Generate unique IDs
private _regimentId = format ["regiment_%1", OpsRoom_NextRegimentID];
OpsRoom_NextRegimentID = OpsRoom_NextRegimentID + 1;

private _groupId = format ["group_%1", OpsRoom_NextGroupID];
OpsRoom_NextGroupID = OpsRoom_NextGroupID + 1;

// Create regiment data
private _regimentData = createHashMapFromArray [
    ["id", _regimentId],
    ["name", _name],
    ["commandingOfficer", _commandingOfficer],
    ["groups", [_groupId]],
    ["dateFormed", date],
    ["badgeImage", "OpsRoom\images\badges\placeholder.paa"]
];

OpsRoom_Regiments set [_regimentId, _regimentData];

// Mark name as used
OpsRoom_UsedRegimentNames pushBack _name;

// Extract regiment short name for group naming (e.g., "Essex" from "The Essex Regiment")
private _shortName = _name;
_shortName = _shortName splitString " " select {_x != "The" && _x != "Regiment"};
_shortName = _shortName joinString " ";

// Create initial group: "1st [ShortName] Regiment"
private _groupName = format ["1st %1 Regiment", _shortName];

// STEP 1: Remove Major from their old OpsRoom group's unit list
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

// STEP 2: Create initial group with ONLY the Major
private _groupData = createHashMapFromArray [
    ["id", _groupId],
    ["name", _groupName],
    ["regimentId", _regimentId],
    ["commandingOfficer", _commandingOfficer],
    ["units", [_commandingOfficer]], // Major is the only initial member
    ["dateFormed", date]
];

OpsRoom_Groups set [_groupId, _groupData];

// STEP 3: Create new ARMA group and move Major to it
if (!isNull _commandingOfficer) then {
    // Create a new ARMA group
    private _newGroup = createGroup [side _commandingOfficer, true];
    
    // Move Major to the new group
    [_commandingOfficer] joinSilent _newGroup;
    
    // Rename the new group
    _newGroup setGroupIdGlobal [_groupName];
    
    diag_log format ["[OpsRoom] Moved %1 to new ARMA group", name _commandingOfficer];
    diag_log format ["[OpsRoom] Renamed new ARMA group to: %1", _groupName];
};

// Debug output
diag_log format ["[OpsRoom] Created regiment: %1 (ID: %2)", _name, _regimentId];
diag_log format ["[OpsRoom] Regiment CO: %1", name _commandingOfficer];
diag_log format ["[OpsRoom] Initial group: %1 (ID: %2) with 1 unit", _groupName, _groupId];

// Return regiment ID
_regimentId
