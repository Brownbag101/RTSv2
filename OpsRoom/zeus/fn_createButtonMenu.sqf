/*
    OpsRoom_fnc_createButtonMenu
    
    Creates an expandable menu above a button
    
    Parameters:
        _display - Zeus display
        _baseButton - The button that was clicked
        _menuItems - Array of [text, icon, action] for each menu item
        _baseX - X position of base button
        _baseY - Y position of base button
        _buttonSize - Size of buttons
*/

params ["_display", "_baseButton", "_menuItems", "_baseX", "_baseY", "_buttonSize"];

// Close any existing menu first
[] call OpsRoom_fnc_closeButtonMenu;

// Calculate menu dimensions
private _padding = 0.003 * safezoneW;
private _menuHeight = (count _menuItems) * (_buttonSize + _padding);

// Menu starts above the base button
private _menuStartY = _baseY - _menuHeight - _padding;

// Store menu controls globally so we can close them
OpsRoom_ActiveMenuControls = [];

// Create each menu item (bottom to top, so index 0 is at bottom)
{
    _x params ["_text", "_icon", "_action"];
    private _index = _forEachIndex;
    
    // Calculate position (reversed - index 0 at bottom)
    private _yPos = _baseY - ((_index + 1) * (_buttonSize + _padding));
    
    // IDC range 9400-9449 for menu items
    private _bgIDC = 9400 + (_index * 2);
    private _btnIDC = 9401 + (_index * 2);
    
    // Create background
    private _bg = _display ctrlCreate ["RscText", _bgIDC];
    _bg ctrlSetPosition [_baseX, _yPos, _buttonSize, _buttonSize];
    _bg ctrlSetBackgroundColor [0.20, 0.18, 0.15, 0.95];
    _bg ctrlCommit 0;
    
    // Create button
    private _btn = _display ctrlCreate ["RscActivePicture", _btnIDC];
    _btn ctrlSetPosition [_baseX, _yPos, _buttonSize, _buttonSize];
    _btn ctrlSetText _icon;
    _btn ctrlSetTooltip _text;
    _btn ctrlSetTextColor [0.85, 0.82, 0.74, 1.0];
    _btn ctrlCommit 0;
    
    // Store reference
    _btn setVariable ["buttonBG", _bg];
    _btn setVariable ["menuAction", _action];
    
    // Click handler - execute action and close menu
    _btn ctrlAddEventHandler ["ButtonClick", {
        params ["_ctrl"];
        private _action = _ctrl getVariable ["menuAction", {}];
        [] call _action;
        [] call OpsRoom_fnc_closeButtonMenu;
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
            _bg ctrlSetBackgroundColor [0.20, 0.18, 0.15, 0.95];
        };
    }];
    
    // Store controls for cleanup
    OpsRoom_ActiveMenuControls pushBack _bg;
    OpsRoom_ActiveMenuControls pushBack _btn;
    
} forEach _menuItems;

// Note: Don't store base button control (causes serialization warning)
