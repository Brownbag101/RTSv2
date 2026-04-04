/*
    Get Available Majors
    
    Returns array of units that:
    - Have rank of EXACTLY Major or higher (NOT Captains)
    - Are not already commanding a regiment (regiment CO)
    - Are not already commanding a group (group CO)
    - Are alive
    - Are Zeus-editable
    - (Optional) Have a specific qualification
    
    Parameters:
        0: STRING - (Optional) Required qualification. "" = no filter.
    
    Returns:
        Array of unit objects
    
    Usage:
        private _majors = [] call OpsRoom_fnc_getAvailableMajors;
        private _commandoMajors = ["commando"] call OpsRoom_fnc_getAvailableMajors;
*/

params [
    ["_requiredQual", "", [""]]
];

private _availableMajors = [];

// Get all Zeus-editable units
private _curator = getAssignedCuratorLogic player;
if (isNull _curator) exitWith {[]};

private _allUnits = curatorEditableObjects _curator select {_x isKindOf "CAManBase"};

// Get all currently assigned regiment COs
private _assignedRegimentCOs = [];
{
    private _regimentData = _y;
    private _co = _regimentData get "commandingOfficer";
    if (!isNull _co) then {
        _assignedRegimentCOs pushBack _co;
    };
} forEach OpsRoom_Regiments;

// Get all currently assigned group COs (group leaders)
private _assignedGroupCOs = [];
{
    private _groupData = _y;
    private _co = _groupData get "commandingOfficer";
    if (!isNull _co) then {
        _assignedGroupCOs pushBack _co;
    };
} forEach OpsRoom_Groups;

// Filter for available Majors
{
    private _unit = _x;
    
    // Skip player unit
    if (_unit == player) then {continue};
    
    // Check rank - Major and above only
    // ARMA 3 rankId: PRIVATE=0, CORPORAL=1, SERGEANT=2, LIEUTENANT=3, CAPTAIN=4, MAJOR=5, COLONEL=6
    // So we want rankId >= 5 for Major and above
    if (rankId _unit >= 5) then {
        // Check not already a regiment CO
        if !(_unit in _assignedRegimentCOs) then {
            // Check not already a group CO
            if !(_unit in _assignedGroupCOs) then {
                // Check alive
                if (alive _unit) then {
                    // Check qualification requirement
                    if (_requiredQual != "") then {
                        private _quals = _unit getVariable ["OpsRoom_Qualifications", []];
                        if (_requiredQual in _quals) then {
                            _availableMajors pushBack _unit;
                        };
                    } else {
                        _availableMajors pushBack _unit;
                    };
                };
            };
        };
    };
} forEach _allUnits;

diag_log format ["[OpsRoom] Found %1 available Majors (rank >= Major, qual filter: '%2')", count _availableMajors, _requiredQual];

_availableMajors
