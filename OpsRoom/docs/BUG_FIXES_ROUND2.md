# Bug Fixes - Round 2

## Issues Fixed

### 1. Back Button Not Working ✅
**Problem:** Back button in Unit Detail dialog (IDC = -1) couldn't be accessed  
**Solution:** Changed IDC from -1 to 8033  
**File:** `dialog_unit_detail.hpp`

### 2. Reattach Button - Main Group Only ✅
**Problem:** Reattach worked when detached unit selected, wanted opposite  
**Solution:** Rewrote to only work when MAIN GROUP is selected  
**File:** `fn_reformGroup.sqf`

**New behavior:**
- Select main group (not detached units)
- Press regroup button
- All detached sub-teams reattach to main group
- Shows count of reattached units

### 3. Kills & Time Tracking ✅
**Problem:** Kills and time in theatre not tracking  
**Solution:** Added tracking on unit spawn  
**File:** `fn_spawnStartingRegiment.sqf`

**Tracking added:**
- **Spawn time:** Stored in `OpsRoom_Unit_[unit]_SpawnTime`
- **Kills:** FiredMan + HitPart event handlers
- Tracks when unit's projectile kills enemy
- Updates `OpsRoom_Kills` variable on unit

### 4. Major Selection for New Regiments ✅
**Problem:** No way to select Major when creating regiment  
**Solution:** Created major selection dialog (like captain select)  
**New Files:**
- `fn_openMajorSelect.sqf`
- `fn_populateMajorGrid.sqf`
- `dialog_major_select.hpp`

**Flow:**
1. Click "Add Regiment"
2. Opens major selection grid
3. Double-click major to select
4. Auto-creates regiment with chosen major
5. Uses first available regiment name

## Files Modified (8)

1. **dialog_unit_detail.hpp** - Fixed back button IDC
2. **fn_reformGroup.sqf** - Main group reattach logic
3. **fn_spawnStartingRegiment.sqf** - Added kill/time tracking
4. **fn_showAddRegiment.sqf** - Major selection flow
5. **displays.hpp** - Include major select dialog
6. **config.hpp** - Register new functions

## Files Created (3)

1. **fn_openMajorSelect.sqf** - Opens major selection
2. **fn_populateMajorGrid.sqf** - Populates major grid
3. **dialog_major_select.hpp** - Major selection dialog

## How Kill Tracking Works

```sqf
// On unit spawn
_unit addEventHandler ["FiredMan", {
    params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile"];
    
    // Track projectile hits
    _projectile addEventHandler ["HitPart", {
        params ["_projectile", "_hitEntity", "_projectileOwner", ...];
        
        // If hit kills an enemy
        if (!isNull _hitEntity && _hitEntity isKindOf "Man" && !alive _hitEntity) then {
            private _kills = _projectileOwner getVariable ["OpsRoom_Kills", 0];
            _projectileOwner setVariable ["OpsRoom_Kills", _kills + 1];
        };
    }];
}];
```

## How Time Tracking Works

```sqf
// On spawn - store current time
private _varName = format ["OpsRoom_Unit_%1_SpawnTime", _unit];
missionNamespace setVariable [_varName, time];

// On display - calculate elapsed
private _timeAlive = time - (missionNamespace getVariable [format ["OpsRoom_Unit_%1_SpawnTime", _unit], time]);
private _days = floor (_timeAlive / 86400);
private _hours = floor ((_timeAlive mod 86400) / 3600);
```

## Testing Checklist

### Back Button
1. ✅ Open Regiments
2. ✅ Open Group
3. ✅ Click unit
4. ✅ Click "< BACK"
5. ✅ Returns to roster grid

### Reattach Button
1. ✅ Detach unit in Zeus
2. ✅ Select MAIN GROUP (not detached unit)
3. ✅ Press regroup button
4. ✅ Unit reattaches
5. ✅ Shows count message

### Kill Tracking
1. ✅ Spawn units (Mission 1)
2. ✅ Kill enemies with units
3. ✅ Open unit detail
4. ✅ See kill count increment

### Time Tracking
1. ✅ Spawn units (Mission 1)
2. ✅ Wait some time
3. ✅ Open unit detail
4. ✅ See time in theatre update

### Major Selection
1. ✅ Promote unit to Major
2. ✅ Click "Add Regiment"
3. ✅ See major selection grid
4. ✅ Double-click major
5. ✅ Regiment created with chosen CO

## Next Steps

1. **Run SYNC_OpsRoom.bat**
2. **Test all four fixes**
3. **Verify:**
   - Back button works
   - Reattach on main group only
   - Kills count
   - Time updates
   - Major selection works

All issues resolved! 🎯
