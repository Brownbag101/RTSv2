/*
    Open Unit Roster Grid
    
    Opens the unit roster grid for a specific group.
    Shows units as clickable squares.
    
    Parameters:
        0: STRING - Group ID
    
    Usage:
        ["group_1"] call OpsRoom_fnc_openRosterGrid;
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

// Store context for navigation
private _regimentId = _groupData get "regimentId";
uiNamespace setVariable ["OpsRoom_SelectedGroup", _groupId];
uiNamespace setVariable ["OpsRoom_SelectedRegiment", _regimentId];

// Create dialog
createDialog "OpsRoom_RosterGridDialog";
waitUntil {!isNull findDisplay 8002};

private _display = findDisplay 8002;

// Update title
private _titleCtrl = _display displayCtrl 8010;
if (!isNull _titleCtrl) then {
    private _groupName = _groupData get "name";
    _titleCtrl ctrlSetText format ["UNIT ROSTER - %1", _groupName];
};

// Setup back button
private _backBtn = _display displayCtrl 8011;
if (!isNull _backBtn) then {
    _backBtn ctrlAddEventHandler ["ButtonClick", {
        [] spawn {
            closeDialog 0;
            sleep 0.1;
            private _regimentId = uiNamespace getVariable ["OpsRoom_SelectedRegiment", ""];
            if (_regimentId != "") then {
                [_regimentId] call OpsRoom_fnc_openGroups;
            };
        };
    }];
};

// Add DEBUG button in title bar (right of BACK, left of X)
private _debugBtn = _display ctrlCreate ["RscButton", 8015];
_debugBtn ctrlSetPosition [
    0.67 * safezoneW + safezoneX,
    0.155 * safezoneH + safezoneY,
    0.055 * safezoneW,
    0.03 * safezoneH
];
_debugBtn ctrlSetText "DEBUG";
_debugBtn ctrlSetTextColor [0.95, 0.85, 0.65, 1];
_debugBtn ctrlSetBackgroundColor [0.40, 0.18, 0.12, 0.9];
_debugBtn ctrlSetFont "PuristaBold";
_debugBtn ctrlSetFontHeight 0.024;
_debugBtn ctrlSetTooltip "Open debug/testing panel for selected unit";
_debugBtn ctrlCommit 0;
_debugBtn setVariable ["groupId", _groupId];
_debugBtn ctrlAddEventHandler ["ButtonClick", {
    params ["_ctrl"];
    private _gId = _ctrl getVariable ["groupId", ""];
    closeDialog 0;
    [] spawn {
        sleep 0.1;
        // Open debug panel — it will auto-detect from dossier or Zeus selection
        [] call OpsRoom_fnc_debugServiceRecord;
    };
}];
_debugBtn ctrlAddEventHandler ["MouseEnter", { (_this select 0) ctrlSetBackgroundColor [0.55, 0.25, 0.18, 1.0] }];
_debugBtn ctrlAddEventHandler ["MouseExit", { (_this select 0) ctrlSetBackgroundColor [0.40, 0.18, 0.12, 0.9] }];

// Populate roster grid
[_groupId] call OpsRoom_fnc_populateRosterGrid;

diag_log format ["[OpsRoom] Roster grid opened for: %1", _groupId];
