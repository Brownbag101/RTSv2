/*
    OpsRoom_fnc_ability_infiltrate
    
    SOE Infiltration. Agent moves stealthily to target position.
    Reduced detection, stealth behaviour, prone on arrival.
    
    Menu: Quick Infiltrate (faster, more visible) / Deep Infiltrate (slow, near invisible)
*/

private _selected = curatorSelected select 0;

if (typeName _selected != "ARRAY") exitWith {};
if (count _selected == 0) exitWith { hint "No units selected"; };

private _capable = _selected select {
    _x getVariable ["OpsRoom_Ability_Infiltrate", false]
};

if (count _capable == 0) exitWith { hint "No SOE agents selected"; };

OpsRoom_Infiltrate_Unit = _capable select 0;

// Find button
private _display = findDisplay 312;
if (isNull _display) exitWith {};

private _myButton = controlNull;
for "_i" from 9350 to 9389 step 2 do {
    private _btn = _display displayCtrl (_i + 1);
    if (!isNull _btn) then {
        if ((_btn getVariable ["abilityID", ""]) == "infiltrate") exitWith {
            _myButton = _btn;
        };
    };
};

if (isNull _myButton) exitWith { hint "Button not found"; };

private _btnPos = ctrlPosition _myButton;
_btnPos params ["_baseX", "_baseY", "_btnW", "_btnH"];

private _menuItems = [
    ["QUICK INFILTRATE", "a3\ui_f\data\igui\cfg\simpleTasks\types\scout_ca.paa", {["quick"] call OpsRoom_fnc_startInfiltrateTargeting}],
    ["DEEP INFILTRATE",  "a3\ui_f\data\igui\cfg\simpleTasks\types\scout_ca.paa", {["deep"]  call OpsRoom_fnc_startInfiltrateTargeting}]
];

[_display, _myButton, _menuItems, _baseX, _baseY, _btnW] call OpsRoom_fnc_createButtonMenu;
