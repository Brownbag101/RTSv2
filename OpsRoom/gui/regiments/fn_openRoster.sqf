/*
    Open Unit Roster Dialog
    
    Opens the unit roster view for a specific group.
    
    Parameters:
        0: STRING - Group ID
    
    Usage:
        ["group_1"] call OpsRoom_fnc_openRoster;
*/

params [
    ["_groupId", "", [""]]
];

if (_groupId == "") exitWith {
    hint "Error: No group ID provided";
};

// Get group data
private _groupData = OpsRoom_Groups get _groupId;
if (isNil "_groupData") exitWith {
    hint "Error: Group not found";
};

// Store selected group ID and regiment ID for navigation
private _regimentId = _groupData get "regimentId";
uiNamespace setVariable ["OpsRoom_SelectedGroup", _groupId];
uiNamespace setVariable ["OpsRoom_SelectedRegiment", _regimentId];

// Create dialog
createDialog "OpsRoom_RosterDialog";

// Wait for dialog to be created
waitUntil {!isNull findDisplay 8002};

private _display = findDisplay 8002;

// Update title with group name
private _titleCtrl = _display displayCtrl 8010;
if (!isNull _titleCtrl) then {
    private _groupName = _groupData get "name";
    _titleCtrl ctrlSetText format ["UNIT ROSTER - %1", _groupName];
};

// Setup back button to return to group grid
private _backBtn = _display displayCtrl 8011;
if (!isNull _backBtn) then {
    _backBtn ctrlAddEventHandler ["ButtonClick", {
        [] spawn {
            closeDialog 0;
            sleep 0.1;  // Small delay to ensure dialog is fully closed
            private _regimentId = uiNamespace getVariable ["OpsRoom_SelectedRegiment", ""];
            if (_regimentId != "") then {
                [_regimentId] call OpsRoom_fnc_openGroups;
            };
        };
    }];
};

// Populate the roster
[_groupId] call OpsRoom_fnc_populateRoster;

// Debug
diag_log format ["[OpsRoom] Roster dialog opened for: %1", _groupId];
