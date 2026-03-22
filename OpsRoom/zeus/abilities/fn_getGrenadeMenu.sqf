/*
    OpsRoom_fnc_getGrenadeMenu
    
    Returns menu items for grenade selection
    Similar to formation menu
    
    Params:
        _unit - Unit who will throw
        _grenadeTypes - Array of grenade magazine classnames
        
    Returns:
        Array of [text, icon, action]
*/

params ["_unit", "_grenadeTypes"];

// Store unit globally so actions can access it
OpsRoom_GrenadeMenu_Unit = _unit;

// Grenade icon mapping
private _grenadeIcons = createHashMapFromArray [
    ["HandGrenade", "a3\ui_f\data\igui\cfg\weaponicons\mg_ca.paa"],
    ["MiniGrenade", "a3\ui_f\data\igui\cfg\weaponicons\mg_ca.paa"],
    ["JMSSA_MillsBomb_HandGrenade", "a3\ui_f\data\igui\cfg\weaponicons\mg_ca.paa"],
    ["fow_e_no36mk1", "a3\ui_f\data\igui\cfg\weaponicons\mg_ca.paa"],
    ["LIB_MillsBomb", "a3\ui_f\data\igui\cfg\weaponicons\mg_ca.paa"],
    ["SmokeShell", "a3\ui_f\data\igui\cfg\actions\heal_ca.paa"],
    ["SmokeShellRed", "a3\ui_f\data\igui\cfg\actions\heal_ca.paa"],
    ["SmokeShellGreen", "a3\ui_f\data\igui\cfg\actions\heal_ca.paa"],
    ["SmokeShellYellow", "a3\ui_f\data\igui\cfg\actions\heal_ca.paa"],
    ["SmokeShellPurple", "a3\ui_f\data\igui\cfg\actions\heal_ca.paa"],
    ["SmokeShellBlue", "a3\ui_f\data\igui\cfg\actions\heal_ca.paa"],
    ["SmokeShellOrange", "a3\ui_f\data\igui\cfg\actions\heal_ca.paa"],
    ["Chemlight_green", "a3\ui_f\data\igui\cfg\actions\heal_ca.paa"],
    ["Chemlight_red", "a3\ui_f\data\igui\cfg\actions\heal_ca.paa"],
    ["Chemlight_yellow", "a3\ui_f\data\igui\cfg\actions\heal_ca.paa"],
    ["Chemlight_blue", "a3\ui_f\data\igui\cfg\actions\heal_ca.paa"]
];

// Grenade display name mapping
private _grenadeNames = createHashMapFromArray [
    ["HandGrenade", "HE Grenade"],
    ["MiniGrenade", "RGN Grenade"],
    ["JMSSA_MillsBomb_HandGrenade", "Mills Bomb"],
    ["fow_e_no36mk1", "No.36 MK1"],
    ["LIB_MillsBomb", "Mills Bomb"],
    ["SmokeShell", "Smoke (White)"],
    ["SmokeShellRed", "Smoke (Red)"],
    ["SmokeShellGreen", "Smoke (Green)"],
    ["SmokeShellYellow", "Smoke (Yellow)"],
    ["SmokeShellPurple", "Smoke (Purple)"],
    ["SmokeShellBlue", "Smoke (Blue)"],
    ["SmokeShellOrange", "Smoke (Orange)"],
    ["Chemlight_green", "Chemlight (Green)"],
    ["Chemlight_red", "Chemlight (Red)"],
    ["Chemlight_yellow", "Chemlight (Yellow)"],
    ["Chemlight_blue", "Chemlight (Blue)"]
];

// Build menu items array
private _menuItems = [];

{
    private _grenadeType = _x;
    private _icon = _grenadeIcons getOrDefault [_grenadeType, "a3\ui_f\data\igui\cfg\actions\heal_ca.paa"];
    private _name = _grenadeNames getOrDefault [_grenadeType, _grenadeType];
    
    // Create action code that gets unit from global variable
    private _actionCode = compile format [
        "private _unit = OpsRoom_GrenadeMenu_Unit; [_unit, '%1'] call OpsRoom_fnc_enterGrenadeTargeting;",
        _grenadeType
    ];
    
    _menuItems pushBack [_name, _icon, _actionCode];
    
} forEach _grenadeTypes;

_menuItems
