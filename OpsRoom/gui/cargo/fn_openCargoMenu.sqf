/*
    Cargo System - Open Cargo Menu
    
    Scans for loadable items near the selected vehicle and creates
    an expanding button menu (same pattern as grenade menu).
    
    Each button represents one loadable item. Hovering shows a
    Draw3D highlight over the item in the world.
    
    Called when the CARGO ability button is clicked.
    
    Usage:
        [] call OpsRoom_fnc_openCargoMenu;
*/

// Get selected vehicle
private _selected = curatorSelected select 0;
if (count _selected != 1) exitWith { hint "Select a single vehicle" };

private _vehicle = _selected select 0;

// Verify it's a cargo carrier
private _cap = [_vehicle] call OpsRoom_fnc_getCargoCapacity;
_cap params ["_usedSlots", "_maxSlots", "_isCarrier"];

if (!_isCarrier) exitWith { hint "This vehicle cannot carry cargo" };
if (_usedSlots >= _maxSlots) exitWith { hint format ["Cargo full (%1/%2)", _usedSlots, _maxSlots] };

private _remainingSlots = _maxSlots - _usedSlots;
private _radius = missionNamespace getVariable ["OpsRoom_Settings_CargoScanRadius", 25];

// ============================================================
// SCAN FOR LOADABLE ITEMS
// ============================================================

private _loadableItems = [];

// 1. Scan for physical objects (crates, barrels, weapon holders)
private _nearObjects = nearestObjects [_vehicle, OpsRoom_CargoLoadableTypes, _radius];

{
    private _obj = _x;
    
    // Skip if already loaded somewhere
    if (!isNull (_obj getVariable ["OpsRoom_LoadedIn", objNull])) then { continue };
    
    // Skip if it IS the vehicle
    if (_obj == _vehicle) then { continue };
    
    // Skip dead/destroyed
    if (!alive _obj) then { continue };
    
    // Get display name
    private _className = typeOf _obj;
    private _displayName = getText (configFile >> "CfgVehicles" >> _className >> "displayName");
    if (_displayName == "") then { _displayName = _className };
    
    // Determine weight (check equipment DB, default 1)
    private _weight = OpsRoom_CargoWeights getOrDefault [_className, 
        missionNamespace getVariable ["OpsRoom_Settings_CargoDefaultWeight", 1]
    ];
    
    // Skip if too heavy for remaining space
    if (_weight > _remainingSlots) then { continue };
    
    _loadableItems pushBack [_obj, _className, _displayName, _weight, false];
    
} forEach _nearObjects;

// 2. Scan for friendly infantry (men) near the vehicle
private _nearMen = nearestObjects [_vehicle, ["Man"], _radius];

{
    private _man = _x;
    
    // Skip if already loaded
    if (!isNull (_man getVariable ["OpsRoom_LoadedIn", objNull])) then { continue };
    
    // Skip if dead
    if (!alive _man) then { continue };
    
    // Skip enemies (only load friendlies)
    if (side _man != side player) then { continue };
    
    // Skip if in a vehicle already
    if (vehicle _man != _man) then { continue };
    
    // Get soldier name and rank
    private _soldierName = name _man;
    private _rankText = switch (rank _man) do {
        case "PRIVATE": {"Pte."};
        case "CORPORAL": {"Cpl."};
        case "SERGEANT": {"Sgt."};
        case "LIEUTENANT": {"Lt."};
        case "CAPTAIN": {"Capt."};
        case "MAJOR": {"Maj."};
        default {rank _man};
    };
    private _displayName = format ["%1 %2", _rankText, _soldierName];
    
    // Men always weigh 1 slot
    if (1 > _remainingSlots) then { continue };
    
    _loadableItems pushBack [_man, typeOf _man, _displayName, 1, true];
    
} forEach _nearMen;

// ============================================================
// NO ITEMS FOUND
// ============================================================

if (count _loadableItems == 0) exitWith {
    hint format ["No loadable items within %1m", _radius];
};

// ============================================================
// BUILD MENU ITEMS
// ============================================================

private _menuItems = [];

{
    _x params ["_obj", "_className", "_displayName", "_weight", "_isUnit"];
    private _index = _forEachIndex;
    
    // Choose icon based on type
    private _icon = if (_isUnit) then {
        "a3\ui_f\data\igui\cfg\simpleTasks\types\meet_ca.paa"
    } else {
        "a3\ui_f\data\igui\cfg\simpleTasks\types\use_ca.paa"
    };
    
    // Tooltip with weight info
    private _tooltip = format ["%1 (%2 slot%3)", _displayName, _weight, if (_weight > 1) then {"s"} else {""}];
    
    // Build action closure — captures the specific item
    private _action = compile format [
        "[curatorSelected select 0 select 0, OpsRoom_CargoMenuItems select %1] call OpsRoom_fnc_loadCargo;",
        _index
    ];
    
    _menuItems pushBack [_tooltip, _icon, _action];
    
} forEach _loadableItems;

// Store items globally so the menu actions can reference them
OpsRoom_CargoMenuItems = _loadableItems;

// Add "LOAD ALL" as the final menu item (appears at top since menu expands upward)
if (count _loadableItems > 1) then {
    private _loadAllAction = compile format [
        "[curatorSelected select 0 select 0] call OpsRoom_fnc_loadAllCargo;"
    ];
    _menuItems pushBack ["LOAD ALL", "a3\ui_f\data\igui\cfg\simpleTasks\types\use_ca.paa", _loadAllAction];
};

// ============================================================
// CREATE EXPANDING MENU
// ============================================================

private _display = findDisplay 312;
if (isNull _display) exitWith {};

// Find the cargo ability button
private _cargoButton = controlNull;
for "_i" from 9350 to 9389 step 2 do {
    private _btn = _display displayCtrl (_i + 1);
    if (!isNull _btn) then {
        private _abilityID = _btn getVariable ["abilityID", ""];
        if (_abilityID == "cargo") exitWith {
            _cargoButton = _btn;
        };
    };
};

if (isNull _cargoButton) exitWith {
    hint "Could not find cargo button";
    diag_log "[OpsRoom:Cargo] ERROR: Could not find cargo ability button for menu";
};

// Get button position
private _btnPos = ctrlPosition _cargoButton;
_btnPos params ["_baseX", "_baseY", "_btnW", "_btnH"];

// Close any existing menu, then create new one
[] call OpsRoom_fnc_closeButtonMenu;

// ============================================================
// CREATE MENU WITH HOVER PREVIEW
// ============================================================

// Calculate menu dimensions
private _padding = 0.003 * safezoneW;
private _menuHeight = (count _menuItems) * (_btnW + _padding);
private _menuStartY = _baseY - _menuHeight - _padding;

OpsRoom_ActiveMenuControls = [];

{
    _x params ["_text", "_icon", "_action"];
    private _itemIndex = _forEachIndex;
    
    // Position (bottom to top)
    private _yPos = _baseY - ((_itemIndex + 1) * (_btnW + _padding));
    
    // IDC range 9400-9449
    private _bgIDC = 9400 + (_itemIndex * 2);
    private _btnIDC = 9401 + (_itemIndex * 2);
    
    // Background
    private _bg = _display ctrlCreate ["RscText", _bgIDC];
    _bg ctrlSetPosition [_baseX, _yPos, _btnW, _btnW];
    _bg ctrlSetBackgroundColor [0.20, 0.18, 0.15, 0.95];
    _bg ctrlCommit 0;
    
    // Button
    private _btn = _display ctrlCreate ["RscActivePicture", _btnIDC];
    _btn ctrlSetPosition [_baseX, _yPos, _btnW, _btnW];
    _btn ctrlSetText _icon;
    _btn ctrlSetTooltip _text;
    _btn ctrlSetTextColor [0.85, 0.82, 0.74, 1.0];
    _btn ctrlCommit 0;
    
    // Store references
    _btn setVariable ["buttonBG", _bg];
    _btn setVariable ["menuAction", _action];
    _btn setVariable ["cargoItemIndex", _itemIndex];
    
    // Click handler — load the item and close menu
    _btn ctrlAddEventHandler ["ButtonClick", {
        params ["_ctrl"];
        private _action = _ctrl getVariable ["menuAction", {}];
        OpsRoom_CargoHoverTargets = [];  // Clear hover highlights
        [] call _action;
        [] call OpsRoom_fnc_closeButtonMenu;
    }];
    
    // Hover Enter — highlight the world object with Draw3D
    _btn ctrlAddEventHandler ["MouseEnter", {
        params ["_ctrl"];
        private _bg = _ctrl getVariable ["buttonBG", controlNull];
        if (!isNull _bg) then {
            _bg ctrlSetBackgroundColor [0.40, 0.35, 0.25, 0.95];
        };
        
        // Set hover target(s) for Draw3D highlight
        private _idx = _ctrl getVariable ["cargoItemIndex", -1];
        private _isLoadAll = _ctrl getVariable ["cargoIsLoadAll", false];
        
        if (_isLoadAll) then {
            // LOAD ALL: highlight every loadable item
            OpsRoom_CargoHoverTargets = OpsRoom_CargoMenuItems apply {_x select 0};
        } else {
            if (_idx >= 0 && _idx < count OpsRoom_CargoMenuItems) then {
                private _itemData = OpsRoom_CargoMenuItems select _idx;
                OpsRoom_CargoHoverTargets = [_itemData select 0];
            };
        };
    }];
    
    // Hover Exit — clear highlight
    _btn ctrlAddEventHandler ["MouseExit", {
        params ["_ctrl"];
        private _bg = _ctrl getVariable ["buttonBG", controlNull];
        if (!isNull _bg) then {
            _bg ctrlSetBackgroundColor [0.20, 0.18, 0.15, 0.95];
        };
        OpsRoom_CargoHoverTargets = [];
    }];
    
    OpsRoom_ActiveMenuControls pushBack _bg;
    OpsRoom_ActiveMenuControls pushBack _btn;
    
} forEach _menuItems;

// Tag the LOAD ALL button (last item) so hover handler knows to highlight everything
if (count _loadableItems > 1) then {
    private _loadAllIdx = (count _menuItems) - 1;
    private _loadAllBtnIDC = 9401 + (_loadAllIdx * 2);
    private _loadAllBtn = _display displayCtrl _loadAllBtnIDC;
    if (!isNull _loadAllBtn) then {
        _loadAllBtn setVariable ["cargoIsLoadAll", true];
    };
};

private _vehName = getText (configFile >> "CfgVehicles" >> typeOf _vehicle >> "displayName");
diag_log format ["[OpsRoom:Cargo] Menu opened for %1 — %2 loadable items, %3/%4 slots used",
    _vehName, count _loadableItems, _usedSlots, _maxSlots];
