/*
    Operations Room - Create Side Menu Buttons
    
    Creates 10 clickable menu buttons (5 on each side).
    Uses RscActiveText for proper click handling in RscTitles.
*/

private _display = uiNamespace getVariable ["OpsRoom_HUD_Display", displayNull];
if (isNull _display) exitWith {
    systemChat "✗ Cannot create buttons - display not found";
};

// Delete existing buttons if they exist
{
    private _existingCtrl = _display displayCtrl _x;
    if (!isNull _existingCtrl) then {
        ctrlDelete _existingCtrl;
    };
} forEach [9100,9101,9102,9103,9104,9105,9106,9107,9108,9109,9200,9201,9202,9203,9204,9205,9206,9207,9208,9209];

// Left side buttons [IDC_BG, IDC_TEXT, "LABEL", "Title", "Description"]
private _leftButtons = [
    [9100, 9101, "RECRUITMENT", "Recruitment & Training", "Open recruitment and unit training interface"],
    [9102, 9103, "PRODUCTION", "Production", "Manage resource production and factories"],
    [9104, 9105, "RESEARCH", "Research", "Access technology research tree"],
    [9106, 9107, "OPERATIONS", "Operations", "Military operations and command"],
    [9108, 9109, "LOGISTICS", "Logistics", "Supply lines and logistics management"]
];

// Right side buttons
private _rightButtons = [
    [9200, 9201, "INTELLIGENCE", "Intelligence", "View intelligence reports and reconnaissance"],
    [9202, 9203, "DIPLOMACY", "Diplomacy", "Manage diplomatic relations and treaties"],
    [9204, 9205, "ECONOMY", "Economy", "Economic overview and trade management"],
    [9206, 9207, "POLITICS", "Politics", "Political decisions and governance"],
    [9208, 9209, "SETTINGS", "Settings", "Campaign settings and game options"]
];

// Button dimensions
private _buttonW = 0.08 * safezoneW;
private _buttonH = 0.05 * safezoneH;
private _padding = 0.01 * safezoneW;
private _startY = safezoneY + (0.15 * safezoneH);
private _spacing = 0.07 * safezoneH;

// Create left buttons
{
    _x params ["_idcBG", "_idcText", "_text", "_title", "_description"];
    private _index = _forEachIndex;
    private _yPos = _startY + (_index * _spacing);
    private _xPos = safezoneX + _padding;
    
    // Create background
    private _bg = _display ctrlCreate ["RscText", _idcBG];
    _bg ctrlSetPosition [_xPos, _yPos, _buttonW, _buttonH];
    _bg ctrlSetBackgroundColor [0.40, 0.35, 0.25, 0.85];
    _bg ctrlCommit 0;
    
    // Create clickable text overlay using RscActiveText
    private _btn = _display ctrlCreate ["RscActiveText", _idcText];
    _btn ctrlSetPosition [_xPos, _yPos, _buttonW, _buttonH];
    _btn ctrlSetText _text;
    _btn ctrlSetTextColor [0.85, 0.82, 0.74, 1.0];
    _btn ctrlSetFont "PuristaBold";
    _btn ctrlSetFontHeight 0.025;
    _btn ctrlCommit 0;
    
    // Store data in control
    _btn setVariable ["buttonTitle", _title];
    _btn setVariable ["buttonDesc", _description];
    _btn setVariable ["buttonBG", _bg];
    
    // Click handler
    _btn ctrlAddEventHandler ["ButtonClick", {
        params ["_ctrl"];
        private _title = _ctrl getVariable ["buttonTitle", "Unknown"];
        private _desc = _ctrl getVariable ["buttonDesc", "No description"];
        hint format ["=== %1 ===\n\n%2\n\n(Not yet implemented)", _title, _desc];
        systemChat format [">>> Clicked: %1", _title];
    }];
    
    // Hover effects
    _btn ctrlAddEventHandler ["MouseEnter", {
        params ["_ctrl"];
        private _bg = _ctrl getVariable ["buttonBG", controlNull];
        if (!isNull _bg) then {
            _bg ctrlSetBackgroundColor [0.50, 0.45, 0.35, 0.95];
        };
        _ctrl ctrlSetTextColor [1.0, 0.96, 0.86, 1.0];
    }];
    
    _btn ctrlAddEventHandler ["MouseExit", {
        params ["_ctrl"];
        private _bg = _ctrl getVariable ["buttonBG", controlNull];
        if (!isNull _bg) then {
            _bg ctrlSetBackgroundColor [0.40, 0.35, 0.25, 0.85];
        };
        _ctrl ctrlSetTextColor [0.85, 0.82, 0.74, 1.0];
    }];
    
} forEach _leftButtons;

// Create right buttons
{
    _x params ["_idcBG", "_idcText", "_text", "_title", "_description"];
    private _index = _forEachIndex;
    private _yPos = _startY + (_index * _spacing);
    private _xPos = safezoneX + safezoneW - _buttonW - _padding;
    
    // Create background
    private _bg = _display ctrlCreate ["RscText", _idcBG];
    _bg ctrlSetPosition [_xPos, _yPos, _buttonW, _buttonH];
    _bg ctrlSetBackgroundColor [0.40, 0.35, 0.25, 0.85];
    _bg ctrlCommit 0;
    
    // Create clickable text overlay using RscActiveText
    private _btn = _display ctrlCreate ["RscActiveText", _idcText];
    _btn ctrlSetPosition [_xPos, _yPos, _buttonW, _buttonH];
    _btn ctrlSetText _text;
    _btn ctrlSetTextColor [0.85, 0.82, 0.74, 1.0];
    _btn ctrlSetFont "PuristaBold";
    _btn ctrlSetFontHeight 0.025;
    _btn ctrlCommit 0;
    
    // Store data in control
    _btn setVariable ["buttonTitle", _title];
    _btn setVariable ["buttonDesc", _description];
    _btn setVariable ["buttonBG", _bg];
    
    // Click handler
    _btn ctrlAddEventHandler ["ButtonClick", {
        params ["_ctrl"];
        private _title = _ctrl getVariable ["buttonTitle", "Unknown"];
        private _desc = _ctrl getVariable ["buttonDesc", "No description"];
        hint format ["=== %1 ===\n\n%2\n\n(Not yet implemented)", _title, _desc];
        systemChat format [">>> Clicked: %1", _title];
    }];
    
    // Hover effects
    _btn ctrlAddEventHandler ["MouseEnter", {
        params ["_ctrl"];
        private _bg = _ctrl getVariable ["buttonBG", controlNull];
        if (!isNull _bg) then {
            _bg ctrlSetBackgroundColor [0.50, 0.45, 0.35, 0.95];
        };
        _ctrl ctrlSetTextColor [1.0, 0.96, 0.86, 1.0];
    }];
    
    _btn ctrlAddEventHandler ["MouseExit", {
        params ["_ctrl"];
        private _bg = _ctrl getVariable ["buttonBG", controlNull];
        if (!isNull _bg) then {
            _bg ctrlSetBackgroundColor [0.40, 0.35, 0.25, 0.85];
        };
        _ctrl ctrlSetTextColor [0.85, 0.82, 0.74, 1.0];
    }];
    
} forEach _rightButtons;

systemChat format ["✓ Created %1 clickable buttons", (count _leftButtons) + (count _rightButtons)];
