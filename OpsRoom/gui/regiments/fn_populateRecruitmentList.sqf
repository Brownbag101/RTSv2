/*
    Populate Recruitment List
    
    Fills the recruitment listbox with available recruits.
    Updates manpower display.
    
    Usage:
        [] call OpsRoom_fnc_populateRecruitmentList;
*/

private _display = findDisplay 8004;
if (isNull _display) exitWith {
    diag_log "[OpsRoom] ERROR: Recruitment dialog not found";
};

private _listbox = _display displayCtrl 8421;
if (isNull _listbox) exitWith {
    diag_log "[OpsRoom] ERROR: Recruitment listbox not found";
};

lbClear _listbox;

// Update manpower display
private _manpowerCtrl = _display displayCtrl 8420;
if (!isNull _manpowerCtrl) then {
    private _manpower = if (isNil "OpsRoom_Resource_Manpower") then {5} else {OpsRoom_Resource_Manpower};
    _manpowerCtrl ctrlSetText format ["Available Manpower: %1 | Recruits in Pool: %2", 
        _manpower,
        count OpsRoom_RecruitPool
    ];
};

// Populate listbox
{
    private _recruit = _x;
    private _name = _recruit get "name";
    private _quality = _recruit get "quality";
    
    // Add star for good recruits
    private _displayName = if (_quality == "good") then {
        format ["%1 ★", _name]
    } else {
        _name
    };
    
    private _index = _listbox lbAdd _displayName;
    _listbox lbSetData [_index, _recruit get "id"];
    
    // Color code
    if (_quality == "good") then {
        _listbox lbSetColor [_index, [1, 0.84, 0, 1]]; // Gold
    };
} forEach OpsRoom_RecruitPool;

// Auto-select first
if (count OpsRoom_RecruitPool > 0) then {
    _listbox lbSetCurSel 0;
};

diag_log format ["[OpsRoom] Recruitment list populated: %1 recruits", count OpsRoom_RecruitPool];
