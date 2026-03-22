/*
    Show Add Regiment Dialog
    
    Opens a dialog for creating a new regiment:
    1. Select a Major as CO (opens major select dialog)
    2. Regiment name automatically chosen from available list
    
    Usage:
        [] call OpsRoom_fnc_showAddRegiment;
*/

// Get available Majors
private _availableMajors = [] call OpsRoom_fnc_getAvailableMajors;

if (count _availableMajors == 0) exitWith {
    hint "No available Majors to command new regiment! Promote a unit to Major first.";
};

// Get unused regiment names
private _unusedNames = OpsRoom_AvailableRegimentNames select {!(_x in OpsRoom_UsedRegimentNames)};

if (count _unusedNames == 0) exitWith {
    hint "All regiment names have been used!";
};

// Check if we already have a major selected (from major select dialog)
private _selectedMajor = uiNamespace getVariable ["OpsRoom_SelectedMajor", objNull];

if (isNull _selectedMajor) exitWith {
    // No major selected yet - open major selection dialog
    [] call OpsRoom_fnc_openMajorSelect;
};

// Have major, use first available regiment name
private _selectedName = _unusedNames select 0;

// Clear the selected major from storage
uiNamespace setVariable ["OpsRoom_SelectedMajor", nil];

// Show confirmation
hint format [
    "Creating New Regiment

Regiment: %1
Commanding Officer: %2 (%3)",
    _selectedName,
    name _selectedMajor,
    rank _selectedMajor
];

// Create the regiment
[_selectedName, _selectedMajor] call OpsRoom_fnc_createRegiment;

// Refresh the grid
[] call OpsRoom_fnc_populateRegimentGrid;

systemChat format ["✓ New regiment formed: %1 under %2", _selectedName, name _selectedMajor];
