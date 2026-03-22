/*
    Populate Training List
    
    Fills the training courses listbox with all available courses.
    
    Usage:
        [] call OpsRoom_fnc_populateTrainingList;
*/

private _display = findDisplay 8006;
if (isNull _display) exitWith {};

private _listbox = _display displayCtrl 8610;
lbClear _listbox;

// Add all training courses
{
    _x params ["_id", "_name", "_desc", "_duration", "_skills", "_quals"];
    
    private _index = _listbox lbAdd _name;
    _listbox lbSetData [_index, _id];
    
} forEach OpsRoom_TrainingCourses;

diag_log format ["[OpsRoom] Training list populated: %1 courses", count OpsRoom_TrainingCourses];
