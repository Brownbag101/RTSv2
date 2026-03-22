/*
    Show Recruit Details
    
    Displays selected recruit's detailed information in the detail panel.
    
    Parameters:
        0: NUMBER - Index in listbox
    
    Usage:
        [0] call OpsRoom_fnc_showRecruitDetails;
*/

params [
    ["_index", -1, [0]]
];

private _display = findDisplay 8004;
if (isNull _display) exitWith {};

if (_index < 0 || _index >= count OpsRoom_RecruitPool) exitWith {
    diag_log format ["[OpsRoom] Invalid recruit index: %1", _index];
};

private _recruit = OpsRoom_RecruitPool select _index;
private _detailCtrl = _display displayCtrl 8422;
if (isNull _detailCtrl) exitWith {};

// Build detail text
private _name = _recruit get "name";
private _quality = _recruit get "quality";
private _skills = _recruit get "skills";

private _text = format ["<t size='1.3' color='#D9D5C9' font='PuristaBold'>%1</t><br/><br/>", _name];

// Quality indicator
_text = _text + format ["<t size='1.0' color='%1'>%2</t><br/><br/>", 
    if (_quality == "good") then {"#FFD700"} else {"#AAAAAA"},
    if (_quality == "good") then {"★ EXPERIENCED RECRUIT ★"} else {"STANDARD RECRUIT"}
];

_text = _text + "<t size='0.95' color='#D9D5C9'>SKILLS</t><br/>";

// Display skills
private _skillLabels = [
    ["aimingAccuracy", "Aim Accuracy"],
    ["aimingShake", "Aim Steadiness"],
    ["aimingSpeed", "Aim Speed"],
    ["spotDistance", "Spot Distance"],
    ["spotTime", "Spot Speed"],
    ["courage", "Courage"],
    ["reloadSpeed", "Reload Speed"],
    ["commanding", "Command"],
    ["general", "General"]
];

{
    _x params ["_key", "_label"];
    private _value = _skills get _key;
    private _displayValue = round (_value * 10);
    
    // Color coding
    private _color = "#FF8800";  // Low (1-4)
    if (_displayValue >= 7) then {_color = "#00FF00"};  // High (7-10)
    if (_displayValue >= 5 && _displayValue < 7) then {_color = "#FFFF00"};  // Medium (5-6)
    
    _text = _text + format ["<t size='0.85' color='#AAAAAA'>%1: </t><t size='0.85' color='%2'>%3</t><br/>",
        _label,
        _color,
        _displayValue
    ];
} forEach _skillLabels;

_detailCtrl ctrlSetStructuredText parseText _text;

diag_log format ["[OpsRoom] Showing details for: %1", _name];
