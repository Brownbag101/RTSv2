/*
    Open Research Subcategories
    
    Shows subcategories within a selected category.
    E.g. Weapons → Rifles, Machine Guns, etc.
    
    Parameters:
        0: STRING - Category name ("Weapons", "Ammunition", etc.)
    
    Usage:
        ["Weapons"] call OpsRoom_fnc_openResearchSubcategories;
*/

params [["_category", "", [""]]];

if (_category == "") exitWith { hint "No category provided" };

// Store for navigation
uiNamespace setVariable ["OpsRoom_ResearchCategory", _category];

createDialog "OpsRoom_ResearchSubcategoriesDialog";
waitUntil {!isNull findDisplay 11001};

private _display = findDisplay 11001;

// Set title
private _titleCtrl = _display displayCtrl 11020;
_titleCtrl ctrlSetText format ["RESEARCH > %1", toUpper _category];

// Show research points
private _rpCtrl = _display displayCtrl 11021;
private _rp = missionNamespace getVariable ["OpsRoom_Resource_Research_Points", 0];
_rpCtrl ctrlSetText format ["Research Points: %1", _rp];

// Back button
private _backBtn = _display displayCtrl 11022;
_backBtn ctrlAddEventHandler ["ButtonClick", {
    [] spawn {
        closeDialog 0;
        sleep 0.1;
        [] call OpsRoom_fnc_openResearchCategories;
    };
}];

// Get subcategories for this category
private _subcategories = [_category] call OpsRoom_fnc_getSubcategories;

// Delete dynamic controls
for "_idc" from 12130 to 15171 do {
    private _ctrl = _display displayCtrl _idc;
    if (!isNull _ctrl) then { ctrlDelete _ctrl };
};

// Populate grid
private _squareIndex = 0;
private _maxSquares = 12;

{
    if (_squareIndex >= _maxSquares) exitWith {};
    
    private _subName = _x;
    private _idc = 11130 + _squareIndex;
    private _ctrl = _display displayCtrl _idc;
    
    if (!isNull _ctrl) then {
        _ctrl ctrlShow true;
        
        // Count items in subcategory
        private _items = [_category, _subName] call OpsRoom_fnc_getItemsBySubcategory;
        private _totalItems = count _items;
        private _researchedCount = 0;
        {
            _x params ["_itemId", "_itemData"];
            if ([_itemId] call OpsRoom_fnc_isResearched) then {
                _researchedCount = _researchedCount + 1;
            };
        } forEach _items;
        
        // Subcategory name
        private _nameCtrl = _display ctrlCreate ["RscStructuredText", _idc + 1000];
        _nameCtrl ctrlSetPosition [
            (ctrlPosition _ctrl) select 0,
            ((ctrlPosition _ctrl) select 1) + ((ctrlPosition _ctrl) select 3) * 0.30,
            (ctrlPosition _ctrl) select 2,
            ((ctrlPosition _ctrl) select 3) * 0.3
        ];
        _nameCtrl ctrlSetStructuredText parseText format [
            "<t align='center' size='1.1' font='PuristaBold'>%1</t>",
            _subName
        ];
        _nameCtrl ctrlCommit 0;
        
        // Item count
        private _countCtrl = _display ctrlCreate ["RscStructuredText", _idc + 2000];
        _countCtrl ctrlSetPosition [
            (ctrlPosition _ctrl) select 0,
            ((ctrlPosition _ctrl) select 1) + ((ctrlPosition _ctrl) select 3) * 0.65,
            (ctrlPosition _ctrl) select 2,
            ((ctrlPosition _ctrl) select 3) * 0.2
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
        _btnCtrl ctrlSetTooltip format ["View %1 research tree", _subName];
        _btnCtrl ctrlCommit 0;
        
        _btnCtrl setVariable ["subcategoryName", _subName];
        _btnCtrl setVariable ["categoryName", _category];
        
        _btnCtrl ctrlAddEventHandler ["ButtonClick", {
            params ["_ctrl"];
            private _cat = _ctrl getVariable ["categoryName", ""];
            private _sub = _ctrl getVariable ["subcategoryName", ""];
            [_cat, _sub] spawn {
                params ["_cat", "_sub"];
                closeDialog 0;
                sleep 0.1;
                [_cat, _sub] call OpsRoom_fnc_openResearchTree;
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
} forEach _subcategories;

// Hide unused squares
for "_i" from _squareIndex to (_maxSquares - 1) do {
    private _ctrl = _display displayCtrl (11130 + _i);
    if (!isNull _ctrl) then { _ctrl ctrlShow false };
};

diag_log format ["[OpsRoom] Research subcategories opened for: %1", _category];
