/*
    Apply Regiment Loadout
    
    Applies type-specific uniform and equipment to a unit based on regiment type.
    Called when forming a regiment (on the Major) and when units join typed regiments.
    
    Only applies loadout for types that have a distinct uniform:
    - pioneer: Service Corps uniform
    - armoured: Tank crew uniform
    - Regular, commando, airborne, soe, sas get their loadouts from training completion instead.
    
    Parameters:
        0: OBJECT - Unit to equip
        1: STRING - Regiment type
    
    Usage:
        [_unit, "pioneer"] call OpsRoom_fnc_applyRegimentLoadout;
*/

params [
    ["_unit", objNull, [objNull]],
    ["_regimentType", "", [""]]
];

if (isNull _unit) exitWith {};
if (_regimentType == "") exitWith {};

// Only apply loadouts for types that have distinct uniforms not handled by training
switch (_regimentType) do {
    case "pioneer": {
        [_unit] spawn {
            params ["_u"];
            sleep 0.5;
            
            private _savedName = name _u;
            
            removeAllWeapons _u;
            removeAllItems _u;
            removeAllAssignedItems _u;
            removeUniform _u;
            removeVest _u;
            removeBackpack _u;
            removeHeadgear _u;
            removeGoggles _u;
            
            // Service Corps uniform
            _u forceAddUniform "UK_Uniform_RASC50th_50thUK_LCpl";
            _u addVest "fow_v_uk_officer";
            
            _u addItemToUniform "FirstAidKit";
            for "_i" from 1 to 2 do {_u addItemToUniform "SmokeShell";};
            
            _u addHeadgear "Beret_50th_rasc";
            _u addGoggles "fow_g_gloves2";
            
            _u linkItem "ItemMap";
            _u linkItem "ItemCompass";
            _u linkItem "ItemWatch";
            
            sleep 0.5;
            _u setName _savedName;
            
            diag_log format ["[OpsRoom] Service Corps loadout applied to %1", _savedName];
        };
    };
    case "armoured": {
        [_unit] spawn {
            params ["_u"];
            sleep 0.5;
            
            private _savedName = name _u;
            
            removeAllWeapons _u;
            removeAllItems _u;
            removeAllAssignedItems _u;
            removeUniform _u;
            removeVest _u;
            removeBackpack _u;
            removeHeadgear _u;
            removeGoggles _u;
            
            // Tank crew uniform
            _u forceAddUniform "U_LIB_UK_P37";
            _u addVest "V_LIB_UK_P37_Crew";
            
            // Sidearm: Webley revolver
            _u addWeapon "LIB_Webley_mk6";
            _u addHandgunItem "LIB_6Rnd_455";
            
            // Binoculars
            _u addWeapon "LIB_Binocular_UK";
            
            _u addItemToUniform "FirstAidKit";
            _u addItemToUniform "LIB_No77";
            for "_i" from 1 to 2 do {_u addItemToUniform "LIB_6Rnd_455";};
            
            _u addHeadgear "H_LIB_UK_Beret_Tankist";
            
            _u linkItem "ItemMap";
            _u linkItem "ItemCompass";
            _u linkItem "ItemWatch";
            _u linkItem "ItemRadio";
            
            sleep 0.5;
            _u setName _savedName;
            
            diag_log format ["[OpsRoom] Tank crew loadout applied to %1", _savedName];
        };
    };
    // Commando, airborne, SOE, SAS loadouts are applied via training completion
    // Regular infantry keeps whatever gear they have
    default {};
};
