/*
    Air Operations - Create Air Wing
    
    Creates a new Air Wing of the specified type.
    
    Parameters:
        _name     - Wing name (e.g., "No. 303 Squadron")
        _wingType - "Fighter", "GroundAttack", "Bomber", "Recon"
    
    Returns:
        String - Wing ID, or "" on failure
*/
params ["_name", "_wingType"];

// Validate wing type
if !(OpsRoom_WingTypes getOrDefault [_wingType, ""] isEqualType createHashMap) exitWith {
    diag_log format ["[OpsRoom] Air: Invalid wing type '%1'", _wingType];
    ""
};

// Generate wing ID
private _wingId = format ["wing_%1", OpsRoom_WingNextID];
OpsRoom_WingNextID = OpsRoom_WingNextID + 1;

// Create wing entry
private _wing = createHashMapFromArray [
    ["name", _name],
    ["wingType", _wingType],
    ["leader", objNull],
    ["leaderName", ""],
    ["aircraft", []],
    ["mission", ""],
    ["missionTarget", []],
    ["loiterMarker", ""],
    ["status", "STANDBY"],
    ["spawnedObjects", []]
];

OpsRoom_AirWings set [_wingId, _wing];

private _typeData = OpsRoom_WingTypes get _wingType;
private _typeDisplayName = _typeData get "displayName";

diag_log format ["[OpsRoom] Air: Created %1 '%2' as %3", _typeDisplayName, _name, _wingId];

// Dispatch
[
    format ["New %1 formed", _typeDisplayName],
    format ["%1 has been established as a %2. Assign aircraft and a Squadron Leader to begin operations.", _name, _typeDisplayName],
    "PRIORITY"
] call OpsRoom_fnc_dispatch;

_wingId
