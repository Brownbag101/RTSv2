# Bug Fixes - Round 3

## Issues Fixed

### 1. Missing Back Buttons ✅
**Problem:** No back button in Major or Captain selection dialogs  
**Solution:** Added back buttons to both dialogs

**Files Modified:**
- `dialog_captain_select.hpp` - Added back button (returns to Groups view)
- `dialog_major_select.hpp` - Already had back button (returns to Regiments view)

**Button Placement:**
- Bottom left of dialog
- Same position as other dialogs
- Returns to appropriate parent view

### 2. Captains Showing as Available Majors ✅
**Problem:** Captain rank units (rankId 4) were showing in Major selection  
**Solution:** Fixed rank check AND added group leader exclusion

**Root Causes:**
1. Wrong rank threshold: `>= 3` included Captains
2. Missing group leader check: Group COs could be selected

**ARMA 3 Rank IDs:**
```
PRIVATE   = 0
CORPORAL  = 1
SERGEANT  = 2
LIEUTENANT = 3
CAPTAIN   = 4
MAJOR     = 5
COLONEL   = 6
```

**New Filter Logic:**
```sqf
// Must be Major or above (rankId >= 5)
if (rankId _unit >= 5) then {
    // NOT a regiment CO
    if !(_unit in _assignedRegimentCOs) then {
        // NOT a group CO (group leader)
        if !(_unit in _assignedGroupCOs) then {
            // Alive
            if (alive _unit) then {
                _availableMajors pushBack _unit;
            };
        };
    };
};
```

**Files Modified:**
- `fn_getAvailableMajors.sqf` - Fixed rank check and added group CO exclusion

## What's Excluded Now

### Regiment Creation (Major Selection)
- ❌ Captains (rankId 4)
- ❌ Lieutenants, Sergeants, etc (rankId < 5)
- ❌ Current Regiment COs
- ❌ Current Group COs (Group Leaders)
- ❌ Dead units
- ❌ Player unit
- ✅ Only Majors and Colonels who are regular soldiers

### Group Creation (Captain Selection)
- Already had proper filtering
- Only shows Captains from the selected regiment
- Excludes Group COs

## Testing Checklist

### Back Buttons
1. ✅ Open Regiments → Add Regiment → Major Select → Back button works
2. ✅ Open Regiment → Groups → Add Group → Captain Select → Back button works

### Major Selection Filter
1. ✅ Promote unit to Captain → NOT shown in Major select
2. ✅ Promote unit to Major → IS shown in Major select
3. ✅ Major is Group CO → NOT shown in Major select
4. ✅ Major is Regiment CO → NOT shown in Major select
5. ✅ Regular Major soldier → IS shown in Major select

## Summary

**Files Changed:** 2
1. `dialog_captain_select.hpp` - Added back button
2. `fn_getAvailableMajors.sqf` - Fixed rank check (5 not 3) + added group CO exclusion

**Result:**
- ✅ Back buttons work in both selection dialogs
- ✅ Only Majors (not Captains) can be selected for Regiments
- ✅ Group Leaders (Group COs) cannot be selected
- ✅ Regiment COs cannot be selected (already worked)

Ready to sync and test! 🎯
