# Grenade Ability - Bug Fixes Applied

## Issues Fixed

### 1. ✅ Menu Appearance
**Problem:** Menu didn't look like formation menu  
**Fix:** Changed `fn_getGrenadeMenu.sqf` to return proper array format: `[text, icon, action]`

### 2. ✅ Menu Persistence
**Problem:** Buttons stuck on screen after use  
**Fix:** Menu now uses standard `OpsRoom_fnc_createButtonMenu` which has proper cleanup via `OpsRoom_fnc_closeButtonMenu`

### 3. ✅ Menu Position
**Problem:** Menu appeared on left side instead of above grenade button  
**Fix:** 
- `fn_ability_grenade.sqf` now finds the grenade button control
- Passes button position to `createButtonMenu`
- Menu expands upward from grenade button (just like formations)

### 4. ✅ Arc Start Position
**Problem:** Arc started too high in the air  
**Fix:** Changed `fn_enterGrenadeTargeting.sqf`:
```sqf
// OLD (wrong):
private _unitPos = getPosASL _unit;
_unitPos set [2, (_unitPos select 2) + 1.5]; // Added 1.5m height

// NEW (correct):
private _unitPos = getPosASL _unit;
// No height adjustment - start from unit's actual position (ground level)
```

### 5. ✅ Menu Action Execution
**Problem:** Actions weren't being called properly  
**Fix:** Changed action format in `fn_getGrenadeMenu.sqf`:
```sqf
// OLD (wrong):
private _boundAction = [_unit, _grenadeType, _action];

// NEW (correct):
private _actionCode = compile format [
    "[%1, '%2'] call OpsRoom_fnc_enterGrenadeTargeting;",
    _unit,
    _grenadeType
];
```

## Files Modified

1. ✅ `fn_ability_grenade.sqf` - Now finds button and uses standard menu system
2. ✅ `fn_getGrenadeMenu.sqf` - Returns proper format, uses compile for actions
3. ✅ `fn_enterGrenadeTargeting.sqf` - Fixed arc start position (removed height offset)

## Expected Behavior Now

1. **Click grenade button** → Menu expands UPWARD from button
2. **Menu appearance** → Matches formation/stance/etc. menus
3. **Click grenade type** → Menu disappears, enters targeting
4. **Arc preview** → Starts at unit's feet (ground level)
5. **ESC or throw** → Full cleanup, no stuck controls

## Test Checklist

- [ ] Menu appears above grenade button (not on left)
- [ ] Menu looks like formation menu (same style)
- [ ] Menu disappears after selecting type
- [ ] Menu disappears if clicking elsewhere
- [ ] Arc starts at unit's feet (not floating)
- [ ] Arc is green when in range
- [ ] Arc is red when out of range
- [ ] Click throws grenade
- [ ] ESC cancels properly
- [ ] No controls left on screen after cancel/throw

## Known Temporary Limitation

**Icon Issue:** Currently using placeholder icon (heal icon) because grenade weapon icon path was invalid. This is cosmetic only - functionality is complete.

**To fix later:** Find correct grenade icon path or create custom icon.

## Ready to Test

All fixes applied. Run SYNC_OpsRoom.bat and reload mission to test!
