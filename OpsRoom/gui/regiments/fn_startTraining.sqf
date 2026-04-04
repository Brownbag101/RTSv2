/*
    Start Training
    
    Begins training for the selected unit with the selected course.
    Enforces prerequisites, courage gates, and research requirements.
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
    if ((_x select 0) == _courseId) exitWith { _courseData = _x; };
} forEach OpsRoom_TrainingCourses;

if (count _courseData == 0) exitWith { hint "Course not found"; };

private _id = _courseData select 0;
private _name = _courseData select 1;
private _desc = _courseData select 2;
private _duration = _courseData select 3;
private _skills = _courseData select 4;
private _quals = _courseData select 5;
private _prereqQuals = if (count _courseData > 6) then { _courseData select 6 } else { [] };
private _minCourage = if (count _courseData > 7) then { _courseData select 7 } else { 0 };
private _reqResearch = if (count _courseData > 8) then { _courseData select 8 } else { "" };

// ========================================
// ENFORCE PREREQUISITES
// ========================================

private _unitQuals = _unit getVariable ["OpsRoom_Qualifications", []];
private _unitCourage = _unit skill "courage";

// Check research requirement
if (_reqResearch != "") then {
    if !([_reqResearch] call OpsRoom_fnc_isResearched) exitWith {
        hint "This course requires research that has not been completed.";
    };
};

// Check prerequisite qualifications (OR logic)
if (count _prereqQuals > 0) then {
    private _prereqMet = false;
    {
        if (_x in _unitQuals) exitWith { _prereqMet = true };
    } forEach _prereqQuals;
    
    if (!_prereqMet) exitWith {
        private _prereqNames = _prereqQuals apply {
            switch (_x) do {
                case "commando": { "Commando" };
                case "paratrooper": { "Paratrooper" };
                case "soe": { "SOE Agent" };
                case "sas": { "SAS Operative" };
                default { _x };
            };
        };
        hint format ["This course requires one of the following qualifications: %1", _prereqNames joinString ", "];
    };
};

// Check courage gate
if (_minCourage > 0) then {
    if (_unitCourage < _minCourage) exitWith {
        hint format ["This unit's courage (%.1f) is below the minimum required (%.1f).", _unitCourage, _minCourage];
    };
};

// ========================================
// BEGIN TRAINING
// ========================================

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
