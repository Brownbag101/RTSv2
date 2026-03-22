# Operations Room - Changelog

## v10.0 - Air Ops Expansion: Recon, Scheduler, Torpedo (March 2026)

### Recon System
- **High-Level Photo Recon** — 500m altitude, 2000m scan, +10% intel/location, 75% cap
- **Low-Level Photo Recon** — 300m altitude, 800m scan, +30% intel/location, 75% cap
- **Enemy Movement Spotting** — Circles target, reveals enemies to Zeus in real-time
- Intel stored on wing, delivered as report on landing
- Auto-RTB after 60s on station

### Mission Scheduler
- Automated mission scheduling from wing detail panel
- Three modes: delay (one-shot), interval (repeating), fixed daily hour
- Uses in-game time (daytime), not real-world time
- Validates fuel, pilots, crew, aircraft condition before each launch
- Auto-cancels on total aircraft loss or 3 consecutive crew failures
- Strike missions auto-RTB after attack run (scheduled only; manual strikes return to loiter)
- Landing hook reschedules repeating missions automatically

### Torpedo Attack
- New `strike_torpedo` mission type for Ground Attack wings
- Low-level approach: aircraft descends to ~30m, flies level toward target
- Torpedo released at 800m range via legitimate ARMA weapon fire (`fireAtTarget`)
- Torpedo drops to water/ground and self-propels toward target
- Immediate egress after release to clear blast zone
- Fallback level-guidance simulation if legit fire fails

### New Aircraft
- **Fairey Swordfish Mk.II** (`sab_nl_drone_swordfish`) — Anti-Shipping subcategory, GroundAttack type. Torpedo + bombs + guns. The "Stringbag".
- **Douglas C-47 Skytrain (RAF)** (`LIB_C47_RAF`) — Transport subcategory, Transport type.
- **Transport Wing** — New wing type with patrol mission

### Auto-Service System
- Toggle buttons in Hangar: AUTO-REPAIR, AUTO-REARM, AUTO-REFUEL
- Background monitor checks every 30s, services HANGARED aircraft automatically
- Uses existing resource costs (Steel, Aluminium, Fuel)
- Supports scheduled mission cycles: land → auto-service → relaunch

### Intel Rebalance
- Tier thresholds: 0→20→45→70→90 (was 0→25→50→75→100)
- Regular infantry: +2%/30s, cap 44%. Recon troops: +4%/30s, cap 69%.
- Photo recon: +10 or +30/pass, cap 75%. SOE agents: +6%/30s, cap 100%.

### RTB & Landing Fixes
- Two-phase RTB: MOVE waypoint to runway first, LAND only within 1500m
- Anti-eject system on all aircraft (GetOut EH forces crew back in)
- Dead pilot/crew cleanup in launch and scheduler
- First-launch doMove fix (doFollow cancels pending moves before boarding)

### Bug Fixes
- Fixed em-dash characters in strafe run `compile format` string causing SQF parse errors
- Fixed scheduled strike auto-RTB: checks `schedule.missionId` instead of `schedule.enabled` (one-shot schedules disable `enabled` before strike executes)
- One-shot schedules cleared after landing to prevent stale auto-RTB on manual strikes
- Create Wing dialog expanded for 5+ wing types
- Wing Mission dialog expanded and tightened for 9+ mission types

### New Files
- `air/fn_photoReconMonitor.sqf`, `air/fn_processReconPhotos.sqf`
- `air/fn_missionScheduler.sqf`, `air/fn_autoServiceMonitor.sqf`
- `gui/air/fn_openWingSchedule.sqf`
- `abilities/fn_airStrike_torpedoRun.sqf`
- `debug/fn_spawnTestAirCrew.sqf`

### New Location Types
- barracks, gun_emplacement, radar, fuel_depot, ammo_dump, bunker

---

## v8.0 - Storehouse & Inventory Improvements (February 2026)

### Storehouse System

New virtual equipment storage and distribution system. Multiple storehouses supported across the map, each with its own virtual inventory database. Equipment arrives via supply crates, gets absorbed into the database, and can be issued to individual soldiers.

- **Multiple storehouses** — Place Eden markers `opsroom_stores_1`, `opsroom_stores_2` etc. Set marker text for custom names. Falls back to `OpsRoom_SupplyPoint` if no markers found.
- **Storehouse grid** — STORES button (was ECONOMY) opens a selection grid showing all depots with item counts and nearby unit counts.
- **Interior view** — Three-panel layout: units in area (left), selected unit inventory (centre), storehouse virtual inventory (right).
- **Crate absorption** — Manual ABSORB CRATES button scans for physical crates/containers within depot radius, extracts all contents into the virtual database, deletes the crate. Maps ARMA classnames to equipment database IDs where possible.
- **Crate scanning** — Status panel shows detected crates in area with distance before absorption.
- **Issue to unit** — Select item from storehouse, click ISSUE TO UNIT. Properly equips uniforms (`forceAddUniform`), vests (`addVest`), headgear (`addHeadgear`), weapons, magazines, and generic items. Checks slot availability.
- **Deposit to store** — Select item from unit's inventory listbox (including items inside vest, uniform, backpack), click DEPOSIT TO STORE. Removes from correct container. Maps classnames to database keys.
- **Categorised inventory display** — Items from equipment database show under proper categories (WEAPONS, AMMUNITION, etc.). Raw classnames categorised by ARMA config: WEAPONS (FIELD), AMMUNITION (FIELD), EQUIPMENT (FIELD).
- **Dispatch integration** — Crate absorption sends ROUTINE dispatch with item counts.
- **"stores" location type** — Added to location types for tactical map integration.

### Equipment Database Additions

8 new items added to the master equipment database, covering a standard infantry loadout:

| ID | Display Name | Category | Subcategory |
|----|-------------|----------|-------------|
| `uk_bd40_uniform` | Battledress (BD40) Uniform | Uniforms | Combat Dress |
| `uk_webbing_green` | 1937 Pattern Webbing | Equipment | Vests |
| `uk_mk2_helmet` | Mk II Brodie Helmet | Equipment | Headgear |
| `10rnd_303` | .303 Rifle Clip (10rnd) | Ammunition | Rifle Ammo |
| `303_bren_ammo` | .303 Bren Magazine | Ammunition | MG Ammo |
| `no36_grenade` | No.36 Mills Bomb | Explosives | Grenades |
| `first_aid_kit` | First Aid Kit | Equipment | Medical |
| `bedford_mw_ammo` | Bedford MW (Ammo Truck) | Vehicles | Trucks |

All items have full research, production, and supply chain data.

### Inventory System Improvements

- **Config-based type detection** — Replaced brute-force equip detection with `CfgWeapons >> ItemInfo >> type` checks (801=uniform, 701=vest, 605=headgear). Eliminates "Tried to add item with type Headgear into slot of type Vest" errors.
- **Ground item categorisation** — Items on the ground now sort into UNIFORMS, VESTS, HEADGEAR, FACEWEAR, BACKPACKS, or ITEMS sections instead of a single flat "ITEMS" dump.
- **Auto-refresh** — Inventory rescans for nearby containers every 2 seconds while open. Dropped items now appear automatically without closing and reopening.
- **Headgear detection order** — Type detection now checks headgear before uniform/vest (cheapest to most destructive), preventing ARMA slot type errors.

### Button Layout (Updated)

```
RIGHT COLUMN
┌──────────────┐
│ INTELLIGENCE │ 9201 → Ops Map
├──────────────┤
│  DISPATCHES  │ 9203 → Dispatch Log
├──────────────┤
│  OPS ROOM    │ 9205 → Operations
├──────────────┤
│   STORES     │ 9207 → Storehouse Grid ★
├──────────────┤
│  POLITICS    │ 9209 → Not implemented
└──────────────┘
```

### New Files (14)

```
gui/storehouse/
├── dialog_storehouse_grid.hpp          (idd 11006)
├── dialog_storehouse_interior.hpp      (idd 11007)
├── fn_initStorehouses.sqf
├── fn_openStorehouseGrid.sqf
├── fn_populateStorehouseGrid.sqf
├── fn_openStorehouseInterior.sqf
├── fn_populateStorehouseUnits.sqf
├── fn_populateStorehouseUnitInv.sqf
├── fn_populateStorehouseInventory.sqf
├── fn_absorbCrates.sqf
├── fn_scanStorehouseCrates.sqf
└── fn_storehouseTransfer.sqf

docs/
└── STOREHOUSE_SYSTEM.md
```

### Modified Files (10)

- `config.hpp` — Added Storehouse class (10 functions)
- `init.sqf` — Added `initStorehouses` call
- `gui/displays.hpp` — Added 2 storehouse dialog includes
- `gui/fn_createButtonsOnZeus.sqf` — Renamed ECONOMY → STORES, wired 9207 to `openStorehouseGrid`
- `settings.sqf` — Added storehouse radius (50m) and max storehouses (8)
- `data/locationTypes.sqf` — Added "stores" location type
- `data/equipmentDatabase.sqf` — Added 8 new items (uniform, vest, helmet, ammo, grenade, medkit, truck)
- `zeus/fn_transferItem.sqf` — Config-based type detection replacing brute-force equip
- `zeus/fn_getContainerItems.sqf` — Ground items categorised by type instead of flat "ITEMS"
- `zeus/fn_openInventory.sqf` — Added auto-refresh loop (2s) for nearby container detection

### New Global Variables

```sqf
OpsRoom_Storehouses              // HashMap: storehouseId → storehouse data
OpsRoom_Settings_StorehouseRadius // Number: detection radius (default 50)
OpsRoom_Settings_MaxStorehouses   // Number: max storehouses (default 8)
```

### IDC Ranges

- 11600-11699: Storehouse grid dialog
- 11700-11899: Storehouse interior dialog

### Editor Setup

Place markers named `opsroom_stores_1`, `opsroom_stores_2` etc. in Eden Editor. Optionally set marker text for custom names. If no markers placed, a default storehouse is created at `OpsRoom_SupplyPoint`.

---

## v7.0 - Air Strike System (February 2026)

### Air Strike Ability

Radio Operators can now call in air strikes from friendly ground attack aircraft. Dynamically detects airborne aircraft registered in the equipment database, checks real weapon/ammo availability, and executes dive attack runs with dispatch comms throughout.

- **Radio Operator training course** — 45 min course grants `OpsRoom_Ability_AirStrike` qualification
- **Dynamic menu** — Only shows attack types that have armed aircraft currently airborne. Displays aircraft count per option.
- **4 attack types:**
  - **GUN RUN** — Strafing pass with cannons/MGs. Aircraft dives at target, fires in 3-second burst.
  - **ROCKET RUN** — Dive attack firing 4-8 rockets at target position.
  - **BOMB RUN** — Dive-bomb approach, releases ordnance at 400m with guided correction.
  - **STRAFE** — Combined guns + rockets in a single pass (Phase 1: guns, Phase 2: rockets). Only available when aircraft has both weapon types.
- **Aircraft selection** — Picks nearest airborne aircraft with correct weapon type and ammo.
- **Dive attack pattern** — Ported from Drongo's Air Ops. Aircraft nose dives at target with forced velocity vector, pitch/bank control, and gradual pull-up. Projectiles guided via Fired EH.
- **Full dispatch integration** — Messages at each phase: strike requested, inbound, cleared hot, weapons away, egress complete.
- **Draw3D target marker** — Red circle and label at target position during attack run, auto-cleaned after completion.
- **Cursor targeting** — Red-orange crosshair with Draw3D preview circle. ESC to cancel.
- **Automatic egress** — Aircraft flies away from target after attack, re-enables AI, climbs to 500m.

### Equipment Database: Aircraft Category

- **New category: Aircraft > Ground Attack** — Dedicated subcategory for strike aircraft.
- **New field: `attackCapabilities`** — Array of `["GUNS", "BOMBS", "ROCKETS"]` per aircraft entry. Determines which attack types are available.
- **DH.98 Mosquito FB Mk.VI** (`sab_fl_dh98`) — First ground attack entry. All three weapon types.

### Weapon Detection System

- **`fn_airStrike_hasWeaponType`** — Checks aircraft weapons via CfgWeapons parent classes and verifies ammo exists:
  - GUNS: Checks for `CannonCore`/`MGun` parents, validates `BulletCore`/`CannonCore` ammo.
  - BOMBS: Checks for `BombCore` parent class, fallback on high-hit/no-thrust detection.
  - ROCKETS: Checks for thrust > 0 with manoeuvrability == 0 (unguided rockets).

### New Files

| File | Purpose |
|------|----------|
| `zeus/abilities/fn_ability_airStrike.sqf` | Button click → dynamic menu |
| `abilities/fn_airStrike_getAvailable.sqf` | Scan airborne aircraft vs equipment DB |
| `abilities/fn_airStrike_hasWeaponType.sqf` | Weapon/ammo detection per type |
| `abilities/fn_startAirStrikeTargeting.sqf` | Cursor targeting mode |
| `abilities/fn_cancelAirStrikeTargeting.sqf` | Targeting cleanup |
| `abilities/fn_executeAirStrike.sqf` | Master dispatcher |
| `abilities/fn_airStrike_gunRun.sqf` | Gun strafing run |
| `abilities/fn_airStrike_bombRun.sqf` | Dive-bomb run |
| `abilities/fn_airStrike_rocketRun.sqf` | Rocket dive attack |
| `abilities/fn_airStrike_strafeRun.sqf` | Combined guns + rockets pass |
| `abilities/fn_airStrike_cleanup.sqf` | Draw3D marker cleanup |

### Modified Files

- `zeus/abilities/config.sqf` — Added `airStrike` ability config entry
- `config.hpp` — Registered 11 new functions (10 in Abilities, 1 in ZeusAbilities)
- `data/equipmentDatabase.sqf` — Added Aircraft > Ground Attack category with DH.98 Mosquito
- `data/trainingCourses.sqf` — Added Radio Operator training course
- `gui/regiments/fn_completeTraining.sqf` — Wired up `airStrike` qualification

---

## v6.0 - Dispatches, Capture Mechanics & Operation Markers (February 2026)

### Dispatch System

Centralised notification system replacing all systemChat/hint calls across the codebase. Every significant event now fires a styled dispatch popup on the Zeus display.

- **5 priority types** — ROUTINE (khaki), PRIORITY (amber), FLASH (red), ULTRA (purple), SOE (dark green)
- **Popup cards** — Slide-in cards on Zeus display 312 with coloured header, title, body, timestamp. FOCUS button moves Zeus camera to target. DISMISS button clears.
- **Auto-dismiss timers** — Configurable per type (15-30 seconds)
- **Queue system** — Multiple dispatches queue up, next shows after dismiss/timeout
- **Message log** — DISPATCHES button (9203) opens full history dialog. Unread badge on button. Newest first, click to focus.
- **Modular API** — Call from anywhere:
  ```sqf
  ["FLASH", "UNIT KILLED", "Pvt. Smith KIA", getPos _unit, _unit] call OpsRoom_fnc_dispatch;
  ```

### Location Ownership & Capture Mechanics

Strategic locations now have owners and can be captured through force superiority.

- **Ownership tracking** — Each location has owner (BRITISH/NAZI/NEUTRAL), previousOwner, capturedTime
- **Capture progress** — 0-100% based on attacker:defender ratio within capture radius
- **Force balance rules:**
  - 2:1+ attackers → progress advances (scales to 2x at 4:1+)
  - Unopposed attackers → double capture speed
  - 1:1 to 2:1 → CONTESTED stalemate
  - Defenders 2:1+ → progress bleeds back (half speed)
  - Empty location → slow bleed to 0
- **Capture times** — Vary by location type: Crossroads ~2min, Town ~5min, Port ~8min (at 2:1 ratio)
- **Map markers** — Colour-coded by owner: Green (British), Red (Nazi), Grey (Neutral), Yellow (Contested with ⚔ icon)
- **Dispatches on capture** — PRIORITY "LOCATION SECURED" on British capture, FLASH "LOCATION LOST" on loss (resets intel to 50%)
- **Background monitor** — 10-second cycle checking all locations

### Operation Draw3D Markers

Selecting units assigned to an active operation shows a 3D marker at the operation target.

- **Task-type icons** — Capture (green flag), Destroy (red), Recon (blue), Sabotage (orange), Raid (dark orange), default (gold objective)
- **Label format** — `Op: MINCEMEAT — CAPTURE (45%)`
- **Auto-cleanup** — Markers removed on deselection
- **Tracked via** `OpsRoom_OpMarkerIds` array for efficient cleanup

### Dispatch Retrofit

All user-facing systemChat and hint calls replaced with dispatch API calls:

| System | Events Now Using Dispatches |
|--------|---------------------------|
| Training | Training complete (ROUTINE) |
| Medals | Medal awarded (PRIORITY) |
| Research | Research started (ROUTINE), Research complete (PRIORITY) |
| Production | Production started/cancelled (ROUTINE), Production complete (ROUTINE), Production halted (PRIORITY), Factory built (PRIORITY) |
| Supply | Shipment dispatched (ROUTINE), Shipment delivered (PRIORITY) |
| Recruitment | Recruit enlisted (ROUTINE) |
| Operations | Operation created (PRIORITY, with target focus) |
| Intelligence | Intel tier changes (ROUTINE), Location identified (PRIORITY), Garrison assessed (PRIORITY), New location detected (PRIORITY) |
| Capture | Location secured (PRIORITY), Location lost (FLASH) |

### Button Layout (Updated)

```
RIGHT COLUMN
┌──────────────┐
│ INTELLIGENCE │ 9201 → Ops Map
├──────────────┤
│  DISPATCHES  │ 9203 → Dispatch Log ★
├──────────────┤
│  OPS ROOM    │ 9205 → Operations
├──────────────┤
│   ECONOMY    │ 9207 → Not implemented
├──────────────┤
│  POLITICS    │ 9209 → Not implemented
└──────────────┘
```

### Bug Fixes

- Fixed dispatch nil error when no focus position passed (defaulting to `[]` instead of `nil`)
- Fixed operation creation dispatch being unclickable behind wizard dialog (now closes dialog first)
- Fixed `fn_gatherIntel` using hardcoded `side west` — now uses `side player` for side-agnostic detection
- Fixed ARMA 3 `continue` keyword incompatibility in forEach loops (replaced with nested if/else)

### New Files (11)

```
gui/dispatches/
├── fn_initDispatches.sqf
├── fn_dispatch.sqf
├── fn_showDispatchPopup.sqf
├── fn_dismissDispatch.sqf
├── fn_focusDispatch.sqf
├── fn_updateDispatchBadge.sqf
├── fn_openDispatchLog.sqf
├── fn_populateDispatchLog.sqf
└── dialog_dispatches.hpp

gui/intelligence/
└── fn_captureMonitor.sqf

zeus/
└── fn_updateOperationMarkers.sqf
```

### Modified Files (18)

- `config.hpp` — Registered 10 new functions
- `init.sqf` — Added dispatch init, capture monitor start
- `settings.sqf` — Added dispatch type config, capture settings
- `gui/fn_createButtonsOnZeus.sqf` — Renamed DIPLOMACY→DISPATCHES, moved OPS ROOM
- `gui/displays.hpp` — Added dispatches dialog include
- `gui/intelligence/fn_initStrategicLocations.sqf` — Added ownership fields
- `gui/intelligence/fn_updateMapMarkers.sqf` — Colour by owner + contested
- `gui/intelligence/fn_showIntelCard.sqf` — Shows owner/contested status
- `gui/intelligence/fn_intelMonitor.sqf` — Retrofitted to dispatches
- `gui/intelligence/fn_gatherIntel.sqf` — Retrofitted to dispatches, fixed side check
- `gui/operations/fn_createOperation.sqf` — Retrofitted, closes dialog before dispatch
- `gui/production/fn_startProduction.sqf` — Retrofitted to dispatches
- `gui/production/fn_cancelProduction.sqf` — Retrofitted to dispatches
- `gui/production/fn_buildFactory.sqf` — Retrofitted to dispatches
- `gui/production/fn_productionMonitor.sqf` — Retrofitted to dispatches
- `gui/research/fn_startResearch.sqf` — Retrofitted to dispatches
- `gui/research/fn_completeResearch.sqf` — Retrofitted to dispatches
- `gui/supply/fn_shipItems.sqf` — Retrofitted to dispatches
- `gui/supply/fn_deliverItems.sqf` — Retrofitted to dispatches
- `gui/regiments/fn_completeTraining.sqf` — Retrofitted to dispatches
- `gui/regiments/fn_checkMedals.sqf` — Retrofitted to dispatches
- `gui/regiments/fn_spawnRecruit.sqf` — Retrofitted to dispatches
- `zeus/fn_unifiedZeusMonitor.sqf` — Hooked operation markers on selection change
- `zeus/fn_debugServiceRecord.sqf` — Added dispatch test + capture test buttons
- `data/locationTypes.sqf` — Added captureRadius, captureTime per type

### New Settings

```sqf
OpsRoom_Settings_CaptureMinRatio = 2.0;        // Attacker:defender ratio needed
OpsRoom_Settings_CaptureRateMultiplier = 1.0;  // Speed multiplier
OpsRoom_Settings_CaptureBleedRate = 0.5;       // Defender recapture rate
OpsRoom_Settings_DefaultOwner = "NAZI";        // Liberation scenario default
```

### IDC Ranges

- 8020: Dispatch Log dialog IDD
- 8021-8035: Dispatch log controls
- 9400-9410: Dispatch popup controls

---

## v5.0 - Unit Dossier & Service Records (February 2026)

### Unit Dossier Panel

Complete replacement for the old unit detail dialog. Now renders directly on Zeus display (312) like the inventory system — camera zooms to the soldier, panel slides in from the right.

- **Three-tab layout** with slide-in animations (ctrlCommit transitions):
  - **PROFILE** — Name, rank, role, time in theatre, health, status, current operation, combat record summary, decorations, promote/demote/training buttons
  - **SERVICE** — Operations participated (with status badges), dispatches, kill log, injury log, decorations with descriptions, rank history
  - **SKILLS** — All 9 combat skills with visual bar graphs (█░) and percentages, colour-coded by level, qualifications list, training status
- **Unit navigation arrows** — ◄ PREV / NEXT ► cycle through all alive units in the group with camera panning to each
- **Mutual exclusion** — Opening dossier closes inventory and vice versa. Auto-closes when selecting different units in Zeus.

### Service Record System

Central tracking of every soldier's career from the moment they spawn.

- **`OpsRoom_UnitServiceRecords`** — HashMap keyed by unit, tracking: kills, kill log (with grid refs), operations fought/completed/failed, dispatches, injuries, injury log, medals, time in theatre, current operation, promotion history
- **Kill tracking** — Mission-level `EntityKilled` event handler fires for every death, credits the killer if they have a service record. Uses `side group` comparison (not `side player`) for reliable side detection with Zeus.
- **Injury tracking** — `Hit` event handler on each registered unit. 30-second cooldown between entries. Records grid reference and active operation.
- **Operation writeback** — When operations are marked complete/failed, all units in assigned regiments get:
  - Operation added to their fought/completed/failed lists
  - Randomised dispatch ("Fought bravely in", "Showed exceptional courage during", "Survived the ill-fated", etc.)
  - Medal eligibility check
- **Current operation tagging** — When an operation is created, all units in assigned regiments have `currentOperation` set on their record.

### Medal System

7 medals with automatic eligibility checks (evaluated on dossier open and operation completion):

| Medal | Symbol | Criteria |
|-------|--------|----------|
| First Blood | † | 1 confirmed kill |
| Purple Heart | ♥ | Wounded in action |
| Service Medal | ★ | 5 operations |
| Gallantry Medal | ✦ | 10 confirmed kills |
| Iron Will | ◆ | Survived 3 wounds |
| Distinguished Service Cross | ✪ | 10 operations completed |
| Veteran | ▣ | 1 hour in theatre |

Medals display on both PROFILE and SERVICE tabs with descriptions. SystemChat notification on award.

### Debug Panel

Test tool for the service record system. Open from debug console:
```
[] call OpsRoom_fnc_debugServiceRecord;
```
Buttons: +1/+5/+10 Kills, +1 Wound, Add Fake Operation, Award ALL Medals, Dump Record to RPT, Reset Record. Auto-refreshes dossier when open.

### Debug Panel (expanded in v5.1)

Full testing toolkit accessible from dossier title bar (DEBUG button) or roster grid title bar.

- **Service Records** — +1/+5/+10 Kills, +1 Wound, Add Fake Operation (Complete), Award ALL Medals
- **Special Abilities** — 8 toggle buttons with ✓/✗ state: Suppressive Fire, Aimed Shot, Timebomb, Reconnoitre, Infiltrate, Assassinate, Heal, Repair. Grant ALL / Revoke ALL.
- **Skill Levels** — Set all 9 skills to LOW (10%), MED (50%), HIGH (80%), MAX (100%)
- **Utilities** — +100 ALL Resources, Heal to 100%, Dump to RPT, Reset Record, Close Panel

### Files Added (9 new files)

**Service Records (gui/regiments/):**
- `fn_initServiceRecords.sqf` — Medal definitions + EntityKilled mission EH
- `fn_registerUnitService.sqf` — Creates record + attaches Hit EH
- `fn_getServiceRecord.sqf` — Retrieves/creates record, updates time in theatre
- `fn_checkMedals.sqf` — Evaluates and awards medals
- `fn_writeOperationService.sqf` — Writes dispatches to all units on op complete/fail

**Dossier (zeus/):**
- `fn_openUnitDossier.sqf` — Panel creation, tabs, nav arrows, camera zoom
- `fn_closeDossier.sqf` — Cleanup all controls + state
- `fn_renderDossierTab.sqf` — Renders active tab content with animations
- `fn_debugServiceRecord.sqf` — Debug/cheat panel

### Files Modified (10 files)

- `config.hpp` — Registered 9 new functions (5 Regiments, 4 Zeus)
- `gui/regiments/fn_openRosterGrid.sqf` — Added DEBUG button to roster title bar
- `zeus/fn_openUnitDossier.sqf` — Added DEBUG button to dossier title bar
- `zeus/fn_closeDossier.sqf` — Also cleans up debug panel controls on close
- `init.sqf` — Added `initServiceRecords` call during startup
- `gui/regiments/fn_populateRosterGrid.sqf` — Clicking unit opens dossier (with groupId) instead of old dialog
- `gui/regiments/fn_spawnRecruit.sqf` — Calls `registerUnitService` on spawn
- `gui/regiments/fn_openTraining.sqf` — Back button returns to dossier
- `gui/regiments/fn_startTraining.sqf` — After starting training returns to dossier
- `gui/operations/fn_createOperation.sqf` — Sets `currentOperation` on all assigned units
- `gui/operations/fn_openOperationDetail.sqf` — Complete/Fail buttons call `writeOperationService`
- `missions/fn_spawnStartingRegiment.sqf` — Calls `registerUnitService` on each starting unit
- `zeus/fn_openInventory.sqf` — Closes dossier if open (mutual exclusion)
- `zeus/fn_unifiedZeusMonitor.sqf` — Auto-closes dossier on Zeus selection change

### IDC Ranges
- 9600-9609: Dossier frame, title, tabs, navigation arrows
- 9620-9759: Tab content (cleared and rebuilt per render)
- 9760-9779: Action buttons
- 9800-9849: Debug panel

### New Global Variables
```sqf
OpsRoom_UnitServiceRecords    // HashMap: str unit → service record hashmap
OpsRoom_MedalDefinitions      // Array: medal definition entries
OpsRoom_DossierOpen           // Bool: is dossier panel visible
OpsRoom_DossierUnit           // Object: currently viewed unit
OpsRoom_DossierGroupId        // String: group for navigation
OpsRoom_DossierUnitList       // Array: units in group for nav arrows
OpsRoom_DossierTab            // Number: active tab index (0-2)
```

---

## v4.0 - Intelligence & Operations Room (February 2026)

### Intelligence System

Full strategic intelligence layer. Mission makers place Eden markers, units gather intel by proximity.

- **Strategic Locations** — 10 location types: Factory, Port, Town, Airfield, Camp, Emplacement, Bridge, Crossroads, Rail Station, HQ
- **Eden Marker Convention** — Place markers named `opsroom_[type]_[number]` (e.g. `opsroom_factory_1`). Set marker text for custom names.
- **Tiered Intel System** — 6 tiers (0-5) based on intel percentage:
  - Tier 0 (0%): Unknown — nothing visible
  - Tier 1 (1-24%): Detected — "?" marker on map
  - Tier 2 (25-49%): Identified — type + production revealed
  - Tier 3 (50-74%): Observed — garrison strength (Light/Moderate/Heavy/Fortified)
  - Tier 4 (75-99%): Detailed — exact numbers, defences, reinforcements
  - Tier 5 (100%): Compromised — real-time intel, officer names (SOE)
- **Intel Gathering** — Background monitor (30s tick). Unit proximity + training determines rate:
  - Regular infantry: +2%/tick, caps at 49%
  - Recon-trained: +5%/tick, caps at 99%
  - SAS/SOE: +8%/tick, reaches 100%
  - Distance scaling: full <200m, half 200-400m, quarter 400-600m
- **Intel Decay** — Slow decay (-0.5%/tick) when no friendlies nearby. Never drops below tier thresholds.
- **Operational Map** — Near-full-screen RscMapControl dialog. Click locations to view intel cards. Status bar shows discovery counts.
- **Intel Cards** — Tier-gated information display. Map shrinks left, card appears right with smooth animation. Shows status, intel bar, grid ref, garrison, defences, available operations.
- **Map Markers** — Auto-created/updated based on intel tier. Enemy (red), friendly (blue), contested (yellow), destroyed (grey).
- **Destroyed Locations** — Shown as greyed-out icons on map.
- **Mission Maker Helper** — `OpsRoom_fnc_setLocationData` to configure garrison data from mission init.

### Operations Room

Task creation and management system. Create named operations targeting strategic locations.

- **Operations Dashboard** — Shows all operations sorted by status (active/completed/failed). Status bar with counts.
- **5-Step Creation Wizard:**
  1. Name — text input for operation codename
  2. Target — select from discovered locations (tier 1+)
  3. Task — contextual task types based on target type (e.g. Factory → Capture/Destroy/Recon/Sabotage)
  4. Assign — toggle regiments with unit strength display
  5. Confirm — summary review + create
- **Operation Detail View** — Status, progress bar, target intel, assigned forces, timeline. Mark complete/failed buttons.
- **15 Task Types** — Capture, Destroy, Reconnoitre, Sabotage, Blockade, Patrol, Liberate, Guard, Ambush, Raid, Suppress, Follow, Assassinate, Rescue, Locate.

### Button Changes

- INTELLIGENCE (9201) → Opens Operational Map
- DIPLOMACY renamed to OPS ROOM (9203) → Opens Operations Room

### New Files

```
data/locationTypes.sqf              — 10 location type definitions
gui/intelligence/                    — 9 files (dialog, map, intel card, monitors)
gui/operations/                      — 9 files (dashboard, wizard, detail view)
```

### Technical

- Added `RscMapControl` base class to ui_defines.hpp (type 101 with full subclass tree)
- Added `RscEdit` base class to ui_defines.hpp (type 2 for text input)
- IDD 8010 (Ops Map), 8011 (Operations), 8012 (Wizard), 8013 (Op Detail)
- IDC ranges: 11500-11599 (map), 11600-11699 (dashboard), 11700-11799 (wizard), 11800-11899 (detail)

---

## v3.0 - Research, Production & Supply Pipeline (February 2025)

### Major New Systems

Complete equipment pipeline: Research → Production → Supply. All three systems share a single **Equipment Database** as the source of truth. Add one entry, it appears in all menus automatically.

- **Equipment Database** (`data/equipmentDatabase.sqf`)
  - Single hashmap defining every item in the game
  - Each entry has: display name, category, subcategory, ARMA classname, research cost/time/tier/prereqs, build cost/time/batch size, supply/spawn info
  - Helper functions for querying by category, subcategory, research status
  - 5 starter items: Lee-Enfield, Bren Gun, .303 Ammo, Mills Bomb, Willys Jeep

- **Research System** (RESEARCH button)
  - 3-level drill-down: Categories → Subcategories → Research Tree
  - Category/subcategory grids reuse Regiment square layout
  - Research tree: tiered listbox with status icons (✓ done, → available, ✗ locked, ⏳ in progress)
  - Detail panel shows description, cost, time, prerequisite chain (green/red)
  - One active research at a time, costs Research Points
  - Background monitor auto-completes when timer expires

- **Production System** (PRODUCTION button)
  - Factory grid: starts with 1 factory, build up to 6 (costs 10 Steel, 5 Wood each)
  - Factory interior: categorised list of researched items with detail panel
  - Shows resource cost per batch with green/red affordability check
  - Continuous production: factory auto-starts next batch if resources available
  - Auto-halts with notification when resources run out
  - Completed batches added to Warehouse automatically
  - Cancel or change production at any time

- **Supply System** (SUPPLY button, was OPERATIONS)
  - 3-column layout: warehouse list, item details + quantity selector, shipment manifest
  - Build shipments of up to 5 item types with +/- quantity controls
  - Items merged if same type added twice
  - SHIP NOW dispatches shipment, removes from warehouse
  - Active shipments panel shows progress % and ETA
  - On delivery: crates spawn filled with correct items, vehicles spawn directly
  - Spawn location: editor-placed marker `OpsRoom_SupplyPoint`

### Left Button Bar (all 5 now functional)
| Button | IDC | Function |
|--------|-----|----------|
| REGIMENTS | 9101 | Regiment management |
| RECRUITMENT | 9103 | Recruitment & training |
| PRODUCTION | 9105 | Factory grid → production |
| RESEARCH | 9107 | Research tree |
| SUPPLY | 9109 | Warehouse → shipment → delivery |

### Files Added (31 new files)

**Data:**
- `data/equipmentDatabase.sqf`

**Research (gui/research/):**
- `dialog_research_categories.hpp` (idd 11000)
- `dialog_research_subcategories.hpp` (idd 11001)
- `dialog_research_tree.hpp` (idd 11002)
- `fn_openResearchCategories.sqf`
- `fn_openResearchSubcategories.sqf`
- `fn_openResearchTree.sqf`
- `fn_populateResearchTree.sqf`
- `fn_showResearchDetails.sqf`
- `fn_startResearch.sqf`
- `fn_completeResearch.sqf`
- `fn_researchMonitor.sqf`

**Production (gui/production/):**
- `dialog_factories.hpp` (idd 11003)
- `dialog_factory_interior.hpp` (idd 11004)
- `fn_openFactories.sqf`
- `fn_populateFactoryGrid.sqf`
- `fn_buildFactory.sqf`
- `fn_openFactoryInterior.sqf`
- `fn_populateProductionList.sqf`
- `fn_showProductionDetails.sqf`
- `fn_startProduction.sqf`
- `fn_cancelProduction.sqf`
- `fn_productionMonitor.sqf`

**Supply (gui/supply/):**
- `dialog_supply.hpp` (idd 11005)
- `fn_openSupply.sqf`
- `fn_populateWarehouse.sqf`
- `fn_showSupplyDetails.sqf`
- `fn_updateShipmentQueue.sqf`
- `fn_updateActiveShipments.sqf`
- `fn_shipItems.sqf`
- `fn_deliverItems.sqf`
- `fn_supplyMonitor.sqf`

### Files Modified
- `config.hpp` — Added Research (8), Production (9), Supply (8) function classes
- `gui/displays.hpp` — Added 6 dialog includes
- `gui/fn_createButtonsOnZeus.sqf` — Wired PRODUCTION, RESEARCH, SUPPLY buttons; renamed OPERATIONS → SUPPLY
- `init.sqf` — Loads equipment DB, initializes state variables, starts 3 monitor loops, creates first factory
- `settings.sqf` — Added production settings (max factories, build cost) and supply settings (delivery time, max slots)

### New Global Variables
```sqf
OpsRoom_EquipmentDB          // HashMap: itemId → item data
OpsRoom_ResearchCompleted    // Array: completed item IDs
OpsRoom_ResearchInProgress   // Array: [itemId, startTime, duration] or []
OpsRoom_Factories            // Array of factory hashmaps
OpsRoom_MaxFactories         // Number: max buildable (default 6)
OpsRoom_Warehouse            // HashMap: itemId → stock count
OpsRoom_ActiveShipments      // Array: [items, startTime, deliveryTime]
OpsRoom_ShipmentQueue        // Array: [itemId, qty] (session-only)
```

### New Settings
```sqf
OpsRoom_MaxFactories = 6;
OpsRoom_Settings_FactoryBuildCost = [["Steel", 10], ["Wood", 5]];
OpsRoom_Settings_DeliveryTime = 5;        // minutes
OpsRoom_Settings_MaxShipmentSlots = 5;
```

### IDC Ranges
- 11000-11002: Research dialog IDDs
- 11010-11061: Research dialog controls
- 11100-11141: Research grid squares
- 11200-11231: Factory grid squares
- 11300-11340: Factory interior controls
- 11400-11460: Supply dialog controls

### Editor Setup
Place a marker named `OpsRoom_SupplyPoint` where deliveries should spawn. Falls back to player position if missing.

---

## v2.2 - Follow Camera System (January 2025)

### New Features
- **Follow Camera System**: Cinematic camera tracking for selected units
  - Toggle button appears when single unit selected
  - Leap-frog positioning: camera stays 50m ahead of target
  - Smooth 8-second glide transitions when repositioning
  - Automatic vehicle/aircraft distance adjustment
  - Visual feedback (button turns green when active)
  - Auto-disables on unit death or Zeus close
  - Uses BIS_fnc_setCuratorCamera for professional smooth movement

### Technical Details
- Update rate: 1 second position checks
- Reposition transition: 8 seconds smooth glide
- Tracking update: 1 second smooth rotation
- Leap-frog behavior: repositions when target moves 50m away
- Uses BIS_fnc_setCuratorCamera for smooth camera control

### Files Added
- `zeus/fn_toggleFollowCamera.sqf`
- `zeus/fn_followCameraLoop.sqf`
- `docs/FOLLOW_CAMERA.md`

### Files Modified
- `zeus/abilities/config.sqf` - Added followCamera ability
- `config.hpp` - Registered new functions
- `zeus/fn_createAbilityButton.sqf` - Refined event handlers

---

## v2.1 - Zeus Control & Fog of War (January 2025)

### New Features
- **Fog of War System**: Progressive enemy visibility
  - Enemies hidden by default, revealed through detection
  - 3 detection methods: Zeus camera (200m), AI knowledge (300m), Line of sight (150m)
  - 30-second timeout before hiding old contacts
  - Optional chat notifications for detections
  - Performance optimized with spatial filtering and caching

- **Selective Control**: Prevent controlling enemy units
  - Blocks waypoint placement on enemy units
  - Visual feedback when enemies selected
  - Toggleable chat messages

- **Enhanced Unit Information Display**:
  - Shows combat mode (Fire at Will, Hold Fire, etc.)
  - Shows behaviour state (Safe, Aware, Combat, Stealth, Careless)
  - Shows target engagement status
  - Color-coded statuses
  - Group selection shows aggregate info

- **New Behaviour Button**: 6th standard command button
  - Control unit AI behaviour (Safe/Aware/Combat/Stealth/Careless)
  - Menu with 5 options and proper icons
  - Integrated with existing command system

### Helper Functions
- `OpsRoom_fnc_revealEnemy` - Manually reveal enemies to Zeus
- `OpsRoom_fnc_hideEnemy` - Manually hide enemies from Zeus
- Mission scripting integration for custom reveals

### Technical Improvements
- **Unified Zeus Monitor**: Single optimized loop replacing 3 separate systems
  - Staggered updates: 0.1s (selection), 0.5s (auto-detach), 1.0s (fog of war)
  - Spatial pre-filtering for enemies
  - Knowledge caching (2s intervals)
  - Friendly unit caching (5s intervals)
  - Adaptive sleep based on processing time

- **UI Improvements**:
  - Taller bottom bar (0.08 vs 0.06)
  - Centered command buttons
  - Taller unit info box to prevent text cutoff
  - All menu icons updated to proper Eden Editor icons

### Settings Added
```sqf
OpsRoom_Settings_SelectiveControl_Enabled
OpsRoom_Settings_SelectiveControl_ShowMessages
OpsRoom_Settings_FogOfWar_Enabled
OpsRoom_Settings_FogOfWar_DetectionRadius
OpsRoom_Settings_FogOfWar_ZeusDirectRadius
OpsRoom_Settings_FogOfWar_RemovalTimeout
OpsRoom_Settings_FogOfWar_ShowDetections
OpsRoom_Settings_FogOfWar_KnowledgeThreshold
OpsRoom_Settings_FogOfWar_LOSThreshold
```

### Files Added
- `zeus/fn_unifiedZeusMonitor.sqf`
- `zeus/fn_revealEnemy.sqf`
- `zeus/fn_hideEnemy.sqf`
- `zeus/fn_getBehaviourMenu.sqf`

### Files Modified
- `settings.sqf` - Added Zeus control settings
- `config.hpp` - Registered new functions
- `init.sqf` - Uses unified monitor
- `gui/displays.hpp` - Taller bottom bar
- `gui/fn_updateUnitInfo.sqf` - Enhanced info display
- `zeus/fn_createStandardButtons.sqf` - Added behaviour button
- `zeus/fn_updateStandardButtons.sqf` - Updated button visibility
- `zeus/fn_hideZeusUI.sqf` - Protected new button IDCs

### Performance
- Optimized for 100+ units
- <2% frame time overhead
- Spatial grid reduces distance checks by 80%
- Knowledge cache reduces queries by 50%

---

## v2.0 - Development Branch Restructure (January 2025)

### Major Changes
- Restructured into streamlined development branch
- New auto-discovery sync tool
- Simplified documentation (4 core docs)
- Removed outdated/redundant files

### Development Workflow
- Master branch: `Desktop/OpsRoom_Dev/`
- Sync tool: `Desktop/SYNC_OpsRoom.bat`
- Auto-detects missions in Documents\Arma 3\missions\
- Quick Sync (A) for code-only updates
- Full Sync (B) for complete setup

### Documentation
- NEW: QUICK_START.md - 3-step workflow
- NEW: EDITING_GUIDE.md - How to edit common things
- NEW: BUTTON_GUIDE.md - Complete button reference
- NEW: SYSTEM_REFERENCE.md - Technical API
- REMOVED: Old installation guides, examples, verbose docs

### System Status
- All features from v1.0 working
- Regiment/Group/Unit management complete
- Auto-detach/reattach system complete
- Zeus integration complete
- 10 side buttons working (1 implemented, 9 available)

---

## v1.0 - Production Ready (January 2025)

### Features
- Complete HUD system with top/bottom bars
- 10 clickable side buttons (5 left, 5 right)
- Resource tracking (9 resources)
- Unit information display
- Zeus UI integration
- Regiment management system
- Group management system
- Unit roster with grid view
- Unit detail dialogs
- Promotion/demotion system
- Captain selection system
- Auto-detach/reattach for Zeus
- Regroup button functionality

### Technical
- Buttons on Zeus display (312) for proper interaction
- RscTitles for HUD overlay
- British Army khaki green theme
- Modular function structure
- CfgFunctions registration
- SafeZone responsive positioning

### Known Limitations
- 9 buttons awaiting implementation
- Auto-reattach has timing edge cases
- No save/load system yet

---

## Development History

**Phase 1:** Basic HUD + Resources  
**Phase 2:** Button system (Zeus display solution)  
**Phase 3:** Regiment management  
**Phase 4:** Zeus integration  
**Phase 5:** Auto-detach/reattach  
**Phase 6:** Production ready  
**Phase 7:** Development branch restructure  
**Phase 8:** Zeus control & fog of war  
**Phase 9:** Follow camera system  
**Phase 10:** Research, Production & Supply pipeline  
**Phase 11:** Intelligence & Operations Room  
**Phase 12:** Unit Dossier & Service Records  
**Phase 13:** Dispatches, Capture Mechanics & Operation Markers  
**Phase 14:** Air Strike System  
**Phase 15:** Storehouse & Inventory Improvements  
**Phase 16:** Air Ops Expansion: Recon, Scheduler, Torpedo (current)