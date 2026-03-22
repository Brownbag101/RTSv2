/*
    Open Research Tree
    
    Shows items in a subcategory as a tiered research tree.
    Left: listbox of items (with tier/status indicators)
    Right: selected item details + research button
    
    Parameters:
        0: STRING - Category name
        1: STRING - Subcategory name
    
    Usage:
        ["Weapons", "Rifles"] call OpsRoom_fnc_openResearchTree;
*/

params [
    ["_category", "", [""]],
    ["_subcategory", "", [""]]
];

if (_category == "" || _subcategory == "") exitWith { hint "Invalid category/subcategory" };

// Store for navigation
uiNamespace setVariable ["OpsRoom_ResearchCategory", _category];
uiNamespace setVariable ["OpsRoom_ResearchSubcategory", _subcategory];

createDialog "OpsRoom_ResearchTreeDialog";
waitUntil {!isNull findDisplay 11002};

private _display = findDisplay 11002;

// Set title
private _titleCtrl = _display displayCtrl 11030;
_titleCtrl ctrlSetText format ["RESEARCH > %1 > %2", toUpper _category, toUpper _subcategory];

// Show research points
private _rpCtrl = _display displayCtrl 11031;
private _rp = missionNamespace getVariable ["OpsRoom_Resource_Research_Points", 0];
_rpCtrl ctrlSetText format ["Research Points: %1", _rp];

// Back button → subcategories
private _backBtn = _display displayCtrl 11032;
_backBtn ctrlAddEventHandler ["ButtonClick", {
    [] spawn {
        private _cat = uiNamespace getVariable ["OpsRoom_ResearchCategory", ""];
        closeDialog 0;
        sleep 0.1;
        [_cat] call OpsRoom_fnc_openResearchSubcategories;
    };
}];

// Populate the tree
[_category, _subcategory] call OpsRoom_fnc_populateResearchTree;

// Listbox selection handler
private _listbox = _display displayCtrl 11040;
_listbox ctrlAddEventHandler ["LBSelChanged", {
    params ["_control", "_selectedIndex"];
    [_selectedIndex] call OpsRoom_fnc_showResearchDetails;
}];

// Research button handler
private _researchBtn = _display displayCtrl 11060;
_researchBtn ctrlAddEventHandler ["ButtonClick", {
    [] call OpsRoom_fnc_startResearch;
}];

// Select first item
_listbox lbSetCurSel 0;

diag_log format ["[OpsRoom] Research tree opened: %1 > %2", _category, _subcategory];
