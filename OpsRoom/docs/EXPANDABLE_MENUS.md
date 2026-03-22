# Expandable Button Menus

## Overview

Standard command buttons now open expandable menus when clicked, giving precise control over unit behavior.

## How It Works

1. Click any standard button (stance/combat/speed/formation)
2. Menu expands **upward** above the button
3. Click desired option
4. Menu closes automatically

## Menu Options

### Stance (4 options)
- Auto Stance
- Stand
- Crouch
- Prone

### Combat Mode (5 options)
- Never Fire (BLUE)
- Hold Fire (GREEN)
- Hold Fire, Engage at Will (WHITE)
- Fire at Will (YELLOW)
- Fire at Will, Engage at Will (RED)

### Speed Mode (3 options)
- Limited Speed (Slow)
- Normal Speed
- Full Speed (Fast)

### Formation (9 options)
- Column
- Staggered Column
- Wedge
- Echelon Left
- Echelon Right
- Vee
- Line
- File
- Diamond

## Files Created

- `fn_createButtonMenu.sqf` - Creates expandable menu above button
- `fn_closeButtonMenu.sqf` - Closes active menu
- `fn_getStanceMenu.sqf` - Returns stance options
- `fn_getCombatModeMenu.sqf` - Returns combat mode options
- `fn_getSpeedModeMenu.sqf` - Returns speed options
- `fn_getFormationMenu.sqf` - Returns formation options

## Files Modified

- `fn_createStandardButtons.sqf` - Changed click handler to open menus
- `fn_hideZeusUI.sqf` - Added menu IDCs (9400-9449) to keepVisible
- `config.hpp` - Registered 6 new functions

## Control IDs

```
9400-9449  Menu buttons (expandable menus, 25 items max per menu)
```

## Technical Details

**Menu Positioning:**
- Menus expand upward from base button
- Each menu item is same size as base button
- Auto-calculates position based on number of items

**Auto-Close:**
- Menu closes when any option is selected
- Menu stored globally in `OpsRoom_ActiveMenuControls`
- Only one menu can be open at a time

**Menu Items Format:**
```sqf
[
    ["Display Text", "icon_path.paa", {code to execute}],
    ["Another Option", "icon_path.paa", {more code}]
]
```

## Adding New Menus

1. Create `fn_getYourMenu.sqf` with menu items array
2. Register in `config.hpp`
3. Add case to switch statement in `fn_createStandardButtons.sqf`

## Benefits

✅ Precise control - no cycling through options
✅ Visual feedback - see all options at once
✅ Clean UI - menus only appear when needed
✅ Expandable - easy to add more options
✅ Consistent - same pattern for all command types
