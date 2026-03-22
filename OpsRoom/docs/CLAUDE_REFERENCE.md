# Claude Reference - OpsRoom System

**Critical context for future Claude instances working on this project.**

## Core Architecture

**Master Development:** `C:\Users\Brown\Desktop\OpsRoom_Dev\OpsRoom\`  
**Sync Tool:** `C:\Users\Brown\Desktop\SYNC_OpsRoom.bat`  
**Runtime:** `C:\Users\Brown\Documents\Arma 3\missions\MissionName.Map\OpsRoom\`

**NEVER edit mission folder files directly - ALWAYS edit Desktop master and sync.**

## Project Philosophy

- **Drop-in system**: Portable across any ARMA 3 mission
- **Zeus-centric**: Transforms tactical Zeus into strategic RTS
- **British Army WW2 aesthetic**: Khaki green, period terminology
- **Modular functions**: CfgFunctions auto-registration, no wrappers
- **Super concise docs**: Facts only, no fluff, streamlined

## Critical Technical Discoveries

### Zeus Display Requirements
- **Buttons MUST be on Zeus display (312)**, not RscTitles overlay
- RscTitles don't support reliable mouse interaction
- Use `cutRsc` with RscTitles for passive HUD elements only
- Use `ctrlCreate` on display 312 for all interactive buttons

### Auto-Detach System
- Hybrid approach: auto-detach for workflow, manual reattach via button
- 10-second cooldown prevents immediate re-detachment
- Group locking prevents unwanted auto-detach after manual control
- Unlock when individual units selected (user intent signal)

### IDC Management
- Systematic ranges prevent invisible button conflicts
- Main buttons: 9100-9209
- Standard commands: 9300-9311
- Date/time: 9320-9321
- Speed controls: 9330-9335
- Abilities: 9350-9389
- Menus: 9400-9449
- Dialogs: 10000+

### Function Definitions
- **NEVER wrap functions** like `OpsRoom_fnc_name = { code };`
- "Attempt to override final function" errors from improper wrapping
- CfgFunctions compiles automatically from file content
- Just write code directly in .sqf files

### Unified Monitoring
- Single spawn loop with staggered updates replaces multiple loops
- 0.1s: Selection + waypoint blocking (lightweight)
- 0.5s: Auto-detach system
- 1.0s: Fog of war (heavy, with optimizations)
- Adaptive sleep based on processing time

## Current System State

### Implemented Features
- 10 side buttons (Regiments implemented, 9 available)
- 6 standard command buttons (stance/combat/speed/formation/behaviour/regroup)
- Regiment → Groups → Units hierarchy with promotion system
- Auto-detach/reattach with regroup button
- Date/time display with speed controls (5 speeds)
- Resource tracking (9 resources)
- Enhanced unit info (rank, name, health, combat mode, behaviour, targets)
- **Fog of War**: Progressive enemy visibility (3 detection methods)
- **Selective Control**: Block enemy unit commands
- Helper functions for scripted reveals/hides

### File Organization
```
OpsRoom/
├── init.sqf                    // System initialization
├── settings.sqf                // All configurable settings
├── config.hpp                  // Function registration
├── gui/
│   ├── ui_defines.hpp          // Colors, fonts, base classes
│   ├── displays.hpp            // HUD + dialog includes
│   ├── fn_*.sqf                // GUI functions
│   └── regiments/              // Regiment system dialogs
├── zeus/
│   ├── fn_unifiedZeusMonitor.sqf   // Combined monitoring loop
│   ├── fn_autoDetachUnits.sqf
│   ├── fn_revealEnemy.sqf
│   ├── fn_hideEnemy.sqf
│   ├── fn_get*Menu.sqf         // Menu generators
│   └── abilities/              // Context abilities
├── data/
│   └── fn_initRegiments.sqf
└── missions/
    └── mission1_init.sqf       // Mission scripts
```

### Menu System
- Expandable menus created on Zeus display
- Icons from Eden Editor (`a3\3den\data\attributes\`)
- Formation: 9 options (File, Line, Column, Vee, Echelon L/R, Diamond, Wedge, Stag Column)
- Stance: 4 options (Auto, Stand, Crouch, Prone)
- Speed: 3 options (Limited, Normal, Full)
- Combat Mode: 5 options (Never Fire, Hold Fire, Hold/Engage, Fire at Will, Fire/Engage)
- Behaviour: 5 options (Safe, Aware, Combat, Stealth, Careless)

### Fog of War System
**Detection Methods:**
1. Zeus camera within 200m (direct observation)
2. Friendly knows about enemy (knowledge > 1.5) within 300m
3. Friendly has line of sight within 150m

**Optimizations:**
- Spatial filtering: Only check enemies near Zeus camera
- Knowledge cache: Update every 2 seconds, use cached between
- Friendly cache: Update every 5 seconds
- Early exit when display closed

**Global Data:**
- `OpsRoom_KnownEnemies` - Array of `[unit, method, time]`
- Auto-cleanup of null/dead/old enemies

### Unit Information Display
**Single unit shows:**
- Rank + Name (e.g., "Private Lee Evans")
- Health percentage (color-coded)
- Combat Mode (Fire at Will, Hold Fire, etc.)
- Behaviour (Safe, Aware, Combat, Stealth, Careless)
- Target if engaging (ENGAGING: Infantry)

**Group selection shows:**
- Group name + unit count
- Status (Healthy/Damaged/Critical)
- Combat Mode (from group)
- Behaviour (from group leader)

## User Preferences

**Andy likes:**
- Build everything at once (not incremental)
- Super concise documentation (facts, no fluff)
- Systematic debugging with detailed logs
- Streamlined workflow (Desktop → Sync → Test)
- Comprehensive implementations over partial solutions

**Documentation style:**
- 5 core docs: QUICK_START, EDITING_GUIDE, BUTTON_GUIDE, SYSTEM_REFERENCE, CHANGELOG
- Short sentences, bullet points, code examples
- No redundancy, no verbose explanations

## Development Workflow

1. **Edit files** in `Desktop/OpsRoom_Dev/OpsRoom/`
2. **Run sync** with `SYNC_OpsRoom.bat`
3. **Test in ARMA 3** on mission
4. **Iterate** as needed

**Branch strategy:**
- VR map for rapid testing
- Production terrain for deployment
- Sync tool handles both

## Common Edit Patterns

**Add new button:**
1. Edit `gui/fn_createButtonsOnZeus.sqf` - add to array
2. Add ButtonClick case handler
3. Sync and test

**Add new function:**
1. Create `path/fn_functionName.sqf`
2. Register in `config.hpp` CfgFunctions
3. Call with `[] call OpsRoom_fnc_functionName;`

**Add new setting:**
1. Add to `settings.sqf` with default value
2. Use in relevant function
3. Document in SYSTEM_REFERENCE

**Add menu option:**
1. Edit appropriate `fn_get*Menu.sqf`
2. Add `[text, icon, action]` array entry
3. Action runs on selected units

## Debugging Tips

**Check Zeus display:**
```sqf
private _display = findDisplay 312;
if (isNull _display) then {hint "Zeus not open"};
```

**Check button exists:**
```sqf
private _btn = _display displayCtrl 9101;
if (isNull _btn) then {hint "Button missing"};
```

**Check button visibility:**
```sqf
private _shown = ctrlShown _btn;
hint format ["Button shown: %1", _shown];
```

**Monitor performance:**
```sqf
private _start = diag_tickTime;
// code here
private _elapsed = diag_tickTime - _start;
diag_log format ["Execution time: %1ms", _elapsed * 1000];
```

## Key Learnings

### Button Visibility Issues
- IDC conflicts cause invisible buttons (same IDC used twice)
- Protected IDCs in `fn_hideZeusUI.sqf` whitelist
- Systematic ranges prevent conflicts

### Race Conditions
- Auto-reattach timing conflicts with manual control
- Solution: Cooldown variables + group locking
- Manual operations should lock automatic ones

### Performance
- Check all units every frame = lag
- Solution: Staggered updates, caching, spatial filtering
- Target <2% frame time overhead

### Zeus Camera
- `curatorCamera` only exists when Zeus display open
- Check `!isNull (findDisplay 312)` before using camera
- Position: `getPos curatorCamera`

## Settings Overview

**Core Settings:**
```sqf
OpsRoom_Settings_InitialResources              // Starting resources
OpsRoom_Settings_UnitInfoUpdateInterval        // 0.5s
OpsRoom_Settings_ZeusCheckInterval             // 2s
OpsRoom_Settings_AutoHideZeusUI                // true
```

**Zeus Control:**
```sqf
OpsRoom_Settings_SelectiveControl_Enabled      // true
OpsRoom_Settings_SelectiveControl_ShowMessages // true
OpsRoom_Settings_FogOfWar_Enabled              // true
OpsRoom_Settings_FogOfWar_DetectionRadius      // 300m
OpsRoom_Settings_FogOfWar_ZeusDirectRadius     // 200m
OpsRoom_Settings_FogOfWar_RemovalTimeout       // 30s
OpsRoom_Settings_FogOfWar_ShowDetections       // true
```

## Future Considerations

**Available for implementation:**
- 9 side buttons (Recruitment, Production, Research, Operations, Intelligence, Diplomacy, Economy, Politics, Settings)
- Territory control system
- Production queue system
- Research tree system
- Save/load functionality
- Advanced mission scripting

**Known limitations:**
- Fog of war only tracks units within 450m of Zeus camera (optimization)
- Knowledge cache means 2-second detection lag max
- Cannot use `currentTarget` or `cursorTarget` on AI (player-only)

## Mission Scripting Helpers

**Reveal enemy:**
```sqf
[_enemyUnit] call OpsRoom_fnc_revealEnemy;
[_enemyUnit, "Intel report"] call OpsRoom_fnc_revealEnemy;
```

**Hide enemy:**
```sqf
[_enemyUnit] call OpsRoom_fnc_hideEnemy;
```

**Reveal area:**
```sqf
private _enemies = allUnits select {side _x == east && _x distance _pos < 500};
{[_x, "Area compromised"] call OpsRoom_fnc_revealEnemy} forEach _enemies;
```

## Critical Reminders

- ✅ Edit Desktop master, never mission folder
- ✅ Buttons on Zeus display (312), not HUD
- ✅ No function wrappers in .sqf files
- ✅ Unified monitor replaces old monitorSelection
- ✅ Super concise docs, no fluff
- ✅ Test on VR, deploy to production terrain
- ✅ Systematic IDC ranges prevent conflicts
- ✅ Performance optimization from the start

---

**Last Updated:** January 2025 - v2.1 (Fog of War & Zeus Control)