/*
    Initialize Regiment System
    
    Creates data structures and starting regiment.
    Called during mission initialization.
    
    Expects (optional):
        OpsRoom_StartingUnits - Array of units to assign to starting regiment
    
    Creates:
        OpsRoom_Regiments - Hashmap of all regiments
        OpsRoom_Groups - Hashmap of all groups
        OpsRoom_NextRegimentID - Counter for unique IDs
        OpsRoom_NextGroupID - Counter for unique IDs
*/

// Load regiment names
call compile preprocessFileLineNumbers "OpsRoom\data\regimentNames.sqf";

// Initialize data structures
OpsRoom_Regiments = createHashMap;
OpsRoom_Groups = createHashMap;
OpsRoom_NextRegimentID = 1;
OpsRoom_NextGroupID = 1;

// Get starting units - ONLY if explicitly defined
private _startingUnits = [];
if (!isNil "OpsRoom_StartingUnits") then {
    _startingUnits = OpsRoom_StartingUnits;
};

// Only create starting regiment if we have starting units defined
if (count _startingUnits > 0) then {
    // Create starting regiment: "1st Essex Regiment"
    private _regimentId = format ["regiment_%1", OpsRoom_NextRegimentID];
    OpsRoom_NextRegimentID = OpsRoom_NextRegimentID + 1;

    private _groupId = format ["group_%1", OpsRoom_NextGroupID];
    OpsRoom_NextGroupID = OpsRoom_NextGroupID + 1;

    // Find the Major (if any) to be CO, otherwise pick first unit
    private _commandingOfficer = objNull;
    {
        if (rankId _x >= 3) exitWith { _commandingOfficer = _x; }; // Major or higher
    } forEach _startingUnits;

    if (isNull _commandingOfficer && count _startingUnits > 0) then {
        _commandingOfficer = _startingUnits select 0;
    };
    
    // If CO has a group, include ALL units from that group
    private _actualStartingUnits = _startingUnits;
    if (!isNull _commandingOfficer) then {
        private _coGroup = group _commandingOfficer;
        if (!isNull _coGroup) then {
            private _groupUnits = units _coGroup;
            // Use all units from the CO's ARMA group
            _actualStartingUnits = _groupUnits;
        };
    };

    // Create regiment
    private _regimentData = createHashMapFromArray [
        ["id", _regimentId],
        ["name", "The Essex Regiment"],
        ["commandingOfficer", _commandingOfficer],
        ["groups", [_groupId]],
        ["dateFormed", date],
        ["badgeImage", "OpsRoom\images\badges\essex.paa"]
    ];

    OpsRoom_Regiments set [_regimentId, _regimentData];

    // Mark Essex as used
    OpsRoom_UsedRegimentNames pushBack "The Essex Regiment";

    // Create starting group: "1st Essex Regiment"
    private _groupData = createHashMapFromArray [
        ["id", _groupId],
        ["name", "1st Essex Regiment"],
        ["regimentId", _regimentId],
        ["commandingOfficer", _commandingOfficer],
        ["units", _actualStartingUnits],  // Use actual units from group
        ["dateFormed", date]
    ];

    OpsRoom_Groups set [_groupId, _groupData];

    // Debug output
    diag_log format ["[OpsRoom] Regiment system initialized"];
    diag_log format ["[OpsRoom] Created regiment: %1 with %2 units", 
        _regimentData get "name", 
        count _actualStartingUnits
    ];
    diag_log format ["[OpsRoom] Regiment CO: %1 (Rank: %2)", 
        name _commandingOfficer, 
        rank _commandingOfficer
    ];

    systemChat format ["Operations Room: %1 formed with %2 personnel", 
        _regimentData get "name", 
        count _actualStartingUnits
    ];
} else {
    // No starting units defined - start with empty regiment system
    diag_log "[OpsRoom] Regiment system initialized - no starting units defined";
    systemChat "Operations Room: Regiment system ready";
};
