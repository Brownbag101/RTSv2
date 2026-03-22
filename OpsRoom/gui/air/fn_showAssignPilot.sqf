/*
    Show Assign Pilot Dialog
    
    Lists all units with "pilot" qualification that aren't already
    assigned to an aircraft. Player picks one to assign.
    
    Parameters:
        _hangarId - Hangar ID of aircraft to assign pilot to
        _returnTo - "wing" or "hangar" (which screen to return to)
        _wingId   - Wing ID (if returning to wing detail)
*/
params ["_hangarId", ["_returnTo", "wing"], ["_wingId", ""]];

private _entry = OpsRoom_Hangar get _hangarId;
if (isNil "_entry") exitWith { systemChat "Aircraft not found" };

private _displayName = _entry get "displayName";

// Find all units with pilot qualification that aren't already assigned
private _candidates = [];

private _fnc_checkPilot = {
    params ["_unit"];
    if (!alive _unit) exitWith {};
    private _quals = _unit getVariable ["OpsRoom_Qualifications", []];
    if !("pilot" in _quals) exitWith {};
    
    // Check not already assigned to another aircraft
    private _alreadyAssigned = false;
    {
        private _otherEntry = _y;
        if ((_otherEntry getOrDefault ["assignedPilot", objNull]) isEqualTo _unit) exitWith {
            _alreadyAssigned = true;
        };
    } forEach OpsRoom_Hangar;
    
    if (!_alreadyAssigned && {!(_unit in _candidates)}) then {
        _candidates pushBack _unit;
    };
};

// Scan regiment groups
{
    private _groupData = _y;
    private _units = _groupData get "units";
    { [_x] call _fnc_checkPilot } forEach _units;
} forEach OpsRoom_Groups;

// Also scan all independent units (pilots leave their groups after training)
{
    if (side _x == independent) then {
        [_x] call _fnc_checkPilot;
    };
} forEach allUnits;

if (count _candidates == 0) exitWith {
    systemChat "No available pilots. Train units with Pilot Training first.";
    if (_returnTo == "wing" && _wingId != "") then {
        [_wingId] spawn OpsRoom_fnc_openWingDetail;
    };
};

// Create selection dialog
createDialog "RscDisplayEmpty";
private _display = findDisplay -1;
if (isNull _display) exitWith {};

// Background
private _bg = _display ctrlCreate ["RscText", 7300];
_bg ctrlSetPosition [0.30 * safezoneW + safezoneX, 0.20 * safezoneH + safezoneY, 0.40 * safezoneW, 0.55 * safezoneH];
_bg ctrlSetBackgroundColor [0.20, 0.25, 0.18, 0.95];
_bg ctrlCommit 0;

// Title
private _title = _display ctrlCreate ["RscText", 7301];
_title ctrlSetPosition [0.30 * safezoneW + safezoneX, 0.20 * safezoneH + safezoneY, 0.40 * safezoneW, 0.04 * safezoneH];
_title ctrlSetText format ["ASSIGN PILOT - %1", _displayName];
_title ctrlSetBackgroundColor [0.15, 0.20, 0.13, 1.0];
_title ctrlSetTextColor [0.85, 0.82, 0.74, 1.0];
_title ctrlSetFont "PuristaLight";
_title ctrlCommit 0;

// Pilot buttons
private _btnIndex = 0;
{
    if (_btnIndex >= 10) exitWith {};
    
    private _unit = _x;
    private _unitName = name _unit;
    private _rank = rankId _unit;
    private _rankName = ["Private", "Corporal", "Sergeant", "Lieutenant", "Captain", "Major", "Colonel"] select (_rank min 6);
    
    private _btn = _display ctrlCreate ["RscButton", 7310 + _btnIndex];
    _btn ctrlSetPosition [
        0.32 * safezoneW + safezoneX,
        (0.26 + (_btnIndex * 0.05)) * safezoneH + safezoneY,
        0.36 * safezoneW,
        0.04 * safezoneH
    ];
    _btn ctrlSetText format ["%1 %2", _rankName, _unitName];
    _btn ctrlSetBackgroundColor [0.26, 0.30, 0.21, 1.0];
    _btn setVariable ["unit", _unit];
    _btn setVariable ["hangarId", _hangarId];
    _btn setVariable ["returnTo", _returnTo];
    _btn setVariable ["wingId", _wingId];
    _btn ctrlCommit 0;
    
    _btn ctrlAddEventHandler ["ButtonClick", {
        params ["_ctrl"];
        private _unit = _ctrl getVariable ["unit", objNull];
        private _hId = _ctrl getVariable ["hangarId", ""];
        private _ret = _ctrl getVariable ["returnTo", "wing"];
        private _wId = _ctrl getVariable ["wingId", ""];
        
        [_hId, _unit] call OpsRoom_fnc_assignPilot;
        closeDialog 0;
        
        if (_ret == "wing" && _wId != "") then {
            [_wId] spawn OpsRoom_fnc_openWingDetail;
        };
    }];
    
    _btnIndex = _btnIndex + 1;
} forEach _candidates;

// Cancel button
private _cancelBtn = _display ctrlCreate ["RscButton", 7350];
_cancelBtn ctrlSetPosition [0.45 * safezoneW + safezoneX, 0.68 * safezoneH + safezoneY, 0.12 * safezoneW, 0.04 * safezoneH];
_cancelBtn ctrlSetText "CANCEL";
_cancelBtn ctrlSetBackgroundColor [0.40, 0.25, 0.20, 1.0];
_cancelBtn setVariable ["returnTo", _returnTo];
_cancelBtn setVariable ["wingId", _wingId];
_cancelBtn ctrlCommit 0;

_cancelBtn ctrlAddEventHandler ["ButtonClick", {
    params ["_ctrl"];
    private _ret = _ctrl getVariable ["returnTo", "wing"];
    private _wId = _ctrl getVariable ["wingId", ""];
    closeDialog 0;
    if (_ret == "wing" && _wId != "") then {
        [_wId] spawn OpsRoom_fnc_openWingDetail;
    };
}];
