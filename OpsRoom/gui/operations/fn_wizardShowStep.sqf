/*
    fn_wizardShowStep
    
    Renders the current step of the operation wizard.
    Dynamically creates controls in the right content area.
    
    Parameters:
        0: NUMBER - Step number (1-5)
    
    Dynamic IDCs: 11720-11799
*/

params [["_step", 1, [0]]];

private _display = findDisplay 8012;
if (isNull _display) exitWith {};

// Store current step
OpsRoom_WizardState set ["step", _step];

// Delete old dynamic content
for "_idc" from 11720 to 11799 do {
    private _ctrl = _display displayCtrl _idc;
    if (!isNull _ctrl) then { ctrlDelete _ctrl };
};

// Content area dimensions (right of sidebar)
private _contentX = 0.26 * safezoneW + safezoneX;
private _contentY = 0.14 * safezoneH + safezoneY;
private _contentW = 0.63 * safezoneW;
private _contentH = 0.72 * safezoneH;
private _lineIDC = 11720;

// Update step indicators in sidebar
private _stepNames = ["1. NAME", "2. TARGET", "3. TASK", "4. ASSIGN", "5. CONFIRM"];
for "_i" from 0 to 4 do {
    private _labelCtrl = _display displayCtrl (11710 + _i);
    if (!isNull _labelCtrl) then {
        private _isActive = (_i + 1) == _step;
        private _isDone = (_i + 1) < _step;
        private _color = if (_isActive) then { "#FFD700" } else { if (_isDone) then { "#88CC88" } else { "#666666" } };
        private _prefix = if (_isDone) then { "✓ " } else { "" };
        _labelCtrl ctrlSetStructuredText parseText format [
            "<t color='%2' font='PuristaBold'>%3%1</t>",
            _stepNames select _i, _color, _prefix
        ];
    };
};

// ========================================
// STEP 1: NAME THE OPERATION
// ========================================
if (_step == 1) then {
    // Title
    private _titleCtrl = _display ctrlCreate ["RscStructuredText", _lineIDC];
    _titleCtrl ctrlSetPosition [_contentX, _contentY, _contentW, 0.04 * safezoneH];
    _titleCtrl ctrlSetStructuredText parseText "<t font='PuristaBold' size='1.3'>Name Your Operation</t>";
    _titleCtrl ctrlCommit 0;
    _lineIDC = _lineIDC + 1;
    
    // Instruction
    private _instrCtrl = _display ctrlCreate ["RscStructuredText", _lineIDC];
    _instrCtrl ctrlSetPosition [_contentX, _contentY + 0.05 * safezoneH, _contentW, 0.03 * safezoneH];
    _instrCtrl ctrlSetStructuredText parseText "<t color='#A0A090'>Enter a codename for this operation (e.g. Operation Mincemeat)</t>";
    _instrCtrl ctrlCommit 0;
    _lineIDC = _lineIDC + 1;
    
    // Text input field
    private _editCtrl = _display ctrlCreate ["RscEdit", _lineIDC];
    _editCtrl ctrlSetPosition [_contentX, _contentY + 0.10 * safezoneH, 0.35 * safezoneW, 0.04 * safezoneH];
    _editCtrl ctrlSetBackgroundColor [0.12, 0.14, 0.10, 0.9];
    _editCtrl ctrlSetTextColor [0.9, 0.9, 0.8, 1.0];
    _editCtrl ctrlSetFont "PuristaBold";
    _editCtrl ctrlCommit 0;
    
    // Pre-fill if going back
    private _existingName = OpsRoom_WizardState get "name";
    if (_existingName != "") then {
        _editCtrl ctrlSetText _existingName;
    };
    
    ctrlSetFocus _editCtrl;
    _lineIDC = _lineIDC + 1;
    
    // Next button
    private _nextBtn = _display ctrlCreate ["RscButton", _lineIDC];
    _nextBtn ctrlSetPosition [_contentX + _contentW - 0.10 * safezoneW, _contentY + _contentH - 0.05 * safezoneH, 0.10 * safezoneW, 0.04 * safezoneH];
    _nextBtn ctrlSetText "NEXT >";
    _nextBtn ctrlSetFont "PuristaBold";
    _nextBtn ctrlSetBackgroundColor [0.25, 0.35, 0.20, 1.0];
    _nextBtn ctrlCommit 0;
    _nextBtn setVariable ["editIDC", _lineIDC - 1];
    _nextBtn ctrlAddEventHandler ["ButtonClick", {
        params ["_ctrl"];
        private _display = findDisplay 8012;
        private _editIDC = _ctrl getVariable ["editIDC", 11722];
        private _editCtrl = _display displayCtrl _editIDC;
        private _name = ctrlText _editCtrl;
        
        if (_name == "") exitWith { systemChat "Please enter an operation name" };
        
        OpsRoom_WizardState set ["name", _name];
        [2] call OpsRoom_fnc_wizardShowStep;
    }];
    _lineIDC = _lineIDC + 1;
};

// ========================================
// STEP 2: SELECT TARGET
// ========================================
if (_step == 2) then {
    // Title
    private _titleCtrl = _display ctrlCreate ["RscStructuredText", _lineIDC];
    _titleCtrl ctrlSetPosition [_contentX, _contentY, _contentW, 0.04 * safezoneH];
    _titleCtrl ctrlSetStructuredText parseText format [
        "<t font='PuristaBold' size='1.3'>Select Target</t>  <t color='#A0A090' size='0.9'>for %1</t>",
        OpsRoom_WizardState get "name"
    ];
    _titleCtrl ctrlCommit 0;
    _lineIDC = _lineIDC + 1;
    
    // Instruction
    private _instrCtrl = _display ctrlCreate ["RscStructuredText", _lineIDC];
    _instrCtrl ctrlSetPosition [_contentX, _contentY + 0.05 * safezoneH, _contentW, 0.03 * safezoneH];
    _instrCtrl ctrlSetStructuredText parseText "<t color='#A0A090'>Choose a strategic location to target. Only discovered locations are shown.</t>";
    _instrCtrl ctrlCommit 0;
    _lineIDC = _lineIDC + 1;
    
    // List discovered locations
    private _listY = _contentY + 0.10 * safezoneH;
    private _rowH = 0.045 * safezoneH;
    private _locCount = 0;
    
    {
        private _locId = _x;
        private _locData = _y;
        private _tier = _locData get "intelTier";
        private _status = _locData get "status";
        
        // Only show discovered enemy/contested locations
        if (_tier >= 1 && _status in ["enemy", "contested"]) then {
            private _name = _locData get "name";
            private _type = _locData get "type";
            private _typeData = OpsRoom_LocationTypes getOrDefault [_type, createHashMap];
            private _typeName = if (count _typeData > 0) then { _typeData get "displayName" } else { "Unknown" };
            
            // Show type only if tier >= 2
            private _typeStr = if (_tier >= 2) then { _typeName } else { "?" };
            private _intelStr = if (_tier >= 2) then { format ["%1%%", round (_locData get "intelPercent")] } else { "Low" };
            
            // Row background
            private _bg = _display ctrlCreate ["RscText", _lineIDC];
            _bg ctrlSetPosition [_contentX, _listY, _contentW, _rowH];
            private _selected = (OpsRoom_WizardState get "targetId") == _locId;
            _bg ctrlSetBackgroundColor (if (_selected) then { [0.30, 0.40, 0.25, 0.9] } else { [0.20, 0.24, 0.16, 0.7] });
            _bg ctrlCommit 0;
            _lineIDC = _lineIDC + 1;
            
            // Location info text
            private _textCtrl = _display ctrlCreate ["RscStructuredText", _lineIDC];
            _textCtrl ctrlSetPosition [_contentX + 0.01 * safezoneW, _listY + 0.005 * safezoneH, _contentW - 0.02 * safezoneW, _rowH];
            _textCtrl ctrlSetStructuredText parseText format [
                "<t font='PuristaBold'>%1</t>   <t color='#A0A090'>Type: %2  |  Intel: %3  |  Grid: %4</t>",
                _name, _typeStr, _intelStr, mapGridPosition (_locData get "pos")
            ];
            _textCtrl ctrlCommit 0;
            _lineIDC = _lineIDC + 1;
            
            // Clickable button overlay
            private _btn = _display ctrlCreate ["RscButton", _lineIDC];
            _btn ctrlSetPosition [_contentX, _listY, _contentW, _rowH];
            _btn ctrlSetBackgroundColor [0, 0, 0, 0];
            _btn ctrlSetTextColor [0, 0, 0, 0];
            _btn ctrlSetText "";
            _btn ctrlCommit 0;
            _btn setVariable ["locId", _locId];
            _btn setVariable ["locName", _name];
            _btn setVariable ["locType", _type];
            _btn ctrlAddEventHandler ["ButtonClick", {
                params ["_ctrl"];
                private _locId = _ctrl getVariable ["locId", ""];
                private _locName = _ctrl getVariable ["locName", ""];
                private _locType = _ctrl getVariable ["locType", ""];
                
                OpsRoom_WizardState set ["targetId", _locId];
                OpsRoom_WizardState set ["targetName", _locName];
                OpsRoom_WizardState set ["targetType", _locType];
                OpsRoom_WizardState set ["taskType", ""];  // Reset task when target changes
                
                // Refresh to show selection highlight
                [2] call OpsRoom_fnc_wizardShowStep;
            }];
            _lineIDC = _lineIDC + 1;
            
            _listY = _listY + _rowH + 0.003 * safezoneH;
            _locCount = _locCount + 1;
        };
    } forEach OpsRoom_StrategicLocations;
    
    if (_locCount == 0) then {
        private _emptyCtrl = _display ctrlCreate ["RscStructuredText", _lineIDC];
        _emptyCtrl ctrlSetPosition [_contentX, _listY, _contentW, 0.04 * safezoneH];
        _emptyCtrl ctrlSetStructuredText parseText "<t color='#FF8844' align='center'>No discovered locations. Send recon units to discover targets.</t>";
        _emptyCtrl ctrlCommit 0;
        _lineIDC = _lineIDC + 1;
    };
    
    // Back button
    private _backBtn = _display ctrlCreate ["RscButton", _lineIDC];
    _backBtn ctrlSetPosition [_contentX, _contentY + _contentH - 0.05 * safezoneH, 0.08 * safezoneW, 0.04 * safezoneH];
    _backBtn ctrlSetText "< BACK";
    _backBtn ctrlSetFont "PuristaBold";
    _backBtn ctrlCommit 0;
    _backBtn ctrlAddEventHandler ["ButtonClick", { [1] call OpsRoom_fnc_wizardShowStep }];
    _lineIDC = _lineIDC + 1;
    
    // Next button (only if target selected)
    if ((OpsRoom_WizardState get "targetId") != "") then {
        private _nextBtn = _display ctrlCreate ["RscButton", _lineIDC];
        _nextBtn ctrlSetPosition [_contentX + _contentW - 0.10 * safezoneW, _contentY + _contentH - 0.05 * safezoneH, 0.10 * safezoneW, 0.04 * safezoneH];
        _nextBtn ctrlSetText "NEXT >";
        _nextBtn ctrlSetFont "PuristaBold";
        _nextBtn ctrlSetBackgroundColor [0.25, 0.35, 0.20, 1.0];
        _nextBtn ctrlCommit 0;
        _nextBtn ctrlAddEventHandler ["ButtonClick", { [3] call OpsRoom_fnc_wizardShowStep }];
        _lineIDC = _lineIDC + 1;
    };
};

// ========================================
// STEP 3: CHOOSE TASK TYPE
// ========================================
if (_step == 3) then {
    private _targetType = OpsRoom_WizardState get "targetType";
    private _targetName = OpsRoom_WizardState get "targetName";
    private _typeData = OpsRoom_LocationTypes getOrDefault [_targetType, createHashMap];
    
    // Title
    private _titleCtrl = _display ctrlCreate ["RscStructuredText", _lineIDC];
    _titleCtrl ctrlSetPosition [_contentX, _contentY, _contentW, 0.04 * safezoneH];
    _titleCtrl ctrlSetStructuredText parseText format [
        "<t font='PuristaBold' size='1.3'>Choose Task</t>  <t color='#A0A090' size='0.9'>for %1</t>",
        _targetName
    ];
    _titleCtrl ctrlCommit 0;
    _lineIDC = _lineIDC + 1;
    
    // Instruction
    private _instrCtrl = _display ctrlCreate ["RscStructuredText", _lineIDC];
    _instrCtrl ctrlSetPosition [_contentX, _contentY + 0.05 * safezoneH, _contentW, 0.03 * safezoneH];
    _instrCtrl ctrlSetStructuredText parseText "<t color='#A0A090'>Select the type of operation to conduct.</t>";
    _instrCtrl ctrlCommit 0;
    _lineIDC = _lineIDC + 1;
    
    // Get available task types for this target type
    private _taskTypes = if (count _typeData > 0) then { _typeData get "taskTypes" } else { ["Reconnoitre"] };
    
    // Task descriptions
    private _taskDescs = createHashMapFromArray [
        ["Capture", "Seize and hold this location. Requires ground forces."],
        ["Destroy", "Demolish this target. Engineers or heavy weapons recommended."],
        ["Reconnoitre", "Gather detailed intelligence on this location."],
        ["Sabotage", "Covert disruption of enemy operations. Special forces recommended."],
        ["Blockade", "Prevent enemy use of this facility."],
        ["Patrol", "Regular security sweeps of the area."],
        ["Liberate", "Free this settlement from enemy occupation."],
        ["Guard", "Defend this location against enemy attack."],
        ["Ambush", "Set up an ambush position at this location."],
        ["Raid", "Quick strike to damage or disrupt. Hit and run."],
        ["Suppress", "Pin down enemy forces at this position."],
        ["Follow", "Track and monitor target movements."],
        ["Assassinate", "Eliminate the target. Marksman or special forces."],
        ["Rescue", "Extract friendly personnel from this location."],
        ["Locate", "Find the target's position."]
    ];
    
    private _listY = _contentY + 0.10 * safezoneH;
    private _btnW = 0.20 * safezoneW;
    private _btnH = 0.06 * safezoneH;
    private _colSpacing = 0.005 * safezoneW;
    private _rowSpacing = 0.005 * safezoneH;
    private _cols = 3;
    private _col = 0;
    private _row = 0;
    
    {
        private _taskType = _x;
        private _taskDesc = _taskDescs getOrDefault [_taskType, "Conduct this operation."];
        
        private _xPos = _contentX + (_col * (_btnW + _colSpacing));
        private _yPos = _listY + (_row * (_btnH + _rowSpacing));
        
        private _selected = (OpsRoom_WizardState get "taskType") == _taskType;
        
        // Task button
        private _btn = _display ctrlCreate ["RscButton", _lineIDC];
        _btn ctrlSetPosition [_xPos, _yPos, _btnW, _btnH];
        _btn ctrlSetText (toUpper _taskType);
        _btn ctrlSetFont "PuristaBold";
        _btn ctrlSetBackgroundColor (if (_selected) then { [0.30, 0.42, 0.25, 1.0] } else { [0.22, 0.26, 0.18, 0.9] });
        _btn ctrlCommit 0;
        _btn setVariable ["taskType", _taskType];
        _btn ctrlAddEventHandler ["ButtonClick", {
            params ["_ctrl"];
            private _task = _ctrl getVariable ["taskType", ""];
            OpsRoom_WizardState set ["taskType", _task];
            [3] call OpsRoom_fnc_wizardShowStep;
        }];
        _lineIDC = _lineIDC + 1;
        
        // Description below button
        private _descCtrl = _display ctrlCreate ["RscStructuredText", _lineIDC];
        _descCtrl ctrlSetPosition [_xPos, _yPos + 0.035 * safezoneH, _btnW, 0.025 * safezoneH];
        _descCtrl ctrlSetStructuredText parseText format ["<t size='0.8' color='#888888' align='center'>%1</t>", _taskDesc];
        _descCtrl ctrlCommit 0;
        _lineIDC = _lineIDC + 1;
        
        _col = _col + 1;
        if (_col >= _cols) then { _col = 0; _row = _row + 1 };
        
    } forEach _taskTypes;
    
    // Back button
    private _backBtn = _display ctrlCreate ["RscButton", _lineIDC];
    _backBtn ctrlSetPosition [_contentX, _contentY + _contentH - 0.05 * safezoneH, 0.08 * safezoneW, 0.04 * safezoneH];
    _backBtn ctrlSetText "< BACK";
    _backBtn ctrlSetFont "PuristaBold";
    _backBtn ctrlCommit 0;
    _backBtn ctrlAddEventHandler ["ButtonClick", { [2] call OpsRoom_fnc_wizardShowStep }];
    _lineIDC = _lineIDC + 1;
    
    // Next button
    if ((OpsRoom_WizardState get "taskType") != "") then {
        private _nextBtn = _display ctrlCreate ["RscButton", _lineIDC];
        _nextBtn ctrlSetPosition [_contentX + _contentW - 0.10 * safezoneW, _contentY + _contentH - 0.05 * safezoneH, 0.10 * safezoneW, 0.04 * safezoneH];
        _nextBtn ctrlSetText "NEXT >";
        _nextBtn ctrlSetFont "PuristaBold";
        _nextBtn ctrlSetBackgroundColor [0.25, 0.35, 0.20, 1.0];
        _nextBtn ctrlCommit 0;
        _nextBtn ctrlAddEventHandler ["ButtonClick", { [4] call OpsRoom_fnc_wizardShowStep }];
        _lineIDC = _lineIDC + 1;
    };
};

// ========================================
// STEP 4: ASSIGN REGIMENTS
// ========================================
if (_step == 4) then {
    // Title
    private _titleCtrl = _display ctrlCreate ["RscStructuredText", _lineIDC];
    _titleCtrl ctrlSetPosition [_contentX, _contentY, _contentW, 0.04 * safezoneH];
    _titleCtrl ctrlSetStructuredText parseText format [
        "<t font='PuristaBold' size='1.3'>Assign Forces</t>  <t color='#A0A090' size='0.9'>%1 - %2 %3</t>",
        OpsRoom_WizardState get "name",
        toUpper (OpsRoom_WizardState get "taskType"),
        OpsRoom_WizardState get "targetName"
    ];
    _titleCtrl ctrlCommit 0;
    _lineIDC = _lineIDC + 1;
    
    // Instruction
    private _instrCtrl = _display ctrlCreate ["RscStructuredText", _lineIDC];
    _instrCtrl ctrlSetPosition [_contentX, _contentY + 0.05 * safezoneH, _contentW, 0.03 * safezoneH];
    _instrCtrl ctrlSetStructuredText parseText "<t color='#A0A090'>Select regiment(s) to assign to this operation. Click to toggle.</t>";
    _instrCtrl ctrlCommit 0;
    _lineIDC = _lineIDC + 1;
    
    private _listY = _contentY + 0.10 * safezoneH;
    private _rowH = 0.05 * safezoneH;
    private _selectedRegs = OpsRoom_WizardState get "regiments";
    
    {
        private _regId = _x;
        private _regData = _y;
        private _regName = _regData get "name";
        private _groups = _regData get "groups";
        private _major = _regData get "major";
        
        // Count total units across groups
        private _totalUnits = 0;
        { 
            private _groupData = OpsRoom_Groups getOrDefault [_x, createHashMap];
            if (count _groupData > 0) then {
                _totalUnits = _totalUnits + count (_groupData get "units");
            };
        } forEach _groups;
        
        private _majorName = if (!isNull _major && alive _major) then { name _major } else { "None" };
        private _isSelected = _regId in _selectedRegs;
        
        // Row background
        private _bg = _display ctrlCreate ["RscText", _lineIDC];
        _bg ctrlSetPosition [_contentX, _listY, _contentW, _rowH];
        _bg ctrlSetBackgroundColor (if (_isSelected) then { [0.28, 0.38, 0.22, 0.9] } else { [0.20, 0.24, 0.16, 0.7] });
        _bg ctrlCommit 0;
        _lineIDC = _lineIDC + 1;
        
        // Checkbox indicator
        private _checkStr = if (_isSelected) then { "[✓]" } else { "[ ]" };
        
        // Regiment info
        private _textCtrl = _display ctrlCreate ["RscStructuredText", _lineIDC];
        _textCtrl ctrlSetPosition [_contentX + 0.01 * safezoneW, _listY + 0.005 * safezoneH, _contentW - 0.02 * safezoneW, _rowH];
        _textCtrl ctrlSetStructuredText parseText format [
            "<t font='PuristaBold' color='%5'>%4</t>  <t font='PuristaBold'>%1</t>   <t color='#A0A090'>CO: %2  |  Groups: %3  |  Strength: %6</t>",
            _regName, _majorName, count _groups, _checkStr,
            if (_isSelected) then { "#88FF88" } else { "#888888" },
            _totalUnits
        ];
        _textCtrl ctrlCommit 0;
        _lineIDC = _lineIDC + 1;
        
        // Clickable overlay
        private _btn = _display ctrlCreate ["RscButton", _lineIDC];
        _btn ctrlSetPosition [_contentX, _listY, _contentW, _rowH];
        _btn ctrlSetBackgroundColor [0, 0, 0, 0];
        _btn ctrlSetTextColor [0, 0, 0, 0];
        _btn ctrlSetText "";
        _btn ctrlCommit 0;
        _btn setVariable ["regId", _regId];
        _btn setVariable ["regName", _regName];
        _btn ctrlAddEventHandler ["ButtonClick", {
            params ["_ctrl"];
            private _regId = _ctrl getVariable ["regId", ""];
            private _regName = _ctrl getVariable ["regName", ""];
            private _regs = OpsRoom_WizardState get "regiments";
            private _regNames = OpsRoom_WizardState get "regimentNames";
            
            if (_regId in _regs) then {
                // Deselect
                _regs = _regs - [_regId];
                _regNames = _regNames - [_regName];
            } else {
                // Select
                _regs pushBack _regId;
                _regNames pushBack _regName;
            };
            
            OpsRoom_WizardState set ["regiments", _regs];
            OpsRoom_WizardState set ["regimentNames", _regNames];
            [4] call OpsRoom_fnc_wizardShowStep;
        }];
        _lineIDC = _lineIDC + 1;
        
        _listY = _listY + _rowH + 0.003 * safezoneH;
    } forEach OpsRoom_Regiments;
    
    if (count OpsRoom_Regiments == 0) then {
        private _emptyCtrl = _display ctrlCreate ["RscStructuredText", _lineIDC];
        _emptyCtrl ctrlSetPosition [_contentX, _listY, _contentW, 0.04 * safezoneH];
        _emptyCtrl ctrlSetStructuredText parseText "<t color='#FF8844' align='center'>No regiments available. Create regiments first.</t>";
        _emptyCtrl ctrlCommit 0;
        _lineIDC = _lineIDC + 1;
    };
    
    // Back button
    private _backBtn = _display ctrlCreate ["RscButton", _lineIDC];
    _backBtn ctrlSetPosition [_contentX, _contentY + _contentH - 0.05 * safezoneH, 0.08 * safezoneW, 0.04 * safezoneH];
    _backBtn ctrlSetText "< BACK";
    _backBtn ctrlSetFont "PuristaBold";
    _backBtn ctrlCommit 0;
    _backBtn ctrlAddEventHandler ["ButtonClick", { [3] call OpsRoom_fnc_wizardShowStep }];
    _lineIDC = _lineIDC + 1;
    
    // Next button
    if (count (OpsRoom_WizardState get "regiments") > 0) then {
        private _nextBtn = _display ctrlCreate ["RscButton", _lineIDC];
        _nextBtn ctrlSetPosition [_contentX + _contentW - 0.10 * safezoneW, _contentY + _contentH - 0.05 * safezoneH, 0.10 * safezoneW, 0.04 * safezoneH];
        _nextBtn ctrlSetText "NEXT >";
        _nextBtn ctrlSetFont "PuristaBold";
        _nextBtn ctrlSetBackgroundColor [0.25, 0.35, 0.20, 1.0];
        _nextBtn ctrlCommit 0;
        _nextBtn ctrlAddEventHandler ["ButtonClick", { [5] call OpsRoom_fnc_wizardShowStep }];
        _lineIDC = _lineIDC + 1;
    };
};

// ========================================
// STEP 5: CONFIRM AND CREATE
// ========================================
if (_step == 5) then {
    // Title
    private _titleCtrl = _display ctrlCreate ["RscStructuredText", _lineIDC];
    _titleCtrl ctrlSetPosition [_contentX, _contentY, _contentW, 0.04 * safezoneH];
    _titleCtrl ctrlSetStructuredText parseText "<t font='PuristaBold' size='1.3'>Confirm Operation</t>";
    _titleCtrl ctrlCommit 0;
    _lineIDC = _lineIDC + 1;
    
    // Summary
    private _summaryY = _contentY + 0.06 * safezoneH;
    private _rowH = 0.035 * safezoneH;
    
    private _fnc_summaryLine = {
        params ["_label", "_value"];
        private _ctrl = _display ctrlCreate ["RscStructuredText", _lineIDC];
        _ctrl ctrlSetPosition [_contentX, _summaryY, _contentW, _rowH];
        _ctrl ctrlSetStructuredText parseText format [
            "<t font='PuristaBold' color='#A0A090' size='1.0'>%1:</t>  <t size='1.1'>%2</t>",
            _label, _value
        ];
        _ctrl ctrlCommit 0;
        _summaryY = _summaryY + _rowH;
        _lineIDC = _lineIDC + 1;
    };
    
    ["Operation Name", OpsRoom_WizardState get "name"] call _fnc_summaryLine;
    ["Target", OpsRoom_WizardState get "targetName"] call _fnc_summaryLine;
    ["Task Type", toUpper (OpsRoom_WizardState get "taskType")] call _fnc_summaryLine;
    ["Assigned Forces", (OpsRoom_WizardState get "regimentNames") joinString ", "] call _fnc_summaryLine;
    
    // Divider
    _summaryY = _summaryY + 0.02 * safezoneH;
    private _divCtrl = _display ctrlCreate ["RscText", _lineIDC];
    _divCtrl ctrlSetPosition [_contentX, _summaryY, _contentW, 0.002 * safezoneH];
    _divCtrl ctrlSetBackgroundColor [0.4, 0.35, 0.25, 0.6];
    _divCtrl ctrlCommit 0;
    _lineIDC = _lineIDC + 1;
    _summaryY = _summaryY + 0.02 * safezoneH;
    
    // Confirmation message
    private _confirmCtrl = _display ctrlCreate ["RscStructuredText", _lineIDC];
    _confirmCtrl ctrlSetPosition [_contentX, _summaryY, _contentW, 0.04 * safezoneH];
    _confirmCtrl ctrlSetStructuredText parseText "<t color='#FFCC44' align='center'>Review the above details and click CREATE to launch this operation.</t>";
    _confirmCtrl ctrlCommit 0;
    _lineIDC = _lineIDC + 1;
    
    // Back button
    private _backBtn = _display ctrlCreate ["RscButton", _lineIDC];
    _backBtn ctrlSetPosition [_contentX, _contentY + _contentH - 0.05 * safezoneH, 0.08 * safezoneW, 0.04 * safezoneH];
    _backBtn ctrlSetText "< BACK";
    _backBtn ctrlSetFont "PuristaBold";
    _backBtn ctrlCommit 0;
    _backBtn ctrlAddEventHandler ["ButtonClick", { [4] call OpsRoom_fnc_wizardShowStep }];
    _lineIDC = _lineIDC + 1;
    
    // CREATE button (big, green)
    private _createBtn = _display ctrlCreate ["RscButton", _lineIDC];
    _createBtn ctrlSetPosition [_contentX + _contentW - 0.15 * safezoneW, _contentY + _contentH - 0.06 * safezoneH, 0.15 * safezoneW, 0.05 * safezoneH];
    _createBtn ctrlSetText "CREATE OPERATION";
    _createBtn ctrlSetFont "PuristaBold";
    _createBtn ctrlSetBackgroundColor [0.20, 0.45, 0.15, 1.0];
    _createBtn ctrlCommit 0;
    _createBtn ctrlAddEventHandler ["ButtonClick", {
        [] spawn {
            [] call OpsRoom_fnc_createOperation;
            closeDialog 0;
            sleep 0.1;
            [] call OpsRoom_fnc_openOperations;
        };
    }];
    _lineIDC = _lineIDC + 1;
};
