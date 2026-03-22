/*
    fn_updateMapMarkers
    
    Creates or updates map markers for a strategic location
    based on its current intel tier AND ownership.
    
    Parameters:
        0: STRING - Location ID
    
    Marker behaviour by tier:
        Tier 0: No marker (location unknown)
        Tier 1: "?" marker at position (something detected)
        Tier 2+: Type-specific icon with name
    
    Ownership colours:
        BRITISH:  Green marker
        NAZI:     Red marker  
        NEUTRAL:  Grey marker
        Contested: Yellow warning marker (flashing via alpha)
*/

params [["_locId", "", [""]]];

if (_locId == "") exitWith {};

private _locData = OpsRoom_StrategicLocations getOrDefault [_locId, createHashMap];
if (count _locData == 0) exitWith {};

private _pos = _locData get "pos";
private _tier = _locData get "intelTier";
private _status = _locData get "status";
private _name = _locData get "name";
private _type = _locData get "type";
private _mapMarkerName = _locData get "mapMarkerName";
private _owner = _locData getOrDefault ["owner", "NAZI"];
private _contested = _locData getOrDefault ["contested", false];
private _captureProgress = _locData getOrDefault ["captureProgress", 0];

// Delete existing marker if present
if (markerType _mapMarkerName != "") then {
    deleteMarker _mapMarkerName;
};

// Also delete capture progress marker if it exists
private _progressMarkerName = _mapMarkerName + "_progress";
if (markerType _progressMarkerName != "") then {
    deleteMarker _progressMarkerName;
};

// Tier 0: No marker at all (unless British-owned)
if (_tier == 0 && _owner != "BRITISH") exitWith {};

// Create the marker
private _marker = createMarker [_mapMarkerName, _pos];

// Determine colour based on ownership
private _ownerColor = switch (_owner) do {
    case "BRITISH": { "ColorBLUFOR" };
    case "NAZI":    { "ColorOPFOR" };
    case "NEUTRAL": { "ColorGrey" };
    default         { "ColorOPFOR" };
};

// Override for contested
if (_contested) then {
    _ownerColor = "ColorYellow";
};

switch (true) do {
    // Destroyed location
    case (_status == "destroyed"): {
        _marker setMarkerType "mil_destroy";
        _marker setMarkerColor "ColorGrey";
        _marker setMarkerText format ["[DESTROYED] %1", _name];
        _marker setMarkerAlpha 0.5;
    };
    
    // Contested location (both sides present)
    case (_contested): {
        _marker setMarkerType "mil_warning";
        _marker setMarkerColor "ColorYellow";
        private _progressStr = if (_captureProgress > 0) then {
            format [" (%1%%)", round _captureProgress]
        } else { "" };
        _marker setMarkerText format ["⚔ %1%2", _name, _progressStr];
        _marker setMarkerAlpha 1.0;
    };
    
    // British-owned location
    case (_owner == "BRITISH"): {
        _marker setMarkerType "mil_flag";
        _marker setMarkerColor "ColorBLUFOR";
        _marker setMarkerText _name;
        _marker setMarkerAlpha 1.0;
    };
    
    // Neutral location
    case (_owner == "NEUTRAL"): {
        _marker setMarkerType "mil_dot";
        _marker setMarkerColor "ColorGrey";
        _marker setMarkerText _name;
        _marker setMarkerAlpha 0.7;
    };
    
    // Enemy - Tier 1: Unknown contact
    case (_tier == 1): {
        _marker setMarkerType "mil_unknown";
        _marker setMarkerColor _ownerColor;
        _marker setMarkerText "?";
        _marker setMarkerAlpha 0.7;
    };
    
    // Enemy - Tier 2: Identified
    case (_tier == 2): {
        _marker setMarkerType "mil_objective";
        _marker setMarkerColor _ownerColor;
        private _typeData = OpsRoom_LocationTypes getOrDefault [_type, createHashMap];
        private _typeName = if (count _typeData > 0) then { _typeData get "displayName" } else { "Location" };
        _marker setMarkerText format ["%1 (%2)", _name, _typeName];
        _marker setMarkerAlpha 0.8;
    };
    
    // Enemy - Tier 3: Observed (more detail)
    case (_tier == 3): {
        _marker setMarkerType "mil_objective";
        _marker setMarkerColor _ownerColor;
        private _garrison = _locData get "garrisonStrength";
        _marker setMarkerText format ["%1 [%2]", _name, _garrison];
        _marker setMarkerAlpha 0.9;
    };
    
    // Enemy - Tier 4-5: Detailed/Compromised
    case (_tier >= 4): {
        _marker setMarkerType "mil_objective";
        _marker setMarkerColor _ownerColor;
        private _garrisonCount = _locData get "garrisonCount";
        private _garrison = _locData get "garrisonStrength";
        if (_garrisonCount > 0) then {
            _marker setMarkerText format ["%1 [%2 - %3 men]", _name, _garrison, _garrisonCount];
        } else {
            _marker setMarkerText format ["%1 [%2]", _name, _garrison];
        };
        _marker setMarkerAlpha 1.0;
    };
};

// Store that marker has been created
_locData set ["mapMarkerCreated", true];
OpsRoom_StrategicLocations set [_locId, _locData];
