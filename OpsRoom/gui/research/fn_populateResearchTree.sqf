/*
    Populate Research Tree
    
    Fills the listbox with items from a subcategory, sorted by tier.
    Shows status: [✓] researched, [→] available, [✗] locked, [⏳] in progress
    
    Parameters:
        0: STRING - Category
        1: STRING - Subcategory
    
    Usage:
        ["Weapons", "Rifles"] call OpsRoom_fnc_populateResearchTree;
*/

params [
    ["_category", "", [""]],
    ["_subcategory", "", [""]]
];

private _display = findDisplay 11002;
if (isNull _display) exitWith {};

private _listbox = _display displayCtrl 11040;
lbClear _listbox;

// Get items sorted by tier
private _items = [_category, _subcategory] call OpsRoom_fnc_getItemsBySubcategory;

// Sort by research tier
_items sort true;  // Sorts by first element naturally, but we need tier
// Custom sort: extract tier and sort
private _sorted = [];
{
    _x params ["_itemId", "_itemData"];
    _sorted pushBack [_itemData get "researchTier", _itemId, _itemData];
} forEach _items;
_sorted sort true;  // Sorts by tier (first element)

// Store item IDs for listbox reference
private _itemIds = [];

{
    _x params ["_tier", "_itemId", "_itemData"];
    
    private _name = _itemData get "displayName";
    private _isResearched = [_itemId] call OpsRoom_fnc_isResearched;
    private _prereqsMet = [_itemId] call OpsRoom_fnc_prereqsMet;
    
    // Check if currently being researched
    private _activeResearch = missionNamespace getVariable ["OpsRoom_ResearchInProgress", []];
    private _isInProgress = false;
    if (count _activeResearch > 0) then {
        if ((_activeResearch select 0) == _itemId) then {
            _isInProgress = true;
        };
    };
    
    // Status prefix
    private _prefix = "";
    private _color = [1, 1, 1, 1];
    
    if (_isResearched) then {
        _prefix = "[✓] ";
        _color = [0.5, 1.0, 0.5, 1.0];  // Green
    } else {
        if (_isInProgress) then {
            _prefix = "[⏳] ";
            _color = [1.0, 0.85, 0.4, 1.0];  // Yellow
        } else {
            if (_prereqsMet) then {
                _prefix = "[→] ";
                _color = [0.85, 0.82, 0.74, 1.0];  // Normal
            } else {
                _prefix = "[✗] ";
                _color = [0.5, 0.5, 0.5, 0.7];  // Grey/locked
            };
        };
    };
    
    // Tier prefix for indentation
    private _tierStr = "";
    for "_t" from 1 to (_tier - 1) do {
        _tierStr = _tierStr + "  ";
    };
    
    private _idx = _listbox lbAdd format ["%1T%2 %3%4", _tierStr, _tier, _prefix, _name];
    _listbox lbSetColor [_idx, _color];
    
    _itemIds pushBack _itemId;
    
} forEach _sorted;

// Store item IDs list for selection lookup
uiNamespace setVariable ["OpsRoom_ResearchTreeItems", _itemIds];

diag_log format ["[OpsRoom] Research tree populated with %1 items", count _sorted];
