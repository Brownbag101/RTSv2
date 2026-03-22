/*
    OpsRoom_fnc_getUnitAbilities
    
    Determines which abilities are available for the selected units
    
    Parameters:
        _units - Array of selected units
        
    Returns:
        Array of ability ID strings (e.g. ["regroup", "suppressiveFire"])
*/

params ["_units"];

if (count _units == 0) exitWith {[]};

private _abilities = [];

// Check each ability's condition
{
    private _abilityID = _x;
    private _config = OpsRoom_AbilityConfig get _abilityID;
    private _condition = _config get "condition";
    
    // Test if this ability is available
    if ([_units] call _condition) then {
        _abilities pushBack _abilityID;
    };
} forEach (keys OpsRoom_AbilityConfig);

_abilities
