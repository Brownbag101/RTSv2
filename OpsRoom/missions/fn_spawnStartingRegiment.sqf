/*
    Spawn Starting Regiment
    
    Spawns the 1st Essex Regiment (10 British infantry) near the player.
    Units are added to Zeus curator and formed into a group.
    
    Returns:
        ARRAY - Spawned unit objects
    
    Usage:
        private _units = [] call OpsRoom_fnc_spawnStartingRegiment;
*/

private _player = player;
private _spawnPos = _player getPos [20, random 360];

// Get player's side for spawning units
private _playerSide = side _player;
if (_playerSide == sideLogic) then {
    _playerSide = independent;  // Default to independent if player is Zeus logic
};

diag_log format ["[OpsRoom Mission1] Player side: %1, spawning units as: %2", side _player, _playerSide];

// Unit composition for 1st Essex Regiment
private _unitClasses = [
    "JMSSA_gb_rifle_serg",  // 1 - Group Leader (will be Major)
    "JMSSA_gb_rifle_cpl",   // 2
    "JMSSA_gb_rifle_rifle", // 3
    "JMSSA_gb_rifle_rifle", // 4
    "JMSSA_gb_rifle_rifle", // 5
    "JMSSA_gb_rifle_cpl",   // 6
    "JMSSA_gb_rifle_rifle", // 7
    "JMSSA_gb_rifle_mg",    // 8
    "JMSSA_gb_rifle_mg",    // 9
    "JMSSA_gb_rifle_serg"   // 10
];

private _spawnedUnits = [];
private _group = createGroup [_playerSide, true];

// Spawn units
{
    private _unitClass = _x;
    private _unit = _group createUnit [_unitClass, _spawnPos, [], 5, "FORM"];
    
    // First unit becomes Major (Commanding Officer)
    if (_forEachIndex == 0) then {
        _unit setRank "MAJOR";
        _group selectLeader _unit;
    };
    
    // Track spawn time for stats
    private _varName = format ["OpsRoom_Unit_%1_SpawnTime", _unit];
    missionNamespace setVariable [_varName, time];
    
    // Track kills made BY this unit
    _unit addEventHandler ["FiredMan", {
        params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile"];
        
        // Track when projectile hits and kills
        _projectile addEventHandler ["HitPart", {
            params ["_projectile", "_hitEntity", "_projectileOwner", "_pos", "_velocity", "_selection", "_ammo", "_vector", "_radius", "_surfaceType", "_isDirect"];
            
            if (!isNull _hitEntity && _hitEntity isKindOf "Man" && !alive _hitEntity) then {
                private _shooter = _projectileOwner;
                if (!isNull _shooter) then {
                    private _kills = _shooter getVariable ["OpsRoom_Kills", 0];
                    _shooter setVariable ["OpsRoom_Kills", _kills + 1];
                    diag_log format ["[OpsRoom] %1 killed %2 (+1 kill, total: %3)", name _shooter, name _hitEntity, _kills + 1];
                };
            };
        }];
    }];
    
    // Register for service record tracking
    [_unit] call OpsRoom_fnc_registerUnitService;
    
    _spawnedUnits pushBack _unit;
    
    diag_log format ["[OpsRoom Mission1] Spawned: %1 (Rank: %2)", typeOf _unit, rank _unit];
} forEach _unitClasses;

// Set group formation
_group setFormation "LINE";

// Set group name to "1st Essex Regiment"
_group setGroupIdGlobal ["1st Essex Regiment"];

// Set abilities on specific units
// Leader (index 0) = Captain with Regroup ability
(_spawnedUnits select 0) setVariable ["OpsRoom_Rank", "CAPTAIN", true];

// MG gunners (index 7, 8) get Suppressive Fire ability  
if (count _spawnedUnits > 7) then {
    (_spawnedUnits select 7) setVariable ["OpsRoom_Ability_SuppressiveFire", true, true];
};
if (count _spawnedUnits > 8) then {
    (_spawnedUnits select 8) setVariable ["OpsRoom_Ability_SuppressiveFire", true, true];
};

diag_log format ["[OpsRoom Mission1] Group named: %1", groupId _group];
diag_log "[OpsRoom Mission1] Abilities assigned: Captain (regroup), 2x MG (suppressive fire)";

// Find Zeus curator and add units
private _curator = objNull;

// Try variable name "z1" first
if (!isNil "z1") then {
    _curator = z1;
};

// Fallback: search for any curator
if (isNull _curator) then {
    _curator = getAssignedCuratorLogic _player;
};

// Last resort: find any curator in mission
if (isNull _curator) then {
    {
        if (_x isKindOf "ModuleCurator_F") exitWith {
            _curator = _x;
        };
    } forEach allCurators;
};

// Add units to curator
if (!isNull _curator) then {
    {
        _curator addCuratorEditableObjects [[_x], false];
    } forEach _spawnedUnits;
    
    diag_log format ["[OpsRoom Mission1] Added %1 units to curator: %2", count _spawnedUnits, _curator];
} else {
    diag_log "[OpsRoom Mission1] WARNING: No curator found - units not added to Zeus";
};

// Store spawn position for task marker
missionNamespace setVariable ["OpsRoom_Mission1_SpawnPos", _spawnPos];

systemChat format ["✓ 1st Essex Regiment deployed: %1 personnel", count _spawnedUnits];

_spawnedUnits
