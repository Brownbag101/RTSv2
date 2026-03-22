/*
    Promote Unit
    
    Increases unit's rank by one level.
    Eventually will have restrictions (time, kills, etc).
    
    Parameters:
        0: OBJECT - Unit to promote
    
    Usage:
        [unitObject] call OpsRoom_fnc_promoteUnit;
*/

params [
    ["_unit", objNull, [objNull]]
];

if (isNull _unit) exitWith {
    hint "Error: No unit provided";
};

if (!alive _unit) exitWith {
    hint "Cannot promote deceased personnel";
};

private _currentRankId = rankId _unit;

// Check if already at max rank
if (_currentRankId >= 6) exitWith {
    hint format ["%1 is already at maximum rank (Colonel)", name _unit];
};

// Rank progression
private _newRank = switch (_currentRankId) do {
    case 0: {"CORPORAL"};       // Private → Corporal
    case 1: {"SERGEANT"};       // Corporal → Sergeant
    case 2: {"LIEUTENANT"};     // Sergeant → Lieutenant
    case 3: {"CAPTAIN"};        // Lieutenant → Captain
    case 4: {"MAJOR"};          // Captain → Major
    case 5: {"COLONEL"};        // Major → Colonel
    default {"CORPORAL"};
};

// Apply promotion
_unit setRank _newRank;

// Log promotion
diag_log format ["[OpsRoom] Promoted %1 to %2", name _unit, _newRank];

// Notify player
systemChat format ["✓ %1 promoted to %2", name _unit, _newRank];
hint format ["PROMOTION
    
%1
%2

Promoted to rank of %3

Well done!", 
    name _unit, 
    rank _unit,
    _newRank
];

// TODO: Future restrictions
// - Minimum time in current rank
// - Minimum kills required
// - Completion of objectives
// - Officer approval required
