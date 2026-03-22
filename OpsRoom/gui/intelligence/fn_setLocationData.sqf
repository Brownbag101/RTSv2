/*
    fn_setLocationData
    
    Helper function for mission makers to set intel data on locations.
    Called from mission init scripts AFTER initStrategicLocations.
    
    Parameters:
        0: STRING - Location ID (e.g. "loc_factory_1")
        1: STRING - Data key to set
        2: ANY    - Value to set
    
    Available keys:
        "name"              - Custom display name
        "garrisonStrength"  - "Light" / "Moderate" / "Heavy" / "Fortified"
        "garrisonCount"     - Number of enemy personnel
        "reinforcements"    - Description string
        "defences"          - Description string
        "produces"          - What the location produces
        "officerName"       - Name of commanding officer (tier 5)
        "officerRank"       - Rank of commanding officer (tier 5)
        "status"            - "enemy" / "friendly" / "contested" / "destroyed"
    
    Example usage in mission init:
        ["loc_factory_1", "garrisonStrength", "Heavy"] call OpsRoom_fnc_setLocationData;
        ["loc_factory_1", "garrisonCount", 45] call OpsRoom_fnc_setLocationData;
        ["loc_factory_1", "reinforcements", "2 platoons from Camp 3 (15 min response)"] call OpsRoom_fnc_setLocationData;
        ["loc_factory_1", "produces", "Ammunition"] call OpsRoom_fnc_setLocationData;
*/

params [["_locId", "", [""]], ["_key", "", [""]], ["_value", nil]];

if (_locId == "" || _key == "") exitWith {
    systemChat "Intel ERROR: setLocationData requires locId and key";
    false
};

if (isNil "_value") exitWith {
    systemChat "Intel ERROR: setLocationData requires a value";
    false
};

private _locData = OpsRoom_StrategicLocations getOrDefault [_locId, createHashMap];
if (count _locData == 0) exitWith {
    systemChat format ["Intel ERROR: Location '%1' not found", _locId];
    false
};

// Validate key
private _validKeys = ["name", "garrisonStrength", "garrisonCount", "reinforcements", "defences", "produces", "officerName", "officerRank", "status"];

if !(_key in _validKeys) exitWith {
    systemChat format ["Intel ERROR: Invalid key '%1'. Valid: %2", _key, _validKeys joinString ", "];
    false
};

_locData set [_key, _value];
OpsRoom_StrategicLocations set [_locId, _locData];

// If status changed, update map markers immediately
if (_key == "status") then {
    [_locId] call OpsRoom_fnc_updateMapMarkers;
    
    // If location is now friendly, set intel to 100%
    if (_value == "friendly") then {
        _locData set ["intelPercent", 100];
        _locData set ["intelTier", 5];
        _locData set ["discovered", true];
        OpsRoom_StrategicLocations set [_locId, _locData];
    };
};

true
