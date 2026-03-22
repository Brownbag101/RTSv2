# Operations Room - Quick Start

## 3-Step Workflow

```
1. EDIT   → Files in Desktop/OpsRoom_Dev/OpsRoom/
2. SYNC   → Run SYNC_OpsRoom.bat (Quick Sync)
3. TEST   → Open ARMA 3 → Reload mission → Press Y
```

## First Time Setup

**Mission already exists?**
Run `SYNC_OpsRoom.bat` → Select mission → Press B (Full Sync)

**New mission?**
1. Create mission in Eden Editor
2. Save it
3. Run `SYNC_OpsRoom.bat` → Select mission → Press B (Full Sync)
4. Done!

## Common Edits

| What | File | Section |
|------|------|---------|
| Button labels | `gui\fn_createButtonsOnZeus.sqf` | Line ~15-30 |
| Button actions | `gui\fn_createButtonsOnZeus.sqf` | Line ~85+ |
| Colors | `gui\ui_defines.hpp` | Line 1-15 |
| Resources | `settings.sqf` | Line 10-20 |

## Files You'll Edit Most

- `gui/fn_createButtonsOnZeus.sqf` - Buttons (labels + actions)
- `gui/ui_defines.hpp` - Colors and styling
- `settings.sqf` - Default values

## Testing

1. Make change in OpsRoom_Dev
2. Run SYNC_OpsRoom.bat
3. Enter mission number → Press A (Quick Sync)
4. In ARMA 3: Preview mission → Press Y for Zeus
5. Check if changes work

## When Sync Fails

- Check you saved files before syncing
- Verify mission exists in Documents\Arma 3\missions\
- Run Full Sync (B) if Quick Sync fails

## Strategic Locations (Intelligence System)

To use the Intel/Ops Room systems, place Eden markers:

1. Open Eden Editor
2. Place markers named `opsroom_[type]_[number]`
3. Valid types: `factory`, `port`, `town`, `airfield`, `camp`, `emplacement`, `bridge`, `crossroads`, `rail`, `hq`
4. Optionally set marker text for a custom name (e.g. "Munitions Factory")
5. Configure garrison data in mission init.sqf (optional):

```sqf
["loc_factory_1", "garrisonStrength", "Heavy"] call OpsRoom_fnc_setLocationData;
["loc_factory_1", "garrisonCount", 45] call OpsRoom_fnc_setLocationData;
```

## Button Map

| Left | Right |
|------|-------|
| REGIMENTS | INTELLIGENCE (Ops Map) |
| RECRUITMENT | OPS ROOM (Operations) |
| PRODUCTION | ECONOMY |
| RESEARCH | POLITICS |
| SUPPLY | SETTINGS |

## That's It!

Edit → Sync → Test → Repeat

See other docs for details.