/*
    fn_intelMonitor
    
    Background loop that runs every 30 seconds.
    Checks all strategic locations for nearby friendly units.
    Updates intel percentages and tiers.
    Creates/updates map markers based on intel level.
*/

// Don't start multiple monitors
if (!isNil "OpsRoom_IntelMonitorRunning" && {OpsRoom_IntelMonitorRunning}) exitWith {
    systemChat "Intel Monitor already running";
};

OpsRoom_IntelMonitorRunning = true;
systemChat "Intel: Monitor started (30s cycle)";

while {OpsRoom_IntelMonitorRunning} do {
    
    // Process each strategic location
    {
        private _locId = _x;
        private _locData = _y;
        
        // Skip friendly/destroyed locations for intel gathering
        private _status = _locData get "status";
        
        // Calculate intel gain
        private _gain = [_locId] call OpsRoom_fnc_gatherIntel;
        
        if (_gain != 0) then {
            private _oldPercent = _locData get "intelPercent";
            private _newPercent = (_oldPercent + _gain) max 0 min 100;
            private _oldTier = [_oldPercent] call OpsRoom_fnc_getIntelLevel;
            private _newTier = [_newPercent] call OpsRoom_fnc_getIntelLevel;
            
            // Update data
            _locData set ["intelPercent", _newPercent];
            _locData set ["intelTier", _newTier];
            _locData set ["lastUpdated", time];
            OpsRoom_StrategicLocations set [_locId, _locData];
            
            // Tier changed? Notify player
            if (_newTier > _oldTier) then {
                private _name = _locData get "name";
                private _tierNames = ["Unknown", "Detected", "Identified", "Observed", "Detailed", "Compromised"];
                private _tierName = _tierNames select _newTier;
                
                ["ROUTINE", "INTEL UPDATE", format ["%1 — Intelligence level: %2 (%3%%)", _name, _tierName, round _newPercent], _locData get "pos"] call OpsRoom_fnc_dispatch;
                
                // Tier 2 reveal: show what the location type is
                if (_newTier == 2) then {
                    private _typeData = OpsRoom_LocationTypes get (_locData get "type");
                    private _typeName = _typeData get "displayName";
                    private _produces = _locData get "produces";
                    private _msg = if (_produces != "") then {
                        format ["%1 identified as %2. Produces: %3", _name, _typeName, _produces]
                    } else {
                        format ["%1 identified as %2", _name, _typeName]
                    };
                    ["PRIORITY", "LOCATION IDENTIFIED", _msg, _locData get "pos"] call OpsRoom_fnc_dispatch;
                };
                
                // Tier 3 reveal: garrison strength
                if (_newTier == 3) then {
                    private _garrison = _locData get "garrisonStrength";
                    if (_garrison != "Unknown") then {
                        ["PRIORITY", "GARRISON ASSESSED", format ["%1 — Enemy garrison: %2", _name, _garrison], _locData get "pos"] call OpsRoom_fnc_dispatch;
                    };
                };
            };
            
            // Update map markers
            [_locId] call OpsRoom_fnc_updateMapMarkers;
        };
        
    } forEach OpsRoom_StrategicLocations;
    
    sleep 30;
};
