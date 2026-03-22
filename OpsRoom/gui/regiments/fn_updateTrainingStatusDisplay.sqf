/*
    Update Training Status Display
    
    Updates the "Units in Training" display at bottom of training dialog.
    
    Usage:
        [] call OpsRoom_fnc_updateTrainingStatusDisplay;
*/

private _display = findDisplay 8006;
if (isNull _display) exitWith {};

private _statusText = "";

if (count OpsRoom_UnitsInTraining == 0) then {
    _statusText = "<t color='#B8B5A9'>No units currently in training</t>";
} else {
    {
        _x params ["_unit", "_courseId", "_startTime", "_duration", "_skills", "_quals"];
        
        // Find course name
        private _courseName = "";
        {
            _x params ["_id", "_name"];
            if (_id == _courseId) exitWith { _courseName = _name; };
        } forEach OpsRoom_TrainingCourses;
        
        // Calculate remaining time
        private _elapsed = (time - _startTime) / 60;  // Convert to minutes
        private _remaining = (_duration - _elapsed) max 0;
        
        _statusText = _statusText + format ["<t color='#D9D5C9'>%1</t> - <t color='#B8B5A9'>%2</t> (<t color='#7FFF7F'>%3m remaining</t>)<br/>", 
            name _unit, 
            _courseName,
            round _remaining
        ];
    } forEach OpsRoom_UnitsInTraining;
};

private _queueCtrl = _display displayCtrl 8660;
_queueCtrl ctrlSetStructuredText parseText _statusText;
