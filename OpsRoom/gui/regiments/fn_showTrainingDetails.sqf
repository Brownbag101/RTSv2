/*
    Show Training Details
    
    Displays course information in the details panel.
    Shows prerequisites, courage requirements, and research gates.
    
    Parameters:
        0: NUMBER - Selected index in listbox
    
    Usage:
        [0] call OpsRoom_fnc_showTrainingDetails;
*/

params [
    ["_index", -1, [0]]
];

private _display = findDisplay 8006;
if (isNull _display) exitWith {};

if (_index < 0) exitWith {};

private _listbox = _display displayCtrl 8610;
private _courseId = _listbox lbData _index;

// Find course data
private _courseData = [];
{
    if ((_x select 0) == _courseId) exitWith { _courseData = _x; };
} forEach OpsRoom_TrainingCourses;

if (count _courseData == 0) exitWith {};

private _id = _courseData select 0;
private _name = _courseData select 1;
private _desc = _courseData select 2;
private _duration = _courseData select 3;
private _skills = _courseData select 4;
private _quals = _courseData select 5;
private _prereqQuals = if (count _courseData > 6) then { _courseData select 6 } else { [] };
private _minCourage = if (count _courseData > 7) then { _courseData select 7 } else { 0 };
private _reqResearch = if (count _courseData > 8) then { _courseData select 8 } else { "" };

// Get unit info for prereq checks
private _unit = uiNamespace getVariable ["OpsRoom_TrainingUnit", objNull];
private _unitQuals = [];
private _unitCourage = 0;
if (!isNull _unit) then {
    _unitQuals = _unit getVariable ["OpsRoom_Qualifications", []];
    _unitCourage = _unit skill "courage";
};

// Build details text
private _text = format ["<t size='1.2' font='PuristaBold' color='#D9D5C9'>%1</t><br/>", _name];
_text = _text + "<br/>";
_text = _text + format ["<t color='#B8B5A9'>Duration:</t> <t color='#D9D5C9'>%1 minutes</t><br/>", _duration];
_text = _text + "<br/>";
_text = _text + format ["<t color='#D9D5C9'>%1</t><br/>", _desc];
_text = _text + "<br/>";

// Show prerequisites section
private _hasPrereqs = (count _prereqQuals > 0) || (_minCourage > 0) || (_reqResearch != "");
if (_hasPrereqs) then {
    _text = _text + "<t color='#B8B5A9' font='PuristaBold'>Requirements:</t><br/>";
    
    // Research requirement
    if (_reqResearch != "") then {
        private _researchMet = [_reqResearch] call OpsRoom_fnc_isResearched;
        private _researchColor = if (_researchMet) then { "#80FF80" } else { "#FF6666" };
        private _researchIcon = if (_researchMet) then { "MET" } else { "NOT MET" };
        private _researchName = _reqResearch;
        private _resData = OpsRoom_EquipmentDB getOrDefault [_reqResearch, createHashMap];
        if (count _resData > 0) then {
            _researchName = _resData getOrDefault ["displayName", _reqResearch];
        };
        _text = _text + format ["  Research: <t color='%1'>%2 [%3]</t><br/>", _researchColor, _researchName, _researchIcon];
    };
    
    // Qualification prerequisites
    if (count _prereqQuals > 0) then {
        private _prereqMet = false;
        {
            if (_x in _unitQuals) exitWith { _prereqMet = true };
        } forEach _prereqQuals;
        
        private _prereqColor = if (_prereqMet) then { "#80FF80" } else { "#FF6666" };
        private _prereqIcon = if (_prereqMet) then { "MET" } else { "NOT MET" };
        
        private _prereqNames = _prereqQuals apply {
            switch (_x) do {
                case "commando": { "Commando" };
                case "paratrooper": { "Paratrooper" };
                case "soe": { "SOE Agent" };
                case "sas": { "SAS Operative" };
                default { _x };
            };
        };
        
        _text = _text + format ["  Qualification: <t color='%1'>%2 [%3]</t><br/>", _prereqColor, _prereqNames joinString " or ", _prereqIcon];
    };
    
    // Courage requirement
    if (_minCourage > 0) then {
        private _courageMet = _unitCourage >= _minCourage;
        private _courageColor = if (_courageMet) then { "#80FF80" } else { "#FF6666" };
        private _courageIcon = if (_courageMet) then { "MET" } else { "NOT MET" };
        _text = _text + format ["  Courage: <t color='%1'>%.1f required (unit: %.1f) [%2]</t><br/>", _courageColor, _minCourage, _courageIcon, _unitCourage];
    };
    
    _text = _text + "<br/>";
};

// Skill bonuses
_text = _text + "<t color='#B8B5A9'>Skill Improvements:</t><br/>";
{
    _x params ["_skillName", "_bonus"];
    
    private _displayName = switch (_skillName) do {
        case "aimingAccuracy": { "Aiming Accuracy" };
        case "aimingShake": { "Aiming Shake" };
        case "aimingSpeed": { "Aiming Speed" };
        case "spotDistance": { "Spot Distance" };
        case "spotTime": { "Spot Time" };
        case "courage": { "Courage" };
        case "reloadSpeed": { "Reload Speed" };
        case "commanding": { "Commanding" };
        case "general": { "General" };
        default { _skillName };
    };
    
    _text = _text + format ["  %1: <t color='#7FFF7F'>+%2</t><br/>", _displayName, _bonus];
} forEach _skills;

// Qualifications and abilities
if (count _quals > 0) then {
    _text = _text + "<br/>";
    
    private _actualQuals = [];
    private _abilities = [];
    
    {
        if (_x in ["suppressiveFire", "repair", "heal", "marksmanShot", "timebomb", "reconnoitre", "infiltrate", "assassinate", "airStrike", "build"]) then {
            _abilities pushBack _x;
        } else {
            _actualQuals pushBack _x;
        };
    } forEach _quals;
    
    if (count _actualQuals > 0) then {
        _text = _text + "<t color='#B8B5A9'>Qualifications Earned:</t><br/>";
        {
            private _qualName = switch (_x) do {
                case "medic": { "Combat Medic" };
                case "engineer": { "Combat Engineer" };
                case "commando": { "Commando" };
                case "paratrooper": { "Paratrooper" };
                case "soe": { "SOE Agent" };
                case "sas": { "SAS Operative" };
                case "pilot": { "RAF Pilot" };
                case "airCrew": { "Air Gunner" };
                default { _x };
            };
            _text = _text + format ["  <t color='#FFD700'>%1</t><br/>", _qualName];
        } forEach _actualQuals;
    };
    
    if (count _abilities > 0) then {
        if (count _actualQuals > 0) then { _text = _text + "<br/>"; };
        _text = _text + "<t color='#B8B5A9'>Abilities Granted:</t><br/>";
        {
            private _abilityName = switch (_x) do {
                case "suppressiveFire": { "Suppressive Fire" };
                case "repair": { "Vehicle Repair" };
                case "heal": { "Medical Treatment" };
                case "marksmanShot": { "Aimed Shot" };
                case "timebomb": { "Timebomb" };
                case "reconnoitre": { "Reconnoitre" };
                case "infiltrate": { "Infiltrate" };
                case "assassinate": { "Assassinate" };
                case "airStrike": { "Air Strike" };
                case "build": { "Build" };
                default { _x };
            };
            _text = _text + format ["  <t color='#7FFF7F'>%1</t><br/>", _abilityName];
        } forEach _abilities;
    };
};

// Update details display
private _detailsCtrl = _display displayCtrl 8620;
_detailsCtrl ctrlSetStructuredText parseText _text;

diag_log format ["[OpsRoom] Showing details for course: %1", _name];
