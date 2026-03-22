/*
    Open Training Dialog
    
    Opens training selection dialog for a specific unit.
    
    Parameters:
        0: OBJECT - Unit to train
    
    Usage:
        [_unit] call OpsRoom_fnc_openTraining;
*/

params [
    ["_unit", objNull, [objNull]]
];

if (isNull _unit) exitWith {
    hint "No unit provided";
};

// Check if unit is already in training
private _inTraining = false;
{
    _x params ["_trainee", "_courseId", "_startTime", "_duration"];
    if (_trainee == _unit) exitWith { _inTraining = true; };
} forEach OpsRoom_UnitsInTraining;

if (_inTraining) exitWith {
    hint "Unit is already in training!";
};

// Store unit reference
uiNamespace setVariable ["OpsRoom_TrainingUnit", _unit];

// Create dialog
createDialog "OpsRoom_TrainingDialog";

private _display = findDisplay 8006;
if (isNull _display) exitWith {};

// Set unit name
private _nameCtrl = _display displayCtrl 8602;
_nameCtrl ctrlSetText format ["Training for: %1", name _unit];

// Populate course list
[] call OpsRoom_fnc_populateTrainingList;

// Setup listbox event handler
private _listbox = _display displayCtrl 8610;
_listbox ctrlAddEventHandler ["LBSelChanged", {
    params ["_control", "_selectedIndex"];
    [_selectedIndex] call OpsRoom_fnc_showTrainingDetails;
}];

// Setup start button
private _startBtn = _display displayCtrl 8630;
_startBtn ctrlAddEventHandler ["ButtonClick", {
    [] call OpsRoom_fnc_startTraining;
}];

// Setup back button - returns to dossier
private _backBtn = _display displayCtrl 8601;
_backBtn ctrlAddEventHandler ["ButtonClick", {
    closeDialog 0;
    private _unit = uiNamespace getVariable ["OpsRoom_TrainingUnit", objNull];
    if (!isNull _unit) then {
        private _groupId = missionNamespace getVariable ["OpsRoom_DossierGroupId", ""];
        [_unit, _groupId] spawn OpsRoom_fnc_openUnitDossier;
    };
}];

// Update training status display
[] call OpsRoom_fnc_updateTrainingStatusDisplay;

// Select first course by default
_listbox lbSetCurSel 0;

diag_log format ["[OpsRoom] Training dialog opened for: %1", name _unit];
