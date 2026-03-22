/*
    Debug - Spawn Test Air Crew
    
    Spawns 10 pilots and 10 air gunners at the pilot ready point
    with all proper qualifications, pool assignments, and uniforms.
    
    Usage (from debug console):
        [] call OpsRoom_fnc_spawnTestAirCrew;
*/

// Determine spawn position
private _spawnPos = if (markerType "OpsRoom_pilot_ready" != "") then {
    getMarkerPos "OpsRoom_pilot_ready"
} else {
    if (markerType "OpsRoom_hangar" != "") then {
        getMarkerPos "OpsRoom_hangar"
    } else {
        getPos player
    };
};

// Init pools if needed
if (isNil "OpsRoom_PilotPool") then { OpsRoom_PilotPool = [] };
if (isNil "OpsRoom_CrewPool") then { OpsRoom_CrewPool = [] };

private _curator = getAssignedCuratorLogic player;

// British first names / surnames for variety
private _firstNames = ["Arthur", "William", "George", "Edward", "Thomas", "Harold", "James", "Albert", "Frederick", "Charles", "Stanley", "Walter", "Ernest", "Leonard", "Reginald", "Herbert", "Norman", "Bernard", "Percy", "Clifford"];
private _surnames = ["Smith", "Jones", "Taylor", "Brown", "Wilson", "Davies", "Evans", "Thomas", "Walker", "Roberts", "Clarke", "Baker", "Harris", "Mitchell", "Young", "Green", "Wood", "Hall", "Turner", "Lewis"];

// === SPAWN 10 PILOTS ===
for "_i" from 1 to 10 do {
    private _grp = createGroup [independent, true];
    private _pos = _spawnPos vectorAdd [random 4 - 2, random 4 - 2, 0];
    private _unit = _grp createUnit ["I_Pilot_F", _pos, [], 0, "NONE"];
    _unit setPos _pos;
    
    // Name
    private _name = format ["%1 %2", selectRandom _firstNames, selectRandom _surnames];
    _unit setName _name;
    
    // Pilot uniform
    removeAllWeapons _unit;
    removeAllItems _unit;
    removeAllAssignedItems _unit;
    removeUniform _unit;
    removeVest _unit;
    removeBackpack _unit;
    removeHeadgear _unit;
    _unit forceAddUniform "sab_fl_pilotuniform_green";
    _unit addBackpack "B_Parachute";
    
    // Qualifications
    _unit setVariable ["OpsRoom_Qualifications", ["pilot"], true];
    _unit setVariable ["OpsRoom_IsPilot", true, true];
    _unit setVariable ["BIS_fnc_setIdentity_done", true];
    
    // Pilot skill
    _unit setSkill 0.8;
    
    // Add to pool
    OpsRoom_PilotPool pushBack _unit;
    
    // Add to Zeus
    if (!isNull _curator) then {
        _curator addCuratorEditableObjects [[_unit], true];
    };
    
    diag_log format ["[OpsRoom] Debug: Spawned pilot %1 (%2)", _name, _i];
};

// === SPAWN 10 AIR GUNNERS ===
for "_i" from 1 to 10 do {
    private _grp = createGroup [independent, true];
    private _pos = _spawnPos vectorAdd [random 4 - 2, random 4 - 2, 0];
    private _unit = _grp createUnit ["I_Pilot_F", _pos, [], 0, "NONE"];
    _unit setPos _pos;
    
    // Name
    private _name = format ["%1 %2", selectRandom _firstNames, selectRandom _surnames];
    _unit setName _name;
    
    // Crew uniform (same as pilot for now)
    removeAllWeapons _unit;
    removeAllItems _unit;
    removeAllAssignedItems _unit;
    removeUniform _unit;
    removeVest _unit;
    removeBackpack _unit;
    removeHeadgear _unit;
    _unit forceAddUniform "sab_fl_pilotuniform_green";
    
    // Qualifications
    _unit setVariable ["OpsRoom_Qualifications", ["airCrew"], true];
    _unit setVariable ["OpsRoom_IsPilot", true, true];  // Exclude from auto-detach
    _unit setVariable ["BIS_fnc_setIdentity_done", true];
    
    // Gunner skill
    _unit setSkill 0.7;
    
    // Add to pool
    OpsRoom_CrewPool pushBack _unit;
    
    // Add to Zeus
    if (!isNull _curator) then {
        _curator addCuratorEditableObjects [[_unit], true];
    };
    
    diag_log format ["[OpsRoom] Debug: Spawned air gunner %1 (%2)", _name, _i];
};

systemChat format ["DEBUG: Spawned 10 pilots and 10 air gunners at ready point. Pools: %1 pilots, %2 crew", count OpsRoom_PilotPool, count OpsRoom_CrewPool];
diag_log format ["[OpsRoom] Debug: Air crew spawn complete. PilotPool: %1, CrewPool: %2", count OpsRoom_PilotPool, count OpsRoom_CrewPool];
