/*
    Initialize Unit Service Records System
    
    Creates the central OpsRoom_UnitServiceRecords hashmap, medal definitions,
    and a mission-level EntityKilled event handler for kill tracking.
    Called once during OpsRoom init.
    
    Usage:
        [] call OpsRoom_fnc_initServiceRecords;
*/

// Central service records: keyed by unit object string
if (isNil "OpsRoom_UnitServiceRecords") then {
    OpsRoom_UnitServiceRecords = createHashMap;
};

// Medal definitions: [id, name, symbol, color, description, check function]
OpsRoom_MedalDefinitions = [
    ["purple_heart", "Purple Heart", "♥", "#AA44CC", "Wounded in action during an operation", {
        params ["_record"];
        (_record getOrDefault ["timesInjured", 0]) > 0
    }],
    ["service_medal", "Service Medal", "★", "#FFD700", "Participated in 5 or more operations", {
        params ["_record"];
        count (_record getOrDefault ["operationsFought", []]) >= 5
    }],
    ["gallantry_medal", "Gallantry Medal", "✦", "#FF4444", "10 or more confirmed kills", {
        params ["_record"];
        (_record getOrDefault ["kills", 0]) >= 10
    }],
    ["distinguished_service", "Distinguished Service Cross", "✪", "#4488FF", "Completed 10 operations successfully", {
        params ["_record"];
        count (_record getOrDefault ["operationsCompleted", []]) >= 10
    }],
    ["first_blood", "First Blood", "†", "#CC0000", "First confirmed kill", {
        params ["_record"];
        (_record getOrDefault ["kills", 0]) >= 1
    }],
    ["iron_will", "Iron Will", "◆", "#888888", "Survived being wounded 3 times", {
        params ["_record"];
        (_record getOrDefault ["timesInjured", 0]) >= 3
    }],
    ["veteran", "Veteran", "▣", "#88AA44", "Served over 1 hour in theatre", {
        params ["_record"];
        (_record getOrDefault ["timeInTheatre", 0]) > 3600
    }]
];

// ========================================
// MISSION-LEVEL KILL TRACKING
// ========================================
// EntityKilled fires for EVERY unit death in the mission.
// We check if the killer has a service record (= one of our tracked units).
addMissionEventHandler ["EntityKilled", {
    params ["_killed", "_killer", "_instigator"];
    
    // Determine who gets credit — instigator is most accurate, fallback to killer
    private _creditUnit = if (!isNull _instigator) then { _instigator } else { _killer };
    
    // Skip if no valid killer or suicide
    if (isNull _creditUnit) exitWith {};
    if (_creditUnit == _killed) exitWith {};
    
    // Only credit units that are infantry (Man)
    if !(_creditUnit isKindOf "CAManBase") exitWith {};
    
    // Skip friendly fire — killer and killed must be on different sides
    if (side group _creditUnit == side group _killed) exitWith {};
    
    // Check if this unit has a service record (= tracked by us)
    private _killerKey = str _creditUnit;
    if !(_killerKey in OpsRoom_UnitServiceRecords) exitWith {};
    
    private _record = OpsRoom_UnitServiceRecords get _killerKey;
    
    // Credit the kill
    private _kills = _record getOrDefault ["kills", 0];
    _record set ["kills", _kills + 1];
    
    // Kill log entry
    private _killLog = _record getOrDefault ["killLog", []];
    private _enemyName = getText (configFile >> "CfgVehicles" >> typeOf _killed >> "displayName");
    if (_enemyName == "") then { _enemyName = typeOf _killed };
    _killLog pushBack [time, _enemyName, mapGridPosition (getPos _killed)];
    _record set ["killLog", _killLog];
    
    // Also update the old variable for HUD compatibility
    _creditUnit setVariable ["OpsRoom_Kills", _kills + 1];
    
    OpsRoom_UnitServiceRecords set [_killerKey, _record];
    
    systemChat format ["[KILL] %1 eliminated %2 (Total: %3)", name _creditUnit, _enemyName, _kills + 1];
    diag_log format ["[OpsRoom Service] KILL: %1 eliminated %2 (total: %3) | killer side: %4 | killed side: %5", 
        name _creditUnit, _enemyName, _kills + 1, side group _creditUnit, side group _killed];
}];

diag_log "[OpsRoom] Service records system initialized (with EntityKilled EH)";
