/*
    OpsRoom_fnc_createStandardButtons
    
    Creates standard buttons that are always visible (LEFT side)
    These control basic unit commands: stance, combat mode, speed, formation, behaviour
*/

waitUntil {!isNull (findDisplay 312)};

private _display = findDisplay 312;

// Button layout - centered vertically in the taller bottom bar
private _buttonSize = 0.035 * safezoneH;
private _padding = 0.005 * safezoneW;
private _startX = safezoneX + _padding;
// Center buttons in the 0.08 tall bottom bar: (0.08 - 0.035) / 2 = 0.0225 from bottom
private _yPos = safezoneY + safezoneH - (0.08 * safezoneH) + (0.0225 * safezoneH);

// Standard button definitions [IDC_BG, IDC_BTN, Name, Icon, Tooltip]
private _standardButtons = [
    [9300, 9301, "stance", "a3\ui_f\data\igui\cfg\simpleTasks\types\walk_ca.paa", "Stance - Click to cycle"],
    [9302, 9303, "combatMode", "a3\ui_f\data\igui\cfg\simpleTasks\types\danger_ca.paa", "Combat Mode - Click to cycle"],
    [9304, 9305, "speedMode", "a3\ui_f\data\igui\cfg\simpleTasks\types\move_ca.paa", "Speed Mode - Click to cycle"],
    [9306, 9307, "formation", "a3\ui_f\data\igui\cfg\simpleTasks\types\meet_ca.paa", "Formation - Click to change"],
    [9308, 9309, "behaviour", "a3\ui_f\data\igui\cfg\simpletasks\types\search_ca.paa", "Behaviour - Click to change"],
    [9310, 9311, "regroup", "a3\ui_f\data\gui\rsc\rscdisplayarcademap\icon_toolbox_groups_ca.paa", "Regroup - Reattach detached units"]
];

{
    _x params ["_bgIDC", "_btnIDC", "_commandType", "_icon", "_tooltip"];
    private _index = _forEachIndex;
    
    // Calculate position
    private _xPos = _startX + (_index * (_buttonSize + _padding));
    
    // Delete existing if present
    private _oldBG = _display displayCtrl _bgIDC;
    private _oldBtn = _display displayCtrl _btnIDC;
    if (!isNull _oldBG) then {ctrlDelete _oldBG};
    if (!isNull _oldBtn) then {ctrlDelete _oldBtn};
    
    // Create background
    private _bg = _display ctrlCreate ["RscText", _bgIDC];
    _bg ctrlSetPosition [_xPos, _yPos, _buttonSize, _buttonSize];
    _bg ctrlSetBackgroundColor [0.15, 0.15, 0.15, 0.8];
    _bg ctrlShow false;  // Start hidden until something is selected
    _bg ctrlCommit 0;
    
    // Create button
    private _btn = _display ctrlCreate ["RscActivePicture", _btnIDC];
    _btn ctrlSetPosition [_xPos, _yPos, _buttonSize, _buttonSize];
    _btn ctrlSetText _icon;
    _btn ctrlSetTooltip _tooltip;
    _btn ctrlSetTextColor [0.85, 0.82, 0.74, 1.0];
    _btn ctrlShow false;  // Start hidden until something is selected
    _btn ctrlCommit 0;
    
    // Store references
    _btn setVariable ["buttonBG", _bg];
    _btn setVariable ["commandType", _commandType];
    
    diag_log format ["[OpsRoom] Created standard button: %1 (IDC %2/%3)", _commandType, _bgIDC, _btnIDC];
    diag_log format ["[OpsRoom] Button %1 position: x=%2, y=%3, w=%4, h=%5", _commandType, _xPos, _yPos, _buttonSize, _buttonSize];
    
    // Button click handler - open menu instead of cycling
    _btn ctrlAddEventHandler ["ButtonClick", {
        params ["_ctrl"];
        private _commandType = _ctrl getVariable ["commandType", ""];
        private _display = ctrlParent _ctrl;
        
        // Get button position for menu placement
        private _btnPos = ctrlPosition _ctrl;
        private _baseX = _btnPos select 0;
        private _baseY = _btnPos select 1;
        private _buttonSize = _btnPos select 2;
        
        // Get menu items based on command type
        private _menuItems = switch (_commandType) do {
            case "stance": {[] call OpsRoom_fnc_getStanceMenu};
            case "combatMode": {[] call OpsRoom_fnc_getCombatModeMenu};
            case "speedMode": {[] call OpsRoom_fnc_getSpeedModeMenu};
            case "formation": {[] call OpsRoom_fnc_getFormationMenu};
            case "behaviour": {[] call OpsRoom_fnc_getBehaviourMenu};
            case "regroup": {
                // Regroup is a direct action, not a menu
                [] call OpsRoom_fnc_ability_regroup;
                [] // Return empty array so no menu is created
            };
            default {[]};
        };
        
        // Create the menu (only if menu items exist)
        if (count _menuItems > 0) then {
            [_display, _ctrl, _menuItems, _baseX, _baseY, _buttonSize] call OpsRoom_fnc_createButtonMenu;
        };
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
    
} forEach _standardButtons;

systemChat "✓ Standard buttons created";
diag_log "[OpsRoom] Standard buttons created on Zeus toolbar";
