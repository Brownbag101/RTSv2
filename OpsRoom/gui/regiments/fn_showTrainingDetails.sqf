/*
    Show Training Details
    
    Displays course information in the details panel.
    
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
    _x params ["_id"];
    if (_id == _courseId) exitWith { _courseData = _x; };
} forEach OpsRoom_TrainingCourses;

if (count _courseData == 0) exitWith {};

_courseData params ["_id", "_name", "_desc", "_duration", "_skills", "_quals"];

// Build details text
private _text = format ["<t size='1.2' font='PuristaBold' color='#D9D5C9'>%1</t><br/>", _name];
_text = _text + "<br/>";
_text = _text + format ["<t color='#B8B5A9'>Duration:</t> <t color='#D9D5C9'>%1 minutes</t><br/>", _duration];
_text = _text + "<br/>";
_text = _text + format ["<t color='#D9D5C9'>%1</t><br/>", _desc];
_text = _text + "<br/>";
_text = _text + "<t color='#B8B5A9'>Skill Improvements:</t><br/>";

// Add skill bonuses
{
    _x params ["_skillName", "_bonus"];
    
    // Format skill name nicely
    private _displayName = _skillName;
    switch (_skillName) do {
        case "aimingAccuracy": { _displayName = "Aiming Accuracy"; };
        case "aimingShake": { _displayName = "Aiming Shake"; };
        case "aimingSpeed": { _displayName = "Aiming Speed"; };
        case "spotDistance": { _displayName = "Spot Distance"; };
        case "spotTime": { _displayName = "Spot Time"; };
        case "courage": { _displayName = "Courage"; };
        case "reloadSpeed": { _displayName = "Reload Speed"; };
        case "commanding": { _displayName = "Commanding"; };
        case "general": { _displayName = "General"; };
    };
    
    _text = _text + format ["  • %1: <t color='#7FFF7F'>+%2</t><br/>", _displayName, _bonus];
} forEach _skills;

// Add qualifications and abilities
if (count _quals > 0) then {
    _text = _text + "<br/>";
    
    // Separate qualifications from abilities
    private _actualQuals = [];
    private _abilities = [];
    
    {
        if (_x in ["suppressiveFire", "repair", "heal"]) then {
            _abilities pushBack _x;
        } else {
            _actualQuals pushBack _x;
        };
    } forEach _quals;
    
    // Show qualifications
    if (count _actualQuals > 0) then {
        _text = _text + "<t color='#B8B5A9'>Qualifications Earned:</t><br/>";
        {
            private _qualName = switch (_x) do {
                case "medic": { "Combat Medic" };
                case "engineer": { "Combat Engineer" };
                default { _x };
            };
            _text = _text + format ["  • <t color='#FFD700'>%1</t><br/>", _qualName];
        } forEach _actualQuals;
    };
    
    // Show abilities
    if (count _abilities > 0) then {
        if (count _actualQuals > 0) then { _text = _text + "<br/>"; };
        _text = _text + "<t color='#B8B5A9'>Abilities Granted:</t><br/>";
        {
            private _abilityName = switch (_x) do {
                case "suppressiveFire": { "Suppressive Fire" };
                case "repair": { "Vehicle Repair" };
                case "heal": { "Medical Treatment" };
                default { _x };
            };
            _text = _text + format ["  • <t color='#7FFF7F'>%1</t><br/>", _abilityName];
        } forEach _abilities;
    };
};

// Update details display
private _detailsCtrl = _display displayCtrl 8620;
_detailsCtrl ctrlSetStructuredText parseText _text;

diag_log format ["[OpsRoom] Showing details for course: %1", _name];
