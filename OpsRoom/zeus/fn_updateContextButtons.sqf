/*
    OpsRoom_fnc_updateContextButtons
    
    Updates ability buttons based on current selection
    Deletes old buttons and creates new ones for available abilities
    
    Parameters:
        _units - Array of selected units
*/

params ["_units"];

private _display = findDisplay 312;
if (isNull _display) exitWith {};

// Get available abilities for this selection
private _abilities = [_units] call OpsRoom_fnc_getUnitAbilities;

// Delete ALL existing ability buttons (9350-9389)
for "_i" from 9350 to 9389 do {
    private _ctrl = _display displayCtrl _i;
    if (!isNull _ctrl) then {
        ctrlDelete _ctrl;
    };
};

// If no abilities, we're done
if (count _abilities == 0) exitWith {
    diag_log "[OpsRoom] No abilities available for current selection";
};

// Button layout configuration
private _buttonSize = 0.035 * safezoneH;
private _padding = 0.005 * safezoneW;

// Position abilities on RIGHT side of toolbar
private _startX = safezoneX + safezoneW - (_buttonSize * (count _abilities)) - (_padding * (count _abilities + 1));
private _yPos = safezoneY + safezoneH - _buttonSize - (0.05 * safezoneH);

// Create button for each ability
{
    private _abilityID = _x;
    private _config = OpsRoom_AbilityConfig get _abilityID;
    private _index = _forEachIndex;
    
    [_display, _abilityID, _config, _index, _startX, _yPos, _buttonSize, _padding] call OpsRoom_fnc_createAbilityButton;
    
    diag_log format ["[OpsRoom] Created ability button: %1", _abilityID];
    
} forEach _abilities;

diag_log format ["[OpsRoom] Updated context buttons: %1 abilities", count _abilities];
