/*
    OpsRoom_fnc_updateInventoryButton
    
    Creates/updates the inventory button on Zeus display
    Shows when units are selected, hides when nothing selected
    
    Rules:
    - Show for friendly alive units
    - Show for ANY dead units (friendly or enemy)
    - Hide for enemy alive units
*/

params ["_selected"];

private _display = findDisplay 312;
if (isNull _display) exitWith {};

private _invButton = _display displayCtrl 9021;
private _invBG = _display displayCtrl 9022;

// If no selection, hide button
if (count _selected == 0) exitWith {
    if (!isNull _invButton) then {_invButton ctrlShow false};
    if (!isNull _invBG) then {_invBG ctrlShow false};
};

// Check if we should show inventory button
private _unit = _selected select 0;
private _showButton = false;

// Allow for dead units (friendly or enemy)
if (!alive _unit) then {
    _showButton = true;
} else {
    // Only allow for friendly alive units
    if ((side _unit) == (side player)) then {
        _showButton = true;
    };
};

// If shouldn't show, hide and exit
if (!_showButton) exitWith {
    if (!isNull _invButton) then {_invButton ctrlShow false};
    if (!isNull _invBG) then {_invBG ctrlShow false};
};

// Create button if it doesn't exist
if (isNull _invButton) then {
    // Button size - square and bigger
    private _buttonSize = 0.045 * safezoneH;
    
    // Position - left of unit info box
    private _xPos = safezoneX + (safezoneW / 2) - (0.15 * safezoneW) - _buttonSize - (0.01 * safezoneW);
    private _yPos = safezoneY + safezoneH - (0.065 * safezoneH);
    
    // Create background
    private _bg = _display ctrlCreate ["RscText", 9022];
    _bg ctrlSetPosition [_xPos, _yPos, _buttonSize, _buttonSize];
    _bg ctrlSetBackgroundColor [0.15, 0.15, 0.15, 0.8];
    _bg ctrlCommit 0;
    
    // Create button with icon
    _invButton = _display ctrlCreate ["RscActivePicture", 9021];
    _invButton ctrlSetPosition [_xPos, _yPos, _buttonSize, _buttonSize];
    _invButton ctrlSetText "JMSSA_brits\data\ico\ico_b_p37_cup.paa";
    _invButton ctrlSetTooltip "Open Inventory";
    _invButton ctrlSetTextColor [0.85, 0.82, 0.74, 1.0];
    _invButton ctrlCommit 0;
    
    // Store background reference
    _invButton setVariable ["buttonBG", _bg];
    
    // Click handler
    _invButton ctrlAddEventHandler ["MouseButtonClick", {
        params ["_ctrl", "_button"];
        if (_button != 0) exitWith {}; // Only left click
        [] call OpsRoom_fnc_openInventory;
    }];
    
    // Hover effects
    _invButton ctrlAddEventHandler ["MouseEnter", {
        params ["_ctrl"];
        private _bg = _ctrl getVariable ["buttonBG", controlNull];
        if (!isNull _bg) then {
            _bg ctrlSetBackgroundColor [0.40, 0.35, 0.25, 0.95];
        };
    }];
    
    _invButton ctrlAddEventHandler ["MouseExit", {
        params ["_ctrl"];
        private _bg = _ctrl getVariable ["buttonBG", controlNull];
        if (!isNull _bg) then {
            _bg ctrlSetBackgroundColor [0.15, 0.15, 0.15, 0.8];
        };
    }];
} else {
    // Button exists, just show it
    _invButton ctrlShow true;
    if (!isNull _invBG) then {_invBG ctrlShow true};
};
