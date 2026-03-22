/*
    Demote Unit
    
    Decreases unit's rank by one level.
    
    Parameters:
        0: OBJECT - Unit to demote
    
    Usage:
        [unitObject] call OpsRoom_fnc_demoteUnit;
*/

params [
    ["_unit", objNull, [objNull]]
];

if (isNull _unit) exitWith {
    hint "Error: No unit provided";
};

if (!alive _unit) exitWith {
    hint "Cannot demote deceased personnel";
};

private _currentRankId = rankId _unit;

// Check if already at minimum rank
if (_currentRankId <= 0) exitWith {
    hint format ["%1 is already at minimum rank (Private)", name _unit];
};

// Rank demotion
private _newRank = switch (_currentRankId) do {
    case 1: {"PRIVATE"};        // Corporal → Private
    case 2: {"CORPORAL"};       // Sergeant → Corporal
    case 3: {"SERGEANT"};       // Lieutenant → Sergeant
    case 4: {"LIEUTENANT"};     // Captain → Lieutenant
    case 5: {"CAPTAIN"};        // Major → Captain
    case 6: {"MAJOR"};          // Colonel → Major
    default {"PRIVATE"};
};

// Apply demotion
_unit setRank _newRank;

// Log demotion
diag_log format ["[OpsRoom] Demoted %1 to %2", name _unit, _newRank];

// Notify player
systemChat format ["! %1 demoted to %2", name _unit, _newRank];
hint format ["DEMOTION
    
%1

Demoted to rank of %2

Disciplinary action taken.", 
    name _unit,
    _newRank
];
