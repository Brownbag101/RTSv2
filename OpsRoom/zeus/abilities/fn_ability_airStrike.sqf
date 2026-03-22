/*
    OpsRoom_fnc_ability_airStrike
    
    Main entry point — called when the Air Strike ability button is clicked.
    Validates selected units, scans for available aircraft, builds dynamic
    menu showing only attack types that have aircraft with matching ammo.
*/

private _selected = curatorSelected select 0;

if (typeName _selected != "ARRAY") exitWith { hint "Error: Invalid selection" };
if (count _selected == 0) exitWith { hint "No units selected" };

// Filter for Radio Operator trained units
private _capable = _selected select {
    _x getVariable ["OpsRoom_Ability_AirStrike", false]
};

if (count _capable == 0) exitWith { hint "No Radio Operators selected" };

// Scan for available aircraft
private _available = [] call OpsRoom_fnc_airStrike_getAvailable;

if (count _available == 0) exitWith { 
    hint "No ground attack aircraft available.\nAircraft must be airborne with ammunition.";
};

// Store for targeting phase
OpsRoom_AirStrike_Unit = _capable select 0;
OpsRoom_AirStrike_Available = _available;

// Determine which attack types have aircraft
private _anyGuns = false;
private _anyBombs = false;
private _anyRockets = false;

{
    if (_x get "hasGuns") then { _anyGuns = true };
    if (_x get "hasBombs") then { _anyBombs = true };
    if (_x get "hasRockets") then { _anyRockets = true };
} forEach _available;

// Find this ability's button on Zeus display
private _display = findDisplay 312;
if (isNull _display) exitWith {};

private _myButton = controlNull;
for "_i" from 9350 to 9389 step 2 do {
    private _btn = _display displayCtrl (_i + 1);
    if (!isNull _btn) then {
        if ((_btn getVariable ["abilityID", ""]) == "airStrike") exitWith {
            _myButton = _btn;
        };
    };
};

if (isNull _myButton) exitWith { hint "Button not found" };

private _btnPos = ctrlPosition _myButton;
_btnPos params ["_baseX", "_baseY", "_btnW", "_btnH"];

// Build menu dynamically — only show options with available aircraft
private _menuItems = [];

if (_anyGuns) then {
    // Count aircraft with guns
    private _gunCount = { _x get "hasGuns" } count _available;
    _menuItems pushBack [
        format ["GUN RUN (%1 aircraft)", _gunCount],
        "\A3\ui_f\data\IGUI\Cfg\SimpleTasks\types\attack_ca.paa",
        {["GUNS"] call OpsRoom_fnc_startAirStrikeTargeting}
    ];
};

if (_anyRockets) then {
    private _rktCount = { _x get "hasRockets" } count _available;
    _menuItems pushBack [
        format ["ROCKET RUN (%1 aircraft)", _rktCount],
        "\A3\ui_f\data\IGUI\Cfg\SimpleTasks\types\destroy_ca.paa",
        {["ROCKETS"] call OpsRoom_fnc_startAirStrikeTargeting}
    ];
};

if (_anyBombs) then {
    private _bmbCount = { _x get "hasBombs" } count _available;
    _menuItems pushBack [
        format ["BOMB RUN (%1 aircraft)", _bmbCount],
        "\A3\ui_f\data\IGUI\Cfg\SimpleTasks\types\destroy_ca.paa",
        {["BOMBS"] call OpsRoom_fnc_startAirStrikeTargeting}
    ];
};

// Combined strafe: guns + rockets if both available
if (_anyGuns && _anyRockets) then {
    // Find aircraft that have BOTH
    private _bothCount = { (_x get "hasGuns") && (_x get "hasRockets") } count _available;
    if (_bothCount > 0) then {
        _menuItems pushBack [
            format ["STRAFE (%1 aircraft)", _bothCount],
            "\A3\ui_f\data\IGUI\Cfg\SimpleTasks\types\attack_ca.paa",
            {["STRAFE"] call OpsRoom_fnc_startAirStrikeTargeting}
        ];
    };
};

if (count _menuItems == 0) exitWith { hint "No attack options available" };

[_display, _myButton, _menuItems, _baseX, _baseY, _btnW] call OpsRoom_fnc_createButtonMenu;
