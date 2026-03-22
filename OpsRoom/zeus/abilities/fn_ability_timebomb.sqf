/*
    OpsRoom_fnc_ability_timebomb
    
    Time Bomb - Main entry point.
    Select unit with demolitions training, pick fuse time, click position.
    Unit moves to position, places bomb, countdown begins, BOOM.
*/

private _selected = curatorSelected select 0;

if (typeName _selected != "ARRAY") exitWith {
    hint "Error: Invalid selection";
};
if (count _selected == 0) exitWith {
    hint "No units selected";
};

// Validate - must have demolitions training
private _capable = _selected select {
    _x getVariable ["OpsRoom_Ability_Timebomb", false]
};

if (count _capable == 0) exitWith {
    hint "No units with demolitions training selected";
};

// Store capable units (take first one - single unit ability)
OpsRoom_Timebomb_Unit = _capable select 0;

// Find THIS ability's button on Zeus display
private _display = findDisplay 312;
if (isNull _display) exitWith {};

private _myButton = controlNull;
for "_i" from 9350 to 9389 step 2 do {
    private _btn = _display displayCtrl (_i + 1);
    if (!isNull _btn) then {
        if ((_btn getVariable ["abilityID", ""]) == "timebomb") exitWith {
            _myButton = _btn;
        };
    };
};

if (isNull _myButton) exitWith { hint "Button not found"; };

private _btnPos = ctrlPosition _myButton;
_btnPos params ["_baseX", "_baseY", "_btnW", "_btnH"];

// Menu items: fuse timer options
private _menuItems = [
    ["30 SECONDS",  "\A3\ui_f\data\IGUI\Cfg\SimpleTasks\types\destroy_ca.paa", {[30]   call OpsRoom_fnc_startTimebombTargeting}],
    ["1 MINUTE",    "\A3\ui_f\data\IGUI\Cfg\SimpleTasks\types\destroy_ca.paa", {[60]   call OpsRoom_fnc_startTimebombTargeting}],
    ["5 MINUTES",   "\A3\ui_f\data\IGUI\Cfg\SimpleTasks\types\destroy_ca.paa", {[300]  call OpsRoom_fnc_startTimebombTargeting}],
    ["30 MINUTES",  "\A3\ui_f\data\IGUI\Cfg\SimpleTasks\types\destroy_ca.paa", {[1800] call OpsRoom_fnc_startTimebombTargeting}]
];

[_display, _myButton, _menuItems, _baseX, _baseY, _btnW] call OpsRoom_fnc_createButtonMenu;
