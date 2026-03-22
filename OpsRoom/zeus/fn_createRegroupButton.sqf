/*
    OpsRoom_fnc_createRegroupButton
    
    Creates a "Regroup" toolbar button at the bottom of Zeus display
    Uses the groups icon from ARMA 3 UI
*/

// Wait for Zeus display to exist
waitUntil {!isNull (findDisplay 312)};

private _zeusDisplay = findDisplay 312;

// Delete existing button if it exists
private _existingBG = _zeusDisplay displayCtrl 9300;
private _existingBtn = _zeusDisplay displayCtrl 9301;
if (!isNull _existingBG) then { ctrlDelete _existingBG; };
if (!isNull _existingBtn) then { ctrlDelete _existingBtn; };

// Button configuration - smaller, toolbar-style button
private _buttonSize = 0.035 * safezoneH; // Smaller square button
private _padding = 0.01 * safezoneW;

// Position at bottom center, slightly higher up
private _xPos = safezoneX + (safezoneW / 2) - (_buttonSize / 2);
private _yPos = safezoneY + safezoneH - _buttonSize - (0.05 * safezoneH);

// Create background
private _bg = _zeusDisplay ctrlCreate ["RscText", 9300];
_bg ctrlSetPosition [_xPos, _yPos, _buttonSize, _buttonSize];
_bg ctrlSetBackgroundColor [0.15, 0.15, 0.15, 0.8];
_bg ctrlCommit 0;

// Create button with icon - use RscPicture for better icon display
private _btn = _zeusDisplay ctrlCreate ["RscActivePicture", 9301];
_btn ctrlSetPosition [_xPos, _yPos, _buttonSize, _buttonSize];
_btn ctrlSetText "a3\ui_f\data\gui\rsc\rscdisplayarcademap\icon_toolbox_groups_ca.paa";
_btn ctrlSetTooltip "Regroup - Reattach detached sub-teams to parent group";
_btn ctrlSetTextColor [0.85, 0.82, 0.74, 1.0];
_btn ctrlCommit 0;

// Store reference to background
_btn setVariable ["buttonBG", _bg];

// Button click handler
_btn ctrlAddEventHandler ["ButtonClick", {
    [] call OpsRoom_fnc_reformGroup;
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

systemChat "✓ Regroup toolbar button created";
