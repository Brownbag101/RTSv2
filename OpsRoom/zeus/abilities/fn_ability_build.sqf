/*
    OpsRoom_fnc_ability_build
    
    Engineer build ability. Opens expandable menu with available buildables,
    filtered by research progress. Clicking an item starts placement mode.
    
    Requires: OpsRoom_Ability_Build = true (from Royal Engineers Training)
*/

private _selected = curatorSelected select 0;

if (typeName _selected != "ARRAY") exitWith {};
if (count _selected == 0) exitWith { hint "No units selected" };

// Filter for engineers with build ability
private _engineers = _selected select {
    _x getVariable ["OpsRoom_Ability_Build", false]
};

if (count _engineers == 0) exitWith { hint "No engineers selected" };

// Store globally for build actions
OpsRoom_Build_Engineers = _engineers;

// Find THIS ability's button
private _display = findDisplay 312;
if (isNull _display) exitWith {};

private _myButton = controlNull;
for "_i" from 9350 to 9389 step 2 do {
    private _btn = _display displayCtrl (_i + 1);
    if (!isNull _btn) then {
        if ((_btn getVariable ["abilityID", ""]) == "build") exitWith {
            _myButton = _btn;
        };
    };
};

if (isNull _myButton) exitWith { hint "Button not found" };

private _btnPos = ctrlPosition _myButton;
_btnPos params ["_baseX", "_baseY", "_btnW", "_btnH"];

// Build the menu items from OpsRoom_Buildables, filtered by research
private _menuItems = [];

{
    private _buildId = _x;
    private _buildData = _y;
    
    private _displayName = _buildData get "displayName";
    private _icon = _buildData getOrDefault ["icon", "a3\ui_f\data\igui\cfg\actions\repair_ca.paa"];
    private _researchReq = _buildData getOrDefault ["researchRequired", ""];
    private _cost = _buildData get "cost";
    private _placementType = _buildData getOrDefault ["placementType", "single"];
    
    // Check research requirement
    private _unlocked = if (_researchReq == "") then {
        true
    } else {
        _researchReq in (missionNamespace getVariable ["OpsRoom_ResearchCompleted", []])
    };
    
    if (_unlocked) then {
        // Build cost string for display
        private _costStr = "";
        {
            _x params ["_res", "_amt"];
            if (_costStr != "") then { _costStr = _costStr + ", " };
            _costStr = _costStr + format ["%1x %2", _amt, _res];
        } forEach _cost;
        
        private _label = format ["%1 (%2)", _displayName, _costStr];
        
        // Create menu item with build action
        _menuItems pushBack [_label, _icon, compile format [
            "private _buildId = '%1';
            private _buildData = OpsRoom_Buildables get _buildId;
            private _placementType = _buildData getOrDefault ['placementType', 'single'];
            if (_placementType == 'line') then {
                [_buildId] call OpsRoom_fnc_startLinePlacement;
            } else {
                [_buildId] call OpsRoom_fnc_startBuildPlacement;
            };",
            _buildId
        ]];
    };
} forEach OpsRoom_Buildables;

if (count _menuItems == 0) exitWith {
    hint "No buildable items available. Research Field Engineering to unlock more.";
};

[_display, _myButton, _menuItems, _baseX, _baseY, _btnW] call OpsRoom_fnc_createButtonMenu;
