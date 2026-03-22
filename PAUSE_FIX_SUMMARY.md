# Pause Button Fix - Zeus Camera Error

## Problem
Clicking the pause button (⏸) caused Zeus camera errors:
```
Error Type Not a Number, expected Number
File A3\ui_f_curator\UI\displays\RscDisplayCurator.sqf..., line 314
```

## Root Cause
Setting time acceleration to 0 (complete pause) breaks Zeus's camera positioning system. Zeus's camera code expects time to be moving to calculate positions and distances.

## Solution
Changed "pause" button from 0x to 0.1x (very slow motion instead of complete stop).

**File:** `OpsRoom/zeus/fn_createSpeedControls.sqf`

### Changes Made:
```sqf
// OLD (broke Zeus camera):
[9310, "⏸", 0],  // Complete pause = 0x

// NEW (works with Zeus):
[9310, "⏸", 0.1],  // Near pause = 0.1x (10% speed)
```

**Feedback message changed:**
- Old: "Game speed: PAUSED"
- New: "Game speed: 0.1x (Near Pause)"

## Why This Works
- 0.1x is slow enough to appear nearly paused
- But fast enough that Zeus's camera calculations still work
- Time still moves, just VERY slowly
- All other speeds (0.5x, 1x, 2x, 4x) work normally

## Updated Speed Controls

| Button | Speed | Effect |
|--------|-------|--------|
| ⏸ | 0.1x | Near Pause (very slow motion) |
| ◄ | 0.5x | Slow (half speed) |
| ► | 1x | Normal |
| ►► | 2x | Fast (double speed) |
| ►►► | 4x | Very Fast (quad speed) |

## Technical Note
ARMA 3's Zeus mode uses the camera bird (curator camera) which constantly calculates distances and positions. When time is completely stopped (0x), these calculations fail because:
- Distance calculations return invalid values
- Position updates can't complete
- Camera movement breaks

At 0.1x speed, these calculations still work but time moves 10x slower than normal, giving the appearance of near-pause without breaking Zeus.

## Test After Sync

1. **Run SYNC_OpsRoom.bat**
2. **Reload mission**
3. **Test pause button:**
   - Click ⏸
   - Should show: "Game speed: 0.1x (Near Pause)"
   - NO camera errors
   - Time moves VERY slowly (watch date/time seconds)
   - Camera still works normally
   - Can still move around in Zeus

All other speed buttons (◄ ► ►► ►►►) should continue working perfectly!
