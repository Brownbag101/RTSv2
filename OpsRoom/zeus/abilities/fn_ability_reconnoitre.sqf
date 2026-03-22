/*
    OpsRoom_fnc_ability_reconnoitre
    
    Forward Observer reconnaissance. Click a position — unit moves there,
    goes prone, scans area. Enemies within radius added to OpsRoom_KnownEnemies.
    
    Menu options control scan radius: Close (100m), Medium (200m), Deep (400m)
*/

private _selected = curatorSelected select 0;

if (typeName _selected != "ARRAY") exitWith {};
if (count _selected == 0) exitWith { hint "No units selected"; };

// Filter for FO-trained units
private _capable = _selected select {
    _x getVariable ["OpsRoom_Ability_Reconnoitre", false]
};

if (count _capable == 0) exitWith { hint "No Forward Observers selected"; };

OpsRoom_Recon_Unit = _capable select 0;

// Find button
private _display = findDisplay 312;
if (isNull _display) exitWith {};

private _myButton = controlNull;
for "_i" from 9350 to 9389 step 2 do {
    private _btn = _display displayCtrl (_i + 1);
    if (!isNull _btn) then {
        if ((_btn getVariable ["abilityID", ""]) == "reconnoitre") exitWith {
            _myButton = _btn;
        };
    };
};

if (isNull _myButton) exitWith { hint "Button not found"; };

private _btnPos = ctrlPosition _myButton;
_btnPos params ["_baseX", "_baseY", "_btnW", "_btnH"];

private _menuItems = [
    ["CLOSE RECON (100m)",  "a3\ui_f\data\igui\cfg\simpleTasks\types\scout_ca.paa", {[100]  call OpsRoom_fnc_startReconTargeting}],
    ["MEDIUM RECON (200m)", "a3\ui_f\data\igui\cfg\simpleTasks\types\scout_ca.paa", {[200]  call OpsRoom_fnc_startReconTargeting}],
    ["DEEP RECON (400m)",   "a3\ui_f\data\igui\cfg\simpleTasks\types\scout_ca.paa", {[400]  call OpsRoom_fnc_startReconTargeting}]
];

[_display, _myButton, _menuItems, _baseX, _baseY, _btnW] call OpsRoom_fnc_createButtonMenu;
