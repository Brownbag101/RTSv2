/*
    OpsRoom_fnc_ability_suppressiveFire
    
    Opens expandable duration menu for suppressive fire
*/

// Get selected units
private _selected = curatorSelected select 0;

// Defensive check
if (typeName _selected != "ARRAY") exitWith {
    hint "Error: Invalid selection";
    diag_log format ["[OpsRoom] ERROR: curatorSelected returned non-array: %1", typeName _selected];
};

if (count _selected == 0) exitWith {
    hint "No units selected";
};

diag_log format ["[OpsRoom] Suppress ability called with %1 units", count _selected];

// Check MG capability and ammo
private _validation = _selected call OpsRoom_fnc_checkSuppressCapable;
_validation params ["_capable", "_failed"];

diag_log format ["[OpsRoom] Validation complete: %1 capable, %2 failed", count _capable, count _failed];

// Check if any units are capable
if (_capable isEqualTo []) exitWith {
    hint "Selected units have no MG or no ammo";
};

// Warn about failed units if any
if !(_failed isEqualTo []) then {
    hint format ["%1 unit(s) lack MG/ammo (proceeding with %2 capable)", count _failed, count _capable];
};

// Store capable units globally for menu actions
OpsRoom_SuppressUnits = _capable;

// Get display and find the suppress button
private _display = findDisplay 312;
if (isNull _display) exitWith {
    hint "Zeus display not found";
};

// Find the suppress ability button
private _suppressButton = controlNull;
for "_i" from 9350 to 9389 step 2 do {
    private _btn = _display displayCtrl (_i + 1);
    if (!isNull _btn) then {
        private _abilityID = _btn getVariable ["abilityID", ""];
        if (_abilityID == "suppressiveFire") exitWith {
            _suppressButton = _btn;
        };
    };
};

if (isNull _suppressButton) exitWith {
    hint "Could not find suppress button";
};

// Get button position
private _btnPos = ctrlPosition _suppressButton;
_btnPos params ["_baseX", "_baseY", "_btnW", "_btnH"];

// Create menu items
private _menuItems = [
    ["10 SECONDS", "\a3\ui_f\data\igui\cfg\weaponicons\mg_ca.paa", {[10] call OpsRoom_fnc_startSuppressTargeting}],
    ["20 SECONDS", "\a3\ui_f\data\igui\cfg\weaponicons\mg_ca.paa", {[20] call OpsRoom_fnc_startSuppressTargeting}],
    ["30 SECONDS", "\a3\ui_f\data\igui\cfg\weaponicons\mg_ca.paa", {[30] call OpsRoom_fnc_startSuppressTargeting}],
    ["UNTIL OUT OF AMMO", "\a3\ui_f\data\igui\cfg\weaponicons\mg_ca.paa", {[-1] call OpsRoom_fnc_startSuppressTargeting}]
];

// Create expandable menu
[_display, _suppressButton, _menuItems, _baseX, _baseY, _btnW] call OpsRoom_fnc_createButtonMenu;
