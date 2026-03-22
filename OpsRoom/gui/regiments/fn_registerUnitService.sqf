/*
    Register Unit for Service Tracking
    
    Creates a service record entry for a unit and attaches injury tracking.
    Kill tracking is handled by a mission-level EntityKilled EH (see initServiceRecords).
    
    Call this whenever a unit is spawned (recruit or starting regiment).
    
    Parameters:
        0: OBJECT - Unit to register
    
    Usage:
        [_unit] call OpsRoom_fnc_registerUnitService;
*/

params [["_unit", objNull, [objNull]]];

if (isNull _unit) exitWith {};
if (isNil "OpsRoom_UnitServiceRecords") then {
    OpsRoom_UnitServiceRecords = createHashMap;
};

// Create record if not exists
private _key = str _unit;
if !(_key in OpsRoom_UnitServiceRecords) then {
    private _record = createHashMapFromArray [
        ["unit", _unit],
        ["name", name _unit],
        ["spawnTime", time],
        ["kills", 0],
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
    diag_log format ["[OpsRoom Service] Created record for: %1 (key: %2)", name _unit, _key];
};

// ========================================
// INJURY TRACKING via Hit EH
// ========================================
_unit addEventHandler ["Hit", {
    params ["_unit", "_source", "_damage", "_instigator"];
    
    // Only track if significant damage and from enemy
    if (_damage > 0.3 && {!isNull _source} && {side _source != side _unit}) then {
        private _key = str _unit;
        private _record = OpsRoom_UnitServiceRecords getOrDefault [_key, createHashMap];
        if (count _record > 0) then {
            // Cooldown: don't count multiple hits in quick succession
            private _lastInjury = _unit getVariable ["OpsRoom_LastInjuryTime", -999];
            if (time - _lastInjury > 30) then {
                private _injuries = _record getOrDefault ["timesInjured", 0];
                _record set ["timesInjured", _injuries + 1];
                
                private _injuryLog = _record getOrDefault ["injuryLog", []];
                private _currentOp = _record getOrDefault ["currentOperation", ""];
                _injuryLog pushBack [time, _currentOp, mapGridPosition (getPos _unit)];
                _record set ["injuryLog", _injuryLog];
                
                OpsRoom_UnitServiceRecords set [_key, _record];
                _unit setVariable ["OpsRoom_LastInjuryTime", time];
                
                diag_log format ["[OpsRoom Service] %1 wounded (injury #%2) during %3", name _unit, _injuries + 1, _currentOp];
            };
        };
    };
}];

diag_log format ["[OpsRoom Service] Registered: %1", name _unit];
