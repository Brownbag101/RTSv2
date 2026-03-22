/*
    fn_showDispatchPopup
    
    Creates a dispatch notification card directly on Zeus display (312).
    Uses cutRsc-style dynamic controls — does NOT steal mouse focus.
    
    Slides in from right side of screen, shows coloured header bar,
    title, body, timestamp, FOCUS and DISMISS buttons.
    Auto-dismisses after configurable time per type.
    
    When dismissed (auto or manual), checks queue for next dispatch.
    
    Parameters:
        0: HASHMAP - Dispatch data
    
    IDC Range: 12000-12019 (popup controls)
*/

params [["_dispatch", createHashMap, [createHashMap]]];

private _type = _dispatch get "type";
private _title = _dispatch get "title";
private _body = _dispatch get "body";
private _dateTime = _dispatch get "dateTime";
private _id = _dispatch get "id";
private _focusPos = _dispatch get "focusPos";
private _focusObj = _dispatch get "focusObj";

// Get type config
private _typeConfig = OpsRoom_DispatchTypes getOrDefault [_type, OpsRoom_DispatchTypes get "ROUTINE"];
private _headerColor = _typeConfig get "color";
private _soundClass = _typeConfig get "sound";
private _dismissTime = _typeConfig get "dismissTime";
private _displayName = _typeConfig get "displayName";

// Mark popup as active
OpsRoom_DispatchPopupActive = true;
OpsRoom_CurrentDispatch = _dispatch;

// Play sound
playSound _soundClass;

// Get Zeus display
private _display = findDisplay 312;
if (isNull _display) exitWith {
    OpsRoom_DispatchPopupActive = false;
    diag_log "[OpsRoom] Dispatch popup failed - no Zeus display";
};

// Clean up any existing popup controls
for "_idc" from 12000 to 12019 do {
    private _ctrl = _display displayCtrl _idc;
    if (!isNull _ctrl) then { ctrlDelete _ctrl };
};

// ========================================
// POPUP DIMENSIONS - Top right of screen
// ========================================
private _popupW = 0.22 * safezoneW;
private _popupH = 0.18 * safezoneH;
private _popupX = safezoneX + safezoneW - _popupW - (0.01 * safezoneW);
private _popupY = safezoneY + (0.07 * safezoneH);  // Below resource bar

// Start position (off-screen right) for slide-in
private _startX = safezoneX + safezoneW + 0.01;

// ========================================
// CREATE CONTROLS
// ========================================

// Main background card
private _bgCard = _display ctrlCreate ["RscText", 12000];
_bgCard ctrlSetPosition [_startX, _popupY, _popupW, _popupH];
_bgCard ctrlSetBackgroundColor [0.15, 0.13, 0.10, 0.92];
_bgCard ctrlCommit 0;

// Coloured header bar (type indicator)
private _headerBar = _display ctrlCreate ["RscText", 12001];
_headerBar ctrlSetPosition [_startX, _popupY, _popupW, 0.03 * safezoneH];
_headerBar ctrlSetBackgroundColor _headerColor;
_headerBar ctrlCommit 0;

// Type label on header
private _typeLabel = _display ctrlCreate ["RscText", 12002];
_typeLabel ctrlSetPosition [_startX + 0.008 * safezoneW, _popupY + 0.003 * safezoneH, _popupW - 0.016 * safezoneW, 0.025 * safezoneH];
_typeLabel ctrlSetText (toUpper _displayName);
_typeLabel ctrlSetFont "PuristaBold";
_typeLabel ctrlSetTextColor [1, 1, 1, 1];
_typeLabel ctrlSetBackgroundColor [0, 0, 0, 0];
_typeLabel ctrlCommit 0;
private _sizeEx = 0.025;
_typeLabel ctrlSetFontHeight _sizeEx;

// Title text
private _titleCtrl = _display ctrlCreate ["RscText", 12003];
_titleCtrl ctrlSetPosition [_startX + 0.008 * safezoneW, _popupY + 0.035 * safezoneH, _popupW - 0.016 * safezoneW, 0.03 * safezoneH];
_titleCtrl ctrlSetText (toUpper _title);
_titleCtrl ctrlSetFont "PuristaBold";
_titleCtrl ctrlSetTextColor [0.95, 0.90, 0.80, 1];
_titleCtrl ctrlSetBackgroundColor [0, 0, 0, 0];
_titleCtrl ctrlCommit 0;

// Body text (structured for multi-line)
private _bodyCtrl = _display ctrlCreate ["RscStructuredText", 12004];
_bodyCtrl ctrlSetPosition [_startX + 0.008 * safezoneW, _popupY + 0.065 * safezoneH, _popupW - 0.016 * safezoneW, 0.06 * safezoneH];
_bodyCtrl ctrlSetStructuredText parseText format ["<t size='0.9' color='#C8C4B8'>%1</t>", _body];
_bodyCtrl ctrlSetBackgroundColor [0, 0, 0, 0];
_bodyCtrl ctrlCommit 0;

// Timestamp
private _timeCtrl = _display ctrlCreate ["RscText", 12005];
_timeCtrl ctrlSetPosition [_startX + 0.008 * safezoneW, _popupY + 0.125 * safezoneH, 0.08 * safezoneW, 0.02 * safezoneH];
_timeCtrl ctrlSetText _dateTime;
_timeCtrl ctrlSetFont "PuristaLight";
_timeCtrl ctrlSetTextColor [0.6, 0.58, 0.52, 0.8];
_timeCtrl ctrlSetBackgroundColor [0, 0, 0, 0];
_timeCtrl ctrlCommit 0;
private _timeSizeEx = 0.022;
_timeCtrl ctrlSetFontHeight _timeSizeEx;

// ========================================
// BUTTONS - FOCUS and DISMISS
// ========================================

// Determine if FOCUS button should show
private _hasFocus = false;
if (!isNil "_focusPos") then { _hasFocus = true };
if (!isNull _focusObj) then { _hasFocus = true };

private _btnY = _popupY + _popupH - 0.035 * safezoneH;

if (_hasFocus) then {
    // FOCUS button
    private _focusBtn = _display ctrlCreate ["RscButton", 12010];
    _focusBtn ctrlSetPosition [_startX + 0.008 * safezoneW, _btnY, 0.09 * safezoneW, 0.028 * safezoneH];
    _focusBtn ctrlSetText "FOCUS";
    _focusBtn ctrlSetFont "PuristaBold";
    _focusBtn ctrlSetTextColor [0.9, 0.9, 0.8, 1];
    _focusBtn ctrlSetBackgroundColor [0.30, 0.35, 0.25, 0.9];
    _focusBtn ctrlCommit 0;
    
    // Store focus data on the button
    _focusBtn setVariable ["dispatchId", _id];
    
    _focusBtn ctrlAddEventHandler ["ButtonClick", {
        params ["_ctrl"];
        private _dId = _ctrl getVariable ["dispatchId", ""];
        [_dId] call OpsRoom_fnc_focusDispatch;
    }];
    
    // DISMISS button (next to focus)
    private _dismissBtn = _display ctrlCreate ["RscButton", 12011];
    _dismissBtn ctrlSetPosition [_startX + 0.108 * safezoneW, _btnY, 0.09 * safezoneW, 0.028 * safezoneH];
    _dismissBtn ctrlSetText "DISMISS";
    _dismissBtn ctrlSetFont "PuristaBold";
    _dismissBtn ctrlSetTextColor [0.9, 0.9, 0.8, 1];
    _dismissBtn ctrlSetBackgroundColor [0.40, 0.35, 0.25, 0.9];
    _dismissBtn ctrlCommit 0;
    
    _dismissBtn ctrlAddEventHandler ["ButtonClick", {
        [] call OpsRoom_fnc_dismissDispatch;
    }];
} else {
    // DISMISS only (centered wider)
    private _dismissBtn = _display ctrlCreate ["RscButton", 12011];
    _dismissBtn ctrlSetPosition [_startX + 0.008 * safezoneW, _btnY, _popupW - 0.016 * safezoneW, 0.028 * safezoneH];
    _dismissBtn ctrlSetText "DISMISS";
    _dismissBtn ctrlSetFont "PuristaBold";
    _dismissBtn ctrlSetTextColor [0.9, 0.9, 0.8, 1];
    _dismissBtn ctrlSetBackgroundColor [0.40, 0.35, 0.25, 0.9];
    _dismissBtn ctrlCommit 0;
    
    _dismissBtn ctrlAddEventHandler ["ButtonClick", {
        [] call OpsRoom_fnc_dismissDispatch;
    }];
};

// ========================================
// SLIDE-IN ANIMATION
// ========================================
// Animate all controls from startX to popupX
private _allIDCs = [12000, 12001, 12002, 12003, 12004, 12005, 12010, 12011];
{
    private _ctrl = _display displayCtrl _x;
    if (!isNull _ctrl) then {
        private _pos = ctrlPosition _ctrl;
        private _offsetFromStart = (_pos select 0) - _startX;
        _ctrl ctrlSetPosition [_popupX + _offsetFromStart, _pos select 1, _pos select 2, _pos select 3];
        _ctrl ctrlCommit 0.3;  // 0.3 second slide-in
    };
} forEach _allIDCs;

// ========================================
// AUTO-DISMISS TIMER
// ========================================
private _dismissAt = time + _dismissTime;
OpsRoom_DispatchDismissAt = _dismissAt;

// Monitor for auto-dismiss
[] spawn {
    private _targetTime = OpsRoom_DispatchDismissAt;
    
    while {OpsRoom_DispatchPopupActive && time < _targetTime} do {
        sleep 0.5;
        // Check if dismiss time was updated (new popup replaced this one)
        if (_targetTime != OpsRoom_DispatchDismissAt) exitWith {};
    };
    
    // Only auto-dismiss if this is still the active popup
    if (OpsRoom_DispatchPopupActive && _targetTime == OpsRoom_DispatchDismissAt) then {
        [] call OpsRoom_fnc_dismissDispatch;
    };
};

diag_log format ["[OpsRoom] Dispatch popup shown: [%1] %2 - %3 (auto-dismiss: %4s)", _type, _title, _id, _dismissTime];
