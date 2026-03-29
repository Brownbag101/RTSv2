/*
    Ability Configuration
    
    Defines all available abilities with their icons, conditions, and actions
*/

OpsRoom_AbilityConfig = createHashMap;

// Note: Regroup moved to standard buttons on left side

// ==================== COMBAT ABILITIES ====================

OpsRoom_AbilityConfig set ["grenade", createHashMapFromArray [
    ["name", "Grenade"],
    ["icon", "a3\ui_f\data\igui\cfg\actions\heal_ca.paa"],
    ["tooltip", "Throw grenade at cursor position"],
    ["condition", {
        params ["_units"];
        _units findIf {
            private _mags = magazines _x;
            private _hasGrenade = false;
            {
                private _type = getNumber (configFile >> "CfgMagazines" >> _x >> "type");
                private _ammo = getText (configFile >> "CfgMagazines" >> _x >> "ammo");
                
                if (_type == 256) then {
                    private _cfg = configFile >> "CfgAmmo" >> _ammo;
                    private _parents = [_cfg, true] call BIS_fnc_returnParents;
                    if ("GrenadeHand" in _parents || "GrenadeBase" in _parents) then {
                        _hasGrenade = true;
                    };
                };
            } forEach _mags;
            _hasGrenade
        } != -1
    }],
    ["action", {call OpsRoom_fnc_ability_grenade}]
]];

OpsRoom_AbilityConfig set ["suppressiveFire", createHashMapFromArray [
    ["name", "Suppress"],
    ["icon", "a3\ui_f\data\igui\cfg\weaponicons\mg_ca.paa"],
    ["tooltip", "Lay down suppressive fire at target position"],
    ["condition", {
        params ["_units"];
        private _mgWeapons = ["fow_w_bren", "fow_v_uk_bren", "JMSSA_bren2_Rifle"];
        _units findIf {
            private _hasAbility = _x getVariable ["OpsRoom_Ability_SuppressiveFire", false];
            if (_hasAbility) then {
                true
            } else {
                private _weapon = primaryWeapon _x;
                if !(_weapon in _mgWeapons) then {
                    false
                } else {
                    private _hasMags = false;
                    {
                        if (_x isEqualTo _weapon) then {_hasMags = true};
                    } forEach (magazines _x);
                    _hasMags
                }
            }
        } != -1
    }],
    ["action", {call OpsRoom_fnc_ability_suppressiveFire}]
]];

OpsRoom_AbilityConfig set ["aimedShot", createHashMapFromArray [
    ["name", "Aimed Shot"],
    ["icon", "x\cba\addons\ai\iconinvisibletarget.paa"],
    ["tooltip", "Slow time, mark known enemies, and take a precision shot"],
    ["condition", {
        params ["_units"];
        _units findIf {
            private _hasQual = _x getVariable ["OpsRoom_Ability_MarksmanShot", false];
            if (_hasQual) then {
                private _weapon = primaryWeapon _x;
                if ((_x ammo _weapon) > 0) then {
                    true
                } else {
                    false
                }
            } else {
                false
            }
        } != -1
    }],
    ["action", {call OpsRoom_fnc_ability_aimedShot}]
]];

OpsRoom_AbilityConfig set ["timebomb", createHashMapFromArray [
    ["name", "Timebomb"],
    ["icon", "\A3\ui_f\data\IGUI\Cfg\SimpleTasks\types\destroy_ca.paa"],
    ["tooltip", "Place timed explosive at target position"],
    ["condition", {
        params ["_units"];
        _units findIf {
            _x getVariable ["OpsRoom_Ability_Timebomb", false]
        } != -1
    }],
    ["action", {call OpsRoom_fnc_ability_timebomb}]
]];

// ==================== SUPPORT ABILITIES ====================

OpsRoom_AbilityConfig set ["repair", createHashMapFromArray [
    ["name", "Repair"],
    ["icon", "a3\ui_f\data\igui\cfg\actions\repair_ca.paa"],
    ["tooltip", "Repair nearby damaged vehicle or building"],
    ["condition", {
        params ["_units"];
        _units findIf {_x getVariable ["OpsRoom_Ability_Repair", false]} != -1
    }],
    ["action", {call OpsRoom_fnc_ability_repair}]
]];

OpsRoom_AbilityConfig set ["heal", createHashMapFromArray [
    ["name", "Heal"],
    ["icon", "a3\ui_f\data\igui\cfg\actions\heal_ca.paa"],
    ["tooltip", "Heal wounded units nearby"],
    ["condition", {
        params ["_units"];
        _units findIf {_x getVariable ["OpsRoom_Ability_Heal", false]} != -1
    }],
    ["action", {call OpsRoom_fnc_ability_heal}]
]];

// ==================== RECON ABILITIES ====================

OpsRoom_AbilityConfig set ["reconnoitre", createHashMapFromArray [
    ["name", "Reconnoitre"],
    ["icon", "a3\ui_f\data\igui\cfg\simpleTasks\types\scout_ca.paa"],
    ["tooltip", "Move to position and scan for enemies"],
    ["condition", {
        params ["_units"];
        _units findIf {
            _x getVariable ["OpsRoom_Ability_Reconnoitre", false]
        } != -1
    }],
    ["action", {call OpsRoom_fnc_ability_reconnoitre}]
]];

// ==================== SOE ABILITIES ====================

OpsRoom_AbilityConfig set ["infiltrate", createHashMapFromArray [
    ["name", "Infiltrate"],
    ["icon", "a3\ui_f\data\igui\cfg\simpleTasks\types\scout_ca.paa"],
    ["tooltip", "Stealthily move to target position"],
    ["condition", {
        params ["_units"];
        _units findIf {
            _x getVariable ["OpsRoom_Ability_Infiltrate", false]
        } != -1
    }],
    ["action", {call OpsRoom_fnc_ability_infiltrate}]
]];

OpsRoom_AbilityConfig set ["assassinate", createHashMapFromArray [
    ["name", "Assassinate"],
    ["icon", "\A3\ui_f\data\IGUI\Cfg\SimpleTasks\types\kill_ca.paa"],
    ["tooltip", "Eliminate a nearby known enemy silently"],
    ["condition", {
        params ["_units"];
        _units findIf {
            _x getVariable ["OpsRoom_Ability_Assassinate", false]
        } != -1
    }],
    ["action", {call OpsRoom_fnc_ability_assassinate}]
]];

// ==================== AIR SUPPORT ABILITIES ====================

OpsRoom_AbilityConfig set ["airStrike", createHashMapFromArray [
    ["name", "Air Strike"],
    ["icon", "\A3\ui_f\data\IGUI\Cfg\SimpleTasks\types\plane_ca.paa"],
    ["tooltip", "Call in air strike on target position (Radio Operator)"],
    ["condition", {
        params ["_units"];
        _units findIf {
            private _hasAbility = _x getVariable ["OpsRoom_Ability_AirStrike", false];
            if (_hasAbility) then {
                private _available = [] call OpsRoom_fnc_airStrike_getAvailable;
                if (count _available > 0) then {
                    true
                } else {
                    false
                }
            } else {
                false
            }
        } != -1
    }],
    ["action", {call OpsRoom_fnc_ability_airStrike}]
]];

// ==================== ENGINEERING ====================

OpsRoom_AbilityConfig set ["build", createHashMapFromArray [
    ["name", "Build"],
    ["icon", "a3\ui_f\data\igui\cfg\actions\repair_ca.paa"],
    ["tooltip", "Construct fortifications, defences, and minefields"],
    ["condition", {
        params ["_units"];
        _units findIf {
            _x getVariable ["OpsRoom_Ability_Build", false]
        } != -1
    }],
    ["action", {call OpsRoom_fnc_ability_build}]
]];

// ==================== CARGO LOGISTICS ====================

OpsRoom_AbilityConfig set ["cargo", createHashMapFromArray [
    ["name", "Cargo"],
    ["icon", "a3\ui_f\data\igui\cfg\simpleTasks\types\use_ca.paa"],
    ["tooltip", "Load/unload cargo items"],
    ["condition", {
        params ["_units"];
        // Single vehicle selection only, must be a registered cargo carrier
        if (count _units != 1) exitWith {false};
        private _unit = _units select 0;
        if (_unit isKindOf "Man") exitWith {false};
        private _vehType = typeOf _unit;
        OpsRoom_CargoCarriers getOrDefault [_vehType, -1] > 0
    }],
    ["action", {call OpsRoom_fnc_openCargoMenu}]
]];

// ==================== CAMERA ABILITIES ====================

OpsRoom_AbilityConfig set ["followCamera", createHashMapFromArray [
    ["name", "Follow"],
    ["icon", "a3\ui_f\data\igui\cfg\simpleTasks\types\scout_ca.paa"],
    ["tooltip", "Toggle camera follow on selected unit (WASD to override)"],
    ["condition", {
        params ["_units"];
        count _units == 1
    }],
    ["action", {call OpsRoom_fnc_toggleFollowCamera}]
]];

diag_log "[OpsRoom] Ability config initialized";
