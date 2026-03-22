# System Reference

## Global Variables

### Resources
```sqf
OpsRoom_Resource_Wood
OpsRoom_Resource_Oil
OpsRoom_Resource_Aluminium
OpsRoom_Resource_Rubber
OpsRoom_Resource_Tungsten
OpsRoom_Resource_Steel
OpsRoom_Resource_Chromium
OpsRoom_Resource_Research_Points
OpsRoom_Resource_Manpower
```

### Data
```sqf
OpsRoom_Regiments           // HashMap of all regiments
OpsRoom_Groups              // HashMap of all groups
OpsRoom_AutoDetachEnabled   // Auto-detach toggle
OpsRoom_CurrentSpeed        // Current game speed multiplier
OpsRoom_KnownEnemies        // Array of detected enemies for fog of war
```

### Settings
```sqf
OpsRoom_Settings_InitialResources
OpsRoom_Settings_UnitInfoUpdateInterval
OpsRoom_Settings_ZeusCheckInterval
OpsRoom_Settings_ShowUnitInfo
OpsRoom_Settings_ShowResources
OpsRoom_Settings_AutoHideZeusUI
OpsRoom_Settings_ZeusInitDelay

// Zeus Control Settings
OpsRoom_Settings_SelectiveControl_Enabled       // Block enemy waypoints
OpsRoom_Settings_SelectiveControl_ShowMessages  // Chat feedback

// Fog of War Settings
OpsRoom_Settings_FogOfWar_Enabled               // Progressive enemy visibility
OpsRoom_Settings_FogOfWar_DetectionRadius       // Friendly detection range (300m)
OpsRoom_Settings_FogOfWar_ZeusDirectRadius      // Zeus camera reveal range (200m)
OpsRoom_Settings_FogOfWar_RemovalTimeout        // Timeout before hiding (30s)
OpsRoom_Settings_FogOfWar_ShowDetections        // Detection notifications
OpsRoom_Settings_FogOfWar_KnowledgeThreshold    // AI knowledge threshold (1.5)
OpsRoom_Settings_FogOfWar_LOSThreshold          // Line of sight threshold (0.2)

// Follow Camera Settings
OpsRoom_FollowCameraActive                      // Boolean - is follow active
OpsRoom_FollowCameraTarget                      // Object - current target unit
```

### Grenade Targeting (Temporary)
```sqf
// Active during grenade targeting mode only
OpsRoom_GrenadeTargeting_Active       // Boolean - targeting mode active
OpsRoom_GrenadeTargeting_Unit         // Object - unit throwing grenade
OpsRoom_GrenadeTargeting_Type         // String - grenade magazine classname
OpsRoom_GrenadeTargeting_CursorCtrl   // Control - cursor overlay control
OpsRoom_GrenadeTargeting_FrameHandler // Number - EachFrame handler ID
OpsRoom_GrenadeTargeting_ClickHandler // Number - MouseButtonDown handler ID
OpsRoom_GrenadeTargeting_ESCHandler   // Number - KeyDown handler ID
OpsRoom_GrenadeMenu_Unit              // Object - unit for menu actions
```

## Functions

### GUI Functions
```sqf
OpsRoom_fnc_initMainGUI              // Initialize GUI system
OpsRoom_fnc_createButtonsOnZeus      // Create side buttons
OpsRoom_fnc_updateResources          // Refresh resource display
OpsRoom_fnc_updateUnitInfo           // Refresh unit info display
OpsRoom_fnc_createDateTimeDisplay    // Create date/time display
OpsRoom_fnc_updateDateTime           // Update date/time text
OpsRoom_fnc_createButtons            // Legacy (don't use)
```

### Zeus Functions
```sqf
OpsRoom_fnc_hideZeusUI               // Configure Zeus UI
OpsRoom_fnc_autoDetachUnits          // Detach units from group
OpsRoom_fnc_autoReattachUnits        // Reattach units to group
OpsRoom_fnc_unifiedZeusMonitor       // Unified monitor (selection + fog of war + selective control)
OpsRoom_fnc_monitorSelection         // Legacy (replaced by unified monitor)
OpsRoom_fnc_createRegroupButton      // Create regroup button (legacy)
OpsRoom_fnc_reformGroup              // Reform group
OpsRoom_fnc_getPhoneticName          // Get phonetic callsign
OpsRoom_fnc_createSpeedControls      // Create speed control buttons
OpsRoom_fnc_getUnitAbilities         // Get available abilities for units
OpsRoom_fnc_createAbilityButton      // Create context ability button
OpsRoom_fnc_updateContextButtons     // Update right-side ability buttons
OpsRoom_fnc_createStandardButtons    // Create standard command buttons
OpsRoom_fnc_updateStandardButtons    // Show/hide standard buttons
OpsRoom_fnc_executeStandardCommand   // Execute standard command
OpsRoom_fnc_createButtonMenu         // Create expandable menu
OpsRoom_fnc_closeButtonMenu          // Close active menu
OpsRoom_fnc_getStanceMenu            // Get stance menu options
OpsRoom_fnc_getCombatModeMenu        // Get combat mode options
OpsRoom_fnc_getSpeedModeMenu         // Get speed mode options
OpsRoom_fnc_getFormationMenu         // Get formation options
OpsRoom_fnc_getBehaviourMenu         // Get behaviour options
OpsRoom_fnc_revealEnemy              // Manually reveal enemy to Zeus
OpsRoom_fnc_hideEnemy                // Manually hide enemy from Zeus
OpsRoom_fnc_toggleFollowCamera       // Toggle follow camera on/off
OpsRoom_fnc_followCameraLoop         // Main follow camera loop
```

### Ability Functions
```sqf
// Grenade System
OpsRoom_fnc_ability_grenade          // Main grenade ability entry
OpsRoom_fnc_getGrenadeMenu           // Get grenade menu items
OpsRoom_fnc_enterGrenadeTargeting    // Enter targeting mode
OpsRoom_fnc_calculateGrenadeArc      // Calculate ballistic arc
OpsRoom_fnc_throwGrenade             // Execute grenade throw
OpsRoom_fnc_cancelGrenadeTargeting   // Cancel targeting mode
```

### Mission Functions
```sqf
OpsRoom_fnc_createMissionIntro       // Create cinematic intro
OpsRoom_fnc_spawnStartingRegiment    // Spawn initial units
OpsRoom_fnc_createClearAreaTask      // Create area-clearing task
OpsRoom_fnc_checkAreaClear           // Check if area is clear
OpsRoom_fnc_create3DMarker           // Create 3D objective marker
OpsRoom_fnc_remove3DMarker           // Remove 3D marker
```

### Regiment Functions
```sqf
OpsRoom_fnc_initRegiments            // Initialize regiment system
OpsRoom_fnc_openRegiments            // Open regiments dialog
OpsRoom_fnc_populateRegimentGrid     // Populate regiment grid
OpsRoom_fnc_getAvailableMajors       // Get units for major rank
OpsRoom_fnc_showAddRegiment          // Show add regiment UI
OpsRoom_fnc_createRegiment           // Create new regiment
OpsRoom_fnc_openGroups               // Open groups dialog
OpsRoom_fnc_populateGroupGrid        // Populate group grid
OpsRoom_fnc_getAvailableCaptains     // Get units for captain rank
OpsRoom_fnc_showAddGroup             // Show add group UI
OpsRoom_fnc_createGroup              // Create new group
OpsRoom_fnc_openRosterGrid           // Open roster grid dialog
OpsRoom_fnc_populateRosterGrid       // Populate roster grid
OpsRoom_fnc_openUnitDetail           // Open unit detail dialog
OpsRoom_fnc_populateUnitDetail       // Populate unit detail
OpsRoom_fnc_promoteUnit              // Promote unit rank
OpsRoom_fnc_demoteUnit               // Demote unit rank
OpsRoom_fnc_openCaptainSelect        // Open captain selection
OpsRoom_fnc_populateCaptainGrid      // Populate captain grid
```

## Grenade Ability System

### Overview
Zeus-based grenade throw ability with visual targeting, ballistic arc preview, and expandable menu for multiple grenade types.

### Grenade Detection
Grenades detected by magazine type 256 AND ammo inheritance:
```sqf
private _type = getNumber (configFile >> "CfgMagazines" >> _magazine >> "type");
private _ammo = getText (configFile >> "CfgMagazines" >> _magazine >> "ammo");
private _parents = [configFile >> "CfgAmmo" >> _ammo, true] call BIS_fnc_returnParents;

// Valid if type 256 AND inherits from GrenadeHand or GrenadeBase
if (_type == 256 && {"GrenadeHand" in _parents || "GrenadeBase" in _parents}) then {
    // This is a grenade
};
```

This filters out pistol magazines (e.g., `JMSSA_6Rnd_455`) that have type 256 but are not grenades.

### Supported Grenades
- **HE Grenades:** HandGrenade, MiniGrenade, JMSSA_MillsBomb_HandGrenade, fow_e_no36mk1, LIB_MillsBomb (40m range)
- **Smoke:** SmokeShell (all colors) (50m range)
- **Chemlight:** Chemlight (all colors) (50m range)

### Visual Targeting Mode
When activated:
1. **Cursor:** Green crosshair when in range, red when too far
2. **Arc Preview:** Real-time ballistic trajectory using physics
3. **Impact Marker:** Shows landing point
4. **Controls:** Left click to throw, ESC to cancel

### Arc Calculation
Uses realistic ballistic physics:
- **Velocity:** 18 m/s (reduced for accuracy)
- **Angle:** 60° (steep for high arc)
- **Gravity:** 9.81 m/s²
- **Sample Points:** 20 points along trajectory
- **Ground Detection:** Arc stops at Z=0 (visual ground level)

### Throw Timing
Animation sequence (4.5 seconds total):
1. **0.3s** - Face target (doWatch)
2. **1.2s** - Start animation (`AwopPercMstpSgthWnonDnon_start`)
3. **1.5s** - Throw animation (`AwopPercMstpSgthWnonDnon_throw`)
4. **1.5s** - Additional wait
5. **Grenade spawns at 4.5s** - createVehicle with velocity
6. **0.5s** - End animation (`AwopPercMstpSgthWnonDnon_end`)

### Event Handlers
Three handlers active during targeting:
- **EachFrame:** Updates cursor color, calculates/draws arc
- **MouseButtonDown:** Left click to throw
- **KeyDown:** ESC (code 1) to cancel

All cleaned up by `fn_cancelGrenadeTargeting.sqf`.

### Coordinate Systems
**Critical for VR map compatibility:**
- VR terrain is at 2m ASL (Above Sea Level)
- Visual ground appears at 0m ASL
- Arc uses Z=0 for start/end positions to match visual ground
- Real terrains will automatically use correct terrain heights

### Usage Example
```sqf
// Manually trigger (unit must have grenades)
[_unit, "JMSSA_MillsBomb_HandGrenade"] call OpsRoom_fnc_enterGrenadeTargeting;

// Cancel targeting
call OpsRoom_fnc_cancelGrenadeTargeting;

// Get available grenade types
private _grenades = [];
{
    private _type = getNumber (configFile >> "CfgMagazines" >> _x >> "type");
    private _ammo = getText (configFile >> "CfgMagazines" >> _x >> "ammo");
    if (_type == 256) then {
        private _cfg = configFile >> "CfgAmmo" >> _ammo;
        private _parents = [_cfg, true] call BIS_fnc_returnParents;
        if ("GrenadeHand" in _parents || "GrenadeBase" in _parents) then {
            _grenades pushBackUnique _x;
        };
    };
} forEach (magazines _unit);
```

## Fog of War Usage

### Automatic Detection
Enemies revealed when:
1. Zeus camera within 200m (Zeus observation)
2. Friendly unit knows about enemy (knowledge > 1.5) within 300m
3. Friendly has line of sight within 150m

Enemies hidden after 30 seconds if not re-detected.

### Manual Control
```sqf
// Reveal enemy manually
[_enemyUnit] call OpsRoom_fnc_revealEnemy;
[_enemyUnit, "Intel report"] call OpsRoom_fnc_revealEnemy;

// Hide enemy manually
[_enemyUnit] call OpsRoom_fnc_hideEnemy;

// Reveal all enemies in area
private _enemies = allUnits select {side _x == east && _x distance _pos < 500};
{[_x, "Area compromised"] call OpsRoom_fnc_revealEnemy} forEach _enemies;
```

## Control IDs

### HUD Display
```sqf
9001-9007  // Backgrounds and frames
9010       // Resource display
9020       // Unit info display
```

### Main Side Buttons (Zeus Display)
```sqf
// Left side buttons (Background, Button pairs)
9100, 9101  // Button 1 - Regiments
9102, 9103  // Button 2 - Research
9104, 9105  // Button 3 - Production
9106, 9107  // Button 4 - Diplomacy
9108, 9109  // Button 5 - Intelligence

// Right side buttons
9200, 9201  // Button 6 - Territory
9202, 9203  // Button 7 - Naval
9204, 9205  // Button 8 - Air Force
9206, 9207  // Button 9 - Settings
9208, 9209  // Button 10 - Help
```

### Standard Command Buttons (Bottom Left)
```sqf
9300, 9301  // Stance button
9302, 9303  // Combat Mode button
9304, 9305  // Speed Mode button
9306, 9307  // Formation button
9308, 9309  // Behaviour button
9310, 9311  // Regroup button (conditional)
```

### Date/Time & Speed Controls (Top Left)
```sqf
9320       // Date/time background
9321       // Date/time text
9330       // Speed controls background
9331       // Speed button: Pause (0.1x)
9332       // Speed button: Slow (0.5x)
9333       // Speed button: Normal (1x)
9334       // Speed button: Fast (2x)
9335       // Speed button: Very Fast (4x)
```

### Context-Aware Ability Buttons (Bottom Right)
```sqf
9350-9389  // Dynamic ability buttons (up to 20 abilities)
           // Created/destroyed based on unit selection
           // Examples: Grenade, Suppress, Repair, Heal
```

### Expandable Menu Buttons
```sqf
9400-9449  // Menu items for standard button menus
           // Stance menu (4 options)
           // Combat mode menu (5 options)
           // Speed mode menu (3 options)
           // Formation menu (9 options)
           // Behaviour menu (5 options)
           // Grenade menu (variable options)
```

### Regiment Dialogs
```sqf
// Regiment dialog
10001       // Regiment grid
10002       // Add regiment button
10003       // Back button

// Group dialog
10101       // Group grid
10102       // Add group button
10103       // Back button

// Roster grid dialog
10201       // Roster grid
10202       // Back button
10203       // Promote button
10204       // Demote button

// Unit detail dialog
10301       // Various controls

// Captain select dialog
10401       // Captain grid
10402       // Select button
10403       // Cancel button
```

## Display References

Get HUD display:
```sqf
private _display = uiNamespace getVariable ["OpsRoom_HUD_Display", displayNull];
```

Get Zeus display:
```sqf
private _display = findDisplay 312;
```

Check display exists:
```sqf
if (!isNull _display) then {
    // Do something
};
```

## Common Patterns

### Update Resources
```sqf
OpsRoom_Resource_Wood = OpsRoom_Resource_Wood + 100;
[] call OpsRoom_fnc_updateResources;
```

### Change Game Speed
```sqf
setTimeMultiplier 2;  // 2x speed
OpsRoom_CurrentSpeed = 2;  // Update tracker
```

### Get Current Date/Time
```sqf
private _date = date;  // [year, month, day, hour, minute]
private _dayTime = dayTime;  // Hours as decimal (14.5 = 14:30)
```

### Get Selected Zeus Units
```sqf
private _curator = getAssignedCuratorLogic player;
private _selected = curatorSelected select 0;
```

### Check If Unit Is Zeus
```sqf
private _isZeus = !isNull (getAssignedCuratorLogic player);
```

### Create Dialog
```sqf
createDialog "Regiment_Dialog";
```

### Get Control From Display
```sqf
private _display = findDisplay 10000;
private _ctrl = _display displayCtrl 10001;
```

### Set Control Text
```sqf
_ctrl ctrlSetText "New text";
```

### Get Grid Selected Row
```sqf
private _grid = _display displayCtrl 10001;
private _selectedRow = lbCurSel _grid;
```

## File Structure

```
OpsRoom/
├── config.hpp              // Function registration + includes
├── init.sqf                // System initialization
├── settings.sqf            // Default values
├── gui/
│   ├── ui_defines.hpp      // Colors, fonts, base classes
│   ├── displays.hpp        // HUD layout + dialog includes
│   ├── fn_initMainGUI.sqf
│   ├── fn_createButtonsOnZeus.sqf
│   ├── fn_updateResources.sqf
│   ├── fn_updateUnitInfo.sqf
│   └── regiments/          // All regiment system files
├── zeus/
│   ├── fn_hideZeusUI.sqf
│   ├── fn_autoDetachUnits.sqf
│   ├── fn_autoReattachUnits.sqf
│   ├── fn_unifiedZeusMonitor.sqf
│   ├── fn_monitorSelection.sqf (legacy)
│   ├── fn_reformGroup.sqf
│   ├── fn_createRegroupButton.sqf
│   ├── fn_getPhoneticName.sqf
│   ├── fn_revealEnemy.sqf
│   ├── fn_hideEnemy.sqf
│   └── abilities/
│       ├── config.sqf           // Ability definitions
│       ├── fn_ability_grenade.sqf
│       ├── fn_getGrenadeMenu.sqf
│       ├── fn_enterGrenadeTargeting.sqf
│       ├── fn_calculateGrenadeArc.sqf
│       ├── fn_throwGrenade.sqf
│       └── fn_cancelGrenadeTargeting.sqf
├── data/
│   ├── fn_initRegiments.sqf
│   └── regimentNames.sqf
└── docs/
    ├── QUICK_START.md
    ├── EDITING_GUIDE.md
    ├── BUTTON_GUIDE.md
    ├── SYSTEM_REFERENCE.md (this file)
    └── CHANGELOG.md
```

## Initialization Sequence

1. Mission description.ext loads config.hpp
2. config.hpp registers functions via CfgFunctions
3. config.hpp includes ui_defines.hpp and displays.hpp
4. Mission init.sqf calls OpsRoom\init.sqf
5. OpsRoom\init.sqf loads settings
6. Resources initialized
7. Regiments initialized
8. GUI initialized (HUD displayed)
9. Zeus UI configured and hidden
10. Unified Zeus monitor started (selection + fog of war + selective control)
11. Mission intro displayed (if enabled)
12. Mission objectives initialized

## Event Flow

### Unified Zeus Monitor Loop
**Update intervals:**
- 0.1s: Selection tracking + selective control (waypoint blocking)
- 0.5s: Auto-detach system
- 1.0s: Fog of war detection

**Optimizations:**
- Spatial filtering (only check enemies near Zeus camera)
- Knowledge caching (2 second cache)
- Friendly unit caching (5 second cache)
- Adaptive sleep based on processing time

### GUI Update Loop
- Unit info updates every 0.5 seconds
- Checks selected units in Zeus
- Shows: Name, Rank, Health, Combat Mode, Behaviour, Target
- Group selection shows: Group Name, Count, Status, Combat Mode, Behaviour

### Auto-Detach/Reattach
- Monitors unit selection continuously
- Detaches when individual unit selected
- Reattaches after 1 second delay
- Creates regroup button when detached

## Color Definitions

Defined in `gui/ui_defines.hpp`:

```cpp
COLOR_MAIN_BG       // Main background
COLOR_ELEMENT_BG    // Element backgrounds
COLOR_BORDER        // Border/frame color
COLOR_TEXT          // Text color
COLOR_BUTTON_BG     // Button background
COLOR_BUTTON_HOVER  // Button hover state
COLOR_BACKGROUND    // Dialog background
COLOR_HEADER        // Dialog header
COLOR_BUTTON        // Dialog button
COLOR_BUTTON_ACTIVE // Dialog button active
```

Format: `{Red, Green, Blue, Alpha}` (0.0 to 1.0)

## SafeZone Coordinates

All positioning uses safezone variables:

```sqf
safezoneX  // Left edge
safezoneY  // Top edge
safezoneW  // Width
safezoneH  // Height
```

Center horizontally:
```sqf
x = safezoneX + (safezoneW / 2) - (width / 2);
```

Center vertically:
```sqf
y = safezoneY + (safezoneH / 2) - (height / 2);
```

## Intelligence System

### Data Structures

```sqf
OpsRoom_LocationTypes    // HashMap - location type definitions (loaded from data/locationTypes.sqf)
OpsRoom_StrategicLocations  // HashMap - all discovered/undiscovered locations
```

### Location Data Keys

```sqf
"loc_factory_1" → HashMap [
    "id", "name", "type", "pos", "markerName",
    "intelPercent" (0-100), "intelTier" (0-5), "discovered" (bool),
    "produces", "garrisonStrength", "garrisonCount",
    "reinforcements", "defences", "officerName", "officerRank",
    "status" (enemy/friendly/contested/destroyed),
    "taskTypes" (array), "mapMarkerCreated", "mapMarkerName"
]
```

### Eden Marker Convention

Place markers named `opsroom_[type]_[number]` in Eden Editor.  
Valid types: factory, port, town, airfield, camp, emplacement, bridge, crossroads, rail, hq.  
Set marker text for custom name. Leave blank for auto-name.

### Mission Maker Functions

```sqf
// Set garrison data after initStrategicLocations runs
["loc_factory_1", "garrisonStrength", "Heavy"] call OpsRoom_fnc_setLocationData;
["loc_factory_1", "garrisonCount", 45] call OpsRoom_fnc_setLocationData;
["loc_factory_1", "reinforcements", "2 platoons from Camp 3"] call OpsRoom_fnc_setLocationData;
["loc_factory_1", "status", "destroyed"] call OpsRoom_fnc_setLocationData;
```

### Intel Functions

```sqf
[] call OpsRoom_fnc_initStrategicLocations;  // Scan Eden markers
[percent] call OpsRoom_fnc_getIntelLevel;     // Returns tier 0-5
[locId] call OpsRoom_fnc_gatherIntel;         // Calculate intel gain
[] call OpsRoom_fnc_intelMonitor;             // Background loop (30s)
[locId] call OpsRoom_fnc_updateMapMarkers;    // Create/update markers
[] call OpsRoom_fnc_openOpsMap;               // Open map dialog
[locId] call OpsRoom_fnc_showIntelCard;       // Show intel card
```

### Files

```
data/locationTypes.sqf                    - Type definitions
gui/intelligence/dialog_opsmap.hpp        - Map dialog (IDD 8010)
gui/intelligence/fn_initStrategicLocations.sqf
gui/intelligence/fn_getIntelLevel.sqf
gui/intelligence/fn_gatherIntel.sqf
gui/intelligence/fn_intelMonitor.sqf
gui/intelligence/fn_updateMapMarkers.sqf
gui/intelligence/fn_openOpsMap.sqf
gui/intelligence/fn_showIntelCard.sqf
gui/intelligence/fn_setLocationData.sqf
```

## Operations Room

### Data Structure

```sqf
OpsRoom_Operations       // HashMap - all operations
OpsRoom_OperationNextID  // NUMBER - auto-increment ID

"op_1" → HashMap [
    "id", "name", "targetId", "targetName", "targetType",
    "taskType", "regiments" (array of IDs), "regimentNames" (array),
    "status" (planning/active/complete/failed),
    "progress" (0-100), "created" (time), "notes"
]
```

### Operation Functions

```sqf
[] call OpsRoom_fnc_openOperations;        // Open dashboard
[] call OpsRoom_fnc_populateOperations;    // Fill operation list
[] call OpsRoom_fnc_openOperationWizard;   // Start creation wizard
[step] call OpsRoom_fnc_wizardShowStep;    // Render wizard step 1-5
[] call OpsRoom_fnc_createOperation;       // Create from wizard state
[opId] call OpsRoom_fnc_openOperationDetail; // View single operation
```

### Task Types by Target

| Target | Available Tasks |
|--------|----------------|
| Factory | Capture, Destroy, Reconnoitre, Sabotage |
| Port | Capture, Destroy, Reconnoitre, Blockade |
| Town | Capture, Reconnoitre, Patrol, Liberate |
| Airfield | Capture, Destroy, Reconnoitre |
| Camp | Destroy, Reconnoitre, Raid |
| Emplacement | Destroy, Reconnoitre, Suppress |
| Bridge | Capture, Destroy, Guard, Reconnoitre |
| Crossroads | Patrol, Guard, Ambush, Reconnoitre |
| Rail Station | Capture, Destroy, Reconnoitre, Sabotage |
| HQ | Capture, Destroy, Reconnoitre, Raid |

### Files

```
gui/operations/dialog_operations.hpp       - Dashboard (IDD 8011)
gui/operations/dialog_operation_wizard.hpp - Wizard (IDD 8012)
gui/operations/dialog_operation_detail.hpp - Detail (IDD 8013)
gui/operations/fn_openOperations.sqf
gui/operations/fn_populateOperations.sqf
gui/operations/fn_openOperationWizard.sqf
gui/operations/fn_wizardShowStep.sqf
gui/operations/fn_createOperation.sqf
gui/operations/fn_openOperationDetail.sqf
```

## Technical Notes

- Buttons MUST be on Zeus display (312), not HUD
- RscTitles for passive display only
- Functions auto-loaded via CfgFunctions
- Don't wrap functions in `functionName = {}`
- Use cutRsc for RscTitles, createDialog for dialogs
- Store display references in uiNamespace
- Zeus display persists across open/close
- Unified monitor replaces old monitorSelection
- Fog of war uses OpsRoom_KnownEnemies global array
- Selective control prevents waypoint placement on enemies
- Grenade targeting uses global variables (cleaned up on cancel/throw)
- Grenade arc calculations use Z=0 for VR compatibility
- Grenade detection filters pistol mags by checking ammo inheritance