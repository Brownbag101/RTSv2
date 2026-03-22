/*
    Air Operations - Scramble Wing
    
    Quick-launch for Fighter wings specifically.
    Bypasses mission assignment — aircraft launch immediately
    and orbit the home airfield in combat mode.
    
    Parameters:
        _wingId - Wing ID to scramble
    
    Returns:
        Boolean - true if scramble initiated
*/
params ["_wingId"];

private _wingData = OpsRoom_AirWings get _wingId;
if (isNil "_wingData") exitWith {
    systemChat "Wing not found";
    false
};

// Scramble only available for Fighter wings
private _wingType = _wingData get "wingType";
if (_wingType != "Fighter") exitWith {
    systemChat "Only Fighter wings can scramble";
    false
};

// Set scramble mission parameters before launching
_wingData set ["mission", "scramble"];

// Scramble loiters around the runway/airfield
private _runwayPos = getMarkerPos "OpsRoom_runway";
_wingData set ["missionTarget", _runwayPos];

// Use standard launch
private _result = [_wingId] call OpsRoom_fnc_launchWing;

if (_result) then {
    private _wingName = _wingData get "name";
    ["FLASH", format ["SCRAMBLE: %1", _wingName],
        format ["%1 scrambled! Fighters launching to defend airfield.", _wingName]
    ] call OpsRoom_fnc_dispatch;
};

_result
