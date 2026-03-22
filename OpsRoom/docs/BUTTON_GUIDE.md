# Button System Reference

## Architecture

- 10 buttons total (5 left, 5 right)
- Each button = background + button control
- Created on Zeus display (312)
- Event handlers: ButtonClick, MouseEnter, MouseExit

## Button IDs

**Left Side:**
- Button 1: 9100 (bg), 9101 (button)
- Button 2: 9102 (bg), 9103 (button)
- Button 3: 9104 (bg), 9105 (button)
- Button 4: 9106 (bg), 9107 (button)
- Button 5: 9108 (bg), 9109 (button)

**Right Side:**
- Button 6: 9200 (bg), 9201 (button)
- Button 7: 9202 (bg), 9203 (button)
- Button 8: 9204 (bg), 9205 (button)
- Button 9: 9206 (bg), 9207 (button)
- Button 10: 9208 (bg), 9209 (button)

## Current Functions

```
[Left]
Button 1 (9101) - REGIMENTS    → OpsRoom_fnc_openRegiments
Button 2 (9103) - RECRUITMENT   → OpsRoom_fnc_openRecruitment
Button 3 (9105) - PRODUCTION    → OpsRoom_fnc_openFactories
Button 4 (9107) - RESEARCH      → OpsRoom_fnc_openResearchCategories
Button 5 (9109) - SUPPLY        → OpsRoom_fnc_openSupply

[Right]
Button 6 (9201) - INTELLIGENCE  → OpsRoom_fnc_openOpsMap
Button 7 (9203) - OPS ROOM      → OpsRoom_fnc_openOperations
Button 8 (9205) - ECONOMY       → Not implemented
Button 9 (9207) - POLITICS      → Not implemented
Button 10 (9209) - SETTINGS     → Not implemented
```

## How Buttons Work

**File:** `gui/fn_createButtonsOnZeus.sqf`

1. Arrays define button properties (~line 15)
2. Zeus display checked/created (~line 35)
3. Buttons created on display 312 (~line 50)
4. Event handlers attached (~line 85)

## Editing Button Labels

Find arrays at top of fn_createButtonsOnZeus.sqf:

```sqf
private _leftButtons = [
    [BG_IDC, BTN_IDC, "LABEL", "Title", "Description"],
    // ...
];
```

Change "LABEL" to your text.

## Editing Button Actions

Find ButtonClick handler (~line 85):

```sqf
_btn ctrlAddEventHandler ["ButtonClick", {
    params ["_control"];
    private _idc = ctrlIDC _control;
    
    // Button 1
    if (_idc == 9101) exitWith {
        createDialog "Regiment_Dialog";
    };
    
    // Button 2
    if (_idc == 9103) exitWith {
        hint "Production menu";
    };
    
    // Add more...
}];
```

## Button Action Examples

### Open Dialog
```sqf
if (_idc == 9101) exitWith {
    createDialog "Your_Dialog_Name";
};
```

### Simple Hint
```sqf
if (_idc == 9101) exitWith {
    hint "Button clicked!";
};
```

### Call Function
```sqf
if (_idc == 9101) exitWith {
    [] call YourModule_fnc_doSomething;
};
```

### Get Selected Units
```sqf
if (_idc == 9101) exitWith {
    private _curator = getAssignedCuratorLogic player;
    private _selected = curatorSelected select 0;
    hint format["Selected: %1 units", count _selected];
};
```

### Modify Resources
```sqf
if (_idc == 9101) exitWith {
    OpsRoom_Resource_Wood = OpsRoom_Resource_Wood + 100;
    [] call OpsRoom_fnc_updateResources;
    hint "Added 100 wood";
};
```

### Complex Action
```sqf
if (_idc == 9101) exitWith {
    private _units = curatorSelected select 0;
    if (count _units == 0) exitWith {
        hint "No units selected";
    };
    
    {
        _x setDamage 0;
        _x setVehicleAmmo 1;
    } forEach _units;
    
    systemChat format["Healed and rearmed %1 units", count _units];
};
```

## Hover Effects

Defined in MouseEnter/MouseExit handlers (~line 120):

```sqf
_btn ctrlAddEventHandler ["MouseEnter", {
    params ["_control"];
    private _bg = _control getVariable "background";
    _bg ctrlSetBackgroundColor COLOR_BUTTON_HOVER;
}];
```

Colors defined in `gui/ui_defines.hpp`.

## Button Positioning

Controlled by variables (~line 40):

```sqf
private _buttonWidth = 0.08;
private _buttonHeight = 0.04;
private _spacing = 0.01;
private _leftX = safezoneX + 0.01;
private _rightX = safezoneX + safezoneW - _buttonWidth - 0.01;
private _startY = safezoneY + (safezoneH * 0.08);
```

Adjust these to reposition buttons.

## Adding More Buttons

1. Add to array with new IDC pair
2. Ensure IDCs are unique
3. Add corresponding if statement in ButtonClick handler

Example:
```sqf
private _leftButtons = [
    // ... existing buttons ...
    [9110, 9111, "NEW BUTTON", "Title", "Desc"]
];
```

Then in ButtonClick:
```sqf
if (_idc == 9111) exitWith {
    hint "New button!";
};
```

## Technical Notes

- Buttons MUST be on Zeus display (312)
- RscTitles don't support reliable mouse interaction
- Background stored in button variable for hover effect
- fn_createButtons.sqf is legacy (don't use)

## Troubleshooting

**Buttons not visible:**
- Press Y for Zeus mode
- Check Zeus display exists: `!isNull (findDisplay 312)`

**Buttons not clickable:**
- Verify using fn_createButtonsOnZeus not fn_createButtons
- Check buttons created on display 312

**Wrong button action fires:**
- Check IDC numbers in if statements
- Verify IDCs match array definitions

**Hover effect not working:**
- Check background variable set correctly
- Verify colors defined in ui_defines.hpp