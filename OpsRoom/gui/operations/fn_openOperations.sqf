/*
    fn_openOperations
    
    Opens the Operations Room dashboard.
    Shows all current operations and a button to create new ones.
*/

createDialog "OpsRoom_OperationsDialog";
waitUntil {!isNull findDisplay 8011};

private _display = findDisplay 8011;

// Setup Create Operation button
private _createBtn = _display displayCtrl 11600;
if (!isNull _createBtn) then {
    _createBtn ctrlAddEventHandler ["ButtonClick", {
        [] spawn {
            closeDialog 0;
            sleep 0.1;
            [] call OpsRoom_fnc_openOperationWizard;
        };
    }];
};

// Set overall objective
private _objCtrl = _display displayCtrl 11602;
if (!isNull _objCtrl) then {
    _objCtrl ctrlSetStructuredText parseText "<t align='center' font='PuristaBold' color='#FFD700'>OVERALL OBJECTIVE: Liberate the Island of Malden</t>";
};

// Populate operation list
[] call OpsRoom_fnc_populateOperations;
