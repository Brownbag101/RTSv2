# Context-Aware Button System - Complete!

## What Was Built

A dynamic button system that shows/hides buttons based on selected unit abilities.

## Files Created

### Core System
- `zeus/fn_getUnitAbilities.sqf` - Determines available abilities for selection
- `zeus/fn_createAbilityButton.sqf` - Creates individual ability button
- `zeus/fn_updateContextButtons.sqf` - Updates buttons on selection change
- `zeus/fn_createStandardButtons.sqf` - Creates always-visible command buttons
- `zeus/fn_executeStandardCommand.sqf` - Handles standard commands

### Configuration
- `zeus/abilities/config.sqf` - Ability definitions with icons, conditions, actions

### Abilities
- `zeus/abilities/fn_ability_regroup.sqf` - Regroup detached units (Captain+ only)
- `zeus/abilities/fn_ability_suppressiveFire.sqf` - MG suppressive fire
- `zeus/abilities/fn_ability_repair.sqf` - Engineer vehicle repair
- `zeus/abilities/fn_ability_heal.sqf` - Medic healing

## Files Modified

- `zeus/fn_monitorSelection.sqf` - Added button update on selection change
- `config.hpp` - Registered new functions
- `init.sqf` - Initialize ability system and standard buttons
- `missions/fn_spawnStartingRegiment.sqf` - Added test abilities to spawned units

## Button Layout

```
Bottom Toolbar:
┌─────────────────────────────────────────────────────────────────┐
│ [Stance] [Combat] [Speed] [Formation]    [Regroup] [Suppress]  │
│   LEFT: Standard Buttons                  RIGHT: Abilities      │
└─────────────────────────────────────────────────────────────────┘
```

## How It Works

1. **Standard Buttons** (Left) - Always visible for any selection
   - Stance (cycle: Auto/Stand/Crouch/Prone)
   - Combat Mode (cycle: Never Fire/Hold/At Will/etc)
   - Speed Mode (cycle: Limited/Normal/Full)
   - Formation (cycle: Column/Wedge/Line/etc)

2. **Ability Buttons** (Right) - Context-aware, only show when conditions met
   - Regroup: Captain+ rank, group leader, has detached units
   - Suppress: Unit has `OpsRoom_Ability_SuppressiveFire` variable
   - Repair: Unit has `OpsRoom_Ability_Repair` variable
   - Heal: Unit has `OpsRoom_Ability_Heal` variable

## Granting Abilities

Set variables on units:

```sqf
// Grant Captain rank (enables Regroup when leading + detached units exist)
_unit setVariable ["OpsRoom_Rank", "CAPTAIN", true];

// Grant specific abilities
_unit setVariable ["OpsRoom_Ability_SuppressiveFire", true, true];
_unit setVariable ["OpsRoom_Ability_Repair", true, true];
_unit setVariable ["OpsRoom_Ability_Heal", true, true];
```

## Adding New Abilities

1. Add to `zeus/abilities/config.sqf`:
```sqf
OpsRoom_AbilityConfig set ["myAbility", createHashMapFromArray [
    ["name", "My Ability"],
    ["icon", "path\to\icon.paa"],
    ["tooltip", "Description"],
    ["condition", {
        params ["_units"];
        // Return true if ability should show
        _units findIf {_x getVariable ["OpsRoom_Ability_MyAbility", false]} != -1
    }],
    ["action", {call OpsRoom_fnc_ability_myAbility}]
]];
```

2. Create function `zeus/abilities/fn_ability_myAbility.sqf`

3. Register in `config.hpp` under `class Abilities`

## Testing

1. Run `SYNC_OpsRoom.bat`
2. Load mission in ARMA 3
3. Open Zeus
4. Select different units:
   - **Leader alone** → Regroup button (if detached units exist)
   - **MG gunner** → Suppress button
   - **Multiple units** → Both buttons
   - **Regular soldier** → No ability buttons
5. Standard buttons always visible

## ARMA 3 Icons Used

```
Stance: a3\ui_f\data\igui\cfg\actions\stand_ca.paa
Combat: a3\ui_f\data\igui\cfg\actions\gear_ca.paa  
Speed: a3\ui_f\data\igui\cfg\actions\run_ca.paa
Formation: a3\ui_f\data\igui\cfg\actions\settimer_ca.paa
Regroup: a3\ui_f\data\gui\rsc\rscdisplayarcademap\icon_toolbox_groups_ca.paa
Suppress: a3\ui_f\data\igui\cfg\weaponicons\mg_ca.paa
Repair: a3\ui_f\data\igui\cfg\actions\repair_ca.paa
Heal: a3\ui_f\data\igui\cfg\actions\heal_ca.paa
```

## Benefits

✅ Solves reattach bug - button only shows when valid  
✅ Clean UI - only relevant buttons shown  
✅ Modular - easy to add abilities  
✅ Scalable - handles 1-20 abilities automatically  
✅ Foundation for progression system  
✅ Standard commands always accessible
