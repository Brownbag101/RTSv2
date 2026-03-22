/*
    Generate Recruit
    
    Generates a single recruit with randomized skills and quality.
    10% chance for "good" recruit with higher skills.
    
    Returns:
        HASHMAP - Recruit data structure
    
    Usage:
        private _recruit = [] call OpsRoom_fnc_generateRecruit;
*/

// Determine quality (10% good, 90% regular)
private _isGood = (random 1) < OpsRoom_Settings_RecruitmentGoodChance;

// British first/last names
private _firstNames = ["James", "William", "Robert", "Charles", "George", "Thomas", "Arthur", "Edward", "Henry", "Albert", "Frederick", "Ernest", "Walter", "Alfred", "Jack", "Harold", "Herbert", "Stanley", "Leonard", "Frank"];
private _lastNames = ["Smith", "Jones", "Williams", "Brown", "Davies", "Evans", "Wilson", "Thomas", "Roberts", "Johnson", "Taylor", "Walker", "White", "Harris", "Martin", "Thompson", "Wood", "Hughes", "Edwards", "Green"];

private _name = format ["Pvt. %1 %2", selectRandom _firstNames, selectRandom _lastNames];

// British unit types (FOW mod)
private _unitTypes = [
    "fow_s_uk_rifleman",
    "fow_s_uk_smg",
    "fow_s_uk_at",
    "fow_s_uk_ar",
    "fow_s_uk_grenadier",
    "fow_s_uk_rifleman"  // Weighted towards rifleman
];

// Generate skills
private _skills = createHashMap;
private _skillNames = ["aimingAccuracy", "aimingShake", "aimingSpeed", "spotDistance", "spotTime", "courage", "reloadSpeed", "commanding", "general"];

if (_isGood) then {
    // Good recruit: base 0.3, select 2-4 skills to boost
    private _boostedSkills = [];
    private _boostCount = 2 + floor(random 3); // 2-4 skills
    
    // Pick random skills to boost
    for "_i" from 0 to (_boostCount - 1) do {
        private _attempts = 0;
        while {_attempts < 20} do {
            private _skill = selectRandom _skillNames;
            if (!(_skill in _boostedSkills)) exitWith {
                _boostedSkills pushBack _skill;
            };
            _attempts = _attempts + 1;
        };
    };
    
    // Set skill values
    {
        if (_x in _boostedSkills) then {
            // Boosted skills: 0.5-1.0
            _skills set [_x, 0.5 + (random 0.5)];
        } else {
            // Normal skills: 0.3-0.5
            _skills set [_x, 0.3 + (random 0.2)];
        };
    } forEach _skillNames;
} else {
    // Regular recruit: flat 0.1
    {
        _skills set [_x, 0.1];
    } forEach _skillNames;
};

// Create recruit data structure
private _recruit = createHashMap;
_recruit set ["name", _name];
_recruit set ["unitType", selectRandom _unitTypes];
_recruit set ["quality", if (_isGood) then {"good"} else {"regular"}];
_recruit set ["skills", _skills];
_recruit set ["id", format ["recruit_%1_%2", floor(time), floor(random 999999)]];

diag_log format ["[OpsRoom] Generated %1 recruit: %2", if (_isGood) then {"GOOD"} else {"regular"}, _name];

_recruit;
