# Mission System - Quick Reference

## Mission 1: Secure Landing Zone

### Overview
Auto-spawns 1st Essex Regiment (10 units) on mission start. Task: Clear OPFOR within 500m.

### Files Created
```
OpsRoom/missions/
├── fn_spawnStartingRegiment.sqf  - Spawns 10 British infantry
├── fn_checkAreaClear.sqf          - Checks for OPFOR in radius
├── fn_createClearAreaTask.sqf     - Creates task & monitors completion
├── fn_createEngineersTask.sqf     - Mission 2 placeholder
└── mission1_init.sqf              - Mission 1 initialization
```

### Files Modified
- `OpsRoom/init.sqf` - Added mission system call
- `OpsRoom/settings.sqf` - Added mission settings
- `OpsRoom/config.hpp` - Registered mission functions

### Settings (in settings.sqf)
```sqf
OpsRoom_Settings_EnableMission1 = true;  // Toggle mission on/off
OpsRoom_Settings_Mission1_ClearRadius = 500;  // meters
OpsRoom_Settings_Mission1_CheckInterval = 10;  // seconds
```

### Unit Composition (1st Essex Regiment)
1. JMSSA_gb_rifle_serg → **MAJOR** (CO)
2. JMSSA_gb_rifle_cpl
3. JMSSA_gb_rifle_rifle
4. JMSSA_gb_rifle_rifle
5. JMSSA_gb_rifle_rifle
6. JMSSA_gb_rifle_cpl
7. JMSSA_gb_rifle_rifle
8. JMSSA_gb_rifle_mg
9. JMSSA_gb_rifle_mg
10. JMSSA_gb_rifle_serg

### Spawn Details
- **Location:** 20m from player, random direction
- **Formation:** LINE
- **Zeus:** Auto-added to curator (checks z1 → player curator → all curators)
- **Regiment:** "The Essex Regiment" with "1st Essex Regiment" group

### Task Flow
1. Mission starts → OpsRoom initializes
2. mission1_init.sqf runs
3. Spawns 10 units → Forms group → Adds to Zeus
4. Creates regiment in system (1st Essex)
5. Creates task "Secure Landing Zone"
6. Creates Zeus marker at spawn position
7. Monitors every 10 seconds
8. Area clear for 10+ seconds → Task completes
9. Shows HintC message
10. Auto-triggers Mission 2

### Task Completion
**HintC Message:**
```
LANDING ZONE SECURED
The 1st Essex Regiment has cleared the immediate area.
You may now call in engineer support to establish your base.
```

**Triggers:** Mission 2 (placeholder - "Call in Engineers")

### Zeus Features
- Static marker at spawn position: "SECURE AREA"
- Blue objective icon
- Visible in Zeus interface
- Deleted on task completion

### Disable Mission
In mission's init.sqf BEFORE calling OpsRoom:
```sqf
OpsRoom_Settings_EnableMission1 = false;
[] execVM "OpsRoom\init.sqf";
```

### Future Missions
- Mission 2: Engineer support (placeholder created)
- Mission 3-5: To be implemented
- Pattern established for additional missions

### Debug Logs
All actions logged with `[OpsRoom Mission1]` prefix in RPT file.

### Portability
✅ Fully portable - just copy OpsRoom folder
✅ No mission.sqm dependencies
✅ Works with or without existing units
✅ Toggle-able via settings
✅ Self-contained task system
