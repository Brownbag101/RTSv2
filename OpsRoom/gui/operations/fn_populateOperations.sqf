/*
    fn_populateOperations
    
    Fills the Operations Dashboard with current operations.
    Creates dynamic controls for each operation entry.
    
    Dynamic IDCs: 11620-11699
*/

private _display = findDisplay 8011;
if (isNull _display) exitWith {};

// Delete old dynamic controls
for "_idc" from 11620 to 11699 do {
    private _ctrl = _display displayCtrl _idc;
    if (!isNull _ctrl) then { ctrlDelete _ctrl };
};

private _startX = 0.16 * safezoneW + safezoneX;
private _contentW = 0.68 * safezoneW;
private _rowH = 0.055 * safezoneH;
private _padding = 0.005 * safezoneH;
private _lineIDC = 11620;

// Sort operations: active first, then completed, then failed
private _activeOps = [];
private _completedOps = [];
private _failedOps = [];

{
    private _opData = _y;
    private _status = _opData get "status";
    switch (_status) do {
        case "planning";
        case "active": { _activeOps pushBack [_x, _opData] };
        case "complete": { _completedOps pushBack [_x, _opData] };
        case "failed": { _failedOps pushBack [_x, _opData] };
    };
} forEach OpsRoom_Operations;

private _currentY = 0.27 * safezoneH + safezoneY;

// Helper: create an operation row
private _fnc_createOpRow = {
    params ["_opId", "_opData"];
    
    private _name = _opData get "name";
    private _taskType = _opData get "taskType";
    private _targetName = _opData get "targetName";
    private _status = _opData get "status";
    private _progress = _opData get "progress";
    
    // Row background
    private _bgColor = switch (_status) do {
        case "active": { [0.22, 0.26, 0.18, 0.8] };
        case "planning": { [0.25, 0.25, 0.18, 0.8] };
        case "complete": { [0.18, 0.28, 0.18, 0.6] };
        case "failed": { [0.30, 0.18, 0.18, 0.6] };
        default { [0.22, 0.22, 0.18, 0.8] };
    };
    
    private _bg = _display ctrlCreate ["RscText", _lineIDC];
    _bg ctrlSetPosition [_startX, _currentY, _contentW, _rowH];
    _bg ctrlSetBackgroundColor _bgColor;
    _bg ctrlCommit 0;
    _lineIDC = _lineIDC + 1;
    
    // Operation name (left)
    private _nameCtrl = _display ctrlCreate ["RscStructuredText", _lineIDC];
    _nameCtrl ctrlSetPosition [_startX + 0.01 * safezoneW, _currentY + 0.005 * safezoneH, 0.22 * safezoneW, _rowH - 0.01 * safezoneH];
    _nameCtrl ctrlSetStructuredText parseText format [
        "<t font='PuristaBold' size='1.05'>%1</t><br/><t size='0.85' color='#A0A090'>%2 %3</t>",
        _name, toUpper _taskType, _targetName
    ];
    _nameCtrl ctrlCommit 0;
    _lineIDC = _lineIDC + 1;
    
    // Status + Progress (centre)
    private _statusColor = switch (_status) do {
        case "active": { "#44CC44" };
        case "planning": { "#FFCC44" };
        case "complete": { "#44FF88" };
        case "failed": { "#FF4444" };
        default { "#888888" };
    };
    
    private _statusCtrl = _display ctrlCreate ["RscStructuredText", _lineIDC];
    _statusCtrl ctrlSetPosition [_startX + 0.35 * safezoneW, _currentY + 0.008 * safezoneH, 0.15 * safezoneW, _rowH - 0.01 * safezoneH];
    _statusCtrl ctrlSetStructuredText parseText format [
        "<t align='center' color='%2'>%1</t>",
        toUpper _status, _statusColor
    ];
    _statusCtrl ctrlCommit 0;
    _lineIDC = _lineIDC + 1;
    
    // Progress bar background
    private _barBgCtrl = _display ctrlCreate ["RscText", _lineIDC];
    _barBgCtrl ctrlSetPosition [_startX + 0.50 * safezoneW, _currentY + 0.02 * safezoneH, 0.12 * safezoneW, 0.012 * safezoneH];
    _barBgCtrl ctrlSetBackgroundColor [0.1, 0.1, 0.1, 0.6];
    _barBgCtrl ctrlCommit 0;
    _lineIDC = _lineIDC + 1;
    
    // Progress bar fill
    private _barFillW = (0.12 * safezoneW) * (_progress / 100);
    private _barFillCtrl = _display ctrlCreate ["RscText", _lineIDC];
    _barFillCtrl ctrlSetPosition [_startX + 0.50 * safezoneW, _currentY + 0.02 * safezoneH, _barFillW, 0.012 * safezoneH];
    private _barColor = if (_status == "complete") then { [0.2, 0.7, 0.3, 0.9] } else { [0.6, 0.5, 0.2, 0.9] };
    _barFillCtrl ctrlSetBackgroundColor _barColor;
    _barFillCtrl ctrlCommit 0;
    _lineIDC = _lineIDC + 1;
    
    // Clickable overlay button
    private _btnCtrl = _display ctrlCreate ["RscButton", _lineIDC];
    _btnCtrl ctrlSetPosition [_startX, _currentY, _contentW, _rowH];
    _btnCtrl ctrlSetBackgroundColor [0, 0, 0, 0];
    _btnCtrl ctrlSetTextColor [0, 0, 0, 0];
    _btnCtrl ctrlSetText "";
    _btnCtrl ctrlCommit 0;
    _btnCtrl setVariable ["opId", _opId];
    _btnCtrl ctrlAddEventHandler ["ButtonClick", {
        params ["_ctrl"];
        private _opId = _ctrl getVariable ["opId", ""];
        if (_opId != "") then {
            uiNamespace setVariable ["OpsRoom_SelectedOpId", _opId];
            [] spawn {
                private _id = uiNamespace getVariable ["OpsRoom_SelectedOpId", ""];
                closeDialog 0;
                sleep 0.1;
                [_id] call OpsRoom_fnc_openOperationDetail;
            };
        };
    }];
    _lineIDC = _lineIDC + 1;
    
    _currentY = _currentY + _rowH + _padding;
};

// ── ACTIVE OPERATIONS SECTION ──
if (count _activeOps > 0) then {
    private _sectionCtrl = _display ctrlCreate ["RscStructuredText", _lineIDC];
    _sectionCtrl ctrlSetPosition [_startX, _currentY, _contentW, 0.03 * safezoneH];
    _sectionCtrl ctrlSetStructuredText parseText "<t font='PuristaBold' color='#C8C0A8'>── ACTIVE OPERATIONS ──</t>";
    _sectionCtrl ctrlCommit 0;
    _lineIDC = _lineIDC + 1;
    _currentY = _currentY + 0.035 * safezoneH;
    
    {
        _x params ["_opId", "_opData"];
        [_opId, _opData] call _fnc_createOpRow;
    } forEach _activeOps;
};

// ── COMPLETED OPERATIONS SECTION ──
if (count _completedOps > 0) then {
    _currentY = _currentY + 0.01 * safezoneH;
    private _sectionCtrl = _display ctrlCreate ["RscStructuredText", _lineIDC];
    _sectionCtrl ctrlSetPosition [_startX, _currentY, _contentW, 0.03 * safezoneH];
    _sectionCtrl ctrlSetStructuredText parseText "<t font='PuristaBold' color='#88AA88'>── COMPLETED OPERATIONS ──</t>";
    _sectionCtrl ctrlCommit 0;
    _lineIDC = _lineIDC + 1;
    _currentY = _currentY + 0.035 * safezoneH;
    
    {
        _x params ["_opId", "_opData"];
        [_opId, _opData] call _fnc_createOpRow;
    } forEach _completedOps;
};

// ── FAILED OPERATIONS SECTION ──
if (count _failedOps > 0) then {
    _currentY = _currentY + 0.01 * safezoneH;
    private _sectionCtrl = _display ctrlCreate ["RscStructuredText", _lineIDC];
    _sectionCtrl ctrlSetPosition [_startX, _currentY, _contentW, 0.03 * safezoneH];
    _sectionCtrl ctrlSetStructuredText parseText "<t font='PuristaBold' color='#CC6666'>── FAILED OPERATIONS ──</t>";
    _sectionCtrl ctrlCommit 0;
    _lineIDC = _lineIDC + 1;
    _currentY = _currentY + 0.035 * safezoneH;
    
    {
        _x params ["_opId", "_opData"];
        [_opId, _opData] call _fnc_createOpRow;
    } forEach _failedOps;
};

// No operations yet?
if (count OpsRoom_Operations == 0) then {
    private _emptyCtrl = _display ctrlCreate ["RscStructuredText", _lineIDC];
    _emptyCtrl ctrlSetPosition [_startX, 0.35 * safezoneH + safezoneY, _contentW, 0.06 * safezoneH];
    _emptyCtrl ctrlSetStructuredText parseText "<t align='center' size='1.1' color='#888888'>No operations created yet.<br/>Click CREATE NEW OPERATION to begin planning.</t>";
    _emptyCtrl ctrlCommit 0;
    _lineIDC = _lineIDC + 1;
};

// Update status bar
private _statusCtrl = _display displayCtrl 11603;
if (!isNull _statusCtrl) then {
    _statusCtrl ctrlSetStructuredText parseText format [
        "<t align='center'>Active: %1  |  Completed: %2  |  Failed: %3  |  Total Locations: %4</t>",
        count _activeOps,
        count _completedOps,
        count _failedOps,
        count OpsRoom_StrategicLocations
    ];
};
