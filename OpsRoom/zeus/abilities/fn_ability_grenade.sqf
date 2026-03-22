/*
    OpsRoom_fnc_ability_grenade
    
    Main entry point for grenade ability
    - Checks selected units for grenades
    - Gets grenade types available
    - ALWAYS shows expandable menu (even for single type)
*/

private _selected = curatorSelected select 0;

if (count _selected == 0) exitWith {
    hint "No units selected";
};

// Find units with grenades
private _unitsWithGrenades = _selected select {
    private _mags = magazines _x;
    private _hasGrenade = false;
    {
        private _type = getNumber (configFile >> "CfgMagazines" >> _x >> "type");
        private _ammo = getText (configFile >> "CfgMagazines" >> _x >> "ammo");
        
        // Type 256 = hand grenades
        // But also check that ammo class inherits from "GrenadeHand" to filter out pistol mags
        if (_type == 256) then {
            // Check if ammo inherits from GrenadeHand
            private _cfg = configFile >> "CfgAmmo" >> _ammo;
            private _parents = [_cfg, true] call BIS_fnc_returnParents;
            if ("GrenadeHand" in _parents || "GrenadeBase" in _parents) then {
                _hasGrenade = true;
            };
        };
    } forEach _mags;
    _hasGrenade
};

if (count _unitsWithGrenades == 0) exitWith {
    hint "No grenades available";
};

// Use first unit with grenades
private _unit = _unitsWithGrenades select 0;

// Get all grenade types this unit has
private _grenadeTypes = [];
private _allMags = magazines _unit;

{
    private _type = getNumber (configFile >> "CfgMagazines" >> _x >> "type");
    private _ammo = getText (configFile >> "CfgMagazines" >> _x >> "ammo");
    
    // Type 256 but must be actual grenades
    if (_type == 256) then {
        // Check if ammo inherits from GrenadeHand
        private _cfg = configFile >> "CfgAmmo" >> _ammo;
        private _parents = [_cfg, true] call BIS_fnc_returnParents;
        if ("GrenadeHand" in _parents || "GrenadeBase" in _parents) then {
            if !(_x in _grenadeTypes) then {
                _grenadeTypes pushBack _x;
                diag_log format ["[OpsRoom] Found grenade type: %1 (ammo: %2)", _x, _ammo];
            };
        } else {
            diag_log format ["[OpsRoom] SKIPPED non-grenade type 256: %1 (ammo: %2, parents: %3)", _x, _ammo, _parents];
        };
    };
} forEach _allMags;

if (count _grenadeTypes == 0) exitWith {
    hint "No grenades available";
    diag_log "[OpsRoom] No actual grenade magazines found";
};

// ALWAYS show menu - even for single grenade type
private _display = findDisplay 312;
if (isNull _display) exitWith {};

// Get menu items
private _menuItems = [_unit, _grenadeTypes] call OpsRoom_fnc_getGrenadeMenu;

diag_log format ["[OpsRoom] Menu items created: %1", _menuItems];

// Find the grenade ability button that was clicked
// Abilities are at IDCs 9350-9389
private _grenadeButton = controlNull;
for "_i" from 9350 to 9389 step 2 do {
    private _btn = _display displayCtrl (_i + 1); // Button is always IDC+1
    if (!isNull _btn) then {
        private _abilityID = _btn getVariable ["abilityID", ""];
        if (_abilityID == "grenade") exitWith {
            _grenadeButton = _btn;
        };
    };
};

if (isNull _grenadeButton) exitWith {
    hint "Could not find grenade button";
    diag_log "[OpsRoom] ERROR: Could not find grenade ability button for menu";
};

// Get button position
private _btnPos = ctrlPosition _grenadeButton;
_btnPos params ["_baseX", "_baseY", "_btnW", "_btnH"];

diag_log format ["[OpsRoom] Grenade button position: %1", _btnPos];

// Create expandable menu above the button
[_display, _grenadeButton, _menuItems, _baseX, _baseY, _btnW] call OpsRoom_fnc_createButtonMenu;

diag_log format ["[OpsRoom] Created grenade menu with %1 types: %2", count _grenadeTypes, _grenadeTypes];
