/*
    fn_openOperationDetail
    
    Shows detailed view of a single operation.
    
    Parameters:
        0: STRING - Operation ID
*/

params [["_opId", "", [""]]];

if (_opId == "") exitWith { systemChat "No operation ID provided" };

private _opData = OpsRoom_Operations getOrDefault [_opId, createHashMap];
if (count _opData == 0) exitWith { systemChat "Operation not found" };

createDialog "OpsRoom_OperationDetailDialog";
waitUntil {!isNull findDisplay 8013};

private _display = findDisplay 8013;

// Back button → return to dashboard
private _backBtn = _display displayCtrl 11801;
if (!isNull _backBtn) then {
    _backBtn ctrlAddEventHandler ["ButtonClick", {
        [] spawn {
            closeDialog 0;
            sleep 0.1;
            [] call OpsRoom_fnc_openOperations;
        };
    }];
};

// Update title
private _titleCtrl = _display displayCtrl 11800;
if (!isNull _titleCtrl) then {
    _titleCtrl ctrlSetText (toUpper (_opData get "name"));
};

// Populate detail content dynamically
private _contentX = 0.22 * safezoneW + safezoneX;
private _contentY = 0.16 * safezoneH + safezoneY;
private _contentW = 0.56 * safezoneW;
private _rowH = 0.032 * safezoneH;
private _lineIDC = 11820;

// Helper: add line
private _fnc_addLine = {
    params ["_label", "_value", ["_color", "#D9D5C9"]];
    private _ctrl = _display ctrlCreate ["RscStructuredText", _lineIDC];
    _ctrl ctrlSetPosition [_contentX, _contentY, _contentW, _rowH];
    _ctrl ctrlSetStructuredText parseText format [
        "<t font='PuristaBold' color='#A0A090'>%1:</t>  <t color='%3'>%2</t>",
        _label, _value, _color
    ];
    _ctrl ctrlCommit 0;
    _contentY = _contentY + _rowH;
    _lineIDC = _lineIDC + 1;
};

// Helper: section header
private _fnc_addSection = {
    params ["_title"];
    _contentY = _contentY + 0.01 * safezoneH;
    private _ctrl = _display ctrlCreate ["RscStructuredText", _lineIDC];
    _ctrl ctrlSetPosition [_contentX, _contentY, _contentW, _rowH];
    _ctrl ctrlSetStructuredText parseText format [
        "<t font='PuristaBold' size='1.05' color='#C8C0A8'>── %1 ──</t>", _title
    ];
    _ctrl ctrlCommit 0;
    _contentY = _contentY + _rowH + 0.005 * safezoneH;
    _lineIDC = _lineIDC + 1;
};

// ── OPERATION INFO ──
private _name = _opData get "name";
private _nameCtrl = _display ctrlCreate ["RscStructuredText", _lineIDC];
_nameCtrl ctrlSetPosition [_contentX, _contentY, _contentW, 0.04 * safezoneH];
_nameCtrl ctrlSetStructuredText parseText format ["<t font='PuristaBold' size='1.4'>%1</t>", _name];
_nameCtrl ctrlCommit 0;
_contentY = _contentY + 0.05 * safezoneH;
_lineIDC = _lineIDC + 1;

// Status
private _status = _opData get "status";
private _statusColor = switch (_status) do {
    case "active": { "#44CC44" };
    case "planning": { "#FFCC44" };
    case "complete": { "#44FF88" };
    case "failed": { "#FF4444" };
    default { "#888888" };
};
["Status", toUpper _status, _statusColor] call _fnc_addLine;

// Progress bar
private _progress = _opData get "progress";
["Progress", format ["%1%%", round _progress]] call _fnc_addLine;

// Progress bar visual
private _barBg = _display ctrlCreate ["RscText", _lineIDC];
_barBg ctrlSetPosition [_contentX, _contentY, _contentW * 0.6, 0.012 * safezoneH];
_barBg ctrlSetBackgroundColor [0.1, 0.1, 0.1, 0.6];
_barBg ctrlCommit 0;
_lineIDC = _lineIDC + 1;

private _barFill = _display ctrlCreate ["RscText", _lineIDC];
_barFill ctrlSetPosition [_contentX, _contentY, (_contentW * 0.6) * (_progress / 100), 0.012 * safezoneH];
_barFill ctrlSetBackgroundColor [0.4, 0.6, 0.3, 0.9];
_barFill ctrlCommit 0;
_lineIDC = _lineIDC + 1;
_contentY = _contentY + 0.025 * safezoneH;

// ── TARGET ──
["TARGET"] call _fnc_addSection;
["Target", _opData get "targetName"] call _fnc_addLine;
["Task", toUpper (_opData get "taskType")] call _fnc_addLine;

// Get target intel if available
private _targetId = _opData get "targetId";
private _locData = OpsRoom_StrategicLocations getOrDefault [_targetId, createHashMap];
if (count _locData > 0) then {
    private _intelPercent = _locData get "intelPercent";
    private _tier = [_intelPercent] call OpsRoom_fnc_getIntelLevel;
    private _tierNames = ["Unknown", "Detected", "Identified", "Observed", "Detailed", "Compromised"];
    ["Intel", format ["%1 (%2%%)", _tierNames select _tier, round _intelPercent]] call _fnc_addLine;
    ["Grid Ref", mapGridPosition (_locData get "pos")] call _fnc_addLine;
};

// ── ASSIGNED FORCES ──
["ASSIGNED FORCES"] call _fnc_addSection;
private _regNames = _opData get "regimentNames";
private _regs = _opData get "regiments";
{
    private _regId = _x;
    private _regData = OpsRoom_Regiments getOrDefault [_regId, createHashMap];
    if (count _regData > 0) then {
        private _regName = _regData get "name";
        private _groups = _regData get "groups";
        private _totalUnits = 0;
        {
            private _groupData = OpsRoom_Groups getOrDefault [_x, createHashMap];
            if (count _groupData > 0) then {
                _totalUnits = _totalUnits + count (_groupData get "units");
            };
        } forEach _groups;
        [_regName, format ["%1 groups, %2 personnel", count _groups, _totalUnits]] call _fnc_addLine;
    };
} forEach _regs;

// ── TIME ──
["TIMELINE"] call _fnc_addSection;
private _created = _opData get "created";
private _elapsed = round (time - _created);
private _elapsedStr = if (_elapsed < 60) then { format ["%1 seconds", _elapsed] }
    else { if (_elapsed < 3600) then { format ["%1 minutes", round (_elapsed / 60)] }
    else { format ["%1 hours", round (_elapsed / 3600)] }};
["Created", format ["%1 ago", _elapsedStr]] call _fnc_addLine;

// ── ACTION BUTTONS ──
_contentY = _contentY + 0.02 * safezoneH;

// Complete operation button
private _completeBtn = _display ctrlCreate ["RscButton", _lineIDC];
_completeBtn ctrlSetPosition [_contentX, _contentY, 0.12 * safezoneW, 0.04 * safezoneH];
_completeBtn ctrlSetText "MARK COMPLETE";
_completeBtn ctrlSetFont "PuristaBold";
_completeBtn ctrlSetBackgroundColor [0.20, 0.40, 0.15, 1.0];
_completeBtn ctrlCommit 0;
_completeBtn setVariable ["opId", _opId];
_completeBtn ctrlAddEventHandler ["ButtonClick", {
    params ["_ctrl"];
    private _opId = _ctrl getVariable ["opId", ""];
    private _opData = OpsRoom_Operations get _opId;
    _opData set ["status", "complete"];
    _opData set ["progress", 100];
    OpsRoom_Operations set [_opId, _opData];
    // Write to unit service records
    [_opId, "complete"] call OpsRoom_fnc_writeOperationService;
    systemChat format ["Operation %1 marked COMPLETE", _opData get "name"];
    [] spawn {
        closeDialog 0;
        sleep 0.1;
        [] call OpsRoom_fnc_openOperations;
    };
}];
_lineIDC = _lineIDC + 1;

// Fail operation button
private _failBtn = _display ctrlCreate ["RscButton", _lineIDC];
_failBtn ctrlSetPosition [_contentX + 0.14 * safezoneW, _contentY, 0.12 * safezoneW, 0.04 * safezoneH];
_failBtn ctrlSetText "MARK FAILED";
_failBtn ctrlSetFont "PuristaBold";
_failBtn ctrlSetBackgroundColor [0.40, 0.15, 0.15, 1.0];
_failBtn ctrlCommit 0;
_failBtn setVariable ["opId", _opId];
_failBtn ctrlAddEventHandler ["ButtonClick", {
    params ["_ctrl"];
    private _opId = _ctrl getVariable ["opId", ""];
    private _opData = OpsRoom_Operations get _opId;
    _opData set ["status", "failed"];
    OpsRoom_Operations set [_opId, _opData];
    // Write to unit service records
    [_opId, "failed"] call OpsRoom_fnc_writeOperationService;
    systemChat format ["Operation %1 marked FAILED", _opData get "name"];
    [] spawn {
        closeDialog 0;
        sleep 0.1;
        [] call OpsRoom_fnc_openOperations;
    };
}];
_lineIDC = _lineIDC + 1;
