/*
    OpsRoom_fnc_renderDossierTab
    
    Renders the content for the currently active dossier tab.
    Clears previous content (IDC 9620-9759) and rebuilds.
    Swish animation via ctrlCommit with slight delay.
    
    IDC Usage:
    - 9600-9609: Frame/title/tabs/nav (owned by openUnitDossier, never cleared here)
    - 9620-9759: Tab content (cleared and rebuilt each render)
    - 9760-9779: Action buttons (cleared and rebuilt each render)
*/

private _display = findDisplay 312;
if (isNull _display) exitWith {};

private _unit = missionNamespace getVariable ["OpsRoom_DossierUnit", objNull];
if (isNull _unit) exitWith {};

private _tabIndex = missionNamespace getVariable ["OpsRoom_DossierTab", 0];

// ========================================
// CLEAR ALL TAB CONTENT + BUTTONS (9620-9779)
// ========================================
for "_i" from 9620 to 9779 do {
    private _ctrl = _display displayCtrl _i;
    if (!isNull _ctrl) then { ctrlDelete _ctrl };
};

// ========================================
// UPDATE TAB BUTTON HIGHLIGHTS
// ========================================
for "_i" from 0 to 2 do {
    private _tabBtn = _display displayCtrl (9604 + _i);
    if (!isNull _tabBtn) then {
        if (_i == _tabIndex) then {
            _tabBtn ctrlSetBackgroundColor [0.30, 0.35, 0.22, 1.0];
        } else {
            _tabBtn ctrlSetBackgroundColor [0.22, 0.25, 0.17, 0.8];
        };
    };
};

// ========================================
// LAYOUT CONSTANTS (must match openUnitDossier)
// ========================================
private _panelW = 0.26 * safezoneW;
private _panelX = safezoneX + safezoneW - _panelW - (0.01 * safezoneW);
private _panelY = safezoneY + (0.06 * safezoneH);
private _titleH = 0.038 * safezoneH;
private _tabH = 0.032 * safezoneH;
private _contentStartY = _panelY + _titleH + _tabH + (0.005 * safezoneH);
private _pad = 0.005 * safezoneW;
private _contentW = _panelW - (2 * _pad);
private _rowH = 0.026 * safezoneH;
private _sectionH = 0.028 * safezoneH;

// Colors
private _textColor = [0.85, 0.82, 0.74, 1.0];
private _accentColor = [0.95, 0.92, 0.80, 1.0];
private _sectionBg = [0.25, 0.28, 0.19, 0.9];
private _btnColor = [0.30, 0.35, 0.22, 0.9];

// Animation
private _animOffset = 0.03 * safezoneW;
private _animTime = 0.15;

// Get service record (also updates timeInTheatre)
private _record = [_unit] call OpsRoom_fnc_getServiceRecord;
[_unit] call OpsRoom_fnc_checkMedals;

// Single continuous IDC counter for ALL content
private _idc = 9620;
private _currentY = _contentStartY;

// ── HELPER: text line with slide-in animation ──
private _fnc_addLine = {
    params ["_labelText", "_valueText", ["_valueColor", "#D9D5C9"]];
    if (_idc >= 9759) exitWith {};
    
    private _ctrl = _display ctrlCreate ["RscStructuredText", _idc];
    _ctrl ctrlSetPosition [_panelX + _pad + _animOffset, _currentY, _contentW, _rowH];
    _ctrl ctrlSetStructuredText parseText format [
        "<t size='0.9' color='#A0A090'>%1</t>  <t size='0.9' color='%3'>%2</t>",
        _labelText, _valueText, _valueColor
    ];
    _ctrl ctrlCommit 0;
    _ctrl ctrlSetPosition [_panelX + _pad, _currentY, _contentW, _rowH];
    _ctrl ctrlCommit _animTime;
    _idc = _idc + 1;
    _currentY = _currentY + _rowH;
};

// ── HELPER: section header ──
private _fnc_addSection = {
    params ["_title"];
    if (_idc >= 9758) exitWith {};
    _currentY = _currentY + (0.006 * safezoneH);
    
    private _bg = _display ctrlCreate ["RscText", _idc];
    _bg ctrlSetPosition [_panelX + _animOffset, _currentY, _panelW, _sectionH];
    _bg ctrlSetBackgroundColor _sectionBg;
    _bg ctrlCommit 0;
    _bg ctrlSetPosition [_panelX, _currentY, _panelW, _sectionH];
    _bg ctrlCommit _animTime;
    _idc = _idc + 1;
    
    private _txt = _display ctrlCreate ["RscText", _idc];
    _txt ctrlSetPosition [_panelX + _pad + _animOffset, _currentY, _contentW, _sectionH];
    _txt ctrlSetText format ["  %1", _title];
    _txt ctrlSetTextColor _accentColor;
    _txt ctrlSetFont "PuristaBold";
    _txt ctrlSetFontHeight 0.026;
    _txt ctrlCommit 0;
    _txt ctrlSetPosition [_panelX + _pad, _currentY, _contentW, _sectionH];
    _txt ctrlCommit _animTime;
    _idc = _idc + 1;
    
    _currentY = _currentY + _sectionH + (0.003 * safezoneH);
};

// ── HELPER: dispatch/log entry (single param text + optional color) ──
private _fnc_addEntry = {
    params ["_text", ["_color", "#A0A090"]];
    if (_idc >= 9759) exitWith {};
    
    private _entryH = _rowH * 1.3;
    private _ctrl = _display ctrlCreate ["RscStructuredText", _idc];
    _ctrl ctrlSetPosition [_panelX + _pad + _animOffset, _currentY, _contentW, _entryH];
    _ctrl ctrlSetStructuredText parseText format ["<t size='0.85' color='%2'>  %1</t>", _text, _color];
    _ctrl ctrlCommit 0;
    _ctrl ctrlSetPosition [_panelX + _pad, _currentY, _contentW, _entryH];
    _ctrl ctrlCommit _animTime;
    _idc = _idc + 1;
    _currentY = _currentY + (_rowH * 1.15);
};

// ========================================
// TAB 0: PROFILE
// ========================================
if (_tabIndex == 0) then {
    
    // Name header
    private _nameCtrl = _display ctrlCreate ["RscStructuredText", _idc];
    _nameCtrl ctrlSetPosition [_panelX + _pad + _animOffset, _currentY, _contentW, 0.04 * safezoneH];
    _nameCtrl ctrlSetStructuredText parseText format [
        "<t size='1.3' font='PuristaBold' color='#D9D5C9'>%1</t>", name _unit
    ];
    _nameCtrl ctrlCommit 0;
    _nameCtrl ctrlSetPosition [_panelX + _pad, _currentY, _contentW, 0.04 * safezoneH];
    _nameCtrl ctrlCommit _animTime;
    _idc = _idc + 1;
    _currentY = _currentY + (0.04 * safezoneH);
    
    // ── IDENTITY ──
    ["IDENTITY"] call _fnc_addSection;
    
    private _rankFormatted = switch (rank _unit) do {
        case "PRIVATE": {"Private"};
        case "CORPORAL": {"Corporal"};
        case "SERGEANT": {"Sergeant"};
        case "LIEUTENANT": {"Lieutenant"};
        case "CAPTAIN": {"Captain"};
        case "MAJOR": {"Major"};
        case "COLONEL": {"Colonel"};
        default { rank _unit };
    };
    ["Rank:", _rankFormatted] call _fnc_addLine;
    
    private _role = roleDescription _unit;
    if (_role == "") then {
        _role = getText (configFile >> "CfgVehicles" >> typeOf _unit >> "displayName");
    };
    ["Role:", _role] call _fnc_addLine;
    
    // Time in theatre
    private _timeInTheatre = _record getOrDefault ["timeInTheatre", 0];
    private _days = floor (_timeInTheatre / 86400);
    private _hours = floor ((_timeInTheatre mod 86400) / 3600);
    private _mins = floor ((_timeInTheatre mod 3600) / 60);
    private _timeStr = if (_days > 0) then {
        format ["%1d %2h %3m", _days, _hours, _mins]
    } else {
        if (_hours > 0) then { format ["%1h %2m", _hours, _mins] } else { format ["%1m", _mins] }
    };
    ["Time in Theatre:", _timeStr] call _fnc_addLine;
    
    // ── STATUS ──
    ["STATUS"] call _fnc_addSection;
    
    private _damage = damage _unit;
    private _healthPct = round ((1 - _damage) * 100);
    private _healthColor = "#00FF00";
    if (_healthPct < 75) then { _healthColor = "#FFFF00" };
    if (_healthPct < 50) then { _healthColor = "#FF8800" };
    if (_healthPct < 25) then { _healthColor = "#FF0000" };
    if (!alive _unit) then { _healthColor = "#666666"; _healthPct = 0 };
    ["Health:", format ["%1%%", _healthPct], _healthColor] call _fnc_addLine;
    
    private _status = "ACTIVE";
    private _statusColor = "#00FF00";
    if (!alive _unit) then { _status = "KIA"; _statusColor = "#FF0000" };
    if (alive _unit && {_unit getVariable ["ACE_isUnconscious", false]}) then {
        _status = "UNCONSCIOUS"; _statusColor = "#FF8800";
    };
    ["Status:", _status, _statusColor] call _fnc_addLine;
    
    private _currentOp = _record getOrDefault ["currentOperation", ""];
    if (_currentOp != "") then {
        private _opData = OpsRoom_Operations getOrDefault [_currentOp, createHashMap];
        private _opName = _opData getOrDefault ["name", "Unknown"];
        ["Current Op:", _opName, "#44CC44"] call _fnc_addLine;
    } else {
        ["Current Op:", "None", "#888888"] call _fnc_addLine;
    };
    
    // ── COMBAT RECORD ──
    ["COMBAT RECORD"] call _fnc_addSection;
    
    private _kills = _record getOrDefault ["kills", 0];
    private _killColor = if (_kills >= 10) then { "#FF4444" } else { if (_kills >= 5) then { "#FFD700" } else { "#D9D5C9" } };
    ["Confirmed Kills:", str _kills, _killColor] call _fnc_addLine;
    
    private _opsFought = count (_record getOrDefault ["operationsFought", []]);
    ["Operations:", str _opsFought] call _fnc_addLine;
    
    private _injuries = _record getOrDefault ["timesInjured", 0];
    private _injColor = if (_injuries > 0) then { "#FF8800" } else { "#D9D5C9" };
    ["Times Wounded:", str _injuries, _injColor] call _fnc_addLine;
    
    // ── MEDALS ──
    private _medals = _record getOrDefault ["medals", []];
    if (count _medals > 0) then {
        ["DECORATIONS"] call _fnc_addSection;
        {
            _x params ["_id", "_name", "_sym", "_col", "_desc"];
            [format ["%1 %2", _sym, _name], _desc, _col] call _fnc_addLine;
        } forEach _medals;
    };
    
    // ── ACTION BUTTONS ──
    _currentY = _currentY + (0.012 * safezoneH);
    
    private _btnW = (_panelW - (3 * _pad)) / 2;
    private _btnH = 0.035 * safezoneH;
    
    // Promote
    private _promBtn = _display ctrlCreate ["RscButton", 9760];
    _promBtn ctrlSetPosition [_panelX + _pad, _currentY, _btnW, _btnH];
    _promBtn ctrlSetText "PROMOTE";
    _promBtn ctrlSetTextColor _textColor;
    _promBtn ctrlSetBackgroundColor _btnColor;
    _promBtn ctrlSetFont "PuristaBold";
    _promBtn ctrlSetFontHeight 0.026;
    _promBtn ctrlCommit 0;
    _promBtn ctrlAddEventHandler ["ButtonClick", {
        private _unit = missionNamespace getVariable ["OpsRoom_DossierUnit", objNull];
        if (!isNull _unit) then {
            [_unit] call OpsRoom_fnc_promoteUnit;
            private _record = [_unit] call OpsRoom_fnc_getServiceRecord;
            private _log = _record getOrDefault ["promotionLog", []];
            _log pushBack [time, rank _unit];
            _record set ["promotionLog", _log];
            [] call OpsRoom_fnc_renderDossierTab;
            private _titleCtrl = (findDisplay 312) displayCtrl 9602;
            if (!isNull _titleCtrl) then {
                _titleCtrl ctrlSetText format ["%1 | %2", name _unit, rank _unit];
            };
        };
    }];
    _promBtn ctrlAddEventHandler ["MouseEnter", { (_this select 0) ctrlSetBackgroundColor [0.45, 0.50, 0.30, 1.0] }];
    _promBtn ctrlAddEventHandler ["MouseExit", { (_this select 0) ctrlSetBackgroundColor [0.30, 0.35, 0.22, 0.9] }];
    
    // Demote
    private _demBtn = _display ctrlCreate ["RscButton", 9761];
    _demBtn ctrlSetPosition [_panelX + _btnW + (2 * _pad), _currentY, _btnW, _btnH];
    _demBtn ctrlSetText "DEMOTE";
    _demBtn ctrlSetTextColor _textColor;
    _demBtn ctrlSetBackgroundColor [0.40, 0.25, 0.20, 0.9];
    _demBtn ctrlSetFont "PuristaBold";
    _demBtn ctrlSetFontHeight 0.026;
    _demBtn ctrlCommit 0;
    _demBtn ctrlAddEventHandler ["ButtonClick", {
        private _unit = missionNamespace getVariable ["OpsRoom_DossierUnit", objNull];
        if (!isNull _unit) then {
            [_unit] call OpsRoom_fnc_demoteUnit;
            private _record = [_unit] call OpsRoom_fnc_getServiceRecord;
            private _log = _record getOrDefault ["promotionLog", []];
            _log pushBack [time, rank _unit];
            _record set ["promotionLog", _log];
            [] call OpsRoom_fnc_renderDossierTab;
            private _titleCtrl = (findDisplay 312) displayCtrl 9602;
            if (!isNull _titleCtrl) then {
                _titleCtrl ctrlSetText format ["%1 | %2", name _unit, rank _unit];
            };
        };
    }];
    _demBtn ctrlAddEventHandler ["MouseEnter", { (_this select 0) ctrlSetBackgroundColor [0.55, 0.30, 0.25, 1.0] }];
    _demBtn ctrlAddEventHandler ["MouseExit", { (_this select 0) ctrlSetBackgroundColor [0.40, 0.25, 0.20, 0.9] }];
    
    _currentY = _currentY + _btnH + (0.005 * safezoneH);
    
    // Training
    private _trainBtn = _display ctrlCreate ["RscButton", 9762];
    _trainBtn ctrlSetPosition [_panelX + _pad, _currentY, _contentW, _btnH];
    _trainBtn ctrlSetText "SEND TO TRAINING";
    _trainBtn ctrlSetTextColor _textColor;
    _trainBtn ctrlSetBackgroundColor [0.22, 0.30, 0.35, 0.9];
    _trainBtn ctrlSetFont "PuristaBold";
    _trainBtn ctrlSetFontHeight 0.026;
    _trainBtn ctrlCommit 0;
    _trainBtn ctrlAddEventHandler ["ButtonClick", {
        private _unit = missionNamespace getVariable ["OpsRoom_DossierUnit", objNull];
        if (!isNull _unit) then {
            [] call OpsRoom_fnc_closeDossier;
            [_unit] call OpsRoom_fnc_openTraining;
        };
    }];
    _trainBtn ctrlAddEventHandler ["MouseEnter", { (_this select 0) ctrlSetBackgroundColor [0.30, 0.40, 0.45, 1.0] }];
    _trainBtn ctrlAddEventHandler ["MouseExit", { (_this select 0) ctrlSetBackgroundColor [0.22, 0.30, 0.35, 0.9] }];
};

// ========================================
// TAB 1: SERVICE RECORD
// ========================================
if (_tabIndex == 1) then {
    
    private _opsFought = _record getOrDefault ["operationsFought", []];
    
    ["OPERATIONS (" + str(count _opsFought) + ")"] call _fnc_addSection;
    
    if (count _opsFought == 0) then {
        ["No operations on record", "#888888"] call _fnc_addEntry;
    } else {
        {
            private _opId = _x;
            private _opData = OpsRoom_Operations getOrDefault [_opId, createHashMap];
            if (count _opData > 0) then {
                private _opName = _opData get "name";
                private _opStatus = _opData get "status";
                private _sColor = switch (_opStatus) do {
                    case "complete": { "#44FF88" };
                    case "failed": { "#FF4444" };
                    case "active": { "#44CC44" };
                    default { "#888888" };
                };
                [format ["%1  [%2]", _opName, toUpper _opStatus], _sColor] call _fnc_addEntry;
            };
        } forEach _opsFought;
    };
    
    // ── DISPATCHES ──
    private _dispatches = _record getOrDefault ["dispatches", []];
    ["DISPATCHES (" + str(count _dispatches) + ")"] call _fnc_addSection;
    
    if (count _dispatches == 0) then {
        ["No dispatches recorded", "#888888"] call _fnc_addEntry;
    } else {
        private _reversed = +_dispatches;
        reverse _reversed;
        private _shown = 0;
        {
            if (_shown >= 10) exitWith {};
            _x params ["_time", "_text", "_type"];
            private _col = if (_type == "complete") then { "#88CC88" } else { "#CC8888" };
            [_text, _col] call _fnc_addEntry;
            _shown = _shown + 1;
        } forEach _reversed;
    };
    
    // ── KILL LOG ──
    private _killLog = _record getOrDefault ["killLog", []];
    ["KILL LOG (" + str(count _killLog) + ")"] call _fnc_addSection;
    
    if (count _killLog == 0) then {
        ["No confirmed kills", "#888888"] call _fnc_addEntry;
    } else {
        private _reversed = +_killLog;
        reverse _reversed;
        private _shown = 0;
        {
            if (_shown >= 8) exitWith {};
            _x params ["_time", "_enemyType", "_grid"];
            [format ["Killed %1 at grid %2", _enemyType, _grid], "#CC6666"] call _fnc_addEntry;
            _shown = _shown + 1;
        } forEach _reversed;
    };
    
    // ── INJURY LOG ──
    private _injuryLog = _record getOrDefault ["injuryLog", []];
    if (count _injuryLog > 0) then {
        ["WOUNDS (" + str(count _injuryLog) + ")"] call _fnc_addSection;
        private _reversed = +_injuryLog;
        reverse _reversed;
        private _shown = 0;
        {
            if (_shown >= 5) exitWith {};
            _x params ["_time", "_duringOp", "_grid"];
            private _opStr = if (_duringOp != "" && _duringOp != "None") then {
                format ["Wounded during %1", _duringOp]
            } else {
                "Wounded in action"
            };
            [format ["%1 at grid %2", _opStr, _grid], "#CC8844"] call _fnc_addEntry;
            _shown = _shown + 1;
        } forEach _reversed;
    };
    
    // ── DECORATIONS ──
    private _medals = _record getOrDefault ["medals", []];
    if (count _medals > 0) then {
        ["DECORATIONS (" + str(count _medals) + ")"] call _fnc_addSection;
        {
            _x params ["_id", "_name", "_sym", "_col", "_desc", "_awardTime"];
            [format ["%1 %2 — %3", _sym, _name, _desc], _col] call _fnc_addEntry;
        } forEach _medals;
    };
    
    // ── PROMOTION HISTORY ──
    private _promLog = _record getOrDefault ["promotionLog", []];
    if (count _promLog > 0) then {
        ["RANK HISTORY"] call _fnc_addSection;
        {
            _x params ["_time", "_newRank"];
            private _elapsed = round (time - _time);
            private _ago = if (_elapsed < 60) then { format ["%1s ago", _elapsed] }
                else { if (_elapsed < 3600) then { format ["%1m ago", round(_elapsed/60)] }
                else { format ["%1h ago", round(_elapsed/3600)] }};
            [format ["Promoted to %1 (%2)", _newRank, _ago]] call _fnc_addEntry;
        } forEach _promLog;
    };
};

// ========================================
// TAB 2: SKILLS & TRAINING
// ========================================
if (_tabIndex == 2) then {
    
    ["COMBAT SKILLS"] call _fnc_addSection;
    
    private _skillArray = [
        ["Aim Accuracy", "aimingAccuracy"],
        ["Aim Steadiness", "aimingShake"],
        ["Aim Speed", "aimingSpeed"],
        ["Spot Distance", "spotDistance"],
        ["Spot Speed", "spotTime"],
        ["Courage", "courage"],
        ["Reload Speed", "reloadSpeed"],
        ["Command", "commanding"],
        ["General", "general"]
    ];
    
    {
        _x params ["_displayName", "_skillId"];
        if (_idc >= 9759) exitWith {};
        
        private _val = _unit skill _skillId;
        private _pct = round (_val * 100);
        private _level = round (_val * 10);
        
        // Build visual bar
        private _barLen = round (_pct / 5);
        private _bar = "";
        for "_j" from 1 to 20 do {
            if (_j <= _barLen) then { _bar = _bar + "█" } else { _bar = _bar + "░" };
        };
        
        private _skillColor = "#FF4444";
        if (_level >= 7) then { _skillColor = "#00FF00" };
        if (_level >= 5 && _level < 7) then { _skillColor = "#FFDD44" };
        if (_level >= 3 && _level < 5) then { _skillColor = "#FF8800" };
        
        private _ctrl = _display ctrlCreate ["RscStructuredText", _idc];
        _ctrl ctrlSetPosition [_panelX + _pad + _animOffset, _currentY, _contentW, _rowH * 1.4];
        _ctrl ctrlSetStructuredText parseText format [
            "<t size='0.85' color='#A0A090'>%1</t><br/><t size='0.75' color='%3'>%2</t> <t size='0.75' color='%3'>%4%%</t>",
            _displayName, _bar, _skillColor, _pct
        ];
        _ctrl ctrlCommit 0;
        _ctrl ctrlSetPosition [_panelX + _pad, _currentY, _contentW, _rowH * 1.4];
        _ctrl ctrlCommit _animTime;
        _idc = _idc + 1;
        _currentY = _currentY + (_rowH * 1.4);
    } forEach _skillArray;
    
    // ── QUALIFICATIONS ──
    ["QUALIFICATIONS"] call _fnc_addSection;
    
    private _quals = [];
    if (_unit getVariable ["OpsRoom_Ability_SuppressiveFire", false]) then { _quals pushBack "Suppressive Fire" };
    if (_unit getVariable ["OpsRoom_Ability_MarksmanShot", false]) then { _quals pushBack "Marksman Shot" };
    if (_unit getVariable ["OpsRoom_Ability_Timebomb", false]) then { _quals pushBack "Demolitions" };
    if (_unit getVariable ["OpsRoom_Ability_Reconnoitre", false]) then { _quals pushBack "Reconnaissance" };
    if (_unit getVariable ["OpsRoom_Ability_Infiltrate", false]) then { _quals pushBack "Infiltration" };
    if (_unit getVariable ["OpsRoom_Ability_Assassinate", false]) then { _quals pushBack "Assassination" };
    if (_unit getVariable ["OpsRoom_Ability_Heal", false]) then { _quals pushBack "Field Medic" };
    if (_unit getVariable ["OpsRoom_Ability_Repair", false]) then { _quals pushBack "Combat Engineer" };
    if (_unit getVariable ["OpsRoom_Ability_Grenade", false]) then { _quals pushBack "Grenadier" };
    
    private _completedCourses = _unit getVariable ["OpsRoom_CompletedCourses", []];
    {
        private _courseId = _x;
        {
            _x params ["_cId", "_cName"];
            if (_cId == _courseId) then {
                private _qualName = format ["%1 (Trained)", _cName];
                if !(_qualName in _quals) then { _quals pushBack _qualName };
            };
        } forEach OpsRoom_TrainingCourses;
    } forEach _completedCourses;
    
    if (count _quals == 0) then {
        ["No qualifications earned", "#888888"] call _fnc_addEntry;
    } else {
        {
            [format ["● %1", _x], "#88CC44"] call _fnc_addEntry;
        } forEach _quals;
    };
    
    // ── TRAINING STATUS ──
    private _inTraining = false;
    private _trainingInfo = "";
    {
        _x params ["_trainee"];
        if (_trainee == _unit) exitWith {
            _inTraining = true;
            _x params ["", "_courseId", "_startTime", "_duration"];
            private _elapsed = time - _startTime;
            private _remaining = (_duration * 60) - _elapsed;
            private _remMins = ceil (_remaining / 60);
            _trainingInfo = format ["Currently training: %1 (%2 min remaining)", _courseId, _remMins];
        };
    } forEach (missionNamespace getVariable ["OpsRoom_UnitsInTraining", []]);
    
    if (_inTraining) then {
        ["TRAINING STATUS"] call _fnc_addSection;
        [_trainingInfo, "#FFCC44"] call _fnc_addEntry;
    };
    
    // Training button
    _currentY = _currentY + (0.012 * safezoneH);
    private _trainBtn = _display ctrlCreate ["RscButton", 9770];
    _trainBtn ctrlSetPosition [_panelX + _pad, _currentY, _contentW, 0.035 * safezoneH];
    _trainBtn ctrlSetText "SEND TO TRAINING";
    _trainBtn ctrlSetTextColor _textColor;
    _trainBtn ctrlSetBackgroundColor [0.22, 0.30, 0.35, 0.9];
    _trainBtn ctrlSetFont "PuristaBold";
    _trainBtn ctrlSetFontHeight 0.026;
    _trainBtn ctrlCommit 0;
    _trainBtn ctrlAddEventHandler ["ButtonClick", {
        private _unit = missionNamespace getVariable ["OpsRoom_DossierUnit", objNull];
        if (!isNull _unit) then {
            [] call OpsRoom_fnc_closeDossier;
            [_unit] call OpsRoom_fnc_openTraining;
        };
    }];
    _trainBtn ctrlAddEventHandler ["MouseEnter", { (_this select 0) ctrlSetBackgroundColor [0.30, 0.40, 0.45, 1.0] }];
    _trainBtn ctrlAddEventHandler ["MouseExit", { (_this select 0) ctrlSetBackgroundColor [0.22, 0.30, 0.35, 0.9] }];
};

diag_log format ["[OpsRoom Dossier] Rendered tab %1 for %2 (used %3 IDCs)", _tabIndex, name _unit, _idc - 9620];
