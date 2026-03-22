/*
    Assign Aircraft from Hangar to Wing (GUI)
    
    Shows a selection dialog listing unassigned aircraft that are
    compatible with the current wing type.
    
    Parameters:
        _wingId - Wing ID to assign to
*/
params ["_wingId"];

private _wingData = OpsRoom_AirWings get _wingId;
if (isNil "_wingData") exitWith { systemChat "Wing not found" };

private _wingName = _wingData get "name";
private _wingType = _wingData get "wingType";
private _wingTypeData = OpsRoom_WingTypes get _wingType;
private _allowedTypes = _wingTypeData get "allowedAircraftTypes";
private _currentCount = count (_wingData get "aircraft");

// Get unassigned, compatible, hangared aircraft
private _candidates = [];
{
    private _hangarId = _x;
    private _entry = _y;
    if ((_entry get "wingId") == "" && 
        {(_entry get "status") == "HANGARED"} && 
        {(_entry get "aircraftType") in _allowedTypes}) then {
        _candidates pushBack [_hangarId, _entry];
    };
} forEach OpsRoom_Hangar;

if (count _candidates == 0) exitWith {
    systemChat format ["No unassigned %1 aircraft in hangar", _wingType];
    [_wingId] spawn OpsRoom_fnc_openWingDetail;
};

// Create selection dialog
createDialog "RscDisplayEmpty";
private _display = findDisplay -1;
if (isNull _display) exitWith {};

// Background
private _bg = _display ctrlCreate ["RscText", 7000];
_bg ctrlSetPosition [0.30 * safezoneW + safezoneX, 0.20 * safezoneH + safezoneY, 0.40 * safezoneW, 0.55 * safezoneH];
_bg ctrlSetBackgroundColor [0.20, 0.25, 0.18, 0.95];
_bg ctrlCommit 0;

// Title
private _title = _display ctrlCreate ["RscText", 7001];
_title ctrlSetPosition [0.30 * safezoneW + safezoneX, 0.20 * safezoneH + safezoneY, 0.40 * safezoneW, 0.04 * safezoneH];
_title ctrlSetText format ["ASSIGN TO %1 (%2/%3)", _wingName, _currentCount, OpsRoom_Settings_MaxWingSize];
_title ctrlSetBackgroundColor [0.15, 0.20, 0.13, 1.0];
_title ctrlSetTextColor [0.85, 0.82, 0.74, 1.0];
_title ctrlSetFont "PuristaLight";
_title ctrlCommit 0;

// Aircraft buttons
private _btnIndex = 0;
{
    _x params ["_hangarId", "_entry"];
    if (_btnIndex >= 10) exitWith {};
    
    private _displayName = _entry get "displayName";
    private _fuel = round ((_entry get "fuel") * 100);
    private _damage = round ((_entry get "damage") * 100);
    
    private _btn = _display ctrlCreate ["RscButton", 7100 + _btnIndex];
    _btn ctrlSetPosition [
        0.32 * safezoneW + safezoneX,
        (0.26 + (_btnIndex * 0.05)) * safezoneH + safezoneY,
        0.36 * safezoneW,
        0.04 * safezoneH
    ];
    _btn ctrlSetText format ["%1  |  F:%2%%  D:%3%%", _displayName, _fuel, _damage];
    _btn ctrlSetBackgroundColor [0.26, 0.30, 0.21, 1.0];
    _btn setVariable ["hangarId", _hangarId];
    _btn setVariable ["wingId", _wingId];
    _btn ctrlCommit 0;
    
    _btn ctrlAddEventHandler ["ButtonClick", {
        params ["_ctrl"];
        private _hangarId = _ctrl getVariable ["hangarId", ""];
        private _wingId = _ctrl getVariable ["wingId", ""];
        
        [_hangarId, _wingId] call OpsRoom_fnc_assignToWing;
        closeDialog 0;
        [_wingId] spawn OpsRoom_fnc_openWingDetail;
    }];
    
    _btnIndex = _btnIndex + 1;
} forEach _candidates;

// Cancel button
private _cancelBtn = _display ctrlCreate ["RscButton", 7200];
_cancelBtn ctrlSetPosition [0.45 * safezoneW + safezoneX, 0.68 * safezoneH + safezoneY, 0.12 * safezoneW, 0.04 * safezoneH];
_cancelBtn ctrlSetText "CANCEL";
_cancelBtn ctrlSetBackgroundColor [0.40, 0.25, 0.20, 1.0];
_cancelBtn setVariable ["wingId", _wingId];
_cancelBtn ctrlCommit 0;

_cancelBtn ctrlAddEventHandler ["ButtonClick", {
    params ["_ctrl"];
    private _wingId = _ctrl getVariable ["wingId", ""];
    closeDialog 0;
    [_wingId] spawn OpsRoom_fnc_openWingDetail;
}];
