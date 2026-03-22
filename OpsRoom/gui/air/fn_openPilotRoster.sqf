/*
    Open Pilot Roster
    
    Shows all qualified pilots, their status (available/assigned/airborne),
    assigned aircraft, skills, medals, and service record.
    
    Uses RscDisplayEmpty with dynamic controls — same pattern as showAssignAircraft.
*/

if (isNil "OpsRoom_PilotPool") then { OpsRoom_PilotPool = [] };

// Also scan all units for pilot qualification (catch any not in pool)
{
    if (alive _x && {side _x == independent}) then {
        private _quals = _x getVariable ["OpsRoom_Qualifications", []];
        if ("pilot" in _quals && {!(_x in OpsRoom_PilotPool)}) then {
            OpsRoom_PilotPool pushBack _x;
        };
    };
} forEach allUnits;

// Clean dead pilots from pool
OpsRoom_PilotPool = OpsRoom_PilotPool select { alive _x };

if (count OpsRoom_PilotPool == 0) exitWith {
    systemChat "No qualified pilots. Train units with Pilot Training first.";
    [] spawn OpsRoom_fnc_openAirOps;
};

// Create dialog
createDialog "RscDisplayEmpty";
private _display = findDisplay -1;
if (isNull _display) exitWith {};

// Layout
private _panelX = 0.20 * safezoneW + safezoneX;
private _panelY = 0.12 * safezoneH + safezoneY;
private _panelW = 0.60 * safezoneW;
private _panelH = 0.75 * safezoneH;

// Background
private _bg = _display ctrlCreate ["RscText", 8000];
_bg ctrlSetPosition [_panelX, _panelY, _panelW, _panelH];
_bg ctrlSetBackgroundColor [0.15, 0.18, 0.12, 0.97];
_bg ctrlCommit 0;

// Title bar
private _titleBg = _display ctrlCreate ["RscText", 8001];
_titleBg ctrlSetPosition [_panelX, _panelY, _panelW, 0.04 * safezoneH];
_titleBg ctrlSetBackgroundColor [0.22, 0.26, 0.18, 1.0];
_titleBg ctrlCommit 0;

private _titleTxt = _display ctrlCreate ["RscText", 8002];
_titleTxt ctrlSetPosition [_panelX + 0.01 * safezoneW, _panelY, _panelW * 0.8, 0.04 * safezoneH];
_titleTxt ctrlSetText format ["PILOT ROSTER  |  %1 Pilots", count OpsRoom_PilotPool];
_titleTxt ctrlSetTextColor [0.85, 0.82, 0.74, 1.0];
_titleTxt ctrlSetFont "PuristaLight";
_titleTxt ctrlCommit 0;

// Close button
private _closeBtn = _display ctrlCreate ["RscButton", 8003];
_closeBtn ctrlSetPosition [_panelX + _panelW - 0.03 * safezoneW, _panelY + 0.005 * safezoneH, 0.025 * safezoneW, 0.03 * safezoneH];
_closeBtn ctrlSetText "X";
_closeBtn ctrlSetBackgroundColor [0.40, 0.20, 0.15, 1.0];
_closeBtn ctrlCommit 0;
_closeBtn ctrlAddEventHandler ["ButtonClick", {
    closeDialog 0;
    [] spawn OpsRoom_fnc_openAirOps;
}];

// Pilot list — one row per pilot
private _rowH = 0.065 * safezoneH;
private _rowY = _panelY + 0.05 * safezoneH;
private _rowX = _panelX + 0.005 * safezoneW;
private _rowW = _panelW - 0.01 * safezoneW;
private _idc = 8100;

{
    private _pilot = _x;
    if (_idc > 8300) exitWith {};  // Max 20 pilots on screen
    
    private _pilotName = name _pilot;
    private _rank = rankId _pilot;
    private _rankName = (["Pvt", "Cpl", "Sgt", "Lt", "Cpt", "Maj", "Col"] select (_rank min 6));
    
    // Determine pilot status
    private _statusText = "Available";
    private _statusColor = "#88CC88";
    private _assignedAC = "Unassigned";
    
    // Check if assigned to any aircraft
    {
        private _entry = _y;
        if ((_entry getOrDefault ["assignedPilot", objNull]) isEqualTo _pilot) exitWith {
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
    
    // Get skills summary
    private _accuracy = round ((_pilot skill "aimingAccuracy") * 100);
    private _spotting = round ((_pilot skill "spotDistance") * 100);
    private _courage = round ((_pilot skill "courage") * 100);
    
    // Get medals count
    private _record = [_pilot] call OpsRoom_fnc_getServiceRecord;
    private _medals = _record getOrDefault ["medals", []];
    private _medalCount = count _medals;
    private _kills = _record getOrDefault ["kills", 0];
    
    // Row background
    private _rowBg = _display ctrlCreate ["RscText", _idc];
    private _bgCol = if (_forEachIndex mod 2 == 0) then {[0.18, 0.22, 0.16, 0.8]} else {[0.20, 0.24, 0.18, 0.8]};
    _rowBg ctrlSetPosition [_rowX, _rowY, _rowW, _rowH];
    _rowBg ctrlSetBackgroundColor _bgCol;
    _rowBg ctrlCommit 0;
    _idc = _idc + 1;
    
    // Name + rank (left)
    private _nameCtrl = _display ctrlCreate ["RscStructuredText", _idc];
    _nameCtrl ctrlSetPosition [_rowX + 0.005 * safezoneW, _rowY, 0.15 * safezoneW, _rowH];
    _nameCtrl ctrlSetStructuredText parseText format [
        "<t size='0.9' font='PuristaBold'>%1 %2</t><br/><t size='0.7' color='#AAAAAA'>Kills: %3  Medals: %4</t>",
        _rankName, _pilotName, _kills, _medalCount
    ];
    _nameCtrl ctrlCommit 0;
    _idc = _idc + 1;
    
    // Aircraft assignment (middle)
    private _acCtrl = _display ctrlCreate ["RscStructuredText", _idc];
    _acCtrl ctrlSetPosition [_rowX + 0.17 * safezoneW, _rowY, 0.18 * safezoneW, _rowH];
    _acCtrl ctrlSetStructuredText parseText format [
        "<t size='0.8'>Aircraft: %1</t><br/><t size='0.75' color='%2'>%3</t>",
        _assignedAC, _statusColor, _statusText
    ];
    _acCtrl ctrlCommit 0;
    _idc = _idc + 1;
    
    // Skills (right)
    private _skillCtrl = _display ctrlCreate ["RscStructuredText", _idc];
    _skillCtrl ctrlSetPosition [_rowX + 0.37 * safezoneW, _rowY, 0.14 * safezoneW, _rowH];
    _skillCtrl ctrlSetStructuredText parseText format [
        "<t size='0.7'>Accuracy: %1%%<br/>Spotting: %2%%<br/>Courage: %3%%</t>",
        _accuracy, _spotting, _courage
    ];
    _skillCtrl ctrlCommit 0;
    _idc = _idc + 1;
    
    // Focus button (right edge)
    private _focusBtn = _display ctrlCreate ["RscButton", _idc];
    _focusBtn ctrlSetPosition [_rowX + _rowW - 0.07 * safezoneW, _rowY + 0.005 * safezoneH, 0.06 * safezoneW, 0.025 * safezoneH];
    _focusBtn ctrlSetText "FOCUS";
    _focusBtn ctrlSetBackgroundColor [0.25, 0.30, 0.35, 1.0];
    _focusBtn setVariable ["pilot", _pilot];
    _focusBtn ctrlCommit 0;
    _focusBtn ctrlAddEventHandler ["ButtonClick", {
        params ["_ctrl"];
        private _p = _ctrl getVariable ["pilot", objNull];
        if (!isNull _p && alive _p) then {
            closeDialog 0;
            private _pos = getPosASL _p;
            private _camPos = _pos vectorAdd [0, -10, 5];
            [_camPos, _p] call BIS_fnc_setCuratorCamera;
        };
    }];
    _idc = _idc + 1;
    
    // Dossier button
    private _dossierBtn = _display ctrlCreate ["RscButton", _idc];
    _dossierBtn ctrlSetPosition [_rowX + _rowW - 0.07 * safezoneW, _rowY + 0.035 * safezoneH, 0.06 * safezoneW, 0.025 * safezoneH];
    _dossierBtn ctrlSetText "DOSSIER";
    _dossierBtn ctrlSetBackgroundColor [0.30, 0.25, 0.20, 1.0];
    _dossierBtn setVariable ["pilot", _pilot];
    _dossierBtn ctrlCommit 0;
    _dossierBtn ctrlAddEventHandler ["ButtonClick", {
        params ["_ctrl"];
        private _p = _ctrl getVariable ["pilot", objNull];
        if (!isNull _p) then {
            closeDialog 0;
            [_p] spawn OpsRoom_fnc_openUnitDossier;
        };
    }];
    _idc = _idc + 1;
    
    _rowY = _rowY + _rowH + 0.003 * safezoneH;
} forEach OpsRoom_PilotPool;

diag_log format ["[OpsRoom] Pilot roster opened: %1 pilots", count OpsRoom_PilotPool];
