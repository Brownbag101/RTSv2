/*
    Populate Unit Roster
    
    Fills the roster list with detailed unit information.
    Shows: Name, Rank, Role, Time Alive, Status
    
    Parameters:
        0: STRING - Group ID
    
    Usage:
        ["group_1"] call OpsRoom_fnc_populateRoster;
*/

params [
    ["_groupId", "", [""]]
];

private _display = findDisplay 8002;
if (isNull _display) exitWith {
    diag_log "[OpsRoom] ERROR: Cannot populate roster - dialog not found";
};

// Get group data
private _groupData = OpsRoom_Groups get _groupId;
if (isNil "_groupData") exitWith {
    diag_log "[OpsRoom] ERROR: Group not found";
};

private _units = _groupData get "units";
private _rosterCtrl = _display displayCtrl 8020;

if (isNull _rosterCtrl) exitWith {
    diag_log "[OpsRoom] ERROR: Roster control not found";
};

// Build roster text
private _rosterText = "";
private _lineHeight = 1.8;

// Header
_rosterText = _rosterText + format [
    "<t size='1.2' color='#D9D5C9' font='PuristaBold'>PERSONNEL ROSTER</t><br/><br/>"
];

// Check if group has units
if (count _units == 0) then {
    _rosterText = _rosterText + format [
        "<t color='#888888'>No personnel assigned to this group.</t>"
    ];
} else {
    // Unit entries
    private _index = 1;
    {
        private _unit = _x;
        
        if (!isNull _unit) then {
            // Get unit info
            private _name = name _unit;
            private _rank = rank _unit;
            private _roleDescription = roleDescription _unit;
            if (_roleDescription == "") then {
                _roleDescription = getText (configFile >> "CfgVehicles" >> typeOf _unit >> "displayName");
            };
            
            // Calculate time in theatre (time alive)
            private _timeAlive = time - (missionNamespace getVariable [format ["OpsRoom_Unit_%1_SpawnTime", _unit], time]);
            private _days = floor (_timeAlive / 86400);
            private _hours = floor ((_timeAlive mod 86400) / 3600);
            private _timeString = format ["%1d %2h", _days, _hours];
            
            // Get health status
            private _damage = damage _unit;
            private _healthPercent = round ((1 - _damage) * 100);
            private _healthColor = "#00FF00";  // Green
            if (_healthPercent < 75) then {_healthColor = "#FFFF00"};  // Yellow
            if (_healthPercent < 50) then {_healthColor = "#FF8800"};  // Orange
            if (_healthPercent < 25) then {_healthColor = "#FF0000"};  // Red
            if (!alive _unit) then {
                _healthColor = "#666666";  // Gray
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
            
            // Format unit entry
            _rosterText = _rosterText + format [
                "<t size='1.0' color='#D9D5C9' font='PuristaBold'>%1. %2</t><br/>",
                _index,
                _name
            ];
            
            _rosterText = _rosterText + format [
                "<t size='0.9' color='#AAAAAA'>   Rank: </t><t size='0.9' color='#D9D5C9'>%1</t><br/>",
                _rank
            ];
            
            _rosterText = _rosterText + format [
                "<t size='0.9' color='#AAAAAA'>   Role: </t><t size='0.9' color='#D9D5C9'>%1</t><br/>",
                _roleDescription
            ];
            
            _rosterText = _rosterText + format [
                "<t size='0.9' color='#AAAAAA'>   Time in Theatre: </t><t size='0.9' color='#D9D5C9'>%1</t><br/>",
                _timeString
            ];
            
            _rosterText = _rosterText + format [
                "<t size='0.9' color='#AAAAAA'>   Health: </t><t size='0.9' color='%1'>%2%%</t><br/>",
                _healthColor,
                _healthPercent
            ];
            
            _rosterText = _rosterText + format [
                "<t size='0.9' color='#AAAAAA'>   Status: </t><t size='0.9' color='%1'>%2</t><br/><br/>",
                _statusColor,
                _status
            ];
            
            _index = _index + 1;
        };
    } forEach _units;
    
    // Summary footer
    private _aliveCount = {alive _x} count _units;
    private _kiaCount = (count _units) - _aliveCount;
    
    _rosterText = _rosterText + "<br/>";
    _rosterText = _rosterText + format [
        "<t size='1.0' color='#D9D5C9' font='PuristaBold'>SUMMARY</t><br/>"
    ];
    _rosterText = _rosterText + format [
        "<t size='0.9' color='#AAAAAA'>Total Personnel: </t><t size='0.9' color='#D9D5C9'>%1</t><br/>",
        count _units
    ];
    _rosterText = _rosterText + format [
        "<t size='0.9' color='#AAAAAA'>Active: </t><t size='0.9' color='#00FF00'>%1</t><br/>",
        _aliveCount
    ];
    _rosterText = _rosterText + format [
        "<t size='0.9' color='#AAAAAA'>KIA: </t><t size='0.9' color='#FF0000'>%1</t>",
        _kiaCount
    ];
};

// Set the roster text
_rosterCtrl ctrlSetStructuredText parseText _rosterText;

diag_log format ["[OpsRoom] Populated roster with %1 units", count _units];
