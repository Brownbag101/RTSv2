/*
    Check and Award Medals
    
    Evaluates a unit's service record against all medal definitions
    and awards any newly earned medals.
    
    Parameters:
        0: OBJECT - Unit to check
    
    Returns:
        ARRAY - Newly awarded medals (can be empty)
    
    Usage:
        private _newMedals = [_unit] call OpsRoom_fnc_checkMedals;
*/

params [["_unit", objNull, [objNull]]];

if (isNull _unit) exitWith { [] };

private _record = [_unit] call OpsRoom_fnc_getServiceRecord;
if (count _record == 0) exitWith { [] };

private _currentMedals = _record getOrDefault ["medals", []];
private _newMedals = [];

{
    _x params ["_medalId", "_medalName", "_symbol", "_color", "_desc", "_checkFnc"];
    
    // Skip if already awarded
    private _alreadyHas = false;
    {
        if ((_x select 0) == _medalId) exitWith { _alreadyHas = true };
    } forEach _currentMedals;
    
    if (!_alreadyHas) then {
        // Check eligibility
        private _eligible = [_record] call _checkFnc;
        if (_eligible) then {
            private _medalEntry = [_medalId, _medalName, _symbol, _color, _desc, time];
            _currentMedals pushBack _medalEntry;
            _newMedals pushBack _medalEntry;
            diag_log format ["[OpsRoom Medals] %1 awarded: %2 %3", name _unit, _symbol, _medalName];
        };
    };
} forEach OpsRoom_MedalDefinitions;

_record set ["medals", _currentMedals];

// Notify if new medals awarded
if (count _newMedals > 0) then {
    {
        _x params ["_id", "_name", "_sym", "_col"];
        ["PRIORITY", "MEDAL AWARDED", format ["%1 awarded the %2 %3", name _unit, _sym, _name], nil, _unit] call OpsRoom_fnc_dispatch;
    } forEach _newMedals;
};

_newMedals
