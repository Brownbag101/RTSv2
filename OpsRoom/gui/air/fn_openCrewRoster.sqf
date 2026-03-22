/*
    Open Crew Roster
    
    Shows all qualified air gunners/crew, their status, assigned aircraft, and skills.
    Same layout pattern as pilot roster.
*/

if (isNil "OpsRoom_CrewPool") then { OpsRoom_CrewPool = [] };

// Scan all units for airCrew qualification
{
    if (alive _x && {side _x == independent}) then {
        private _quals = _x getVariable ["OpsRoom_Qualifications", []];
        if ("airCrew" in _quals && {!(_x in OpsRoom_CrewPool)}) then {
            OpsRoom_CrewPool pushBack _x;
        };
    };
} forEach allUnits;

OpsRoom_CrewPool = OpsRoom_CrewPool select { alive _x };

if (count OpsRoom_CrewPool == 0) exitWith {
    systemChat "No qualified air gunners. Train units with Air Gunner Training first.";
    [] spawn OpsRoom_fnc_openAirOps;
};

createDialog "RscDisplayEmpty";
private _display = findDisplay -1;
if (isNull _display) exitWith {};

private _panelX = 0.20 * safezoneW + safezoneX;
private _panelY = 0.12 * safezoneH + safezoneY;
private _panelW = 0.60 * safezoneW;
private _panelH = 0.75 * safezoneH;

private _bg = _display ctrlCreate ["RscText", 8500];
_bg ctrlSetPosition [_panelX, _panelY, _panelW, _panelH];
_bg ctrlSetBackgroundColor [0.15, 0.18, 0.12, 0.97];
_bg ctrlCommit 0;

private _titleBg = _display ctrlCreate ["RscText", 8501];
_titleBg ctrlSetPosition [_panelX, _panelY, _panelW, 0.04 * safezoneH];
_titleBg ctrlSetBackgroundColor [0.22, 0.26, 0.18, 1.0];
_titleBg ctrlCommit 0;

private _titleTxt = _display ctrlCreate ["RscText", 8502];
_titleTxt ctrlSetPosition [_panelX + 0.01 * safezoneW, _panelY, _panelW * 0.8, 0.04 * safezoneH];
_titleTxt ctrlSetText format ["AIRCREW ROSTER  |  %1 Air Gunners", count OpsRoom_CrewPool];
_titleTxt ctrlSetTextColor [0.85, 0.82, 0.74, 1.0];
_titleTxt ctrlSetFont "PuristaLight";
_titleTxt ctrlCommit 0;

private _closeBtn = _display ctrlCreate ["RscButton", 8503];
_closeBtn ctrlSetPosition [_panelX + _panelW - 0.03 * safezoneW, _panelY + 0.005 * safezoneH, 0.025 * safezoneW, 0.03 * safezoneH];
_closeBtn ctrlSetText "X";
_closeBtn ctrlSetBackgroundColor [0.40, 0.20, 0.15, 1.0];
_closeBtn ctrlCommit 0;
_closeBtn ctrlAddEventHandler ["ButtonClick", {
    closeDialog 0;
    [] spawn OpsRoom_fnc_openAirOps;
}];

private _rowH = 0.065 * safezoneH;
private _rowY = _panelY + 0.05 * safezoneH;
private _rowX = _panelX + 0.005 * safezoneW;
private _rowW = _panelW - 0.01 * safezoneW;
private _idc = 8510;

{
    private _crewUnit = _x;
    if (_idc > 8700) exitWith {};
    
    private _crewName = name _crewUnit;
    private _rank = rankId _crewUnit;
    private _rankName = (["Pvt", "Cpl", "Sgt", "Lt", "Cpt", "Maj", "Col"] select (_rank min 6));
    
    private _statusText = "Available";
    private _statusColor = "#88CC88";
    private _assignedAC = "Unassigned";
    
    {
        private _entry = _y;
        private _entryCrew = _entry getOrDefault ["assignedCrew", []];
        if (_crewUnit in _entryCrew) exitWith {
            _assignedAC = _entry get "displayName";
            private _acStatus = _entry get "status";
            if (_acStatus == "AIRBORNE") then {
                _statusText = "Airborne";
                _statusColor = "#CCCC44";
            } else {
                _statusText = "Assigned";
                _statusColor = "#88AACC";
            };
        };
    } forEach OpsRoom_Hangar;
    
    private _accuracy = round ((_crewUnit skill "aimingAccuracy") * 100);
    private _spotting = round ((_crewUnit skill "spotDistance") * 100);
    private _courage = round ((_crewUnit skill "courage") * 100);
    
    private _record = [_crewUnit] call OpsRoom_fnc_getServiceRecord;
    private _kills = _record getOrDefault ["kills", 0];
    
    private _rowBg = _display ctrlCreate ["RscText", _idc];
    private _bgCol = if (_forEachIndex mod 2 == 0) then {[0.18, 0.22, 0.16, 0.8]} else {[0.20, 0.24, 0.18, 0.8]};
    _rowBg ctrlSetPosition [_rowX, _rowY, _rowW, _rowH];
    _rowBg ctrlSetBackgroundColor _bgCol;
    _rowBg ctrlCommit 0;
    _idc = _idc + 1;
    
    private _nameCtrl = _display ctrlCreate ["RscStructuredText", _idc];
    _nameCtrl ctrlSetPosition [_rowX + 0.005 * safezoneW, _rowY, 0.15 * safezoneW, _rowH];
    _nameCtrl ctrlSetStructuredText parseText format [
        "<t size='0.9' font='PuristaBold'>%1 %2</t><br/><t size='0.7' color='#AAAAAA'>Air Gunner | Kills: %3</t>",
        _rankName, _crewName, _kills
    ];
    _nameCtrl ctrlCommit 0;
    _idc = _idc + 1;
    
    private _acCtrl = _display ctrlCreate ["RscStructuredText", _idc];
    _acCtrl ctrlSetPosition [_rowX + 0.17 * safezoneW, _rowY, 0.18 * safezoneW, _rowH];
    _acCtrl ctrlSetStructuredText parseText format [
        "<t size='0.8'>Aircraft: %1</t><br/><t size='0.75' color='%2'>%3</t>",
        _assignedAC, _statusColor, _statusText
    ];
    _acCtrl ctrlCommit 0;
    _idc = _idc + 1;
    
    private _skillCtrl = _display ctrlCreate ["RscStructuredText", _idc];
    _skillCtrl ctrlSetPosition [_rowX + 0.37 * safezoneW, _rowY, 0.14 * safezoneW, _rowH];
    _skillCtrl ctrlSetStructuredText parseText format [
        "<t size='0.7'>Accuracy: %1%%<br/>Spotting: %2%%<br/>Courage: %3%%</t>",
        _accuracy, _spotting, _courage
    ];
    _skillCtrl ctrlCommit 0;
    _idc = _idc + 1;
    
    private _focusBtn = _display ctrlCreate ["RscButton", _idc];
    _focusBtn ctrlSetPosition [_rowX + _rowW - 0.07 * safezoneW, _rowY + 0.005 * safezoneH, 0.06 * safezoneW, 0.025 * safezoneH];
    _focusBtn ctrlSetText "FOCUS";
    _focusBtn ctrlSetBackgroundColor [0.25, 0.30, 0.35, 1.0];
    _focusBtn setVariable ["unit", _crewUnit];
    _focusBtn ctrlCommit 0;
    _focusBtn ctrlAddEventHandler ["ButtonClick", {
        params ["_ctrl"];
        private _u = _ctrl getVariable ["unit", objNull];
        if (!isNull _u && alive _u) then {
            closeDialog 0;
            private _pos = getPosASL _u;
            [_pos vectorAdd [0, -10, 5], _u] call BIS_fnc_setCuratorCamera;
        };
    }];
    _idc = _idc + 1;
    
    private _dossierBtn = _display ctrlCreate ["RscButton", _idc];
    _dossierBtn ctrlSetPosition [_rowX + _rowW - 0.07 * safezoneW, _rowY + 0.035 * safezoneH, 0.06 * safezoneW, 0.025 * safezoneH];
    _dossierBtn ctrlSetText "DOSSIER";
    _dossierBtn ctrlSetBackgroundColor [0.30, 0.25, 0.20, 1.0];
    _dossierBtn setVariable ["unit", _crewUnit];
    _dossierBtn ctrlCommit 0;
    _dossierBtn ctrlAddEventHandler ["ButtonClick", {
        params ["_ctrl"];
        private _u = _ctrl getVariable ["unit", objNull];
        if (!isNull _u) then {
            closeDialog 0;
            [_u] spawn OpsRoom_fnc_openUnitDossier;
        };
    }];
    _idc = _idc + 1;
    
    _rowY = _rowY + _rowH + 0.003 * safezoneH;
} forEach OpsRoom_CrewPool;

diag_log format ["[OpsRoom] Crew roster opened: %1 gunners", count OpsRoom_CrewPool];
