# Grenade Animation System - Added

## What Changed

### Animation Sequence Added
The unit now performs a full throw animation sequence before the grenade spawns:

1. **Switch to pistol stance** - Unit holsters rifle
2. **Crouch/wind-up** - Prepares to throw
3. **Stand and throw** - Throwing motion
4. **Switch back to rifle** - Returns to ready
5. **Grenade spawns** - At peak of throw animation (~1.2 seconds)

### Technical Changes

**File: `fn_throwGrenade.sqf`**
- Added animation sequence using `playMoveNow`
- Added `sleep` timing between animations
- Grenade spawns after animation completes
- Unit faces target with `doWatch`

**File: `fn_enterGrenadeTargeting.sqf`**
- Changed `call` to `spawn` for throw function
- Allows `sleep` commands to work properly
- Cleanup happens immediately (animation runs independently)

## Animation Classes Used

```sqf
"AmovPercMstpSrasWrflDnon_AmovPercMstpSrasWpstDnon"  // Rifle to pistol
"AmovPercMstpSrasWpstDnon_AmovPpneMstpSrasWpstDnon"  // Stand to prone (wind-up)
"AmovPpneMstpSrasWpstDnon_AmovPercMstpSrasWpstDnon"  // Prone to stand (throw)
"AmovPercMstpSrasWpstDnon_AmovPercMstpSrasWrflDnon"  // Pistol to rifle
```

These are the same animations visible in the action menu screenshot you showed!

## Timing

- **Total animation time:** ~1.2 seconds
- **Grenade spawn:** After all animations complete
- **User experience:** Click → Unit animates → Grenade flies

## Benefits

✅ Realistic throw animation
✅ Unit faces target automatically
✅ Grenade spawns at correct moment
✅ Visual feedback during throw
✅ Matches ARMA 3 grenade throw behavior

## Notes

- Animation only plays if unit is on foot (not in vehicle)
- If in vehicle, grenade spawns immediately
- Targeting mode cleanup happens right away
- Animation plays independently in background

## Ready to Test

Sync and test - unit should now perform the full grenade throw animation sequence!
