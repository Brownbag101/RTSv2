/*
    Show Add Regiment Dialog
    
    Opens a type-picker dialog (like air wing creation).
    Player selects a regiment type, then picks a qualified Major.
    
    Flow:
        1. Show type selection buttons (greys out locked types)
        2. Player clicks type -> stores selection
        3. Player clicks CONFIRM -> opens Major selection (filtered by qualification)
        4. Major selected -> regiment created with type + auto-name
    
    Usage:
        [] call OpsRoom_fnc_showAddRegiment;
*/

// Check if we already have a major selected (returning from major select dialog)
private _selectedMajor = uiNamespace getVariable ["OpsRoom_SelectedMajor", objNull];
private _selectedType = uiNamespace getVariable ["OpsRoom_SelectedRegimentType", ""];

if (!isNull _selectedMajor && _selectedType != "") exitWith {
    // We have both type and major - create the regiment
    
    // Get name pool for this type
    private _typeData = OpsRoom_RegimentTypes get _selectedType;
    private _namePoolVar = _typeData get "namePool";
    private _namePool = missionNamespace getVariable [_namePoolVar, []];
    
    // Find unused name
    private _unusedNames = _namePool select {!(_x in OpsRoom_UsedRegimentNames)};
    
    if (count _unusedNames == 0) exitWith {
        hint "All regiment names for this type have been used!";
        uiNamespace setVariable ["OpsRoom_SelectedMajor", nil];
        uiNamespace setVariable ["OpsRoom_SelectedRegimentType", nil];
    };
    
    private _selectedName = _unusedNames select 0;
    
    // Clear stored selections
    uiNamespace setVariable ["OpsRoom_SelectedMajor", nil];
    uiNamespace setVariable ["OpsRoom_SelectedRegimentType", nil];
    
    // Show confirmation
    private _typeName = _typeData get "displayName";
    hint format [
        "Creating New Regiment\n\nType: %1\nRegiment: %2\nCommanding Officer: %3 (%4)",
        _typeName,
        _selectedName,
        name _selectedMajor,
        rank _selectedMajor
    ];
    
    // Create the regiment with type
    [_selectedName, _selectedMajor, _selectedType] call OpsRoom_fnc_createRegiment;
    
    // Open the regiments dialog to see the new regiment
    [] spawn {
        sleep 0.1;
        [] call OpsRoom_fnc_openRegiments;
    };
    
    systemChat format ["New regiment formed: %1 under %2", _selectedName, name _selectedMajor];
    
    // Dispatch based on type
    private _dispatchType = if (_selectedType in ["soe", "sas", "commando"]) then { "FLASH" } else { "PRIORITY" };
    [_dispatchType, "REGIMENT FORMED", format ["%1 has been formed under the command of %2.", _selectedName, name _selectedMajor]] call OpsRoom_fnc_dispatch;
};

// No major selected yet — show type picker dialog
uiNamespace setVariable ["OpsRoom_SelectedMajor", nil];
uiNamespace setVariable ["OpsRoom_SelectedRegimentType", nil];
OpsRoom_CreateReg_SelectedType = "";

// Create dialog on empty display
createDialog "RscDisplayEmpty";
private _display = findDisplay -1;
if (isNull _display) exitWith {};

// Background
private _bg = _display ctrlCreate ["RscText", 7000];
_bg ctrlSetPosition [0.25 * safezoneW + safezoneX, 0.15 * safezoneH + safezoneY, 0.5 * safezoneW, 0.72 * safezoneH];
_bg ctrlSetBackgroundColor [0.20, 0.25, 0.18, 0.95];
_bg ctrlCommit 0;

// Title bar
private _titleBar = _display ctrlCreate ["RscText", 7001];
_titleBar ctrlSetPosition [0.25 * safezoneW + safezoneX, 0.15 * safezoneH + safezoneY, 0.5 * safezoneW, 0.045 * safezoneH];
_titleBar ctrlSetText "   FORM NEW REGIMENT";
_titleBar ctrlSetBackgroundColor [0.15, 0.20, 0.13, 1.0];
_titleBar ctrlSetTextColor [0.85, 0.82, 0.74, 1.0];
_titleBar ctrlSetFont "PuristaLight";
_titleBar ctrlCommit 0;

// Subtitle
private _subtitle = _display ctrlCreate ["RscStructuredText", 7002];
_subtitle ctrlSetPosition [0.27 * safezoneW + safezoneX, 0.21 * safezoneH + safezoneY, 0.46 * safezoneW, 0.04 * safezoneH];
_subtitle ctrlSetStructuredText parseText "<t color='#B8B5A9' size='0.9'>Select the type of regiment to form:</t>";
_subtitle ctrlCommit 0;

// Description panel (right side, updates on hover/select)
private _descBg = _display ctrlCreate ["RscText", 7050];
_descBg ctrlSetPosition [0.52 * safezoneW + safezoneX, 0.26 * safezoneH + safezoneY, 0.21 * safezoneW, 0.50 * safezoneH];
_descBg ctrlSetBackgroundColor [0.15, 0.18, 0.12, 0.8];
_descBg ctrlCommit 0;

private _descCtrl = _display ctrlCreate ["RscStructuredText", 7051];
_descCtrl ctrlSetPosition [0.53 * safezoneW + safezoneX, 0.27 * safezoneH + safezoneY, 0.19 * safezoneW, 0.48 * safezoneH];
_descCtrl ctrlSetStructuredText parseText "<t color='#B8B5A9' size='0.85'>Hover over a regiment type to see details.</t>";
_descCtrl ctrlCommit 0;

// Build type buttons
private _typeOrder = ["regular", "pioneer", "armoured", "commando", "airborne", "soe", "sas"];
private _btnIndex = 0;

{
    private _typeId = _x;
    private _typeData = OpsRoom_RegimentTypes get _typeId;
    if (isNil "_typeData") then { continue };
    
    private _typeName = _typeData get "displayName";
    private _typeDesc = _typeData get "description";
    private _reqResearch = _typeData get "requiresResearch";
    private _reqQual = _typeData get "requiresQualification";
    
    // Check if this type is available
    // Research gate: must be researched (if required)
    private _researchMet = true;
    if (_reqResearch != "") then {
        _researchMet = [_reqResearch] call OpsRoom_fnc_isResearched;
    };
    
    // Check name pool has unused names
    private _namePoolVar = _typeData get "namePool";
    private _namePool = missionNamespace getVariable [_namePoolVar, []];
    private _hasNames = count (_namePool select {!(_x in OpsRoom_UsedRegimentNames)}) > 0;
    
    // Type button unlocks on RESEARCH + NAMES only.
    // Major qualification check happens at the Major selection step.
    private _isAvailable = _researchMet && _hasNames;
    
    // Create button
    private _btn = _display ctrlCreate ["RscButton", 7100 + _btnIndex];
    _btn ctrlSetPosition [
        0.27 * safezoneW + safezoneX,
        (0.26 + (_btnIndex * 0.055)) * safezoneH + safezoneY,
        0.23 * safezoneW,
        0.045 * safezoneH
    ];
    _btn ctrlSetText (toUpper _typeName);
    _btn ctrlSetFont "PuristaLight";
    _btn setVariable ["typeId", _typeId];
    _btn setVariable ["typeDesc", _typeDesc];
    _btn setVariable ["typeName", _typeName];
    _btn setVariable ["isAvailable", _isAvailable];
    _btn setVariable ["researchMet", _researchMet];
    _btn setVariable ["reqResearch", _reqResearch];
    _btn setVariable ["reqQual", _reqQual];
    _btn ctrlCommit 0;
    
    if (_isAvailable) then {
        _btn ctrlSetBackgroundColor [0.26, 0.30, 0.21, 1.0];
        _btn ctrlSetTextColor [0.85, 0.82, 0.74, 1.0];
        
        // Click handler — select this type
        _btn ctrlAddEventHandler ["ButtonClick", {
            params ["_ctrl"];
            OpsRoom_CreateReg_SelectedType = _ctrl getVariable ["typeId", ""];
            
            // Highlight selected, unhighlight others
            private _display = ctrlParent _ctrl;
            for "_i" from 0 to 9 do {
                private _otherBtn = _display displayCtrl (7100 + _i);
                if (!isNull _otherBtn) then {
                    if ((_otherBtn getVariable ["isAvailable", false])) then {
                        _otherBtn ctrlSetBackgroundColor [0.26, 0.30, 0.21, 1.0];
                    };
                };
            };
            _ctrl ctrlSetBackgroundColor [0.3, 0.45, 0.25, 1.0];
            
            // Update description panel
            private _descCtrl = _display displayCtrl 7051;
            private _typeName = _ctrl getVariable ["typeName", ""];
            private _typeDesc = _ctrl getVariable ["typeDesc", ""];
            _descCtrl ctrlSetStructuredText parseText format [
                "<t size='1.1' font='PuristaBold' color='#D9D5C9'>%1</t><br/><br/><t color='#B8B5A9' size='0.85'>%2</t><br/><br/><t color='#80FF80' size='0.8'>AVAILABLE — Click CONFIRM to proceed.</t>",
                _typeName, _typeDesc
            ];
        }];
        
        // Hover handler — show description
        _btn ctrlAddEventHandler ["MouseEnter", {
            params ["_ctrl"];
            private _display = ctrlParent _ctrl;
            private _descCtrl = _display displayCtrl 7051;
            private _typeName = _ctrl getVariable ["typeName", ""];
            private _typeDesc = _ctrl getVariable ["typeDesc", ""];
            
            if (OpsRoom_CreateReg_SelectedType != (_ctrl getVariable ["typeId", ""])) then {
                _ctrl ctrlSetBackgroundColor [0.30, 0.35, 0.25, 1.0];
            };
            
            _descCtrl ctrlSetStructuredText parseText format [
                "<t size='1.1' font='PuristaBold' color='#D9D5C9'>%1</t><br/><br/><t color='#B8B5A9' size='0.85'>%2</t>",
                _typeName, _typeDesc
            ];
        }];
        
        _btn ctrlAddEventHandler ["MouseExit", {
            params ["_ctrl"];
            if (OpsRoom_CreateReg_SelectedType != (_ctrl getVariable ["typeId", ""])) then {
                _ctrl ctrlSetBackgroundColor [0.26, 0.30, 0.21, 1.0];
            };
        }];
    } else {
        // Disabled / locked state
        _btn ctrlSetBackgroundColor [0.15, 0.15, 0.15, 1.0];
        _btn ctrlSetTextColor [0.45, 0.45, 0.45, 1.0];
        
        // Build lock reason
        private _lockReason = "";
        if (!_researchMet) then {
            private _researchName = _reqResearch;
            // Try to get display name from equipment DB
            private _resData = OpsRoom_EquipmentDB getOrDefault [_reqResearch, createHashMap];
            if (count _resData > 0) then {
                _researchName = _resData getOrDefault ["displayName", _reqResearch];
            };
            _lockReason = format ["Requires research: %1", _researchName];
        } else {
            _lockReason = "No regiment names available";
        };
        
        _btn ctrlSetTooltip _lockReason;
        
        // Hover shows lock reason in description panel
        _btn ctrlAddEventHandler ["MouseEnter", {
            params ["_ctrl"];
            private _display = ctrlParent _ctrl;
            private _descCtrl = _display displayCtrl 7051;
            private _typeName = _ctrl getVariable ["typeName", ""];
            private _typeDesc = _ctrl getVariable ["typeDesc", ""];
            private _reqResearch = _ctrl getVariable ["reqResearch", ""];
            private _researchMet = _ctrl getVariable ["researchMet", true];
            
            private _lockText = "";
            if (!_researchMet) then {
                private _researchName = _reqResearch;
                private _resData = OpsRoom_EquipmentDB getOrDefault [_reqResearch, createHashMap];
                if (count _resData > 0) then {
                    _researchName = _resData getOrDefault ["displayName", _reqResearch];
                };
                _lockText = format ["<t color='#FF6666' size='0.8'>LOCKED: Requires research: %1</t>", _researchName];
            } else {
                _lockText = "<t color='#FF6666' size='0.8'>LOCKED: No regiment names available.</t>";
            };
            
            _descCtrl ctrlSetStructuredText parseText format [
                "<t size='1.1' font='PuristaBold' color='#666666'>%1</t><br/><br/><t color='#888888' size='0.85'>%2</t><br/><br/>%3",
                _typeName, _typeDesc, _lockText
            ];
        }];
    };
    
    _btnIndex = _btnIndex + 1;
} forEach _typeOrder;

// Confirm button
private _confirmBtn = _display ctrlCreate ["RscButton", 7200];
_confirmBtn ctrlSetPosition [0.35 * safezoneW + safezoneX, 0.78 * safezoneH + safezoneY, 0.12 * safezoneW, 0.04 * safezoneH];
_confirmBtn ctrlSetText "CONFIRM";
_confirmBtn ctrlSetBackgroundColor [0.25, 0.40, 0.25, 1.0];
_confirmBtn ctrlSetFont "PuristaLight";
_confirmBtn ctrlCommit 0;

_confirmBtn ctrlAddEventHandler ["ButtonClick", {
    params ["_ctrl"];
    
    if (OpsRoom_CreateReg_SelectedType == "") exitWith {
        systemChat "Select a regiment type first.";
    };
    
    // Store selected type
    uiNamespace setVariable ["OpsRoom_SelectedRegimentType", OpsRoom_CreateReg_SelectedType];
    
    // Close type picker
    closeDialog 0;
    
    // Open major selection (filtered by qualification)
    [] spawn {
        sleep 0.1;
        [] call OpsRoom_fnc_openMajorSelect;
    };
}];

// Cancel button
private _cancelBtn = _display ctrlCreate ["RscButton", 7201];
_cancelBtn ctrlSetPosition [0.48 * safezoneW + safezoneX, 0.78 * safezoneH + safezoneY, 0.12 * safezoneW, 0.04 * safezoneH];
_cancelBtn ctrlSetText "CANCEL";
_cancelBtn ctrlSetBackgroundColor [0.40, 0.25, 0.20, 1.0];
_cancelBtn ctrlSetFont "PuristaLight";
_cancelBtn ctrlCommit 0;

_cancelBtn ctrlAddEventHandler ["ButtonClick", {
    uiNamespace setVariable ["OpsRoom_SelectedRegimentType", nil];
    closeDialog 0;
    [] spawn {
        sleep 0.1;
        [] call OpsRoom_fnc_openRegiments;
    };
}];

diag_log "[OpsRoom] Regiment type picker opened";
