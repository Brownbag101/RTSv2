/*
    Show Research Details
    
    Displays item details in the right panel when selected from the tree.
    Shows: name, description, cost, time, prerequisites, status
    
    Parameters:
        0: NUMBER - Selected listbox index
    
    Usage:
        [0] call OpsRoom_fnc_showResearchDetails;
*/

params [["_index", -1, [0]]];

private _display = findDisplay 11002;
if (isNull _display) exitWith {};

if (_index < 0) exitWith {};

// Get item ID from stored list
private _itemIds = uiNamespace getVariable ["OpsRoom_ResearchTreeItems", []];
if (_index >= count _itemIds) exitWith {};

private _itemId = _itemIds select _index;
private _itemData = OpsRoom_EquipmentDB get _itemId;
if (isNil "_itemData") exitWith {};

// Store selected item for research button
uiNamespace setVariable ["OpsRoom_ResearchSelectedItem", _itemId];

private _name = _itemData get "displayName";
private _desc = _itemData get "researchDesc";
private _cost = _itemData get "researchCost";
private _time = _itemData get "researchTime";
private _tier = _itemData get "researchTier";
private _prereqs = _itemData get "researchPrereqs";

// Build details text
private _text = "";

// Name header
_text = _text + format ["<t size='1.3' font='PuristaBold'>%1</t><br/>", _name];
_text = _text + format ["<t size='0.8' color='#AAAAAA'>Tier %1 | %2 > %3</t><br/><br/>", 
    _tier, _itemData get "category", _itemData get "subcategory"];

// Status
private _isResearched = [_itemId] call OpsRoom_fnc_isResearched;
private _prereqsMet = [_itemId] call OpsRoom_fnc_prereqsMet;
private _activeResearch = missionNamespace getVariable ["OpsRoom_ResearchInProgress", []];
private _isInProgress = false;
if (count _activeResearch > 0) then {
    if ((_activeResearch select 0) == _itemId) then {
        _isInProgress = true;
    };
};

if (_isResearched) then {
    _text = _text + "<t color='#80FF80' size='0.9' font='PuristaBold'>✓ RESEARCHED</t><br/><br/>";
} else {
    if (_isInProgress) then {
        _activeResearch params ["", "_startTime", "_duration"];
        private _elapsed = time - _startTime;
        private _remaining = (_duration * 60) - _elapsed;
        private _minsLeft = ceil (_remaining / 60);
        private _pct = floor ((_elapsed / (_duration * 60)) * 100) min 100;
        _text = _text + format ["<t color='#FFD966' size='0.9' font='PuristaBold'>⏳ RESEARCHING... %1%2 (%3 min left)</t><br/><br/>", _pct, "%", _minsLeft];
    } else {
        if (_prereqsMet) then {
            _text = _text + "<t color='#D9D5C9' size='0.9'>→ Available for research</t><br/><br/>";
        } else {
            _text = _text + "<t color='#FF6666' size='0.9'>✗ Prerequisites not met</t><br/><br/>";
        };
    };
};

// Description
_text = _text + format ["<t size='0.85'>%1</t><br/><br/>", _desc];

// Cost
_text = _text + format ["<t size='0.9' font='PuristaBold' color='#FFD966'>Cost: %1 Research Points</t><br/>", _cost];
_text = _text + format ["<t size='0.9' font='PuristaBold'>Time: %1 minutes</t><br/><br/>", _time];

// Prerequisites
if (count _prereqs > 0) then {
    _text = _text + "<t size='0.9' font='PuristaBold'>Prerequisites:</t><br/>";
    {
        private _prereqData = OpsRoom_EquipmentDB get _x;
        private _prereqName = if (!isNil "_prereqData") then { _prereqData get "displayName" } else { _x };
        private _prereqDone = [_x] call OpsRoom_fnc_isResearched;
        private _prereqColor = if (_prereqDone) then { "#80FF80" } else { "#FF6666" };
        private _prereqIcon = if (_prereqDone) then { "✓" } else { "✗" };
        _text = _text + format ["<t color='%1' size='0.85'>  %2 %3</t><br/>", _prereqColor, _prereqIcon, _prereqName];
    } forEach _prereqs;
} else {
    _text = _text + "<t size='0.85' color='#AAAAAA'>No prerequisites</t><br/>";
};

// Set details text
private _detailsCtrl = _display displayCtrl 11050;
_detailsCtrl ctrlSetStructuredText parseText _text;

// Update research button state
private _researchBtn = _display displayCtrl 11060;
private _statusCtrl = _display displayCtrl 11061;

private _rp = missionNamespace getVariable ["OpsRoom_Resource_Research_Points", 0];

if (_isResearched) then {
    _researchBtn ctrlSetText "RESEARCHED";
    _researchBtn ctrlEnable false;
    _statusCtrl ctrlSetStructuredText parseText "";
} else {
    if (_isInProgress) then {
        _researchBtn ctrlSetText "IN PROGRESS";
        _researchBtn ctrlEnable false;
        _statusCtrl ctrlSetStructuredText parseText "";
    } else {
        if (!_prereqsMet) then {
            _researchBtn ctrlSetText "LOCKED";
            _researchBtn ctrlEnable false;
            _statusCtrl ctrlSetStructuredText parseText "<t color='#FF6666' size='0.8'>Prerequisites required</t>";
        } else {
            if (_rp < _cost) then {
                _researchBtn ctrlSetText "BEGIN RESEARCH";
                _researchBtn ctrlEnable false;
                _statusCtrl ctrlSetStructuredText parseText format ["<t color='#FF6666' size='0.8'>Need %1 RP (have %2)</t>", _cost, _rp];
            } else {
                // Check if another research is already in progress
                if (count _activeResearch > 0) then {
                    _researchBtn ctrlSetText "BEGIN RESEARCH";
                    _researchBtn ctrlEnable false;
                    _statusCtrl ctrlSetStructuredText parseText "<t color='#FFD966' size='0.8'>Another research active</t>";
                } else {
                    _researchBtn ctrlSetText "BEGIN RESEARCH";
                    _researchBtn ctrlEnable true;
                    _statusCtrl ctrlSetStructuredText parseText "";
                };
            };
        };
    };
};
