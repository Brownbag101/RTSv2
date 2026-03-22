/*
    Operations Room - Create Buttons on Zeus Display
    
    Creates buttons directly on Zeus display (312) for proper mouse interaction.
    Buttons created on RscTitles overlays don't receive mouse events properly.
*/

// Wait for Zeus display to exist
waitUntil {!isNull (findDisplay 312)};

private _zeusDisplay = findDisplay 312;
systemChat "Creating buttons on Zeus display (312)...";

// Delete ALL existing buttons aggressively (including backgrounds)
// This handles both old and new button sets
private _allButtonIDCs = [];
_allButtonIDCs append [9100,9101,9102,9103,9104,9105,9106,9107,9108,9109];
_allButtonIDCs append [9200,9201,9202,9203,9204,9205,9206,9207,9208,9209];

// Delete multiple times to ensure they're gone
for "_i" from 0 to 2 do {
    {
        private _existingCtrl = _zeusDisplay displayCtrl _x;
        if (!isNull _existingCtrl) then {
            ctrlDelete _existingCtrl;
        };
    } forEach _allButtonIDCs;
    
    // Small delay between deletion passes
    uiSleep 0.05;
};

// Button configuration
private _buttonW = 0.08 * safezoneW;
private _buttonH = 0.05 * safezoneH;
private _padding = 0.01 * safezoneW;
private _startY = safezoneY + (0.20 * safezoneH);  // Moved DOWN to leave space for hints at top
private _spacing = 0.07 * safezoneH;

// Left side buttons [IDC_BG, IDC_BTN, "LABEL", "Title", "Description"]
private _leftButtons = [
    [9100, 9101, "REGIMENTS", "Regiments", "Manage military regiments and unit organization"],
    [9102, 9103, "RECRUITMENT", "Recruitment & Training", "Open recruitment and unit training interface"],
    [9104, 9105, "PRODUCTION", "Production", "Manage resource production and factories"],
    [9106, 9107, "RESEARCH", "Research", "Access technology research tree"],
    [9108, 9109, "SUPPLY", "Supply & Logistics", "Ship equipment from warehouse to the battlefield"]
];

// Right side buttons
private _rightButtons = [
    [9200, 9201, "INTELLIGENCE", "Intelligence", "Open operational map and intelligence reports"],
    [9202, 9203, "DISPATCHES", "Dispatches", "View received dispatches and signals"],
    [9204, 9205, "OPS ROOM", "Operations Room", "Create and manage military operations"],
    [9206, 9207, "STORES", "Supply Stores", "Manage supply depots and equipment distribution"],
    [9208, 9209, "AIR OPS", "Air Operations", "Manage aircraft, air wings, and air missions"]
];

// Create left buttons
{
    _x params ["_idcBG", "_idcBtn", "_text", "_title", "_description"];
    private _index = _forEachIndex;
    private _yPos = _startY + (_index * _spacing);
    private _xPos = safezoneX + _padding;
    
    // Create background
    private _bg = _zeusDisplay ctrlCreate ["RscText", _idcBG];
    _bg ctrlSetPosition [_xPos, _yPos, _buttonW, _buttonH];
    _bg ctrlSetBackgroundColor [0.40, 0.35, 0.25, 0.85];
    _bg ctrlCommit 0;
    _bg ctrlShow true;
    
    // Create clickable button
    private _btn = _zeusDisplay ctrlCreate ["RscButton", _idcBtn];
    _btn ctrlSetPosition [_xPos, _yPos, _buttonW, _buttonH];
    _btn ctrlSetText _text;
    _btn ctrlSetTextColor [0.85, 0.82, 0.74, 1.0];
    _btn ctrlSetFont "PuristaBold";
    _btn ctrlCommit 0;
    _btn ctrlShow true;
    
    // Store data
    _btn setVariable ["buttonTitle", _title];
    _btn setVariable ["buttonDesc", _description];
    _btn setVariable ["buttonBG", _bg];
    
    // ButtonClick handler
    _btn ctrlAddEventHandler ["ButtonClick", {
        params ["_ctrl"];
        private _idcBtn = ctrlIDC _ctrl;
        private _title = _ctrl getVariable ["buttonTitle", "Unknown"];
        private _desc = _ctrl getVariable ["buttonDesc", "No description"];
        
        // Special handlers for specific buttons
        switch (_idcBtn) do {
            case 9101: { // REGIMENTS button
                [] call OpsRoom_fnc_openRegiments;
            };
            case 9103: { // RECRUITMENT button
                [] call OpsRoom_fnc_openRecruitment;
            };
            case 9105: { // PRODUCTION button
                [] call OpsRoom_fnc_openFactories;
            };
            case 9107: { // RESEARCH button
                [] call OpsRoom_fnc_openResearchCategories;
            };
            case 9109: { // OPERATIONS button → Supply for now
                [] call OpsRoom_fnc_openSupply;
            };
            default {
                hint format ["=== %1 ===\n\n%2\n\n(Not yet implemented)", _title, _desc];
                systemChat format [">>> Clicked: %1", _title];
            };
        };
    }];
    
    // Hover effects
    _btn ctrlAddEventHandler ["MouseEnter", {
        params ["_ctrl"];
        private _bg = _ctrl getVariable ["buttonBG", controlNull];
        if (!isNull _bg) then {
            _bg ctrlSetBackgroundColor [0.50, 0.45, 0.35, 0.95];
        };
    }];
    
    _btn ctrlAddEventHandler ["MouseExit", {
        params ["_ctrl"];
        private _bg = _ctrl getVariable ["buttonBG", controlNull];
        if (!isNull _bg) then {
            _bg ctrlSetBackgroundColor [0.40, 0.35, 0.25, 0.85];
        };
    }];
    
} forEach _leftButtons;

// Create right buttons
{
    _x params ["_idcBG", "_idcBtn", "_text", "_title", "_description"];
    private _index = _forEachIndex;
    private _yPos = _startY + (_index * _spacing);
    private _xPos = safezoneX + safezoneW - _buttonW - _padding;
    
    // Create background
    private _bg = _zeusDisplay ctrlCreate ["RscText", _idcBG];
    _bg ctrlSetPosition [_xPos, _yPos, _buttonW, _buttonH];
    _bg ctrlSetBackgroundColor [0.40, 0.35, 0.25, 0.85];
    _bg ctrlCommit 0;
    _bg ctrlShow true;
    
    // Create clickable button
    private _btn = _zeusDisplay ctrlCreate ["RscButton", _idcBtn];
    _btn ctrlSetPosition [_xPos, _yPos, _buttonW, _buttonH];
    _btn ctrlSetText _text;
    _btn ctrlSetTextColor [0.85, 0.82, 0.74, 1.0];
    _btn ctrlSetFont "PuristaBold";
    _btn ctrlCommit 0;
    _btn ctrlShow true;
    
    // Store data
    _btn setVariable ["buttonTitle", _title];
    _btn setVariable ["buttonDesc", _description];
    _btn setVariable ["buttonBG", _bg];
    
    // ButtonClick handler
    _btn ctrlAddEventHandler ["ButtonClick", {
        params ["_ctrl"];
        private _title = _ctrl getVariable ["buttonTitle", "Unknown"];
        private _desc = _ctrl getVariable ["buttonDesc", "No description"];
        
        // Right-side button handlers
        private _idcBtn = ctrlIDC _ctrl;
        switch (_idcBtn) do {
            case 9201: { // INTELLIGENCE button
                [] call OpsRoom_fnc_openOpsMap;
            };
            case 9203: { // DISPATCHES button
                [] call OpsRoom_fnc_openDispatchLog;
            };
            case 9205: { // OPS ROOM button
                [] call OpsRoom_fnc_openOperations;
            };
            case 9207: { // STORES button
                [] call OpsRoom_fnc_openStorehouseGrid;
            };
            case 9209: { // AIR OPS button
                [] call OpsRoom_fnc_openAirOps;
            };
            default {
                hint format ["=== %1 ===\n\n%2\n\n(Not yet implemented)", _title, _desc];
                systemChat format [">>> Clicked: %1", _title];
            };
        };
    }];
    
    // Hover effects
    _btn ctrlAddEventHandler ["MouseEnter", {
        params ["_ctrl"];
        private _bg = _ctrl getVariable ["buttonBG", controlNull];
        if (!isNull _bg) then {
            _bg ctrlSetBackgroundColor [0.50, 0.45, 0.35, 0.95];
        };
    }];
    
    _btn ctrlAddEventHandler ["MouseExit", {
        params ["_ctrl"];
        private _bg = _ctrl getVariable ["buttonBG", controlNull];
        if (!isNull _bg) then {
            _bg ctrlSetBackgroundColor [0.40, 0.35, 0.25, 0.85];
        };
    }];
    
} forEach _rightButtons;

systemChat format ["✓ Created %1 clickable buttons on Zeus display", (count _leftButtons) + (count _rightButtons)];
