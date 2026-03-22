/*
    Open Research Categories
    
    Opens the top-level research menu showing equipment categories.
    Dynamically reads categories from the equipment database.
    
    Usage:
        [] call OpsRoom_fnc_openResearchCategories;
*/

createDialog "OpsRoom_ResearchCategoriesDialog";
waitUntil {!isNull findDisplay 11000};

private _display = findDisplay 11000;

// Show research points
private _rpCtrl = _display displayCtrl 11010;
private _rp = missionNamespace getVariable ["OpsRoom_Resource_Research_Points", 0];
_rpCtrl ctrlSetText format ["Research Points: %1", _rp];

// Show active research status
private _statusCtrl = _display displayCtrl 11012;
private _activeResearch = missionNamespace getVariable ["OpsRoom_ResearchInProgress", []];
if (count _activeResearch > 0) then {
    _activeResearch params ["_itemId", "_startTime", "_duration"];
    private _itemData = OpsRoom_EquipmentDB get _itemId;
    private _itemName = if (!isNil "_itemData") then { _itemData get "displayName" } else { _itemId };
    private _elapsed = time - _startTime;
    private _remaining = (_duration * 60) - _elapsed;
    private _minsLeft = ceil (_remaining / 60);
    if (_remaining <= 0) then {
        _statusCtrl ctrlSetStructuredText parseText format [
            "<t color='#80FF80'>RESEARCH COMPLETE: %1 — Ready to collect!</t>", _itemName
        ];
    } else {
        _statusCtrl ctrlSetStructuredText parseText format [
            "<t color='#FFD966'>RESEARCHING: %1 — %2 min remaining</t>", _itemName, _minsLeft
        ];
    };
} else {
    _statusCtrl ctrlSetStructuredText parseText "<t color='#AAAAAA'>No active research</t>";
};

// Get categories from database
private _categories = [] call OpsRoom_fnc_getCategories;

// Category icons (map category name to a description for the square)
private _categoryInfo = createHashMapFromArray [
    ["Weapons", "Rifles, pistols, machine guns and more"],
    ["Ammunition", "Bullets, shells and magazines"],
    ["Explosives", "Grenades, mines and demolitions"],
    ["Uniforms", "Clothing, armour and helmets"],
    ["Vehicles", "Cars, trucks, tanks, boats and planes"]
];

// Delete dynamic controls
for "_idc" from 12100 to 15141 do {
    private _ctrl = _display displayCtrl _idc;
    if (!isNull _ctrl) then { ctrlDelete _ctrl };
};

// Populate grid squares
private _squareIndex = 0;
private _maxSquares = 12;

{
    if (_squareIndex >= _maxSquares) exitWith {};
    
    private _categoryName = _x;
    private _idc = 11100 + _squareIndex;
    private _ctrl = _display displayCtrl _idc;
    
    if (!isNull _ctrl) then {
        _ctrl ctrlShow true;
        
        // Count items in category
        private _items = [_categoryName] call OpsRoom_fnc_getItemsByCategory;
        private _totalItems = count _items;
        private _researchedCount = 0;
        {
            _x params ["_itemId", "_itemData"];
            if ([_itemId] call OpsRoom_fnc_isResearched) then {
                _researchedCount = _researchedCount + 1;
            };
        } forEach _items;
        
        // Category name text (center of square)
        private _nameCtrl = _display ctrlCreate ["RscStructuredText", _idc + 1000];
        _nameCtrl ctrlSetPosition [
            (ctrlPosition _ctrl) select 0,
            ((ctrlPosition _ctrl) select 1) + ((ctrlPosition _ctrl) select 3) * 0.25,
            (ctrlPosition _ctrl) select 2,
            ((ctrlPosition _ctrl) select 3) * 0.3
        ];
        _nameCtrl ctrlSetStructuredText parseText format [
            "<t align='center' size='1.2' font='PuristaBold'>%1</t>",
            toUpper _categoryName
        ];
        _nameCtrl ctrlCommit 0;
        
        // Description text
        private _desc = _categoryInfo getOrDefault [_categoryName, ""];
        private _descCtrl = _display ctrlCreate ["RscStructuredText", _idc + 2000];
        _descCtrl ctrlSetPosition [
            (ctrlPosition _ctrl) select 0,
            ((ctrlPosition _ctrl) select 1) + ((ctrlPosition _ctrl) select 3) * 0.55,
            (ctrlPosition _ctrl) select 2,
            ((ctrlPosition _ctrl) select 3) * 0.2
        ];
        _descCtrl ctrlSetStructuredText parseText format [
            "<t align='center' size='0.7' color='#AAAAAA'>%1</t>", _desc
        ];
        _descCtrl ctrlCommit 0;
        
        // Progress count
        private _countCtrl = _display ctrlCreate ["RscStructuredText", _idc + 3000];
        _countCtrl ctrlSetPosition [
            (ctrlPosition _ctrl) select 0,
            ((ctrlPosition _ctrl) select 1) + ((ctrlPosition _ctrl) select 3) * 0.82,
            (ctrlPosition _ctrl) select 2,
            ((ctrlPosition _ctrl) select 3) * 0.18
        ];
        private _countColor = if (_researchedCount == _totalItems && _totalItems > 0) then { "#80FF80" } else { "#AAAAAA" };
        _countCtrl ctrlSetStructuredText parseText format [
            "<t align='center' size='0.7' color='%1'>%2 / %3 researched</t>",
            _countColor, _researchedCount, _totalItems
        ];
        _countCtrl ctrlCommit 0;
        
        // Button overlay
        private _btnCtrl = _display ctrlCreate ["RscButton", _idc + 4000];
        _btnCtrl ctrlSetPosition [
            (ctrlPosition _ctrl) select 0,
            (ctrlPosition _ctrl) select 1,
            (ctrlPosition _ctrl) select 2,
            (ctrlPosition _ctrl) select 3
        ];
        _btnCtrl ctrlSetText "";
        _btnCtrl ctrlSetTooltip format ["Open %1 research", _categoryName];
        _btnCtrl ctrlCommit 0;
        
        _btnCtrl setVariable ["categoryName", _categoryName];
        
        _btnCtrl ctrlAddEventHandler ["ButtonClick", {
            params ["_ctrl"];
            private _cat = _ctrl getVariable ["categoryName", ""];
            [_cat] spawn {
                params ["_cat"];
                closeDialog 0;
                sleep 0.1;
                [_cat] call OpsRoom_fnc_openResearchSubcategories;
            };
        }];
        
        // Hover effects
        _btnCtrl ctrlAddEventHandler ["MouseEnter", {
            params ["_ctrl"];
            private _bgCtrl = (ctrlParent _ctrl) displayCtrl ((ctrlIDC _ctrl) - 4000);
            _bgCtrl ctrlSetBackgroundColor [0.3, 0.35, 0.25, 1];
        }];
        _btnCtrl ctrlAddEventHandler ["MouseExit", {
            params ["_ctrl"];
            private _bgCtrl = (ctrlParent _ctrl) displayCtrl ((ctrlIDC _ctrl) - 4000);
            _bgCtrl ctrlSetBackgroundColor [0.26, 0.3, 0.21, 1];
        }];
    };
    
    _squareIndex = _squareIndex + 1;
} forEach _categories;

// Hide unused squares
for "_i" from _squareIndex to (_maxSquares - 1) do {
    private _ctrl = _display displayCtrl (11100 + _i);
    if (!isNull _ctrl) then { _ctrl ctrlShow false };
};

diag_log "[OpsRoom] Research categories dialog opened";
