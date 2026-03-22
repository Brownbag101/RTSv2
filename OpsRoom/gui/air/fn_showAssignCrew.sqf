/*
    Show Assign Crew Dialog
    
    Lists all units with "airCrew" qualification that aren't already
    assigned. Player picks one to assign to the aircraft's crew.
    
    Parameters:
        _hangarId - Hangar ID of aircraft
        _wingId   - Wing ID (to return to wing detail)
*/
params ["_hangarId", ["_wingId", ""]];

private _entry = OpsRoom_Hangar get _hangarId;
if (isNil "_entry") exitWith { systemChat "Aircraft not found" };

private _displayName = _entry get "displayName";
private _crewRequired = _entry getOrDefault ["crewRequired", 0];
private _assignedCrew = _entry getOrDefault ["assignedCrew", []];

if (_crewRequired == 0) exitWith {
    systemChat format ["%1 is a single-seat aircraft — no crew needed", _displayName];
    if (_wingId != "") then { [_wingId] spawn OpsRoom_fnc_openWingDetail };
};

if (count _assignedCrew >= _crewRequired) exitWith {
    systemChat format ["%1 crew is full (%2/%3)", _displayName, count _assignedCrew, _crewRequired];
    if (_wingId != "") then { [_wingId] spawn OpsRoom_fnc_openWingDetail };
};

// Find available crew
if (isNil "OpsRoom_CrewPool") then { OpsRoom_CrewPool = [] };

// Also scan all units for airCrew qualification
{
    if (alive _x && {side _x == independent}) then {
        private _quals = _x getVariable ["OpsRoom_Qualifications", []];
        if ("airCrew" in _quals && {!(_x in OpsRoom_CrewPool)}) then {
            OpsRoom_CrewPool pushBack _x;
        };
    };
} forEach allUnits;

OpsRoom_CrewPool = OpsRoom_CrewPool select { alive _x };

private _candidates = [];
{
    private _unit = _x;
    // Check not already assigned to any aircraft
    private _alreadyAssigned = false;
    {
        private _otherEntry = _y;
        private _otherCrew = _otherEntry getOrDefault ["assignedCrew", []];
        if (_unit in _otherCrew) exitWith { _alreadyAssigned = true };
        if ((_otherEntry getOrDefault ["assignedPilot", objNull]) isEqualTo _unit) exitWith { _alreadyAssigned = true };
    } forEach OpsRoom_Hangar;
    
    if (!_alreadyAssigned) then {
        _candidates pushBack _unit;
    };
} forEach OpsRoom_CrewPool;

if (count _candidates == 0) exitWith {
    systemChat "No available air gunners. Train units with Air Gunner Training first.";
    if (_wingId != "") then { [_wingId] spawn OpsRoom_fnc_openWingDetail };
};

// Create selection dialog
createDialog "RscDisplayEmpty";
private _display = findDisplay -1;
if (isNull _display) exitWith {};

// Background
private _bg = _display ctrlCreate ["RscText", 7400];
_bg ctrlSetPosition [0.30 * safezoneW + safezoneX, 0.20 * safezoneH + safezoneY, 0.40 * safezoneW, 0.55 * safezoneH];
_bg ctrlSetBackgroundColor [0.20, 0.25, 0.18, 0.95];
_bg ctrlCommit 0;

// Title
private _title = _display ctrlCreate ["RscText", 7401];
_title ctrlSetPosition [0.30 * safezoneW + safezoneX, 0.20 * safezoneH + safezoneY, 0.40 * safezoneW, 0.04 * safezoneH];
_title ctrlSetText format ["ASSIGN CREW - %1 (%2/%3)", _displayName, count _assignedCrew, _crewRequired];
_title ctrlSetBackgroundColor [0.15, 0.20, 0.13, 1.0];
_title ctrlSetTextColor [0.85, 0.82, 0.74, 1.0];
_title ctrlSetFont "PuristaLight";
_title ctrlCommit 0;

// Crew buttons
private _btnIndex = 0;
{
    if (_btnIndex >= 10) exitWith {};
    
    private _unit = _x;
    private _unitName = name _unit;
    private _rank = rankId _unit;
    private _rankName = (["Pvt", "Cpl", "Sgt", "Lt", "Cpt", "Maj", "Col"] select (_rank min 6));
    
    private _btn = _display ctrlCreate ["RscButton", 7410 + _btnIndex];
    _btn ctrlSetPosition [
        0.32 * safezoneW + safezoneX,
        (0.26 + (_btnIndex * 0.05)) * safezoneH + safezoneY,
        0.36 * safezoneW,
        0.04 * safezoneH
    ];
    _btn ctrlSetText format ["%1 %2  (Air Gunner)", _rankName, _unitName];
    _btn ctrlSetBackgroundColor [0.26, 0.30, 0.21, 1.0];
    _btn setVariable ["unit", _unit];
    _btn setVariable ["hangarId", _hangarId];
    _btn setVariable ["wingId", _wingId];
    _btn ctrlCommit 0;
    
    _btn ctrlAddEventHandler ["ButtonClick", {
        params ["_ctrl"];
        private _unit = _ctrl getVariable ["unit", objNull];
        private _hId = _ctrl getVariable ["hangarId", ""];
        private _wId = _ctrl getVariable ["wingId", ""];
        
        [_hId, _unit] call OpsRoom_fnc_assignCrew;
        closeDialog 0;
        
        // Check if more crew needed — if so, reopen this dialog
        private _entry2 = OpsRoom_Hangar get _hId;
        if (!isNil "_entry2") then {
            private _crew2 = _entry2 getOrDefault ["assignedCrew", []];
            private _needed2 = _entry2 getOrDefault ["crewRequired", 0];
            if (count _crew2 < _needed2) then {
                [_hId, _wId] spawn OpsRoom_fnc_showAssignCrew;
            } else {
                if (_wId != "") then { [_wId] spawn OpsRoom_fnc_openWingDetail };
            };
        };
    }];
    
    _btnIndex = _btnIndex + 1;
} forEach _candidates;

// Cancel button
private _cancelBtn = _display ctrlCreate ["RscButton", 7450];
_cancelBtn ctrlSetPosition [0.45 * safezoneW + safezoneX, 0.68 * safezoneH + safezoneY, 0.12 * safezoneW, 0.04 * safezoneH];
_cancelBtn ctrlSetText "CANCEL";
_cancelBtn ctrlSetBackgroundColor [0.40, 0.25, 0.20, 1.0];
_cancelBtn setVariable ["wingId", _wingId];
_cancelBtn ctrlCommit 0;

_cancelBtn ctrlAddEventHandler ["ButtonClick", {
    params ["_ctrl"];
    private _wId = _ctrl getVariable ["wingId", ""];
    closeDialog 0;
    if (_wId != "") then { [_wId] spawn OpsRoom_fnc_openWingDetail };
}];
