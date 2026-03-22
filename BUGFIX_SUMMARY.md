# Bug Fix - Date/Time Controls Disappearing

## Problem
Date/time display and speed controls appeared initially but disappeared when Zeus interface closed and reopened.

## Root Cause
1. Controls were being created once in `init.sqf`
2. When Zeus display closes, all controls are destroyed
3. Controls were not being recreated when Zeus reopened
4. Control ID conflict: Date/time used 9300/9301 which were already used by regroup button

## Solution

### 1. Moved Control Creation to Zeus Monitor
**File: `OpsRoom/zeus/fn_hideZeusUI.sqf`**
- Added date/time and speed control creation to initial Zeus setup
- Added recreation logic when Zeus reopens
- Controls now persist across Zeus close/open cycles

### 2. Fixed Control ID Conflict
**File: `OpsRoom/gui/fn_createDateTimeDisplay.sqf`**
- Changed date/time background: 9300 → 9320
- Changed date/time text: 9301 → 9321
- Now unique from regroup button (9300/9301)

### 3. Updated Keep-Visible List
**File: `OpsRoom/zeus/fn_hideZeusUI.sqf`**
- Added new control IDs to _ourButtons array
- Prevents Zeus UI hiding system from hiding our controls

### 4. Fixed String Replacement Error
**File: `OpsRoom/init.sqf`**
- Replaced `BIS_fnc_replaceString` with manual implementation
- Function wasn't available during early initialization
- Now handles "Research Points" → "Research_Points" conversion properly

## Files Changed
- `OpsRoom/zeus/fn_hideZeusUI.sqf` - Added control creation/recreation
- `OpsRoom/gui/fn_createDateTimeDisplay.sqf` - Fixed control IDs
- `OpsRoom/init.sqf` - Fixed string replacement
- `OpsRoom/docs/SYSTEM_REFERENCE.md` - Updated control IDs
- `IMPLEMENTATION_SUMMARY.md` - Updated control IDs

## Correct Control IDs

```
9300, 9301 - Regroup button (existing)
9320, 9321 - Date/time display (NEW - fixed)
9310-9315  - Speed controls (NEW)
```

## Test After Sync
1. Run SYNC_OpsRoom.bat
2. Load mission in ARMA 3
3. Open Zeus (Y key)
4. Verify date/time and speed controls appear in top-left
5. Close Zeus (ESC)
6. Open Zeus again (Y key)
7. **VERIFY**: Controls should reappear automatically
8. Click speed buttons to test functionality
9. Watch date/time update every second

## Expected Behavior
- Date/time and speed controls appear when Zeus opens
- Controls persist while Zeus is open
- Controls recreate automatically when Zeus reopens
- No errors in RPT log
- Resources display correctly (all 9 resources, starting at 5)
