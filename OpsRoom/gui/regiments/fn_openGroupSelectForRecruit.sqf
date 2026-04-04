/*
    Open Group Select for Recruit
    
    Shows group selection dialog for assigning recruited unit.
    Filters out special regiment groups that require qualifications
    the recruit doesn't have.
    
    Usage:
        [] call OpsRoom_fnc_openGroupSelectForRecruit;
*/

createDialog "OpsRoom_GroupSelectDialog";
waitUntil {!isNull findDisplay 8005};

private _display = findDisplay 8005;

// Populate group listbox
private _listbox = _display displayCtrl 8520;
if (!isNull _listbox) then {
    lbClear _listbox;
    
    // Get pending recruit data (if available) to check qualifications
    private _pendingRecruit = uiNamespace getVariable ["OpsRoom_PendingRecruit", createHashMap];
    
    // Get all groups
    private _allGroupIds = keys OpsRoom_Groups;
    
    if (count _allGroupIds == 0) exitWith {
        hint "No groups available! Create a group first.";
        closeDialog 0;
        [] call OpsRoom_fnc_openRecruitment;
    };
    
    private _addedCount = 0;
    
    {
        private _groupId = _x;
        private _groupData = OpsRoom_Groups get _groupId;
        if (isNil "_groupData") then { continue };
        
        private _groupName = _groupData get "name";
        private _regimentId = _groupData get "regimentId";
        
        // Get regiment data and check type
        private _regimentData = OpsRoom_Regiments get _regimentId;
        private _regimentName = if (!isNil "_regimentData") then {
            _regimentData get "name"
        } else {
            "Unknown Regiment"
        };
        
        // Check if this regiment type requires a qualification
        private _regType = if (!isNil "_regimentData") then {
            _regimentData getOrDefault ["type", "regular"]
        } else {
            "regular"
        };
        
        private _typeData = OpsRoom_RegimentTypes getOrDefault [_regType, createHashMap];
        private _reqUnitQual = if (count _typeData > 0) then {
            _typeData getOrDefault ["unitQualification", ""]
        } else {
            ""
        };
        
        // For recruits (new units), they won't have qualifications yet
        // So special regiment groups should be hidden from the recruit picker
        // (recruits must be trained THEN transferred to special regiments)
        if (_reqUnitQual != "") then {
            // Skip this group - new recruits can't join special regiments directly
            continue;
        };
        
        private _displayName = format ["%1 (%2)", _groupName, _regimentName];
        private _idx = _listbox lbAdd _displayName;
        _listbox lbSetData [_idx, _groupId];
        _addedCount = _addedCount + 1;
    } forEach _allGroupIds;
    
    if (_addedCount == 0) exitWith {
        hint "No regular groups available for recruitment. Special regiments require trained personnel.";
        closeDialog 0;
        [] call OpsRoom_fnc_openRecruitment;
    };
    
    // Auto-select first
    if (lbSize _listbox > 0) then {
        _listbox lbSetCurSel 0;
    };
};

// Setup confirm button
private _confirmBtn = _display displayCtrl 8530;
if (!isNull _confirmBtn) then {
    _confirmBtn ctrlAddEventHandler ["ButtonClick", {
        private _display = findDisplay 8005;
        private _listbox = _display displayCtrl 8520;
        private _index = lbCurSel _listbox;
        
        if (_index >= 0) then {
            private _groupId = _listbox lbData _index;
            [_groupId] call OpsRoom_fnc_spawnRecruit;
        } else {
            hint "No group selected";
        };
    }];
};

// Setup cancel button
private _cancelBtn = _display displayCtrl 8531;
if (!isNull _cancelBtn) then {
    _cancelBtn ctrlAddEventHandler ["ButtonClick", {
        closeDialog 0;
        sleep 0.1;
        [] call OpsRoom_fnc_openRecruitment;
    }];
};

diag_log "[OpsRoom] Group select dialog opened for recruitment";
