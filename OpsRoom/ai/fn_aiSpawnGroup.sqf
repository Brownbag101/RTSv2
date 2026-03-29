/*
    fn_aiSpawnGroup
    
    Spawns an AI commander group from a template at a location.
    
    Parameters:
        0: STRING - Template key (e.g. "rifle_section")
        1: STRING - Location ID to spawn at
    
    Returns: HASHMAP with:
        "group"   - The created group
        "vehicle" - The vehicle (objNull if infantry only)
    
    Units spawn at the location position.
    Motorised groups get their vehicle spawned first, then units loaded.
    
    All spawned units are EAST side (enemy).
    FOW mod overwrites unit names async — we re-apply after a delay.
*/

params [["_templateKey", "", [""]], ["_spawnLocId", "", [""]]];

private _result = createHashMapFromArray [
    ["group", grpNull],
    ["vehicle", objNull]
];

if (_templateKey == "" || _spawnLocId == "") exitWith { _result };

private _template = OpsRoom_AI_GroupTemplates getOrDefault [_templateKey, createHashMap];
if (count _template == 0) exitWith {
    diag_log format ["[OpsRoom] aiSpawnGroup: Unknown template '%1'", _templateKey];
    _result
};

private _locData = OpsRoom_StrategicLocations getOrDefault [_spawnLocId, createHashMap];
if (count _locData == 0) exitWith {
    diag_log format ["[OpsRoom] aiSpawnGroup: Unknown location '%1'", _spawnLocId];
    _result
};

private _spawnPos = _locData get "pos";
private _units = _template get "units";
private _vehicleClass = _template getOrDefault ["vehicle", ""];
private _templateName = _template get "name";

// Create the group on WEST side
private _grp = createGroup [west, true];  // true = delete when empty
_grp setGroupIdGlobal [_templateName];

// Spawn vehicle first if motorised
private _veh = objNull;
if (_vehicleClass != "") then {
    // Find a road-adjacent position for vehicle spawn
    private _roads = _spawnPos nearRoads 100;
    private _vehPos = if (count _roads > 0) then {
        getPos (selectRandom _roads)
    } else {
        _spawnPos getPos [20, random 360]
    };
    
    _veh = createVehicle [_vehicleClass, _vehPos, [], 0, "NONE"];
    _veh setDir (random 360);
    
    diag_log format ["[OpsRoom] aiSpawnGroup: Vehicle '%1' spawned at %2", _vehicleClass, _vehPos];
};

// Spawn infantry units
// If motorised, spawn at vehicle position so moveInCargo works reliably
private _infantrySpawnPos = if (!isNull _veh) then { getPosATL _veh } else { _spawnPos };
private _spawnedUnits = [];
{
    _x params ["_className", "_count"];
    
    for "_i" from 1 to _count do {
        private _unitPos = _infantrySpawnPos getPos [2 + random 5, random 360];
        private _unit = _grp createUnit [_className, _unitPos, [], 0, "NONE"];
        
        if (!isNull _unit) then {
            _unit setSkill 0.6;
            _spawnedUnits pushBack _unit;
        };
    };
} forEach _units;

// Load units into vehicle if motorised
if (!isNull _veh && count _spawnedUnits > 0) then {
    // Small delay to let units fully initialise before boarding
    sleep 0.5;
    
    // Assign driver
    (_spawnedUnits select 0) assignAsDriver _veh;
    (_spawnedUnits select 0) moveInDriver _veh;
    
    // Load rest as cargo
    {
        if (_forEachIndex > 0) then {
            _x assignAsCargo _veh;
            _x moveInCargo _veh;
        };
    } forEach _spawnedUnits;
    
    // Verification loop — retry boarding for stragglers
    sleep 0.5;
    {
        if (vehicle _x == _x) then {
            // Unit not in any vehicle — force board
            _x moveInAny _veh;
            diag_log format ["[OpsRoom] aiSpawnGroup: Retrying board for %1", _x];
        };
    } forEach _spawnedUnits;
};

// Set combat behaviour
_grp setBehaviourStrong "SAFE";
_grp setCombatMode "RED";
_grp setSpeedMode "NORMAL";

// Tag group as AI commander managed
_grp setVariable ["OpsRoom_AI_Managed", true, true];
_grp setVariable ["OpsRoom_AI_TemplateKey", _templateKey, true];

diag_log format ["[OpsRoom] aiSpawnGroup: Spawned '%1' (%2 units) at %3",
    _templateName, count _spawnedUnits, _locData get "name"];

_result set ["group", _grp];
_result set ["vehicle", _veh];

_result
