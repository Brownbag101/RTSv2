/*
    OpsRoom_fnc_debugServiceRecord
    
    Debug & Testing panel for the service record system.
    Opens on Zeus display (312) on the LEFT side.
    
    Sections:
    - SERVICE RECORDS: Add kills, wounds, operations, medals
    - ABILITIES: Grant/revoke all special abilities
    - SKILLS: Set skill levels (low/med/high/max)
    - UTILITIES: Dump record, reset, heal unit
    
    Can be opened from:
    - Roster grid "DEBUG" button (passes unit + groupId)
    - Debug console: [] call OpsRoom_fnc_debugServiceRecord;
    - With dossier open (uses dossier unit)
    - With Zeus selection (uses selected unit)
    
    IDC Range: 9800-9899
    
    Parameters:
        0: OBJECT - (optional) Unit to debug. Auto-detects if not provided.
    
    Usage:
        [] call OpsRoom_fnc_debugServiceRecord;
        [_unit] call OpsRoom_fnc_debugServiceRecord;
*/

params [["_unit", objNull, [objNull]]];

private _display = findDisplay 312;
if (isNull _display) exitWith { systemChat "[DEBUG] Zeus display not found" };

// Auto-detect unit
if (isNull _unit) then {
    _unit = missionNamespace getVariable ["OpsRoom_DossierUnit", objNull];
};
if (isNull _unit) then {
    private _selected = curatorSelected select 0;
    if (count _selected > 0) then { _unit = _selected select 0 };
};
if (isNull _unit) exitWith { systemChat "[DEBUG] No unit — select one or open a dossier first" };

// Close existing debug panel
for "_i" from 9800 to 9999 do {
    private _ctrl = _display displayCtrl _i;
    if (!isNull _ctrl) then { ctrlDelete _ctrl };
};

// Store unit ref
missionNamespace setVariable ["OpsRoom_DebugUnit", _unit];

// ========================================
// LAYOUT
// ========================================
private _panelW = 0.40 * safezoneW;
private _panelX = safezoneX + (0.005 * safezoneW);
private _panelY = safezoneY + (0.02 * safezoneH);
private _btnH = 0.026 * safezoneH;
private _sectionH = 0.024 * safezoneH;
private _pad = 0.002 * safezoneH;
private _innerPad = 0.004 * safezoneW;
private _idc = 9800;
private _currentY = _panelY;

// Colors
private _bgColor = [0.12, 0.10, 0.08, 0.95];
private _titleColor = [0.40, 0.18, 0.12, 1.0];
private _sectionColor = [0.28, 0.22, 0.15, 0.9];
private _btnColor = [0.30, 0.25, 0.18, 0.9];
private _btnHover = [0.45, 0.35, 0.22, 1.0];
private _abilityOnColor = [0.20, 0.35, 0.20, 0.9];
private _abilityOffColor = [0.30, 0.25, 0.18, 0.9];
private _abilityOnHover = [0.30, 0.50, 0.30, 1.0];
private _textColor = [0.95, 0.85, 0.65, 1.0];
private _sectionTextColor = [0.95, 0.90, 0.70, 1.0];
private _dimText = [0.70, 0.65, 0.50, 1.0];

// Background (will resize at end)
private _bg = _display ctrlCreate ["RscText", _idc];
_bg ctrlSetPosition [_panelX, _panelY, _panelW, 0.80 * safezoneH];
_bg ctrlSetBackgroundColor _bgColor;
_bg ctrlCommit 0;
_idc = _idc + 1;

// ── HELPER: section header ──
private _fnc_section = {
    params ["_title"];
    _currentY = _currentY + (_pad * 0.5);
    private _secBg = _display ctrlCreate ["RscText", _idc];
    _secBg ctrlSetPosition [_panelX, _currentY, _panelW, _sectionH];
    _secBg ctrlSetBackgroundColor _sectionColor;
    _secBg ctrlCommit 0;
    _idc = _idc + 1;
    
    private _secTxt = _display ctrlCreate ["RscText", _idc];
    _secTxt ctrlSetPosition [_panelX + _innerPad, _currentY, _panelW - (2 * _innerPad), _sectionH];
    _secTxt ctrlSetText format ["  %1", _title];
    _secTxt ctrlSetTextColor _sectionTextColor;
    _secTxt ctrlSetFont "PuristaBold";
    _secTxt ctrlSetFontHeight 0.026;
    _secTxt ctrlCommit 0;
    _idc = _idc + 1;
    _currentY = _currentY + _sectionH + _pad;
};

// ── HELPER: standard button ──
private _fnc_btn = {
    params ["_label", "_code", ["_color", [0.30, 0.25, 0.18, 0.9]], ["_hoverColor", [0.45, 0.35, 0.22, 1.0]]];
    if (_idc >= 9999) exitWith {};
    
    private _btn = _display ctrlCreate ["RscButton", _idc];
    _btn ctrlSetPosition [_panelX + _innerPad, _currentY, _panelW - (2 * _innerPad), _btnH];
    _btn ctrlSetText _label;
    _btn ctrlSetTextColor _textColor;
    _btn ctrlSetBackgroundColor _color;
    _btn ctrlSetFont "PuristaMedium";
    _btn ctrlSetFontHeight 0.024;
    _btn ctrlCommit 0;
    _btn setVariable ["debugCode", _code];
    _btn setVariable ["hoverCol", _hoverColor];
    _btn setVariable ["baseCol", _color];
    _btn ctrlAddEventHandler ["ButtonClick", {
        params ["_ctrl"];
        private _code = _ctrl getVariable ["debugCode", {}];
        private _u = missionNamespace getVariable ["OpsRoom_DebugUnit", objNull];
        if (!isNull _u) then { [_u] call _code };
    }];
    _btn ctrlAddEventHandler ["MouseEnter", {
        (_this select 0) ctrlSetBackgroundColor ((_this select 0) getVariable ["hoverCol", [0.45,0.35,0.22,1]]);
    }];
    _btn ctrlAddEventHandler ["MouseExit", {
        (_this select 0) ctrlSetBackgroundColor ((_this select 0) getVariable ["baseCol", [0.30,0.25,0.18,0.9]]);
    }];
    _idc = _idc + 1;
    _currentY = _currentY + _btnH + (_pad * 0.5);
};

// ── HELPER: half-width button pair ──
private _fnc_btnPair = {
    params ["_label1", "_code1", "_label2", "_code2", ["_color", [0.30, 0.25, 0.18, 0.9]], ["_hoverColor", [0.45, 0.35, 0.22, 1.0]]];
    if (_idc >= 9998) exitWith {};
    
    private _halfW = (_panelW - (3 * _innerPad)) / 2;
    
    private _btn1 = _display ctrlCreate ["RscButton", _idc];
    _btn1 ctrlSetPosition [_panelX + _innerPad, _currentY, _halfW, _btnH];
    _btn1 ctrlSetText _label1;
    _btn1 ctrlSetTextColor _textColor;
    _btn1 ctrlSetBackgroundColor _color;
    _btn1 ctrlSetFont "PuristaMedium";
    _btn1 ctrlSetFontHeight 0.024;
    _btn1 ctrlCommit 0;
    _btn1 setVariable ["debugCode", _code1];
    _btn1 setVariable ["hoverCol", _hoverColor];
    _btn1 setVariable ["baseCol", _color];
    _btn1 ctrlAddEventHandler ["ButtonClick", {
        params ["_ctrl"];
        private _code = _ctrl getVariable ["debugCode", {}];
        private _u = missionNamespace getVariable ["OpsRoom_DebugUnit", objNull];
        if (!isNull _u) then { [_u] call _code };
    }];
    _btn1 ctrlAddEventHandler ["MouseEnter", { (_this select 0) ctrlSetBackgroundColor ((_this select 0) getVariable ["hoverCol", [0.45,0.35,0.22,1]]); }];
    _btn1 ctrlAddEventHandler ["MouseExit", { (_this select 0) ctrlSetBackgroundColor ((_this select 0) getVariable ["baseCol", [0.30,0.25,0.18,0.9]]); }];
    _idc = _idc + 1;
    
    private _btn2 = _display ctrlCreate ["RscButton", _idc];
    _btn2 ctrlSetPosition [_panelX + (2 * _innerPad) + _halfW, _currentY, _halfW, _btnH];
    _btn2 ctrlSetText _label2;
    _btn2 ctrlSetTextColor _textColor;
    _btn2 ctrlSetBackgroundColor _color;
    _btn2 ctrlSetFont "PuristaMedium";
    _btn2 ctrlSetFontHeight 0.024;
    _btn2 ctrlCommit 0;
    _btn2 setVariable ["debugCode", _code2];
    _btn2 setVariable ["hoverCol", _hoverColor];
    _btn2 setVariable ["baseCol", _color];
    _btn2 ctrlAddEventHandler ["ButtonClick", {
        params ["_ctrl"];
        private _code = _ctrl getVariable ["debugCode", {}];
        private _u = missionNamespace getVariable ["OpsRoom_DebugUnit", objNull];
        if (!isNull _u) then { [_u] call _code };
    }];
    _btn2 ctrlAddEventHandler ["MouseEnter", { (_this select 0) ctrlSetBackgroundColor ((_this select 0) getVariable ["hoverCol", [0.45,0.35,0.22,1]]); }];
    _btn2 ctrlAddEventHandler ["MouseExit", { (_this select 0) ctrlSetBackgroundColor ((_this select 0) getVariable ["baseCol", [0.30,0.25,0.18,0.9]]); }];
    _idc = _idc + 1;
    
    _currentY = _currentY + _btnH + (_pad * 0.5);
};

// ── HELPER: ability toggle button (shows ON/OFF state) ──
private _fnc_abilityToggle = {
    params ["_label", "_varName"];
    if (_idc >= 9899) exitWith {};
    
    private _isOn = _unit getVariable [_varName, false];
    private _displayLabel = if (_isOn) then { format ["✓ %1", _label] } else { format ["✗ %1", _label] };
    private _baseCol = if (_isOn) then { _abilityOnColor } else { _abilityOffColor };
    private _hovCol = if (_isOn) then { _abilityOnHover } else { _btnHover };
    
    private _btn = _display ctrlCreate ["RscButton", _idc];
    _btn ctrlSetPosition [_panelX + _innerPad, _currentY, _panelW - (2 * _innerPad), _btnH];
    _btn ctrlSetText _displayLabel;
    _btn ctrlSetTextColor _textColor;
    _btn ctrlSetBackgroundColor _baseCol;
    _btn ctrlSetFont "PuristaMedium";
    _btn ctrlSetFontHeight 0.024;
    _btn ctrlCommit 0;
    _btn setVariable ["abilityVar", _varName];
    _btn setVariable ["abilityLabel", _label];
    _btn ctrlAddEventHandler ["ButtonClick", {
        params ["_ctrl"];
        private _u = missionNamespace getVariable ["OpsRoom_DebugUnit", objNull];
        if (isNull _u) exitWith {};
        private _var = _ctrl getVariable ["abilityVar", ""];
        private _lbl = _ctrl getVariable ["abilityLabel", ""];
        private _current = _u getVariable [_var, false];
        _u setVariable [_var, !_current, true];
        
        // Update button visually
        if (!_current) then {
            _ctrl ctrlSetText format ["✓ %1", _lbl];
            _ctrl ctrlSetBackgroundColor [0.20, 0.35, 0.20, 0.9];
            _ctrl setVariable ["baseCol", [0.20, 0.35, 0.20, 0.9]];
            _ctrl setVariable ["hoverCol", [0.30, 0.50, 0.30, 1.0]];
            systemChat format ["[DEBUG] %1: %2 GRANTED", name _u, _lbl];
        } else {
            _ctrl ctrlSetText format ["✗ %1", _lbl];
            _ctrl ctrlSetBackgroundColor [0.30, 0.25, 0.18, 0.9];
            _ctrl setVariable ["baseCol", [0.30, 0.25, 0.18, 0.9]];
            _ctrl setVariable ["hoverCol", [0.45, 0.35, 0.22, 1.0]];
            systemChat format ["[DEBUG] %1: %2 REVOKED", name _u, _lbl];
        };
        
        // Refresh dossier if open
        if (missionNamespace getVariable ["OpsRoom_DossierOpen", false]) then {
            [] call OpsRoom_fnc_renderDossierTab;
        };
    }];
    _btn setVariable ["hoverCol", _hovCol];
    _btn setVariable ["baseCol", _baseCol];
    _btn ctrlAddEventHandler ["MouseEnter", { (_this select 0) ctrlSetBackgroundColor ((_this select 0) getVariable ["hoverCol", [0.45,0.35,0.22,1]]); }];
    _btn ctrlAddEventHandler ["MouseExit", { (_this select 0) ctrlSetBackgroundColor ((_this select 0) getVariable ["baseCol", [0.30,0.25,0.18,0.9]]); }];
    _idc = _idc + 1;
    _currentY = _currentY + _btnH + (_pad * 0.5);
};

// ========================================
// TITLE BAR
// ========================================
private _title = _display ctrlCreate ["RscText", _idc];
_title ctrlSetPosition [_panelX, _currentY, _panelW, 0.034 * safezoneH];
_title ctrlSetBackgroundColor _titleColor;
_title ctrlSetText format ["  DEBUG: %1", name _unit];
_title ctrlSetTextColor _textColor;
_title ctrlSetFont "PuristaBold";
_title ctrlSetFontHeight 0.024;
_title ctrlCommit 0;
_idc = _idc + 1;
_currentY = _currentY + (0.034 * safezoneH) + _pad;

// ========================================
// SERVICE RECORDS
// ========================================
["SERVICE RECORDS"] call _fnc_section;

private _fnc_refreshDossier = {
    if (missionNamespace getVariable ["OpsRoom_DossierOpen", false]) then {
        [] call OpsRoom_fnc_renderDossierTab;
    };
};

["+1 Kill", {
    params ["_u"];
    private _r = [_u] call OpsRoom_fnc_getServiceRecord;
    private _k = _r getOrDefault ["kills", 0]; _r set ["kills", _k + 1];
    private _kl = _r getOrDefault ["killLog", []];
    _kl pushBack [time, "Debug Target", mapGridPosition (getPos _u)];
    _r set ["killLog", _kl]; _u setVariable ["OpsRoom_Kills", _k + 1];
    [_u] call OpsRoom_fnc_checkMedals;
    systemChat format ["[DEBUG] %1 kills: %2", name _u, _k + 1];
    if (missionNamespace getVariable ["OpsRoom_DossierOpen", false]) then { [] call OpsRoom_fnc_renderDossierTab };
}, "+5 Kills", {
    params ["_u"];
    private _r = [_u] call OpsRoom_fnc_getServiceRecord;
    private _k = _r getOrDefault ["kills", 0]; _r set ["kills", _k + 5];
    private _kl = _r getOrDefault ["killLog", []];
    for "_i" from 1 to 5 do { _kl pushBack [time, format ["Debug Target %1", _i], mapGridPosition (getPos _u)] };
    _r set ["killLog", _kl]; _u setVariable ["OpsRoom_Kills", _k + 5];
    [_u] call OpsRoom_fnc_checkMedals;
    systemChat format ["[DEBUG] %1 kills: %2", name _u, _k + 5];
    if (missionNamespace getVariable ["OpsRoom_DossierOpen", false]) then { [] call OpsRoom_fnc_renderDossierTab };
}] call _fnc_btnPair;

["+10 Kills", {
    params ["_u"];
    private _r = [_u] call OpsRoom_fnc_getServiceRecord;
    private _k = _r getOrDefault ["kills", 0]; _r set ["kills", _k + 10];
    private _kl = _r getOrDefault ["killLog", []];
    for "_i" from 1 to 10 do { _kl pushBack [time, format ["Debug Target %1", _i], mapGridPosition (getPos _u)] };
    _r set ["killLog", _kl]; _u setVariable ["OpsRoom_Kills", _k + 10];
    [_u] call OpsRoom_fnc_checkMedals;
    systemChat format ["[DEBUG] %1 kills: %2", name _u, _k + 10];
    if (missionNamespace getVariable ["OpsRoom_DossierOpen", false]) then { [] call OpsRoom_fnc_renderDossierTab };
}, "+1 Wound", {
    params ["_u"];
    private _r = [_u] call OpsRoom_fnc_getServiceRecord;
    private _inj = _r getOrDefault ["timesInjured", 0]; _r set ["timesInjured", _inj + 1];
    private _il = _r getOrDefault ["injuryLog", []];
    _il pushBack [time, _r getOrDefault ["currentOperation", ""], mapGridPosition (getPos _u)];
    _r set ["injuryLog", _il];
    [_u] call OpsRoom_fnc_checkMedals;
    systemChat format ["[DEBUG] %1 wounds: %2", name _u, _inj + 1];
    if (missionNamespace getVariable ["OpsRoom_DossierOpen", false]) then { [] call OpsRoom_fnc_renderDossierTab };
}] call _fnc_btnPair;

["Add Fake Op (Complete)", {
    params ["_u"];
    private _r = [_u] call OpsRoom_fnc_getServiceRecord;
    private _fakeId = format ["debug_op_%1", floor(random 99999)];
    private _fakeName = selectRandom ["Iron Fist", "Thunder Ridge", "Silver Dawn", "Red Tempest", "Cobra Strike", "Eagle Eye", "Black Arrow", "Storm Front"];
    private _fakeOp = createHashMapFromArray [
        ["id", _fakeId], ["name", _fakeName], ["status", "complete"],
        ["targetName", "Debug"], ["taskType", "assault"], ["progress", 100],
        ["regiments", []], ["regimentNames", []], ["created", time]
    ];
    OpsRoom_Operations set [_fakeId, _fakeOp];
    private _of = _r getOrDefault ["operationsFought", []]; _of pushBack _fakeId; _r set ["operationsFought", _of];
    private _oc = _r getOrDefault ["operationsCompleted", []]; _oc pushBack _fakeId; _r set ["operationsCompleted", _oc];
    private _d = _r getOrDefault ["dispatches", []];
    _d pushBack [time, format ["%1 Operation ""%2""", selectRandom ["Fought bravely in", "Showed exceptional courage during", "Instrumental in the success of"], _fakeName], "complete"];
    _r set ["dispatches", _d];
    [_u] call OpsRoom_fnc_checkMedals;
    systemChat format ["[DEBUG] Added op: %1 (%2 total)", _fakeName, count _of];
    if (missionNamespace getVariable ["OpsRoom_DossierOpen", false]) then { [] call OpsRoom_fnc_renderDossierTab };
}, "Award ALL Medals", {
    params ["_u"];
    private _r = [_u] call OpsRoom_fnc_getServiceRecord;
    private _medals = [];
    { _x params ["_id", "_name", "_sym", "_col", "_desc"]; _medals pushBack [_id, _name, _sym, _col, _desc, time]; } forEach OpsRoom_MedalDefinitions;
    _r set ["medals", _medals];
    systemChat format ["[DEBUG] All %1 medals awarded to %2", count _medals, name _u];
    if (missionNamespace getVariable ["OpsRoom_DossierOpen", false]) then { [] call OpsRoom_fnc_renderDossierTab };
}] call _fnc_btnPair;

// ========================================
// ABILITIES
// ========================================
["SPECIAL ABILITIES (click to toggle)"] call _fnc_section;

["Suppressive Fire", "OpsRoom_Ability_SuppressiveFire"] call _fnc_abilityToggle;
["Aimed Shot", "OpsRoom_Ability_MarksmanShot"] call _fnc_abilityToggle;
["Timebomb", "OpsRoom_Ability_Timebomb"] call _fnc_abilityToggle;
["Reconnoitre", "OpsRoom_Ability_Reconnoitre"] call _fnc_abilityToggle;
["Infiltrate", "OpsRoom_Ability_Infiltrate"] call _fnc_abilityToggle;
["Assassinate", "OpsRoom_Ability_Assassinate"] call _fnc_abilityToggle;
["Heal", "OpsRoom_Ability_Heal"] call _fnc_abilityToggle;
["Repair", "OpsRoom_Ability_Repair"] call _fnc_abilityToggle;

["Grant ALL Abilities", {
    params ["_u"];
    { _u setVariable [_x, true, true] } forEach [
        "OpsRoom_Ability_SuppressiveFire", "OpsRoom_Ability_MarksmanShot",
        "OpsRoom_Ability_Timebomb", "OpsRoom_Ability_Reconnoitre",
        "OpsRoom_Ability_Infiltrate", "OpsRoom_Ability_Assassinate",
        "OpsRoom_Ability_Heal", "OpsRoom_Ability_Repair"
    ];
    systemChat format ["[DEBUG] ALL abilities granted to %1", name _u];
    // Reopen to refresh toggle states
    [_u] call OpsRoom_fnc_debugServiceRecord;
}, "Revoke ALL Abilities", {
    params ["_u"];
    { _u setVariable [_x, false, true] } forEach [
        "OpsRoom_Ability_SuppressiveFire", "OpsRoom_Ability_MarksmanShot",
        "OpsRoom_Ability_Timebomb", "OpsRoom_Ability_Reconnoitre",
        "OpsRoom_Ability_Infiltrate", "OpsRoom_Ability_Assassinate",
        "OpsRoom_Ability_Heal", "OpsRoom_Ability_Repair"
    ];
    systemChat format ["[DEBUG] ALL abilities revoked from %1", name _u];
    [_u] call OpsRoom_fnc_debugServiceRecord;
}] call _fnc_btnPair;

// ========================================
// SKILLS
// ========================================
["SKILL LEVELS"] call _fnc_section;

private _fnc_setAllSkills = {
    params ["_u", "_val"];
    {
        _u setSkill [_x, _val];
    } forEach ["aimingAccuracy", "aimingShake", "aimingSpeed", "spotDistance", "spotTime", "courage", "reloadSpeed", "commanding", "general"];
    systemChat format ["[DEBUG] %1 all skills set to %2%%", name _u, round(_val * 100)];
    if (missionNamespace getVariable ["OpsRoom_DossierOpen", false]) then { [] call OpsRoom_fnc_renderDossierTab };
};

["Skills: LOW (10%)", {
    params ["_u"]; [_u, 0.1] call OpsRoom_fnc_debugSetAllSkills;
}, "Skills: MED (50%)", {
    params ["_u"]; [_u, 0.5] call OpsRoom_fnc_debugSetAllSkills;
}] call _fnc_btnPair;

["Skills: HIGH (80%)", {
    params ["_u"]; [_u, 0.8] call OpsRoom_fnc_debugSetAllSkills;
}, "Skills: MAX (100%)", {
    params ["_u"]; [_u, 1.0] call OpsRoom_fnc_debugSetAllSkills;
}] call _fnc_btnPair;

// Store the skill setter in missionNamespace so button callbacks can find it
OpsRoom_fnc_debugSetAllSkills = {
    params ["_u", "_val"];
    {
        _u setSkill [_x, _val];
    } forEach ["aimingAccuracy", "aimingShake", "aimingSpeed", "spotDistance", "spotTime", "courage", "reloadSpeed", "commanding", "general"];
    systemChat format ["[DEBUG] %1 all skills → %2%%", name _u, round(_val * 100)];
    if (missionNamespace getVariable ["OpsRoom_DossierOpen", false]) then { [] call OpsRoom_fnc_renderDossierTab };
};

// ========================================
// UTILITIES
// ========================================
["UTILITIES"] call _fnc_section;

["+ 100 ALL Resources", {
    {
        _x params ["_name"];
        private _varName = format ["OpsRoom_Resource_%1", _name];
        private _current = missionNamespace getVariable [_varName, 0];
        missionNamespace setVariable [_varName, _current + 100];
    } forEach OpsRoom_Settings_InitialResources;
    [] call OpsRoom_fnc_updateResources;
    systemChat "[DEBUG] +100 to ALL resources";
}] call _fnc_btn;

["Heal to 100%", {
    params ["_u"];
    _u setDamage 0;
    systemChat format ["[DEBUG] %1 fully healed", name _u];
    if (missionNamespace getVariable ["OpsRoom_DossierOpen", false]) then { [] call OpsRoom_fnc_renderDossierTab };
}, "Dump to RPT", {
    params ["_u"];
    private _r = [_u] call OpsRoom_fnc_getServiceRecord;
    diag_log "========== SERVICE RECORD DUMP ==========";
    diag_log format ["Unit: %1 (key: %2)", name _u, str _u];
    { diag_log format ["  %1: %2", _x, _y] } forEach _r;
    diag_log format ["Abilities: Suppress=%1 Aimed=%2 Bomb=%3 Recon=%4 Infil=%5 Assass=%6 Heal=%7 Repair=%8",
        _u getVariable ["OpsRoom_Ability_SuppressiveFire", false],
        _u getVariable ["OpsRoom_Ability_MarksmanShot", false],
        _u getVariable ["OpsRoom_Ability_Timebomb", false],
        _u getVariable ["OpsRoom_Ability_Reconnoitre", false],
        _u getVariable ["OpsRoom_Ability_Infiltrate", false],
        _u getVariable ["OpsRoom_Ability_Assassinate", false],
        _u getVariable ["OpsRoom_Ability_Heal", false],
        _u getVariable ["OpsRoom_Ability_Repair", false]
    ];
    diag_log "==========================================";
    systemChat format ["[DEBUG] Full record dumped for %1", name _u];
}] call _fnc_btnPair;

["Reset Record", {
    params ["_u"];
    OpsRoom_UnitServiceRecords deleteAt (str _u);
    _u setVariable ["OpsRoom_Kills", 0];
    [_u] call OpsRoom_fnc_registerUnitService;
    systemChat format ["[DEBUG] Record wiped for %1", name _u];
    if (missionNamespace getVariable ["OpsRoom_DossierOpen", false]) then { [] call OpsRoom_fnc_renderDossierTab };
}, "Close Panel", {
    private _d = findDisplay 312;
    if (!isNull _d) then { for "_i" from 9800 to 9899 do { private _c = _d displayCtrl _i; if (!isNull _c) then { ctrlDelete _c } } };
    systemChat "[DEBUG] Panel closed";
}] call _fnc_btnPair;

// ========================================
// GLOBAL CHEATS
// ========================================
["GLOBAL CHEATS"] call _fnc_section;

["Complete ALL Research", {
    {
        private _itemId = _x;
        if !(_itemId in OpsRoom_ResearchCompleted) then {
            OpsRoom_ResearchCompleted pushBack _itemId;
        };
    } forEach (keys OpsRoom_EquipmentDB);
    systemChat format ["[DEBUG] All %1 items marked as researched", count OpsRoom_ResearchCompleted];
}] call _fnc_btn;

["Finish All Training", {
    {
        _x params ["_unit", "_courseId", "_startTime", "_courseDuration", "_skills", "_quals"];
        [_unit, _skills, _quals] call OpsRoom_fnc_completeTraining;
        systemChat format ["[DEBUG] Completed training for %1", name _unit];
    } forEach OpsRoom_UnitsInTraining;
    OpsRoom_UnitsInTraining = [];
    systemChat "[DEBUG] All training completed";
}] call _fnc_btn;

["Add Hurricane (Hangar)", {
    private _id = ["hurricane_mk1"] call OpsRoom_fnc_addToHangar;
    systemChat format ["[DEBUG] Hurricane added to hangar: %1", _id];
}, "Add Mosquito (Hangar)", {
    private _id = ["mosquito_fb"] call OpsRoom_fnc_addToHangar;
    systemChat format ["[DEBUG] Mosquito added to hangar: %1", _id];
}] call _fnc_btnPair;

["Add Halifax Bomber", {
    private _id = ["halifax_bomber"] call OpsRoom_fnc_addToHangar;
    systemChat format ["[DEBUG] Halifax added to hangar: %1", _id];
}, "Add Spitfire Recon", {
    private _id = ["spitfire_pr"] call OpsRoom_fnc_addToHangar;
    systemChat format ["[DEBUG] Spitfire PR added to hangar: %1", _id];
}] call _fnc_btnPair;

["Grant Pilot Qual", {
    params ["_u"];
    private _quals = _u getVariable ["OpsRoom_Qualifications", []];
    if !("pilot" in _quals) then { _quals pushBack "pilot" };
    _u setVariable ["OpsRoom_Qualifications", _quals, true];
    _u setVariable ["OpsRoom_IsPilot", true, true];
    _u forceAddUniform "sab_fl_pilotuniform_green";
    _u addBackpack "B_Parachute";
    // Remove from regiment groups
    { private _grpData = _y; private _grpUnits = _grpData get "units";
      _grpData set ["units", _grpUnits - [_u]];
    } forEach OpsRoom_Groups;
    // Move to airfield
    private _pg = createGroup [independent, true]; [_u] joinSilent _pg;
    _u setVariable ["OpsRoom_ParentGroup", nil];
    if (markerType "OpsRoom_hangar" != "") then { _u setPos (getMarkerPos "OpsRoom_hangar") };
    if (isNil "OpsRoom_PilotPool") then { OpsRoom_PilotPool = [] };
    OpsRoom_PilotPool pushBack _u;
    systemChat format ["[DEBUG] %1 granted Pilot qual + transferred to airfield", name _u];
}, "+1000 Manpower", {
    OpsRoom_Resource_Manpower = (missionNamespace getVariable ["OpsRoom_Resource_Manpower", 0]) + 1000;
    [] call OpsRoom_fnc_updateResources;
    systemChat "[DEBUG] +1000 Manpower";
}] call _fnc_btnPair;

// ========================================
// DISPATCH TEST SECTION
// ========================================
_currentY = _currentY + _pad;
private _dispHeader = _display ctrlCreate ["RscText", _idc];
_dispHeader ctrlSetPosition [_panelX + _pad, _currentY, _panelW - _pad * 2, _btnH];
_dispHeader ctrlSetText "── DISPATCH TESTS ──";
_dispHeader ctrlSetFont "PuristaBold";
_dispHeader ctrlSetTextColor [0.8, 0.7, 0.5, 1];
_dispHeader ctrlSetBackgroundColor [0, 0, 0, 0];
_dispHeader ctrlCommit 0;
_idc = _idc + 1;
_currentY = _currentY + _btnH + (_pad * 0.5);

["Test ROUTINE", {
    ["ROUTINE", "EQUIPMENT DELIVERED", "Supply crate arrived at Forward Base Alpha"] call OpsRoom_fnc_dispatch;
}, "Test PRIORITY", {
    params ["_u"];
    ["PRIORITY", "MEDAL EARNED", format ["%1 awarded the Military Cross", name _u], nil, _u] call OpsRoom_fnc_dispatch;
}] call _fnc_btnPair;

["Test FLASH", {
    params ["_u"];
    ["FLASH", "UNIT KILLED", format ["%1 killed in action", name _u], getPosATL _u, _u] call OpsRoom_fnc_dispatch;
}, "Test ULTRA", {
    ["ULTRA", "DECRYPT", "Enemy convoy departing grid 045-089 at 0600hrs. Destination: Port Malden.", [5000, 3000, 0]] call OpsRoom_fnc_dispatch;
}] call _fnc_btnPair;

["Test SOE", {
    ["SOE", "AGENT REPORT", "Agent GARBO reports troop buildup at Malden Airfield. Estimated 2 companies.", [4000, 5000, 0]] call OpsRoom_fnc_dispatch;
}, "Test Queue (3)", {
    params ["_u"];
    ["ROUTINE", "TRAINING COMPLETE", "Recruit completed basic training"] call OpsRoom_fnc_dispatch;
    ["PRIORITY", "OPERATION UPDATE", "Op Mincemeat: 40% complete"] call OpsRoom_fnc_dispatch;
    ["FLASH", "LOCATION CAPTURED", "Factory 1 secured by British forces!", [3000, 4000, 0]] call OpsRoom_fnc_dispatch;
}] call _fnc_btnPair;

// ========================================
// CAPTURE TEST SECTION
// ========================================
_currentY = _currentY + _pad;
private _capHeader = _display ctrlCreate ["RscText", _idc];
_capHeader ctrlSetPosition [_panelX + _pad, _currentY, _panelW - _pad * 2, _btnH];
_capHeader ctrlSetText "── CAPTURE TESTS ──";
_capHeader ctrlSetFont "PuristaBold";
_capHeader ctrlSetTextColor [0.8, 0.7, 0.5, 1];
_capHeader ctrlSetBackgroundColor [0, 0, 0, 0];
_capHeader ctrlCommit 0;
_idc = _idc + 1;
_currentY = _currentY + _btnH + (_pad * 0.5);

["Flip 1st to BRITISH", {
    private _keys = keys OpsRoom_StrategicLocations;
    if (count _keys > 0) then {
        private _first = OpsRoom_StrategicLocations get (_keys select 0);
        private _name = _first get "name";
        _first set ["owner", "BRITISH"];
        _first set ["status", "friendly"];
        _first set ["captureProgress", 0];
        _first set ["contested", false];
        [_first get "id"] call OpsRoom_fnc_updateMapMarkers;
        ["PRIORITY", "LOCATION SECURED", format ["%1 captured (DEBUG)", _name], _first get "pos"] call OpsRoom_fnc_dispatch;
        systemChat format ["[DEBUG] %1 set to BRITISH", _name];
    };
}, "Flip 1st to NAZI", {
    private _keys = keys OpsRoom_StrategicLocations;
    if (count _keys > 0) then {
        private _first = OpsRoom_StrategicLocations get (_keys select 0);
        private _name = _first get "name";
        _first set ["owner", "NAZI"];
        _first set ["status", "enemy"];
        _first set ["captureProgress", 0];
        _first set ["contested", false];
        _first set ["intelPercent", 50];
        _first set ["intelTier", [50] call OpsRoom_fnc_getIntelLevel];
        [_first get "id"] call OpsRoom_fnc_updateMapMarkers;
        ["FLASH", "LOCATION LOST", format ["%1 lost (DEBUG)", _name], _first get "pos"] call OpsRoom_fnc_dispatch;
        systemChat format ["[DEBUG] %1 set to NAZI", _name];
    };
}] call _fnc_btnPair;

["Set 1st Contested", {
    private _keys = keys OpsRoom_StrategicLocations;
    if (count _keys > 0) then {
        private _first = OpsRoom_StrategicLocations get (_keys select 0);
        _first set ["contested", true];
        _first set ["captureProgress", 45];
        _first set ["captureDirection", "british"];
        [_first get "id"] call OpsRoom_fnc_updateMapMarkers;
        systemChat format ["[DEBUG] %1 set to CONTESTED (45%%)", _first get "name"];
    };
}, "Dump Locations", {
    { 
        diag_log format ["[OpsRoom] Loc: %1 | Owner: %2 | Contested: %3 | Progress: %4%% | Intel: %5%%",
            _y get "name", _y getOrDefault ["owner", "?"], _y getOrDefault ["contested", false],
            round (_y getOrDefault ["captureProgress", 0]), round (_y get "intelPercent")
        ];
        systemChat format ["%1: %2 | %3%% cap | %4%% intel",
            _y get "name", _y getOrDefault ["owner", "?"],
            round (_y getOrDefault ["captureProgress", 0]), round (_y get "intelPercent")
        ];
    } forEach OpsRoom_StrategicLocations;
}] call _fnc_btnPair;

// ========================================
// RESIZE BACKGROUND TO FIT
// ========================================
private _finalH = _currentY - _panelY + _pad;
private _bgCtrl = _display displayCtrl 9800;
if (!isNull _bgCtrl) then {
    _bgCtrl ctrlSetPosition [_panelX, _panelY, _panelW, _finalH];
    _bgCtrl ctrlCommit 0;
};

systemChat format ["[DEBUG] Panel open for %1 — %2 controls", name _unit, _idc - 9800];
diag_log format ["[OpsRoom] Debug panel: %1 IDCs used (9800-%2)", _idc - 9800, _idc - 1];
