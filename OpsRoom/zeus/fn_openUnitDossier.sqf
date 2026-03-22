/*
    OpsRoom_fnc_openUnitDossier
    
    Full unit dossier panel on Zeus display (312).
    Replaces the old dialog-based unit detail.
    Camera zooms to unit. Three tabs with swish transitions:
      PROFILE | SERVICE RECORD | SKILLS & TRAINING
    
    Arrow buttons to cycle through units in the group.
    
    IDC Range: 9600-9799
    - 9600-9609: Frame, title, close, tabs, nav arrows
    - 9610-9659: Tab 1 - Profile content
    - 9660-9709: Tab 2 - Service Record content
    - 9710-9759: Tab 3 - Skills & Training content
    - 9760-9779: Action buttons (promote, demote, training)
    
    Parameters:
        0: OBJECT - Unit to display
        1: STRING - (optional) Group ID for navigation
    
    Usage:
        [_unit, "group_1"] call OpsRoom_fnc_openUnitDossier;
*/

params [
    ["_unit", objNull, [objNull]],
    ["_groupId", "", [""]]
];

if (isNull _unit) exitWith { systemChat "No unit provided" };

private _display = findDisplay 312;
if (isNull _display) exitWith {};

// Close inventory if open
if (missionNamespace getVariable ["OpsRoom_InventoryOpen", false]) then {
    [] call OpsRoom_fnc_closeInventory;
};

// Close existing dossier if open
[] call OpsRoom_fnc_closeDossier;

// ========================================
// RESOLVE GROUP & UNIT LIST FOR NAVIGATION
// ========================================
private _unitList = [];
private _unitIndex = 0;

if (_groupId != "") then {
    private _groupData = OpsRoom_Groups getOrDefault [_groupId, createHashMap];
    if (count _groupData > 0) then {
        _unitList = (_groupData getOrDefault ["units", []]) select { !isNull _x && alive _x };
        _unitIndex = _unitList find _unit;
        if (_unitIndex < 0) then { _unitIndex = 0 };
    };
};

// Store state
missionNamespace setVariable ["OpsRoom_DossierOpen", true];
missionNamespace setVariable ["OpsRoom_DossierUnit", _unit];
missionNamespace setVariable ["OpsRoom_DossierGroupId", _groupId];
missionNamespace setVariable ["OpsRoom_DossierUnitList", _unitList];
missionNamespace setVariable ["OpsRoom_DossierUnitIndex", _unitIndex];
missionNamespace setVariable ["OpsRoom_DossierTab", 0];

// ========================================
// LAYOUT CONSTANTS
// ========================================
private _panelW = 0.26 * safezoneW;
private _panelX = safezoneX + safezoneW - _panelW - (0.01 * safezoneW);
private _panelY = safezoneY + (0.06 * safezoneH);
private _titleH = 0.038 * safezoneH;
private _tabH = 0.032 * safezoneH;
private _navH = 0.032 * safezoneH;
private _contentY = _panelY + _titleH + _tabH;
private _maxPanelH = 0.86 * safezoneH;
private _contentH = _maxPanelH - _titleH - _tabH - _navH - (0.05 * safezoneH);
private _pad = 0.005 * safezoneW;

// Colors
private _bgColor = [0.18, 0.20, 0.14, 0.95];
private _titleColor = [0.20, 0.25, 0.18, 1.0];
private _tabActiveColor = [0.30, 0.35, 0.22, 1.0];
private _tabInactiveColor = [0.22, 0.25, 0.17, 0.8];
private _textColor = [0.85, 0.82, 0.74, 1.0];
private _dimColor = [0.65, 0.62, 0.54, 1.0];
private _accentColor = [0.95, 0.92, 0.80, 1.0];
private _btnColor = [0.30, 0.35, 0.22, 0.9];
private _btnHoverColor = [0.45, 0.50, 0.30, 1.0];
private _closeBtnColor = [0.45, 0.20, 0.18, 0.95];

// ========================================
// PANEL BACKGROUND
// ========================================
private _bg = _display ctrlCreate ["RscText", 9600];
_bg ctrlSetPosition [_panelX, _panelY, _panelW, _maxPanelH];
_bg ctrlSetBackgroundColor _bgColor;
_bg ctrlCommit 0;

// ========================================
// TITLE BAR
// ========================================
private _titleBg = _display ctrlCreate ["RscText", 9601];
_titleBg ctrlSetPosition [_panelX, _panelY, _panelW, _titleH];
_titleBg ctrlSetBackgroundColor _titleColor;
_titleBg ctrlCommit 0;

private _titleText = _display ctrlCreate ["RscText", 9602];
_titleText ctrlSetPosition [_panelX + _pad, _panelY, _panelW - (0.06 * safezoneW), _titleH];
_titleText ctrlSetText format ["%1 | %2", name _unit, rank _unit];
_titleText ctrlSetTextColor _accentColor;
_titleText ctrlSetFont "PuristaBold";
_titleText ctrlSetFontHeight 0.030;
_titleText ctrlCommit 0;

// Debug button (left of close)
private _debugBtnW = 0.04 * safezoneW;
private _debugBtn = _display ctrlCreate ["RscButton", 9610];
_debugBtn ctrlSetPosition [_panelX + _panelW - 0.022 * safezoneW - _debugBtnW - (2 * _pad), _panelY + 0.004 * safezoneH, _debugBtnW, _titleH - 0.008 * safezoneH];
_debugBtn ctrlSetText "DEBUG";
_debugBtn ctrlSetTextColor [0.95, 0.85, 0.65, 1];
_debugBtn ctrlSetBackgroundColor [0.40, 0.18, 0.12, 0.9];
_debugBtn ctrlSetFont "PuristaBold";
_debugBtn ctrlSetFontHeight 0.022;
_debugBtn ctrlCommit 0;
_debugBtn ctrlAddEventHandler ["ButtonClick", {
    private _u = missionNamespace getVariable ["OpsRoom_DossierUnit", objNull];
    if (!isNull _u) then { [_u] call OpsRoom_fnc_debugServiceRecord };
}];
_debugBtn ctrlAddEventHandler ["MouseEnter", { (_this select 0) ctrlSetBackgroundColor [0.55, 0.25, 0.18, 1.0] }];
_debugBtn ctrlAddEventHandler ["MouseExit", { (_this select 0) ctrlSetBackgroundColor [0.40, 0.18, 0.12, 0.9] }];

// Close button
private _closeBtn = _display ctrlCreate ["RscButton", 9603];
private _closeBtnW = 0.022 * safezoneW;
_closeBtn ctrlSetPosition [_panelX + _panelW - _closeBtnW - _pad, _panelY + 0.004 * safezoneH, _closeBtnW, _titleH - 0.008 * safezoneH];
_closeBtn ctrlSetText "X";
_closeBtn ctrlSetTextColor [1, 1, 1, 1];
_closeBtn ctrlSetBackgroundColor _closeBtnColor;
_closeBtn ctrlSetFont "PuristaBold";
_closeBtn ctrlSetFontHeight 0.030;
_closeBtn ctrlCommit 0;
_closeBtn ctrlAddEventHandler ["ButtonClick", { [] call OpsRoom_fnc_closeDossier }];
_closeBtn ctrlAddEventHandler ["MouseEnter", { (_this select 0) ctrlSetBackgroundColor [0.65, 0.25, 0.20, 1.0] }];
_closeBtn ctrlAddEventHandler ["MouseExit", { (_this select 0) ctrlSetBackgroundColor [0.45, 0.20, 0.18, 0.95] }];

// ========================================
// TAB BUTTONS
// ========================================
private _tabY = _panelY + _titleH;
private _tabW = _panelW / 3;
private _tabNames = ["PROFILE", "SERVICE", "SKILLS"];

for "_i" from 0 to 2 do {
    private _tabBtn = _display ctrlCreate ["RscButton", 9604 + _i];
    _tabBtn ctrlSetPosition [_panelX + (_tabW * _i), _tabY, _tabW, _tabH];
    _tabBtn ctrlSetText (_tabNames select _i);
    _tabBtn ctrlSetTextColor _textColor;
    _tabBtn ctrlSetBackgroundColor (if (_i == 0) then { _tabActiveColor } else { _tabInactiveColor });
    _tabBtn ctrlSetFont "PuristaBold";
    _tabBtn ctrlSetFontHeight 0.026;
    _tabBtn ctrlCommit 0;
    
    _tabBtn setVariable ["tabIndex", _i];
    _tabBtn ctrlAddEventHandler ["ButtonClick", {
        params ["_ctrl"];
        private _idx = _ctrl getVariable ["tabIndex", 0];
        missionNamespace setVariable ["OpsRoom_DossierTab", _idx];
        [] call OpsRoom_fnc_renderDossierTab;
    }];
    _tabBtn ctrlAddEventHandler ["MouseEnter", { (_this select 0) ctrlSetBackgroundColor [0.35, 0.40, 0.25, 1.0] }];
    _tabBtn ctrlAddEventHandler ["MouseExit", {
        params ["_ctrl"];
        private _idx = _ctrl getVariable ["tabIndex", 0];
        private _active = missionNamespace getVariable ["OpsRoom_DossierTab", 0];
        if (_idx == _active) then {
            _ctrl ctrlSetBackgroundColor [0.30, 0.35, 0.22, 1.0];
        } else {
            _ctrl ctrlSetBackgroundColor [0.22, 0.25, 0.17, 0.8];
        };
    }];
};

// ========================================
// NAVIGATION ARROWS (bottom of panel)
// ========================================
private _navY = _panelY + _maxPanelH - _navH - (0.005 * safezoneH);
private _arrowW = 0.04 * safezoneW;

if (count _unitList > 1) then {
    // Previous unit
    private _prevBtn = _display ctrlCreate ["RscButton", 9607];
    _prevBtn ctrlSetPosition [_panelX + _pad, _navY, _arrowW, _navH];
    _prevBtn ctrlSetText "◄ PREV";
    _prevBtn ctrlSetTextColor _textColor;
    _prevBtn ctrlSetBackgroundColor _btnColor;
    _prevBtn ctrlSetFont "PuristaBold";
    _prevBtn ctrlSetFontHeight 0.024;
    _prevBtn ctrlCommit 0;
    _prevBtn ctrlAddEventHandler ["ButtonClick", {
        private _list = missionNamespace getVariable ["OpsRoom_DossierUnitList", []];
        private _idx = missionNamespace getVariable ["OpsRoom_DossierUnitIndex", 0];
        if (count _list > 0) then {
            _idx = (_idx - 1 + count _list) mod count _list;
            private _newUnit = _list select _idx;
            private _groupId = missionNamespace getVariable ["OpsRoom_DossierGroupId", ""];
            [] call OpsRoom_fnc_closeDossier;
            [_newUnit, _groupId] call OpsRoom_fnc_openUnitDossier;
        };
    }];
    _prevBtn ctrlAddEventHandler ["MouseEnter", { (_this select 0) ctrlSetBackgroundColor [0.45, 0.50, 0.30, 1.0] }];
    _prevBtn ctrlAddEventHandler ["MouseExit", { (_this select 0) ctrlSetBackgroundColor [0.30, 0.35, 0.22, 0.9] }];
    
    // Unit counter
    private _counterText = _display ctrlCreate ["RscText", 9608];
    private _counterW = _panelW - (2 * _arrowW) - (4 * _pad);
    _counterText ctrlSetPosition [_panelX + _arrowW + (2 * _pad), _navY, _counterW, _navH];
    _counterText ctrlSetText format ["%1 / %2", _unitIndex + 1, count _unitList];
    _counterText ctrlSetTextColor _dimColor;
    _counterText ctrlSetFont "PuristaMedium";
    _counterText ctrlSetFontHeight 0.024;
    _counterText ctrlSetBackgroundColor [0, 0, 0, 0];
    _counterText ctrlCommit 0;
    // Center text with style 2
    
    // Next unit
    private _nextBtn = _display ctrlCreate ["RscButton", 9609];
    _nextBtn ctrlSetPosition [_panelX + _panelW - _arrowW - _pad, _navY, _arrowW, _navH];
    _nextBtn ctrlSetText "NEXT ►";
    _nextBtn ctrlSetTextColor _textColor;
    _nextBtn ctrlSetBackgroundColor _btnColor;
    _nextBtn ctrlSetFont "PuristaBold";
    _nextBtn ctrlSetFontHeight 0.024;
    _nextBtn ctrlCommit 0;
    _nextBtn ctrlAddEventHandler ["ButtonClick", {
        private _list = missionNamespace getVariable ["OpsRoom_DossierUnitList", []];
        private _idx = missionNamespace getVariable ["OpsRoom_DossierUnitIndex", 0];
        if (count _list > 0) then {
            _idx = (_idx + 1) mod count _list;
            private _newUnit = _list select _idx;
            private _groupId = missionNamespace getVariable ["OpsRoom_DossierGroupId", ""];
            [] call OpsRoom_fnc_closeDossier;
            [_newUnit, _groupId] call OpsRoom_fnc_openUnitDossier;
        };
    }];
    _nextBtn ctrlAddEventHandler ["MouseEnter", { (_this select 0) ctrlSetBackgroundColor [0.45, 0.50, 0.30, 1.0] }];
    _nextBtn ctrlAddEventHandler ["MouseExit", { (_this select 0) ctrlSetBackgroundColor [0.30, 0.35, 0.22, 0.9] }];
};

// ========================================
// RENDER INITIAL TAB (Profile)
// ========================================
[] call OpsRoom_fnc_renderDossierTab;

// ========================================
// CAMERA: Zoom to unit
// ========================================
[] spawn {
    private _unit = missionNamespace getVariable ["OpsRoom_DossierUnit", objNull];
    if (isNull _unit) exitWith {};
    
    private _unitPos = getPosATL _unit;
    private _unitDir = getDir _unit;
    
    private _dirRad = _unitDir * (pi / 180);
    private _camX = (_unitPos select 0) + (3 * sin _dirRad) + (0.8 * cos _dirRad);
    private _camY = (_unitPos select 1) + (3 * cos _dirRad) - (0.8 * sin _dirRad);
    private _camZ = 1.5;
    
    private _camPos = [_camX, _camY, _camZ];
    [_camPos, _unit, 1.5] call BIS_fnc_setCuratorCamera;
};

diag_log format ["[OpsRoom Dossier] Opened for: %1", name _unit];
