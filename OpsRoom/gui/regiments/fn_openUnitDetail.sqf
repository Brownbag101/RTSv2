/*
    Open Unit Detail Dialog
    
    Shows detailed information about a specific unit with action buttons.
    
    Parameters:
        0: OBJECT - Unit to display
    
    Usage:
        [unitObject] call OpsRoom_fnc_openUnitDetail;
*/

params [
    ["_unit", objNull, [objNull]]
];

if (isNull _unit) exitWith {
    hint "Error: No unit provided";
};

// Store unit in uiNamespace for actions
uiNamespace setVariable ["OpsRoom_SelectedUnit", _unit];

// Create dialog
createDialog "OpsRoom_UnitDetailDialog";
waitUntil {!isNull findDisplay 8003};

private _display = findDisplay 8003;

// Populate unit information
[_unit] call OpsRoom_fnc_populateUnitDetail;

// Setup Promote button
private _promoteBtn = _display displayCtrl 8030;
if (!isNull _promoteBtn) then {
    _promoteBtn ctrlAddEventHandler ["ButtonClick", {
        private _unit = uiNamespace getVariable ["OpsRoom_SelectedUnit", objNull];
        if (!isNull _unit) then {
            [_unit] call OpsRoom_fnc_promoteUnit;
            [_unit] call OpsRoom_fnc_populateUnitDetail;  // Refresh display
        };
    }];
};

// Setup Training button
private _trainingBtn = _display displayCtrl 8032;
if (!isNull _trainingBtn) then {
    _trainingBtn ctrlAddEventHandler ["ButtonClick", {
        private _unit = uiNamespace getVariable ["OpsRoom_SelectedUnit", objNull];
        if (!isNull _unit) then {
            closeDialog 0;
            [_unit] call OpsRoom_fnc_openTraining;
        };
    }];
};

// Setup Back button
private _backBtn = _display displayCtrl 8011;
if (!isNull _backBtn) then {
    _backBtn ctrlAddEventHandler ["ButtonClick", {
        [] spawn {
            closeDialog 0;
            sleep 0.1;
            private _groupId = uiNamespace getVariable ["OpsRoom_SelectedGroup", ""];
            if (_groupId != "") then {
                [_groupId] call OpsRoom_fnc_openRosterGrid;
            };
        };
    }];
};

diag_log format ["[OpsRoom] Unit detail opened for: %1", name _unit];
