/*
    Process Recruitment
    
    Handles enlist button click - validates selection and opens group picker.
    
    Usage:
        [] call OpsRoom_fnc_processRecruitment;
*/

private _display = findDisplay 8004;
if (isNull _display) exitWith {};

private _listbox = _display displayCtrl 8421;
if (isNull _listbox) exitWith {};

private _index = lbCurSel _listbox;

if (_index < 0) exitWith {
    hint "No recruit selected";
};

// Check manpower
private _manpower = if (isNil "OpsRoom_Resource_Manpower") then {5} else {OpsRoom_Resource_Manpower};
if (_manpower <= 0) exitWith {
    hint "Insufficient manpower!";
};

// Get recruit data
private _recruit = OpsRoom_RecruitPool select _index;

// Store selected recruit temporarily
uiNamespace setVariable ["OpsRoom_PendingRecruit", _recruit];
uiNamespace setVariable ["OpsRoom_PendingRecruitIndex", _index];

// Close recruitment dialog
closeDialog 0;

// Open group selection dialog
[] call OpsRoom_fnc_openGroupSelectForRecruit;

diag_log format ["[OpsRoom] Processing recruitment for: %1", _recruit get "name"];
