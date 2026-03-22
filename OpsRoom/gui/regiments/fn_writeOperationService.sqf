/*
    Write Operation to Unit Service Records
    
    Called when an operation status changes (complete/failed).
    Records participation, dispatches, and triggers medal checks
    for ALL units in the assigned regiments.
    
    Parameters:
        0: STRING - Operation ID
        1: STRING - New status ("complete" or "failed")
    
    Usage:
        [_opId, "complete"] call OpsRoom_fnc_writeOperationService;
*/

params [
    ["_opId", "", [""]],
    ["_status", "", [""]]
];

if (_opId == "" || _status == "") exitWith {};

private _opData = OpsRoom_Operations getOrDefault [_opId, createHashMap];
if (count _opData == 0) exitWith {};

private _opName = _opData get "name";
private _regiments = _opData get "regiments";

// Dispatch phrases for variety
private _dispatchPhrases = [
    "Fought bravely in",
    "Took an active role in",
    "Served with distinction during",
    "Participated in",
    "Showed courage during",
    "Held the line during",
    "Advanced under fire during",
    "Demonstrated resolve in"
];

private _completePhrases = [
    "Helped secure victory in",
    "Instrumental in the success of",
    "Contributed to the completion of"
];

private _failPhrases = [
    "Survived the ill-fated",
    "Withdrew under fire from",
    "Endured the defeat at"
];

// Get all units from assigned regiments
private _affectedUnits = [];
{
    private _regId = _x;
    private _regData = OpsRoom_Regiments getOrDefault [_regId, createHashMap];
    if (count _regData > 0) then {
        private _groups = _regData getOrDefault ["groups", []];
        {
            private _groupData = OpsRoom_Groups getOrDefault [_x, createHashMap];
            if (count _groupData > 0) then {
                private _units = _groupData getOrDefault ["units", []];
                {
                    if (!isNull _x && alive _x) then {
                        _affectedUnits pushBack _x;
                    };
                } forEach _units;
            };
        } forEach _groups;
    };
} forEach _regiments;

// Write to each unit's service record
{
    private _unit = _x;
    private _record = [_unit] call OpsRoom_fnc_getServiceRecord;
    if (count _record == 0) then { continue };
    
    // Add to operations fought
    private _opsFought = _record getOrDefault ["operationsFought", []];
    if !(_opId in _opsFought) then {
        _opsFought pushBack _opId;
        _record set ["operationsFought", _opsFought];
    };
    
    // Add to completed/failed list
    if (_status == "complete") then {
        private _opsCompleted = _record getOrDefault ["operationsCompleted", []];
        _opsCompleted pushBack _opId;
        _record set ["operationsCompleted", _opsCompleted];
    } else {
        private _opsFailed = _record getOrDefault ["operationsFailed", []];
        _opsFailed pushBack _opId;
        _record set ["operationsFailed", _opsFailed];
    };
    
    // Clear current operation
    _record set ["currentOperation", ""];
    
    // Generate dispatch
    private _phrase = if (_status == "complete") then {
        selectRandom _completePhrases
    } else {
        selectRandom _failPhrases
    };
    
    private _dispatches = _record getOrDefault ["dispatches", []];
    _dispatches pushBack [time, format ["%1 Operation ""%2""", _phrase, _opName], _status];
    _record set ["dispatches", _dispatches];
    
    // Check for new medals
    [_unit] call OpsRoom_fnc_checkMedals;
    
    diag_log format ["[OpsRoom Service] %1: %2 Operation %3", name _unit, _status, _opName];
} forEach _affectedUnits;

systemChat format ["[SERVICE RECORDS] %1 personnel records updated for Operation %2", count _affectedUnits, _opName];
