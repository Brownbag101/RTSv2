# Editing Guide

## Button System

### Change Button Label

**File:** `gui/fn_createButtonsOnZeus.sqf`  
**Lines:** ~15-30

Find the arrays:
```sqf
private _leftButtons = [
    [9100, 9101, "REGIMENTS", "Regiment Management", "Create and manage regiments"],
    [9102, 9103, "PRODUCTION", "Production", "Build units and structures"],
    // etc...
];
```

Change the third value (e.g., "REGIMENTS") to your new label.

### Change Button Action

**File:** `gui/fn_createButtonsOnZeus.sqf`  
**Lines:** ~85-200

Find the ButtonClick event handler:
```sqf
_btn ctrlAddEventHandler ["ButtonClick", {
    params ["_control"];
    
    // Button 1 - REGIMENTS
    if (ctrlIDC _control == 9101) exitWith {
        createDialog "Regiment_Dialog";  // Current action
    };
    
    // Add your code here
}];
```

Replace `createDialog "Regiment_Dialog";` with your action.

**Examples:**

Simple message:
```sqf
hint "Button clicked!";
```

Call function:
```sqf
[] call YourFunction;
```

Multiple actions:
```sqf
private _units = curatorSelected select 0;
{
    _x setDamage 0;
} forEach _units;
systemChat format["Healed %1 units", count _units];
```

## Colors

**File:** `gui/ui_defines.hpp`  
**Lines:** 1-15

Change color values (Red, Green, Blue, Alpha):
```cpp
#define COLOR_MAIN_BG {0.27, 0.22, 0.14, 0.9}
#define COLOR_BUTTON_BG {0.40, 0.35, 0.25, 0.85}
#define COLOR_BUTTON_HOVER {0.45, 0.40, 0.30, 0.95}
```

## Resources

**Current Resources:** Wood, Oil, Aluminium, Rubber, Tungsten, Steel, Chromium, Research Points, Manpower

**Add/Change Resources:**

**File 1:** `settings.sqf` (~line 10)
```sqf
OpsRoom_Settings_InitialResources = [
    ["Wood", 5],
    ["Oil", 5],
    ["NewResource", 100]  // Add here
];
```

**File 2:** `gui/fn_updateResources.sqf` (~line 10)
Add variable and format string:
```sqf
private _new = if (isNil "OpsRoom_Resource_NewResource") then {0} else {OpsRoom_Resource_NewResource};
_text = format["%1 | New: %2", _text, _new];
```

**Note:** Resource names with spaces are converted to underscores in variable names (e.g., "Research Points" becomes `OpsRoom_Resource_Research_Points`).

## Date/Time Display

**File:** `gui/fn_updateDateTime.sqf`

The date/time display in top-left shows real game date and time. The date is set in Eden Editor mission attributes.

To change format:
```sqf
private _text = format [
    "<t color='#D4C5A0' size='0.9'>%1 %2 %3 | %4:%5:%6</t>",
    _day, _monthName, _year, _hourStr, _minStr, _secStr
];
```

## Speed Controls

**File:** `zeus/fn_createSpeedControls.sqf`

Speed buttons below date/time:
- ⏸ - Pause (0x)
- ◄ - Slow (0.5x)
- ► - Normal (1x)
- ►► - Fast (2x)
- ►►► - Very Fast (4x)

To change speeds, edit the `_speeds` array:
```sqf
private _speeds = [
    [9310, "⏸", 0],
    [9311, "◄", 0.5],
    [9312, "►", 1],
    [9313, "►►", 2],
    [9314, "►►►", 4]
];
```

## Bar Sizes

**File:** `gui/displays.hpp`

Top bar height:
```cpp
h = 0.06 * safezoneH;  // Change 0.06 to adjust
```

Bottom bar height:
```cpp
h = 0.06 * safezoneH;  // Change 0.06 to adjust
```

## Button Size/Position

**File:** `gui/fn_createButtonsOnZeus.sqf`  
**Lines:** ~35-60

```sqf
private _buttonWidth = 0.08;   // Width
private _buttonHeight = 0.04;  // Height
private _spacing = 0.01;       // Gap between buttons
```

## Function Files

All functions in `gui/` folder are auto-loaded by config.hpp.

To add new function:
1. Create `gui/fn_yourFunction.sqf`
2. Add to `config.hpp` in CfgFunctions
3. Call with `[] call OpsRoom_fnc_yourFunction;`

## Regiment System

Files in `gui/regiments/`:
- Dialog layouts: `dialog_*.hpp`
- Functions: `fn_*.sqf`

Edit these to customize regiment/group/unit management.

## Zeus Integration

Files in `zeus/`:
- `fn_hideZeusUI.sqf` - Zeus interface config
- `fn_autoDetachUnits.sqf` - Auto-detach system
- `fn_monitorSelection.sqf` - Selection monitoring
- `fn_createRegroupButton.sqf` - Regroup button

## Data Files

Files in `data/`:
- `fn_initRegiments.sqf` - Regiment initialization
- `regimentNames.sqf` - Name lists

## Testing Changes

After editing:
1. Save file
2. Run SYNC_OpsRoom.bat
3. Select mission → A (Quick Sync)
4. In ARMA: Reload mission
5. Press Y for Zeus
6. Test your change

## Common Mistakes

**Forgot to sync** - Changes won't appear
**Edited wrong file** - Edit files in OpsRoom_Dev, not in mission folder
**Syntax error** - Check RPT log: `C:\Users\Brown\AppData\Local\Arma 3\`
**Button not working** - Check IDC numbers match in arrays

## Debug Commands

In ARMA Debug Console (ESC → Debug Console):

Update resources:
```sqf
[] call OpsRoom_fnc_updateResources;
```

Check resource value:
```sqf
systemChat str OpsRoom_Resource_Wood;
```

Set resource:
```sqf
OpsRoom_Resource_Wood = 5000;
[] call OpsRoom_fnc_updateResources;
```

Force speed update:
```sqf
setTimeMultiplier 2;  // 2x speed
```

Check current speed:
```sqf
systemChat str OpsRoom_CurrentSpeed;
```

Check display exists:
```sqf
systemChat str (!isNull (findDisplay 312));
```