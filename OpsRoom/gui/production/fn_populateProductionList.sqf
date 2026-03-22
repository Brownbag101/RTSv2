/*
    Populate Production List
    
    Fills the listbox with all RESEARCHED items, grouped by category.
    Only items that have been researched appear here.
    
    Usage:
        [] call OpsRoom_fnc_populateProductionList;
*/

private _display = findDisplay 11004;
if (isNull _display) exitWith {};

private _listbox = _display displayCtrl 11310;
lbClear _listbox;

private _researchedItems = missionNamespace getVariable ["OpsRoom_ResearchCompleted", []];

if (count _researchedItems == 0) exitWith {
    private _idx = _listbox lbAdd "No items researched";
    _listbox lbSetColor [_idx, [0.5, 0.5, 0.5, 0.7]];
    uiNamespace setVariable ["OpsRoom_ProductionListItems", []];
};

// Group researched items by category
private _categories = [] call OpsRoom_fnc_getCategories;
private _itemIds = [];

{
    private _category = _x;
    private _categoryItems = [];
    
    // Find all researched items in this category
    {
        private _itemId = _x;
        private _itemData = OpsRoom_EquipmentDB get _itemId;
        if (!isNil "_itemData") then {
            if ((_itemData get "category") == _category) then {
                _categoryItems pushBack [_itemId, _itemData];
            };
        };
    } forEach _researchedItems;
    
    // If any items in this category, add header + items
    if (count _categoryItems > 0) then {
        // Category header
        private _idx = _listbox lbAdd format ["── %1 ──", toUpper _category];
        _listbox lbSetColor [_idx, [0.95, 0.85, 0.40, 1.0]];
        _itemIds pushBack "";  // Empty = header, not selectable
        
        // Items
        {
            _x params ["_itemId", "_itemData"];
            private _name = _itemData get "displayName";
            private _sub = _itemData get "subcategory";
            
            private _idx = _listbox lbAdd format ["  %1", _name];
            _listbox lbSetColor [_idx, [0.85, 0.82, 0.74, 1.0]];
            _itemIds pushBack _itemId;
        } forEach _categoryItems;
    };
} forEach _categories;

// Store for selection lookup
uiNamespace setVariable ["OpsRoom_ProductionListItems", _itemIds];

diag_log format ["[OpsRoom] Production list populated: %1 researched items", count _researchedItems];
