/*
    Start Research
    
    Begins researching the currently selected item.
    Deducts research points, sets timer.
    
    Usage:
        [] call OpsRoom_fnc_startResearch;
*/

private _itemId = uiNamespace getVariable ["OpsRoom_ResearchSelectedItem", ""];
if (_itemId == "") exitWith { hint "No item selected" };

private _itemData = OpsRoom_EquipmentDB get _itemId;
if (isNil "_itemData") exitWith { hint "Invalid item" };

// Validation
if ([_itemId] call OpsRoom_fnc_isResearched) exitWith { hint "Already researched" };
if !([_itemId] call OpsRoom_fnc_prereqsMet) exitWith { hint "Prerequisites not met" };

private _activeResearch = missionNamespace getVariable ["OpsRoom_ResearchInProgress", []];
if (count _activeResearch > 0) exitWith { hint "Another research is already in progress" };

private _cost = _itemData get "researchCost";
private _time = _itemData get "researchTime";
private _name = _itemData get "displayName";
private _rp = missionNamespace getVariable ["OpsRoom_Resource_Research_Points", 0];

if (_rp < _cost) exitWith { hint format ["Not enough Research Points. Need %1, have %2", _cost, _rp] };

// Deduct research points
missionNamespace setVariable ["OpsRoom_Resource_Research_Points", _rp - _cost];
OpsRoom_Resource_Research_Points = _rp - _cost;
[] call OpsRoom_fnc_updateResources;

// Start research timer
missionNamespace setVariable ["OpsRoom_ResearchInProgress", [_itemId, time, _time]];

["ROUTINE", "RESEARCH STARTED", format ["%1 — Estimated time: %2 minutes", _name, _time]] call OpsRoom_fnc_dispatch;

// Refresh the tree display
private _cat = uiNamespace getVariable ["OpsRoom_ResearchCategory", ""];
private _sub = uiNamespace getVariable ["OpsRoom_ResearchSubcategory", ""];
if (_cat != "" && _sub != "") then {
    [_cat, _sub] call OpsRoom_fnc_populateResearchTree;
    
    // Re-select the item
    private _itemIds = uiNamespace getVariable ["OpsRoom_ResearchTreeItems", []];
    private _newIndex = _itemIds find _itemId;
    if (_newIndex >= 0) then {
        private _display = findDisplay 11002;
        if (!isNull _display) then {
            private _listbox = _display displayCtrl 11040;
            _listbox lbSetCurSel _newIndex;
        };
    };
};

diag_log format ["[OpsRoom] Research started: %1 (cost: %2 RP, time: %3 min)", _itemId, _cost, _time];
