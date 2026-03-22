/*
    Open Groups Dialog
    
    Opens the group management interface for a specific regiment.
    
    Parameters:
        0: STRING - Regiment ID
    
    Usage:
        ["regiment_1"] call OpsRoom_fnc_openGroups;
*/

params [
    ["_regimentId", "", [""]]
];

if (_regimentId == "") exitWith {
    hint "Error: No regiment ID provided";
};

// Get regiment data
private _regimentData = OpsRoom_Regiments get _regimentId;
if (isNil "_regimentData") exitWith {
    hint "Error: Regiment not found";
};

// Store selected regiment ID for use by other functions
uiNamespace setVariable ["OpsRoom_SelectedRegiment", _regimentId];

// Create dialog
createDialog "OpsRoom_GroupDialog";

// Wait for dialog to be created
waitUntil {!isNull findDisplay 8001};

private _display = findDisplay 8001;

// Update title with regiment name
private _titleCtrl = _display displayCtrl 8010;
if (!isNull _titleCtrl) then {
    private _regimentName = _regimentData get "name";
    _titleCtrl ctrlSetText format ["GROUPS - %1", _regimentName];
};

// Setup back button to return to regiments
private _backBtn = _display displayCtrl 8011;
if (!isNull _backBtn) then {
    _backBtn ctrlAddEventHandler ["ButtonClick", {
        [] spawn {
            closeDialog 0;
            sleep 0.1;  // Small delay to ensure dialog is fully closed
            [] call OpsRoom_fnc_openRegiments;
        };
    }];
};

// Populate the grid
[_regimentId] call OpsRoom_fnc_populateGroupGrid;

// Debug
diag_log format ["[OpsRoom] Groups dialog opened for: %1", _regimentId];
