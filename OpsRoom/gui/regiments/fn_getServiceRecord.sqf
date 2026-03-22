/*
    Get Unit Service Record
    
    Returns the service record for a unit, creating one if it doesn't exist.
    Also updates time-based fields (timeInTheatre).
    
    Parameters:
        0: OBJECT - Unit
    
    Returns:
        HASHMAP - Service record
    
    Usage:
        private _record = [_unit] call OpsRoom_fnc_getServiceRecord;
*/

params [["_unit", objNull, [objNull]]];

if (isNull _unit) exitWith { createHashMap };

if (isNil "OpsRoom_UnitServiceRecords") then {
    OpsRoom_UnitServiceRecords = createHashMap;
};

private _key = str _unit;
private _record = OpsRoom_UnitServiceRecords getOrDefault [_key, createHashMap];

// Auto-create if missing
if (count _record == 0) then {
    _record = createHashMapFromArray [
        ["unit", _unit],
        ["name", name _unit],
        ["spawnTime", _unit getVariable ["OpsRoom_Unit_SpawnTime", time]],
        ["kills", _unit getVariable ["OpsRoom_Kills", 0]],
        ["killLog", []],
        ["operationsFought", []],
        ["operationsCompleted", []],
        ["operationsFailed", []],
        ["dispatches", []],
        ["timesInjured", 0],
        ["injuryLog", []],
        ["medals", []],
        ["timeInTheatre", 0],
        ["currentOperation", ""],
        ["promotionLog", []]
    ];
    OpsRoom_UnitServiceRecords set [_key, _record];
};

// Update time in theatre
private _spawnTime = _record getOrDefault ["spawnTime", time];
_record set ["timeInTheatre", time - _spawnTime];

// Update current name (may have changed after promotion)
_record set ["name", name _unit];

// Sync kills from variable if higher (backwards compat with old tracking)
private _varKills = _unit getVariable ["OpsRoom_Kills", 0];
private _recKills = _record getOrDefault ["kills", 0];
if (_varKills > _recKills) then {
    _record set ["kills", _varKills];
};

_record
