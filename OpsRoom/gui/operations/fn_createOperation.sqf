/*
    fn_createOperation
    
    Creates a new operation from the wizard state.
    Stores it in OpsRoom_Operations hashmap.
*/

private _name = OpsRoom_WizardState get "name";
private _targetId = OpsRoom_WizardState get "targetId";
private _targetName = OpsRoom_WizardState get "targetName";
private _targetType = OpsRoom_WizardState get "targetType";
private _taskType = OpsRoom_WizardState get "taskType";
private _regiments = OpsRoom_WizardState get "regiments";
private _regimentNames = OpsRoom_WizardState get "regimentNames";

// Generate operation ID
private _opId = format ["op_%1", OpsRoom_OperationNextID];
OpsRoom_OperationNextID = OpsRoom_OperationNextID + 1;

// Create operation data
private _opData = createHashMapFromArray [
    ["id", _opId],
    ["name", _name],
    ["targetId", _targetId],
    ["targetName", _targetName],
    ["targetType", _targetType],
    ["taskType", _taskType],
    ["regiments", _regiments],
    ["regimentNames", _regimentNames],
    ["status", "active"],
    ["progress", 0],
    ["created", time],
    ["notes", ""]
];

// Store it
OpsRoom_Operations set [_opId, _opData];

// Get target position for focus button
private _targetPos = [];
if (_targetId != "") then {
    private _locData = OpsRoom_StrategicLocations getOrDefault [_targetId, createHashMap];
    if (count _locData > 0) then {
        _targetPos = _locData get "pos";
    };
};

// Close the wizard/operations dialog so dispatch popup is clickable
closeDialog 0;

["PRIORITY", "OPERATION CREATED", format ["Op %1: %2 %3. Assigned: %4", _name, toUpper _taskType, _targetName, _regimentNames joinString ", "], _targetPos] call OpsRoom_fnc_dispatch;

// Set current operation on all units in assigned regiments
{
    private _regId = _x;
    private _regData = OpsRoom_Regiments getOrDefault [_regId, createHashMap];
    if (count _regData > 0) then {
        private _groups = _regData getOrDefault ["groups", []];
        {
            private _groupData = OpsRoom_Groups getOrDefault [_x, createHashMap];
            if (count _groupData > 0) then {
                {
                    if (!isNull _x && alive _x) then {
                        private _record = [_x] call OpsRoom_fnc_getServiceRecord;
                        _record set ["currentOperation", _opId];
                    };
                } forEach (_groupData getOrDefault ["units", []]);
            };
        } forEach _groups;
    };
} forEach _regiments;

// Clean up wizard state
OpsRoom_WizardState = nil;
