/*
    Air Operations - Process Recon Photos
    
    Called when a photo recon wing lands.
    Takes the accumulated photo intel from the sortie and applies it
    to strategic locations, capped at 75%.
    
    Generates a dispatch report summarising what was found.
    Updates map markers for any locations whose tier changed.
    
    Parameters:
        0: STRING - Wing ID
    
    Photo intel is stored on wing data as:
        "photoIntel" → HashMap [ "loc_id" → gain_amount, ... ]
*/

params [["_wingId", "", [""]]];

if (_wingId == "") exitWith {};

private _wingData = OpsRoom_AirWings get _wingId;
if (isNil "_wingData") exitWith {};

private _wingName = _wingData get "name";
private _photoIntel = _wingData getOrDefault ["photoIntel", createHashMap];

// Nothing photographed?
if (count _photoIntel == 0) exitWith {
    ["ROUTINE", format ["RECON REPORT: %1", _wingName],
        format ["%1 returned with no photo intelligence. No strategic locations overflown.", _wingName]
    ] call OpsRoom_fnc_dispatch;
    
    diag_log format ["[OpsRoom] Photo Recon: %1 landed with no photos", _wingId];
};

// Process each photographed location
private _locationsUpdated = 0;
private _tiersChanged = 0;
private _reportLines = [];
private _photoCap = 75;  // Photo recon caps at 75% (Tier 4: Detailed)

{
    private _locId = _x;
    private _gain = _y;
    
    private _locData = OpsRoom_StrategicLocations getOrDefault [_locId, createHashMap];
    if (count _locData == 0) then { continue };
    
    private _locName = _locData get "name";
    private _oldPercent = _locData get "intelPercent";
    private _oldTier = [_oldPercent] call OpsRoom_fnc_getIntelLevel;
    
    // Apply gain, capped at photo recon maximum
    private _newPercent = (_oldPercent + _gain) min _photoCap;
    
    // Only update if there's actual gain
    if (_newPercent > _oldPercent) then {
        private _actualGain = _newPercent - _oldPercent;
        private _newTier = [_newPercent] call OpsRoom_fnc_getIntelLevel;
        
        // Update location data
        _locData set ["intelPercent", _newPercent];
        _locData set ["intelTier", _newTier];
        _locData set ["lastUpdated", time];
        OpsRoom_StrategicLocations set [_locId, _locData];
        
        _locationsUpdated = _locationsUpdated + 1;
        
        // Build report line
        private _tierNames = ["Unknown", "Detected", "Identified", "Observed", "Detailed", "Compromised"];
        private _tierName = _tierNames select _newTier;
        _reportLines pushBack format ["  %1: +%2%% → %3%% (%4)", _locName, round _actualGain, round _newPercent, _tierName];
        
        // Tier changed? Extra notification
        if (_newTier > _oldTier) then {
            _tiersChanged = _tiersChanged + 1;
            
            // Tier-specific reveals (same as intelMonitor)
            if (_newTier == 2) then {
                private _typeData = OpsRoom_LocationTypes get (_locData get "type");
                private _typeName = _typeData get "displayName";
                private _produces = _locData get "produces";
                private _msg = if (_produces != "") then {
                    format ["%1 identified as %2. Produces: %3", _locName, _typeName, _produces]
                } else {
                    format ["%1 identified as %2", _locName, _typeName]
                };
                ["PRIORITY", "PHOTO INTEL: IDENTIFIED", _msg, _locData get "pos"] call OpsRoom_fnc_dispatch;
            };
            
            if (_newTier == 3) then {
                private _garrison = _locData get "garrisonStrength";
                if (_garrison != "Unknown") then {
                    ["PRIORITY", "PHOTO INTEL: GARRISON", format ["%1 — Enemy garrison assessed: %2", _locName, _garrison], _locData get "pos"] call OpsRoom_fnc_dispatch;
                };
            };
            
            if (_newTier == 4) then {
                ["PRIORITY", "PHOTO INTEL: DETAILED", format ["Detailed reconnaissance of %1 complete. Full assessment available.", _locName], _locData get "pos"] call OpsRoom_fnc_dispatch;
            };
        };
        
        // Update map markers
        [_locId] call OpsRoom_fnc_updateMapMarkers;
    };
} forEach _photoIntel;

// Generate summary dispatch
private _mission = _wingData getOrDefault ["mission", "recon_photo_high"];
private _missionType = if (_mission == "recon_photo_high") then { "High-Level" } else { "Low-Level" };

private _summaryBody = format [
    "%1 %2 Photo Reconnaissance Report\n%3 location(s) photographed, %4 intelligence tier(s) upgraded.\n\n%5",
    _wingName,
    _missionType,
    _locationsUpdated,
    _tiersChanged,
    _reportLines joinString "\n"
];

["PRIORITY", format ["RECON REPORT: %1", _wingName], _summaryBody] call OpsRoom_fnc_dispatch;

// Clear photo intel from wing (consumed)
_wingData set ["photoIntel", createHashMap];

systemChat format ["%1: Photo reconnaissance report filed. %2 locations updated.", _wingName, _locationsUpdated];
diag_log format ["[OpsRoom] Photo Recon: %1 processed %2 photos, %3 tier changes", _wingId, _locationsUpdated, _tiersChanged];
