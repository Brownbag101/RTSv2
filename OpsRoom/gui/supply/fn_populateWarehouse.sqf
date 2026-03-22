/*
    Populate Warehouse List
    
    Fills the listbox with warehouse contents, grouped by category.
    Only items with stock > 0 are shown.
    
    Usage:
        [] call OpsRoom_fnc_populateWarehouse;
*/

private _display = findDisplay 11005;
if (isNull _display) exitWith {};

private _listbox = _display displayCtrl 11410;
lbClear _listbox;

private _itemIds = [];

// Check if warehouse has anything
private _totalItems = 0;
{ _totalItems = _totalItems + _y } forEach OpsRoom_Warehouse;

if (_totalItems == 0) exitWith {
    private _idx = _listbox lbAdd "Warehouse empty";
    _listbox lbSetColor [_idx, [0.5, 0.5, 0.5, 0.7]];
    _idx = _listbox lbAdd "Produce items first";
    _listbox lbSetColor [_idx, [0.5, 0.5, 0.5, 0.5]];
    uiNamespace setVariable ["OpsRoom_SupplyListItems", []];
};

// Group by category
private _categories = [] call OpsRoom_fnc_getCategories;

{
    private _category = _x;
    private _categoryItems = [];
    
    // Find warehouse items in this category
    {
        private _itemId = _x;
        private _stock = _y;
        if (_stock > 0) then {
            private _itemData = OpsRoom_EquipmentDB get _itemId;
            if (!isNil "_itemData") then {
                if ((_itemData get "category") == _category) then {
                    _categoryItems pushBack [_itemId, _stock, _itemData];
                };
            };
        };
    } forEach OpsRoom_Warehouse;
    
    if (count _categoryItems > 0) then {
        // Category header
        private _idx = _listbox lbAdd format ["── %1 ──", toUpper _category];
        _listbox lbSetColor [_idx, [0.95, 0.85, 0.40, 1.0]];
        _itemIds pushBack "";
        
        // Items with stock count
        {
            _x params ["_itemId", "_stock", "_itemData"];
            private _name = _itemData get "displayName";
            
            private _idx = _listbox lbAdd format ["  %1 (x%2)", _name, _stock];
            _listbox lbSetColor [_idx, [0.85, 0.82, 0.74, 1.0]];
            _itemIds pushBack _itemId;
        } forEach _categoryItems;
    };
} forEach _categories;

uiNamespace setVariable ["OpsRoom_SupplyListItems", _itemIds];

diag_log format ["[OpsRoom] Warehouse list populated: %1 total items", _totalItems];
