# 3D Marker System - Complete Rewrite

## Problem Solved
Previous 3D marker system wasn't showing in Zeus. Rewrote using proven bomb marker pattern.

## New System Architecture

### Core Files
1. **fn_create3DMarker.sqf** - Creates markers with Draw3D event handler
2. **fn_remove3DMarker.sqf** - Removes markers by clearing data
3. **markerIcons.sqf** - Icon library with presets

### How It Works
Based on your proven bomb marker system:
1. Store marker data in missionNamespace variable
2. Create Draw3D event handler that reads the variable
3. Handler auto-removes when data is cleared
4. Supports both position arrays and objects

## API Reference

### Create Marker
```sqf
private _handlerId = [
    "markerID",           // Unique identifier
    [x, y, z],            // Position OR object to follow
    "Display Text",       // Text shown below icon
    "icon_path.paa",      // Icon texture path
    [R, G, B, A],         // Color array
    2                     // Icon size multiplier
] call OpsRoom_fnc_create3DMarker;

// Store handler ID for cleanup
missionNamespace setVariable ["myMarker_handler", _handlerId];
```

### Remove Marker
```sqf
["markerID"] call OpsRoom_fnc_remove3DMarker;
```

### Using Icon Library
```sqf
// Load library first (done in mission1_init.sqf)
call compile preprocessFileLineNumbers "OpsRoom\missions\markerIcons.sqf";

// Use preset icon and color
[
    "objective1",
    getPos player,
    "OBJECTIVE",
    OpsRoom_MarkerIcons get "objective",  // Icon preset
    OpsRoom_MarkerColors get "blue",       // Color preset
    2
] call OpsRoom_fnc_create3DMarker;
```

## Icon Library

### Available Icons
**Military:**
- `objective` - Blue objective icon
- `destroy` - Destroy target
- `defend` - Defend position
- `attack` - Attack position
- `secure` - Search/secure area

**Support:**
- `repair` - Repair icon
- `rearm` - Rearm icon
- `refuel` - Refuel icon
- `heal` - Medical icon

**Vehicles:**
- `car` - Vehicle icon
- `heli` - Helicopter icon
- `plane` - Aircraft icon
- `boat` - Naval icon

**Special:**
- `mine` - Mine/explosive
- `danger` - Warning
- `explosion` - Destruction
- `intel` - Documents/intel
- `meet` - Meeting point
- `talk` - Conversation
- `container` - Supply container

### Available Colors
- `blue` - Friendly/Objective [0.2, 0.6, 1, 1]
- `green` - Safe/Complete [0.2, 1, 0.3, 1]
- `yellow` - Warning [1, 0.9, 0.2, 1]
- `orange` - Alert [1, 0.5, 0.1, 1]
- `red` - Danger/Enemy [1, 0.2, 0.2, 1]
- `purple` - Special/VIP [0.8, 0.3, 1, 1]
- `white` - Neutral/Info [1, 1, 1, 1]
- `black` - Dark/Stealth [0.1, 0.1, 0.1, 1]

## Usage Examples

### Static Position Marker
```sqf
// Objective at coordinates
[
    "obj1",
    [5000, 5000, 10],
    "SECURE AREA",
    OpsRoom_MarkerIcons get "objective",
    OpsRoom_MarkerColors get "blue",
    2
] call OpsRoom_fnc_create3DMarker;
```

### Follow Object Marker
```sqf
// Engineer marker that follows unit
[
    "engineer1",
    _engineerUnit,  // Object reference
    "ENGINEER",
    OpsRoom_MarkerIcons get "repair",
    OpsRoom_MarkerColors get "green",
    1.5
] call OpsRoom_fnc_create3DMarker;
```

### Danger Zone Marker
```sqf
// Mine field warning
[
    "mines1",
    _minePos,
    "DANGER - MINES",
    OpsRoom_MarkerIcons get "mine",
    OpsRoom_MarkerColors get "red",
    2
] call OpsRoom_fnc_create3DMarker;
```

### Temporary Marker with Timer
```sqf
// Show marker for 30 seconds
private _handlerId = [
    "temp1",
    getPos player,
    "EXTRACTION POINT",
    OpsRoom_MarkerIcons get "heli",
    OpsRoom_MarkerColors get "green",
    2
] call OpsRoom_fnc_create3DMarker;

// Remove after 30 seconds
[_handlerId] spawn {
    params ["_id"];
    sleep 30;
    ["temp1"] call OpsRoom_fnc_remove3DMarker;
};
```

## Mission 1 Implementation

```sqf
// In fn_createClearAreaTask.sqf
private _marker3DPos = [_spawnPos select 0, _spawnPos select 1, (_spawnPos select 2) + 10];

private _marker3DHandler = [
    "opsroom_mission1_3d",
    _marker3DPos,
    "SECURE AREA",
    "\A3\ui_f\data\map\markers\military\objective_CA.paa",
    [0.2, 0.6, 1, 1],
    2
] call OpsRoom_fnc_create3DMarker;

// Store for cleanup
missionNamespace setVariable ["OpsRoom_Mission1_3DHandler", _marker3DHandler];

// Later, on task complete:
["opsroom_mission1_3d"] call OpsRoom_fnc_remove3DMarker;
```

## Key Differences from Old System

### OLD (Broken)
- Single Draw3D handler for all markers
- Stored in hashmap with complex forEach loop
- Icon path from config lookup (could fail)
- No handler cleanup

### NEW (Working)
- One Draw3D handler per marker
- Handler checks for data existence
- Auto-removes when data cleared
- Direct icon path (no config lookup)
- Proven pattern from bomb marker

## Benefits

1. **Works reliably** - Based on proven code
2. **Simple cleanup** - Just clear the data variable
3. **Follows objects** - Pass object instead of position
4. **Icon library** - Standardized icons and colors
5. **Auto-cleanup** - Handler removes itself when data gone
6. **Flexible** - Easy to extend for new marker types

## Testing Checklist

1. ✅ Marker shows in Zeus 3D view
2. ✅ Icon and text visible
3. ✅ Correct color
4. ✅ Stays at position
5. ✅ Removes cleanly on task complete
6. ✅ No errors in RPT
7. ✅ Can follow objects if needed

## Future Use Cases

- Engineer spawn locations
- Supply drops
- Extraction points
- Enemy positions
- VIP locations
- Danger zones
- Rally points
- Objectives
- Resource nodes
- Build sites

## Technical Notes

- Handler passes marker ID as parameter
- Uses missionNamespace for data storage
- ASLToAGL conversion for object positions
- Text rendered with outline (shadow=2)
- Icon size is multiplier (1 = normal, 2 = double)
- Position raised 10m for visibility in Mission 1
