/*
    Open Hangar Browser
    
    Shows all aircraft in the hangar with filter tabs.
    Camera moves to hangar marker.
*/

OpsRoom_HangarFilter = "";  // Current filter ("" = all)

createDialog "OpsRoom_HangarDialog";
waitUntil {!isNull findDisplay 11003};

private _display = findDisplay 11003;

// Back button
private _backBtn = _display displayCtrl 11501;
_backBtn ctrlAddEventHandler ["ButtonClick", {
    // Clean up preview
    [] call OpsRoom_fnc_deletePreviewAircraft;
    closeDialog 0;
    [] spawn OpsRoom_fnc_openAirOps;
}];

// Filter tab handlers
private _tabFilters = [["", 11510], ["Fighter", 11511], ["GroundAttack", 11512], ["Bomber", 11513], ["Recon", 11514], ["Transport", 11515]];
{
    _x params ["_filter", "_idc"];
    private _tabBtn = _display displayCtrl _idc;
    _tabBtn setVariable ["filter", _filter];
    _tabBtn ctrlAddEventHandler ["ButtonClick", {
        params ["_ctrl"];
        OpsRoom_HangarFilter = _ctrl getVariable ["filter", ""];
        
        // Update tab highlights
        private _display = ctrlParent _ctrl;
        {
            private _btn = _display displayCtrl _x;
            if (!isNull _btn) then {
                _btn ctrlSetBackgroundColor [0.26, 0.30, 0.21, 1.0];
            };
        } forEach [11510, 11511, 11512, 11513, 11514, 11515];
        _ctrl ctrlSetBackgroundColor [0.30, 0.35, 0.25, 1.0];
        
        // Repopulate
        [] call OpsRoom_fnc_populateHangarGrid;
    }];
} forEach _tabFilters;

// Service all buttons
(_display displayCtrl 11580) ctrlAddEventHandler ["ButtonClick", {
    { [_x, "repair"] call OpsRoom_fnc_repairAircraft } forEach (keys OpsRoom_Hangar);
    [] call OpsRoom_fnc_populateHangarGrid;
}];
(_display displayCtrl 11581) ctrlAddEventHandler ["ButtonClick", {
    { [_x, "rearm"] call OpsRoom_fnc_repairAircraft } forEach (keys OpsRoom_Hangar);
    [] call OpsRoom_fnc_populateHangarGrid;
}];
(_display displayCtrl 11582) ctrlAddEventHandler ["ButtonClick", {
    { [_x, "refuel"] call OpsRoom_fnc_repairAircraft } forEach (keys OpsRoom_Hangar);
    [] call OpsRoom_fnc_populateHangarGrid;
}];

// Auto-service toggle helper
private _fnc_updateAutoBtn = {
    params ["_ctrl", "_enabled", "_label"];
    if (_enabled) then {
        _ctrl ctrlSetText format ["%1: ON", _label];
        _ctrl ctrlSetBackgroundColor [0.25, 0.40, 0.20, 1.0];
    } else {
        _ctrl ctrlSetText format ["%1: OFF", _label];
        _ctrl ctrlSetBackgroundColor [0.35, 0.25, 0.20, 1.0];
    };
};

// Auto-repair toggle
private _autoRepairBtn = _display displayCtrl 11583;
[_autoRepairBtn, OpsRoom_AutoRepair, "AUTO-REPAIR"] call _fnc_updateAutoBtn;
_autoRepairBtn ctrlAddEventHandler ["ButtonClick", {
    OpsRoom_AutoRepair = !OpsRoom_AutoRepair;
    private _ctrl = _this select 0;
    if (OpsRoom_AutoRepair) then {
        _ctrl ctrlSetText "AUTO-REPAIR: ON";
        _ctrl ctrlSetBackgroundColor [0.25, 0.40, 0.20, 1.0];
        systemChat "Auto-repair ENABLED";
    } else {
        _ctrl ctrlSetText "AUTO-REPAIR: OFF";
        _ctrl ctrlSetBackgroundColor [0.35, 0.25, 0.20, 1.0];
        systemChat "Auto-repair DISABLED";
    };
}];

// Auto-rearm toggle
private _autoRearmBtn = _display displayCtrl 11584;
[_autoRearmBtn, OpsRoom_AutoRearm, "AUTO-REARM"] call _fnc_updateAutoBtn;
_autoRearmBtn ctrlAddEventHandler ["ButtonClick", {
    OpsRoom_AutoRearm = !OpsRoom_AutoRearm;
    private _ctrl = _this select 0;
    if (OpsRoom_AutoRearm) then {
        _ctrl ctrlSetText "AUTO-REARM: ON";
        _ctrl ctrlSetBackgroundColor [0.25, 0.40, 0.20, 1.0];
        systemChat "Auto-rearm ENABLED";
    } else {
        _ctrl ctrlSetText "AUTO-REARM: OFF";
        _ctrl ctrlSetBackgroundColor [0.35, 0.25, 0.20, 1.0];
        systemChat "Auto-rearm DISABLED";
    };
}];

// Auto-refuel toggle
private _autoRefuelBtn = _display displayCtrl 11585;
[_autoRefuelBtn, OpsRoom_AutoRefuel, "AUTO-REFUEL"] call _fnc_updateAutoBtn;
_autoRefuelBtn ctrlAddEventHandler ["ButtonClick", {
    OpsRoom_AutoRefuel = !OpsRoom_AutoRefuel;
    private _ctrl = _this select 0;
    if (OpsRoom_AutoRefuel) then {
        _ctrl ctrlSetText "AUTO-REFUEL: ON";
        _ctrl ctrlSetBackgroundColor [0.25, 0.40, 0.20, 1.0];
        systemChat "Auto-refuel ENABLED";
    } else {
        _ctrl ctrlSetText "AUTO-REFUEL: OFF";
        _ctrl ctrlSetBackgroundColor [0.35, 0.25, 0.20, 1.0];
        systemChat "Auto-refuel DISABLED";
    };
}];

// Update title with count
private _titleCtrl = _display displayCtrl 11500;
_titleCtrl ctrlSetText format ["HANGAR (%1 aircraft)", count OpsRoom_Hangar];

// Populate grid
[] call OpsRoom_fnc_populateHangarGrid;

// Move camera to hangar if marker exists
if (markerType "OpsRoom_hangar" != "") then {
    private _hangarPos = getMarkerPos "OpsRoom_hangar";
    private _curator = getAssignedCuratorLogic player;
    if (!isNull _curator) then {
        private _camPos = _hangarPos vectorAdd [15, 15, 8];
        curatorCamera setPosASL (AGLToASL _camPos);
    };
};

diag_log "[OpsRoom] Hangar browser opened";
