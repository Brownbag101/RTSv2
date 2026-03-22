# Grenade Ability System - Implementation Complete

## Overview

Complete grenade throw ability with visual targeting, arc preview, and expandable menu for multiple grenade types.

## Features

✅ **Automatic Grenade Detection**
- Scans selected unit's magazines
- Identifies all grenade types (HE, smoke, chemlight)
- Shows only available types

✅ **Expandable Menu System**
- Single button if only 1 grenade type
- Expandable menu if multiple types
- Icons and names for each grenade
- Menu appears above ability button

✅ **Visual Targeting Mode**
- Custom crosshair cursor overlay
- Green cursor = in range
- Red cursor = too far
- Real-time range checking

✅ **Ballistic Arc Preview**
- Draws predicted throw arc
- Green line = valid throw
- Red line = out of range
- Impact marker at landing point
- Uses real physics (velocity, gravity, angle)

✅ **Range Limits**
- HE grenades: 40m
- Smoke grenades: 50m
- Validates before throw

✅ **Cancel Mechanism**
- Press ESC to cancel
- Cleans up all UI elements
- Removes event handlers

✅ **Multi-Unit Support**
- Uses first selected unit with grenades
- Automatic filtering

## File Structure

```
zeus/abilities/
├── config.sqf                        ← Updated with grenade ability
├── fn_ability_grenade.sqf           ← Main entry point
├── fn_getGrenadeMenu.sqf            ← Expandable grenade selection
├── fn_enterGrenadeTargeting.sqf     ← Targeting mode with visuals
├── fn_calculateGrenadeArc.sqf       ← Ballistic arc calculation
├── fn_throwGrenade.sqf              ← Execute throw
└── fn_cancelGrenadeTargeting.sqf    ← Cleanup
```

## Usage Flow

```
1. Select unit with grenades
2. Click "Grenade" ability button
   ↓
3a. If 1 type: Enter targeting immediately
3b. If multiple: Show expandable menu
   ↓
4. Click grenade type (if menu shown)
   ↓
5. TARGETING MODE ACTIVE
   - Green/red crosshair appears
   - Arc preview draws continuously
   - Range indicator shows
   ↓
6a. Left click: Throw grenade (if in range)
6b. ESC: Cancel targeting
   ↓
7. Cleanup and return to normal
```

## Supported Grenade Types

### High Explosive
- `HandGrenade` - RGO Grenade (40m range)
- `MiniGrenade` - RGN Grenade (40m range)

### Smoke Grenades (50m range)
- `SmokeShell` - White
- `SmokeShellRed` - Red
- `SmokeShellGreen` - Green
- `SmokeShellYellow` - Yellow
- `SmokeShellPurple` - Purple
- `SmokeShellBlue` - Blue
- `SmokeShellOrange` - Orange

### Chemlights (50m range)
- `Chemlight_green` - Green
- `Chemlight_red` - Red
- `Chemlight_yellow` - Yellow
- `Chemlight_blue` - Blue

## Technical Details

### Grenade Detection
```sqf
// Checks magazine type = 256 (grenades)
getNumber (configFile >> "CfgMagazines" >> _mag >> "type") == 256
```

### Cursor Position
```sqf
// Gets 3D world position at screen center
private _targetPos = screenToWorld [0.5, 0.5];
```

### Arc Calculation
- Uses ballistic physics formulas
- Initial velocity: 25 m/s
- Gravity: 9.81 m/s²
- Angle: Calculated for optimal trajectory
- 20 sample points for smooth arc

### Throw Execution
1. Removes magazine from unit
2. Creates projectile at shoulder height
3. Applies calculated velocity vector
4. Plays throw gesture animation
5. Native ARMA physics take over

## Global Variables

Active during targeting mode only:
```sqf
OpsRoom_GrenadeTargeting_Active         // Boolean flag
OpsRoom_GrenadeTargeting_Unit          // Unit throwing
OpsRoom_GrenadeTargeting_Type          // Magazine class
OpsRoom_GrenadeTargeting_CursorCtrl    // Cursor control
OpsRoom_GrenadeTargeting_FrameHandler  // EachFrame EH ID
OpsRoom_GrenadeTargeting_ClickHandler  // Mouse EH ID
OpsRoom_GrenadeTargeting_ESCHandler    // Keyboard EH ID
```

All cleaned up on cancel or throw.

## Event Handlers

### EachFrame (Visual Updates)
- Updates cursor color based on range
- Calculates and draws arc preview
- Draws impact marker
- Runs every frame for smooth visuals

### MouseButtonDown (Throw Trigger)
- Detects left click only
- Validates range
- Executes throw
- Cleans up targeting mode

### KeyDown (Cancel)
- Detects ESC key (code 1)
- Cancels targeting
- Cleans up all elements
- Consumes key to prevent other actions

## Performance

- **EachFrame handler**: ~20 arc points + 1 icon = minimal CPU
- **Memory**: ~7 global variables during targeting
- **Cleanup**: Full cleanup on exit, no leaks
- **Display**: Uses Zeus display 312 (existing)

## Integration

Ability appears in ability bar when:
1. Unit(s) selected
2. At least one has grenades (type 256 magazines)
3. Ability button shows grenade icon

## Future Enhancements

Possible additions:
- Velocity adjustment (hold to throw farther/shorter)
- Wind calculation (advanced)
- Terrain slope consideration
- Multiple unit simultaneous throw
- Grenade type quick-swap (number keys)
- Trajectory angle indicator
- Time-to-impact display

## Testing Checklist

- [ ] Ability button appears when unit has grenades
- [ ] Menu shows all grenade types
- [ ] Single type goes straight to targeting
- [ ] Cursor changes color at 40m/50m boundary
- [ ] Arc preview draws correctly
- [ ] ESC cancels targeting
- [ ] Left click throws grenade
- [ ] Grenade lands near target
- [ ] Magazine removed from unit
- [ ] No error logs in RPT
- [ ] Cleanup completes (no ghost controls)
- [ ] Works with HE grenades
- [ ] Works with smoke grenades
- [ ] Works with chemlights
- [ ] Multiple units selection (uses first)

## Known Limitations

1. **Physics Accuracy**: Uses simplified ballistic model (no air resistance, wind)
2. **Arc Sampling**: 20 points may not be perfect on steep terrain
3. **Unit Animation**: Throw gesture may not sync perfectly with projectile spawn
4. **Cursor Position**: Always at screen center (not following mouse in Zeus)
5. **Collision**: Arc preview doesn't check for obstacles (walls, trees)

## Debug Commands

```sqf
// Force enable targeting
[player, "HandGrenade"] call OpsRoom_fnc_enterGrenadeTargeting;

// Cancel targeting
call OpsRoom_fnc_cancelGrenadeTargeting;

// Check active state
hint str OpsRoom_GrenadeTargeting_Active;

// Add test grenades to unit
player addMagazine "HandGrenade";
player addMagazine "SmokeShellRed";
player addMagazine "SmokeShellGreen";
```

## System Status

**✅ FULLY IMPLEMENTED AND READY TO TEST**

All files created:
1. ✅ fn_ability_grenade.sqf
2. ✅ fn_getGrenadeMenu.sqf
3. ✅ fn_enterGrenadeTargeting.sqf
4. ✅ fn_calculateGrenadeArc.sqf
5. ✅ fn_throwGrenade.sqf
6. ✅ fn_cancelGrenadeTargeting.sqf
7. ✅ config.sqf (updated)

Functions registered in config.hpp: ✅

**Ready for sync and testing!**
