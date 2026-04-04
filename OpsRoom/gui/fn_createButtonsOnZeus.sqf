/*
    Operations Room - Create Buttons on Zeus Display
    Uses RscActivePicture (same as working standard buttons).
    Textures are .paa in OpsRoom\gui\textures\
*/

waitUntil {!isNull (findDisplay 312)};

private _zeusDisplay = findDisplay 312;
systemChat "Creating buttons on Zeus display (312)...";

// Delete ALL existing buttons
private _allButtonIDCs = [];
for "_i" from 9100 to 9120 do { _allButtonIDCs pushBack _i; };
for "_i" from 9200 to 9220 do { _allButtonIDCs pushBack _i; };

for "_i" from 0 to 2 do {
    {
        private _existingCtrl = _zeusDisplay displayCtrl _x;
        if (!isNull _existingCtrl) then {
            ctrlDelete _existingCtrl;
        };
    } forEach _allButtonIDCs;
    uiSleep 0.05;
};

// Button configuration
private _buttonW = 0.045 * safezoneW;
private _buttonH = 0.045 * safezoneW;
private _padding = 0.008 * safezoneW;
private _startY = safezoneY + (0.20 * safezoneH);
private _spacing = _buttonH + (0.012 * safezoneH);

// Build texture path with backslashes via toString
private _sep = toString [92];
private _texBase = "OpsRoom" + _sep + "gui" + _sep + "textures" + _sep;

// Left buttons [IDC, "Tooltip", "texture filename"]
private _leftButtons = [
    [9101, "Regiments - Manage unit organisation",        "regiments_button.paa"],
    [9103, "Recruitment - Train and recruit new units",    "recruitment_button.paa"],
    [9105, "Production - Manage factories and resources",  "production_button_icon.paa"],
    [9107, "Research - Develop new technologies",          "research_button.paa"],
    [9109, "Supply - Ship equipment to the battlefield",   "supply_button.paa"]
];

// Right buttons
private _rightButtons = [
    [9201, "Intelligence - Operational map and reports",    "intelligence_button.paa"],
    [9203, "Dispatches - View signals and messages",        "dispatches_button.paa"],
    [9205, "Operations Room - Plan and manage operations",  "opsroom_button.paa"],
    [9207, "Stores - Manage supply depots and equipment",   "supply_button.paa"],
    [9209, "Air Operations - Manage aircraft and missions", "airops_button_icon.paa"]
];

// Create left buttons — RscActivePicture (same pattern as working standard buttons)
{
    _x params ["_idc", "_tooltip", "_texFile"];
    private _index = _forEachIndex;
    private _yPos = _startY + (_index * _spacing);
    private _xPos = safezoneX + _padding;
    private _texture = _texBase + _texFile;

    private _btn = _zeusDisplay ctrlCreate ["RscActivePicture", _idc];
    _btn ctrlSetPosition [_xPos, _yPos, _buttonW, _buttonH];
    _btn ctrlSetText _texture;
    _btn ctrlSetTooltip _tooltip;
    _btn ctrlSetTextColor [1, 1, 1, 1];
    _btn ctrlCommit 0;

    _btn setVariable ["picBaseX", _xPos];
    _btn setVariable ["picBaseY", _yPos];
    _btn setVariable ["picBaseSize", _buttonW];

    _btn ctrlAddEventHandler ["ButtonClick", {
        params ["_ctrl"];
        private _idc = ctrlIDC _ctrl;
        switch (_idc) do {
            case 9101: { [] call OpsRoom_fnc_openRegiments; };
            case 9103: { [] call OpsRoom_fnc_openRecruitment; };
            case 9105: { [] call OpsRoom_fnc_openFactories; };
            case 9107: { [] call OpsRoom_fnc_openResearchCategories; };
            case 9109: { [] call OpsRoom_fnc_openSupply; };
            default { hint format ["Not yet implemented: IDC %1", _idc]; };
        };
    }];

    _btn ctrlAddEventHandler ["MouseEnter", {
        params ["_ctrl"];
        private _bx = _ctrl getVariable ["picBaseX", 0];
        private _by = _ctrl getVariable ["picBaseY", 0];
        private _bs = _ctrl getVariable ["picBaseSize", 0];
        private _newSize = _bs * 1.15;
        private _offset  = (_newSize - _bs) / 2;
        _ctrl ctrlSetPosition [_bx - _offset, _by - _offset, _newSize, _newSize];
        _ctrl ctrlCommit 0.08;
    }];

    _btn ctrlAddEventHandler ["MouseExit", {
        params ["_ctrl"];
        private _bx = _ctrl getVariable ["picBaseX", 0];
        private _by = _ctrl getVariable ["picBaseY", 0];
        private _bs = _ctrl getVariable ["picBaseSize", 0];
        _ctrl ctrlSetPosition [_bx, _by, _bs, _bs];
        _ctrl ctrlCommit 0.08;
    }];

} forEach _leftButtons;

// Create right buttons
{
    _x params ["_idc", "_tooltip", "_texFile"];
    private _index = _forEachIndex;
    private _yPos = _startY + (_index * _spacing);
    private _xPos = safezoneX + safezoneW - _buttonW - _padding;
    private _texture = _texBase + _texFile;

    private _btn = _zeusDisplay ctrlCreate ["RscActivePicture", _idc];
    _btn ctrlSetPosition [_xPos, _yPos, _buttonW, _buttonH];
    _btn ctrlSetText _texture;
    _btn ctrlSetTooltip _tooltip;
    _btn ctrlSetTextColor [1, 1, 1, 1];
    _btn ctrlCommit 0;

    _btn setVariable ["picBaseX", _xPos];
    _btn setVariable ["picBaseY", _yPos];
    _btn setVariable ["picBaseSize", _buttonW];

    _btn ctrlAddEventHandler ["ButtonClick", {
        params ["_ctrl"];
        private _idc = ctrlIDC _ctrl;
        switch (_idc) do {
            case 9201: { [] call OpsRoom_fnc_openOpsMap; };
            case 9203: { [] call OpsRoom_fnc_openDispatchLog; };
            case 9205: { [] call OpsRoom_fnc_openOperations; };
            case 9207: { [] call OpsRoom_fnc_openStorehouseGrid; };
            case 9209: { [] call OpsRoom_fnc_openAirOps; };
            default { hint format ["Not yet implemented: IDC %1", _idc]; };
        };
    }];

    _btn ctrlAddEventHandler ["MouseEnter", {
        params ["_ctrl"];
        private _bx = _ctrl getVariable ["picBaseX", 0];
        private _by = _ctrl getVariable ["picBaseY", 0];
        private _bs = _ctrl getVariable ["picBaseSize", 0];
        private _newSize = _bs * 1.15;
        private _offset  = (_newSize - _bs) / 2;
        _ctrl ctrlSetPosition [_bx - _offset, _by - _offset, _newSize, _newSize];
        _ctrl ctrlCommit 0.08;
    }];

    _btn ctrlAddEventHandler ["MouseExit", {
        params ["_ctrl"];
        private _bx = _ctrl getVariable ["picBaseX", 0];
        private _by = _ctrl getVariable ["picBaseY", 0];
        private _bs = _ctrl getVariable ["picBaseSize", 0];
        _ctrl ctrlSetPosition [_bx, _by, _bs, _bs];
        _ctrl ctrlCommit 0.08;
    }];

} forEach _rightButtons;

systemChat format ["Created %1 icon buttons on Zeus display", (count _leftButtons) + (count _rightButtons)];
