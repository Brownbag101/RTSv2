/*
    Populate Unit Detail Display
    
    Fills the unit detail dialog with comprehensive unit information.
    
    Parameters:
        0: OBJECT - Unit to display
    
    Usage:
        [unitObject] call OpsRoom_fnc_populateUnitDetail;
*/

params [
    ["_unit", objNull, [objNull]]
];

private _display = findDisplay 8003;
if (isNull _display) exitWith {
    diag_log "[OpsRoom] ERROR: Cannot populate unit detail - dialog not found";
};

if (isNull _unit) exitWith {
    diag_log "[OpsRoom] ERROR: No unit provided";
};

private _infoCtrl = _display displayCtrl 8020;
if (isNull _infoCtrl) exitWith {
    diag_log "[OpsRoom] ERROR: Info control not found";
};

// Get unit information
private _name = name _unit;
private _rank = rank _unit;
private _rankId = rankId _unit;
private _roleDescription = roleDescription _unit;
if (_roleDescription == "") then {
    _roleDescription = getText (configFile >> "CfgVehicles" >> typeOf _unit >> "displayName");
};

// Calculate time in theatre
private _timeAlive = time - (missionNamespace getVariable [format ["OpsRoom_Unit_%1_SpawnTime", _unit], time]);
private _days = floor (_timeAlive / 86400);
private _hours = floor ((_timeAlive mod 86400) / 3600);
private _timeString = format ["%1d %2h", _days, _hours];

// Get health status
private _damage = damage _unit;
private _healthPercent = round ((1 - _damage) * 100);
private _healthColor = "#00FF00";
if (_healthPercent < 75) then {_healthColor = "#FFFF00"};
if (_healthPercent < 50) then {_healthColor = "#FF8800"};
if (_healthPercent < 25) then {_healthColor = "#FF0000"};
if (!alive _unit) then {
    _healthColor = "#666666";
    _healthPercent = 0;
};

// Status
private _status = "ACTIVE";
private _statusColor = "#00FF00";
if (!alive _unit) then {
    _status = "KIA";
    _statusColor = "#FF0000";
} else {
    if (_unit getVariable ["ACE_isUnconscious", false]) then {
        _status = "UNCONSCIOUS";
        _statusColor = "#FF8800";
    };
};

// Get kills (if tracked)
private _kills = _unit getVariable ["OpsRoom_Kills", 0];

// Build detail text
private _detailText = "";

_detailText = _detailText + format [
    "<t size='1.5' color='#D9D5C9' font='PuristaBold'>%1</t><br/><br/>",
    _name
];

_detailText = _detailText + format [
    "<t size='1.0' color='#AAAAAA'>Rank: </t><t size='1.0' color='#D9D5C9'>%1</t><br/>",
    _rank
];

_detailText = _detailText + format [
    "<t size='0.9' color='#AAAAAA'>Role: </t><t size='0.9' color='#D9D5C9'>%1</t><br/><br/>",
    _roleDescription
];

_detailText = _detailText + format [
    "<t size='0.9' color='#AAAAAA'>Time in Theatre: </t><t size='0.9' color='#D9D5C9'>%1</t><br/>",
    _timeString
];

_detailText = _detailText + format [
    "<t size='0.9' color='#AAAAAA'>Health: </t><t size='0.9' color='%1'>%2%%</t><br/>",
    _healthColor,
    _healthPercent
];

_detailText = _detailText + format [
    "<t size='0.9' color='#AAAAAA'>Status: </t><t size='0.9' color='%1'>%2</t><br/><br/>",
    _statusColor,
    _status
];

_detailText = _detailText + format [
    "<t size='0.9' color='#AAAAAA'>Confirmed Kills: </t><t size='0.9' color='#D9D5C9'>%1</t><br/>",
    _kills
];

// Get unit skills
_detailText = _detailText + "<br/><t size='1.0' color='#D9D5C9'>SKILLS</t><br/>";

private _skillArray = [
    ["Aim Accuracy", _unit skill "aimingAccuracy"],
    ["Aim Steadiness", _unit skill "aimingShake"],
    ["Aim Speed", _unit skill "aimingSpeed"],
    ["Spot Distance", _unit skill "spotDistance"],
    ["Spot Speed", _unit skill "spotTime"],
    ["Courage", _unit skill "courage"],
    ["Reload Speed", _unit skill "reloadSpeed"],
    ["Command", _unit skill "commanding"],
    ["General", _unit skill "general"]
];

{
    _x params ["_skillName", "_skillValue"];
    private _skillLevel = round (_skillValue * 10);
    private _skillColor = "#888888";
    if (_skillLevel >= 7) then {_skillColor = "#00FF00"};
    if (_skillLevel >= 5 && _skillLevel < 7) then {_skillColor = "#FFFF00"};
    if (_skillLevel < 5) then {_skillColor = "#FF8800"};
    
    _detailText = _detailText + format [
        "<t size='0.85' color='#AAAAAA'>%1: </t><t size='0.85' color='%2'>%3</t><br/>",
        _skillName,
        _skillColor,
        _skillLevel
    ];
} forEach _skillArray;

// Set the detail text
_infoCtrl ctrlSetStructuredText parseText _detailText;

diag_log format ["[OpsRoom] Populated unit detail for: %1", _name];
