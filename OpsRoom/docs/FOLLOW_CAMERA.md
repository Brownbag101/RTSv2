# Follow Camera System

## Overview

A toggle-able camera follow system that smoothly tracks selected units in Zeus mode using cinematic camera movements. Appears as a context-sensitive button when exactly one unit is selected.

## How to Use

1. **Enable:** Select a single unit in Zeus, click the "Follow" button (scout icon) in bottom-right
2. **Watch:** Camera smoothly positions ahead of unit and tracks their movement
3. **Auto-reposition:** Camera leaps ahead when unit gets 50m away
4. **Disable:** Click Follow button again (button shows green when active)

## Camera Behavior

**Leap-frog System:**
- Camera positions 50m ahead of target in their direction of travel
- Stays in position, rotating to watch the target
- When target walks 50m away from camera → smooth 8-second glide to new position ahead
- Continuous smooth tracking using BIS_fnc_setCuratorCamera

**Distance Settings:**

**Infantry:**
- Position: 50m ahead
- Height: 15m above
- Trigger: Repositions at 50m distance

**Ground Vehicles:**
- Position: 60m ahead
- Height: 20m above
- Trigger: Repositions at 60m distance

**Aircraft:**
- Position: 100m ahead
- Height: 30m above
- Trigger: Repositions at 80m distance

## Button Location

Bottom-right toolbar, appears only when:
- Exactly 1 unit selected
- Unit is alive

**Visual States:**
- Normal: Dark background with scout icon
- Hover: Tan background (standard hover)
- Active: Green-tinted background
- Only visible when 1 unit selected

## Status Messages

```
"Follow camera: ENABLED on [unit name]"  - Started following
"Follow camera: DISABLED"                - Manually disabled
"Camera repositioning (target Xm away)"  - Camera leaping to new position
"Follow camera: DISABLED (Zeus closed)"  - Zeus interface closed
"Follow camera: DISABLED (target invalid)" - Unit died
```

## Technical Details

**Files:**
- `zeus/fn_toggleFollowCamera.sqf` - Toggle on/off with visual feedback
- `zeus/fn_followCameraLoop.sqf` - Main follow loop with leap-frog behavior
- `zeus/abilities/config.sqf` - Ability registration

**Global Variables:**
- `OpsRoom_FollowCameraActive` - Boolean, is follow active
- `OpsRoom_FollowCameraTarget` - Object, current target unit

**Update Rate:** 
- Position check: Every 1 second
- Reposition transition: 8 seconds smooth glide
- Tracking update: 1 second smooth rotation

**Key Function:**
- Uses `BIS_fnc_setCuratorCamera` for professional smooth transitions
- Parameters: `[position, target, transition_time]`

## BIS Functions Used

```sqf
BIS_fnc_setCuratorCamera  // Smooth camera transitions with target tracking
curatorCamera             // Get Zeus camera object
curatorSelected           // Get selected units
getPosASL                 // Get camera/unit position
getDir                    // Get unit direction
vehicle                   // Check if in vehicle
```

## Integration

Registered as context-aware ability:
- ID: `"followCamera"`
- Condition: Exactly 1 unit selected
- Icon: Scout icon (`simpleTasks\types\scout_ca.paa`)
- Color when active: Green tint background

## Tuning Parameters

Located in `fn_followCameraLoop.sqf`:

```sqf
_followDistance = 50;     // Position ahead of target
_followHeight = 15;       // Height above target
_triggerDistance = 50;    // Distance before repositioning

// In BIS_fnc_setCuratorCamera calls:
[_cameraPos, _target, 8]  // 8 second reposition glide
[_lastCameraPos, _target, 1]  // 1 second tracking update

// Update frequency:
sleep 1;  // Check every 1 second
```

**To adjust smoothness:**
- Slower glide: Increase `8` to `10` or `12`
- Faster glide: Decrease `8` to `5` or `6`
- More responsive: Decrease `sleep 1` to `0.5`

**To adjust behavior:**
- Jump further ahead: Increase `_followDistance`
- Reposition more often: Decrease `_triggerDistance`
- Higher camera: Increase `_followHeight`
