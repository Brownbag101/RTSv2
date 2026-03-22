/*
    Start Training
    
    Begins training for the selected unit with the selected course.
    Hides unit from Zeus, makes invulnerable, sets timer.
    
    Usage:
        [] call OpsRoom_fnc_startTraining;
*/

private _display = findDisplay 8006;
if (isNull _display) exitWith {};

private _unit = uiNamespace getVariable ["OpsRoom_TrainingUnit", objNull];
if (isNull _unit) exitWith { hint "No unit selected"; };

// Get selected course
private _listbox = _display displayCtrl 8610;
private _index = lbCurSel _listbox;
if (_index < 0) exitWith { hint "No course selected"; };

private _courseId = _listbox lbData _index;

// Find course data
private _courseData = [];
{
    _x params ["_id"];
    if (_id == _courseId) exitWith { _courseData = _x; };
} forEach OpsRoom_TrainingCourses;

if (count _courseData == 0) exitWith { hint "Course not found"; };

_courseData params ["_id", "_name", "_desc", "_duration", "_skills", "_quals"];

// Store original position
_unit setVariable ["OpsRoom_Training_OriginalPos", getPosATL _unit];
_unit setVariable ["OpsRoom_Training_OriginalGroup", group _unit];

// Hide unit from Zeus
private _curator = getAssignedCuratorLogic player;
if (!isNull _curator) then {
    _curator removeCuratorEditableObjects [[_unit], true];
};

// Make unit invulnerable and invisible
_unit allowDamage false;
_unit hideObjectGlobal true;
_unit enableSimulationGlobal false;

// Add to training array
private _startTime = time;
private _trainingEntry = [_unit, _courseId, _startTime, _duration, _skills, _quals];
OpsRoom_UnitsInTraining pushBack _trainingEntry;

// Feedback
systemChat format ["[TRAINING] %1 has begun %2 (Duration: %3 minutes)", name _unit, _name, _duration];
diag_log format ["[OpsRoom] Training started: %1 -> %2 (%3 min)", name _unit, _name, _duration];

// Close dialog
closeDialog 0;

// Return to dossier
[_unit] spawn {
    params ["_unit"];
    sleep 0.1;
    private _groupId = missionNamespace getVariable ["OpsRoom_DossierGroupId", ""];
    [_unit, _groupId] call OpsRoom_fnc_openUnitDossier;
};
