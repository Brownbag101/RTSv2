/*
    Operations Room - Update Date/Time Display
    
    Updates the date and time display every second.
    Formats real game date and time.
*/

private _ctrl = uiNamespace getVariable ["OpsRoom_DateTime_Ctrl", controlNull];
if (isNull _ctrl) exitWith {};

// Get current game date [year, month, day, hour, minute]
private _date = date;
private _year = _date select 0;
private _month = _date select 1;
private _day = _date select 2;
private _hour = _date select 3;
private _minute = _date select 4;

// Get seconds from dayTime
private _dayTime = dayTime;
private _second = floor ((_dayTime * 3600) % 60);

// Month names
private _monthNames = [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
];
private _monthName = _monthNames select (_month - 1);

// Format time with leading zeros
private _hourStr = if (_hour < 10) then {format ["0%1", _hour]} else {str _hour};
private _minStr = if (_minute < 10) then {format ["0%1", _minute]} else {str _minute};
private _secStr = if (_second < 10) then {format ["0%1", _second]} else {str _second};

// Create display text
private _text = format [
    "<t color='#D4C5A0' size='0.9'>%1 %2 %3 | %4:%5:%6</t>",
    _day, _monthName, _year, _hourStr, _minStr, _secStr
];

_ctrl ctrlSetStructuredText parseText _text;
