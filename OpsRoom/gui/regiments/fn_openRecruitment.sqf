/*
    Open Recruitment Dialog
    
    Opens the recruitment depot showing available recruits.
    
    Usage:
        [] call OpsRoom_fnc_openRecruitment;
*/

createDialog "OpsRoom_RecruitmentDialog";
waitUntil {!isNull findDisplay 8004};

private _display = findDisplay 8004;

// Setup back button
private _backBtn = _display displayCtrl 8411;
if (!isNull _backBtn) then {
    _backBtn ctrlAddEventHandler ["ButtonClick", {
        closeDialog 0;
    }];
};

// Setup refresh button
private _refreshBtn = _display displayCtrl 8431;
if (!isNull _refreshBtn) then {
    _refreshBtn ctrlAddEventHandler ["ButtonClick", {
        [] call OpsRoom_fnc_initRecruitmentPool;
        [] call OpsRoom_fnc_populateRecruitmentList;
        systemChat "[RECRUITMENT] Pool manually refreshed";
    }];
};

// Setup enlist button
private _enlistBtn = _display displayCtrl 8430;
if (!isNull _enlistBtn) then {
    _enlistBtn ctrlAddEventHandler ["ButtonClick", {
        [] call OpsRoom_fnc_processRecruitment;
    }];
};

// Setup listbox selection handler
private _listbox = _display displayCtrl 8421;
if (!isNull _listbox) then {
    _listbox ctrlAddEventHandler ["LBSelChanged", {
        params ["_ctrl", "_index"];
        [_index] call OpsRoom_fnc_showRecruitDetails;
    }];
};

// Populate list
[] call OpsRoom_fnc_populateRecruitmentList;

diag_log "[OpsRoom] Recruitment dialog opened";
