/*
    OpsRoom_fnc_createAbilityButton
    
    Creates a single ability button on Zeus display
    
    Parameters:
        _display - Zeus display (312)
        _abilityID - Ability identifier
        _config - Ability config hashmap
        _index - Button index (0, 1, 2...)
        _startX - Starting X position
        _yPos - Y position
        _buttonSize - Button size
        _padding - Padding between buttons
*/

params ["_display", "_abilityID", "_config", "_index", "_startX", "_yPos", "_buttonSize", "_padding"];

private _name = _config get "name";
private _icon = _config get "icon";
private _tooltip = _config get "tooltip";
private _action = _config get "action";

// Calculate position
private _xPos = _startX + (_index * (_buttonSize + _padding));

// Control IDs: BG = 9350 + (index * 2), BTN = 9351 + (index * 2)
private _bgIDC = 9350 + (_index * 2);
private _btnIDC = 9351 + (_index * 2);

// Create background
private _bg = _display ctrlCreate ["RscText", _bgIDC];
_bg ctrlSetPosition [_xPos, _yPos, _buttonSize, _buttonSize];
_bg ctrlSetBackgroundColor [0.15, 0.15, 0.15, 0.8];
_bg ctrlCommit 0;

// Create button with icon
private _btn = _display ctrlCreate ["RscActivePicture", _btnIDC];
_btn ctrlSetPosition [_xPos, _yPos, _buttonSize, _buttonSize];
_btn ctrlSetText _icon;
_btn ctrlSetTooltip _tooltip;
_btn ctrlSetTextColor [0.85, 0.82, 0.74, 1.0];
_btn ctrlCommit 0;

// Store references
_btn setVariable ["buttonBG", _bg];
_btn setVariable ["abilityID", _abilityID];
_btn setVariable ["abilityAction", _action];

diag_log format ["[OpsRoom] Created ability button %1 at IDC %2/%3", _abilityID, _bgIDC, _btnIDC];
diag_log format ["[OpsRoom] Button %1 action: %2", _abilityID, _action];

// Button click handler - Use MouseButtonClick only
_btn ctrlAddEventHandler ["MouseButtonClick", {
    params ["_ctrl", "_button"];
    if (_button != 0) exitWith {}; // Only left click
    diag_log format ["[OpsRoom] MouseButtonClick event! IDC: %1", ctrlIDC _ctrl];
    private _abilityID = _ctrl getVariable ["abilityID", "unknown"];
    diag_log format ["[OpsRoom] Ability ID: %1", _abilityID];
    private _action = _ctrl getVariable ["abilityAction", {}];
    diag_log format ["[OpsRoom] Calling action: %1", _action];
    [] call _action;
}];

// Hover effects
_btn ctrlAddEventHandler ["MouseEnter", {
    params ["_ctrl"];
    private _bg = _ctrl getVariable ["buttonBG", controlNull];
    if (!isNull _bg) then {
        _bg ctrlSetBackgroundColor [0.40, 0.35, 0.25, 0.95];
    };
}];

_btn ctrlAddEventHandler ["MouseExit", {
    params ["_ctrl"];
    private _bg = _ctrl getVariable ["buttonBG", controlNull];
    if (!isNull _bg) then {
        _bg ctrlSetBackgroundColor [0.15, 0.15, 0.15, 0.8];
    };
}];
