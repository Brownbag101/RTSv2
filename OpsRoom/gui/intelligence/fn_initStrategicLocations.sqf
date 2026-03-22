/*
    fn_initStrategicLocations
    
    Scans Eden Editor markers for strategic locations.
    Mission maker places markers named: opsroom_[type]_[number]
    
    Examples:
        opsroom_factory_1
        opsroom_port_1
        opsroom_town_1
        opsroom_airfield_1
        opsroom_camp_1
        opsroom_bridge_1
    
    Optional: Set marker text in Eden to give a custom name.
    If no text set, auto-generates name from type + number.
    
    Each location gets a garrison config via marker variables (optional):
        markerName setVariable ["opsroom_garrison", "Heavy"];
        markerName setVariable ["opsroom_garrisonCount", 45];
        markerName setVariable ["opsroom_reinforcements", "2 platoons from town_3"];
        markerName setVariable ["opsroom_produces", "Ammunition"];
    
    Or these can be set in a mission init script for full control.
*/

// Initialize the global locations hashmap
OpsRoom_StrategicLocations = createHashMap;
OpsRoom_IntelNextID = 1;

// Get all markers in the mission
private _allMarkers = allMapMarkers;
private _foundCount = 0;

{
    private _markerName = _x;
    
    // Check if marker name starts with "opsroom_"
    if (_markerName find "opsroom_" == 0) then {
        
        // Parse type from marker name: opsroom_[type]_[number]
        private _parts = _markerName splitString "_";
        
        // Must be EXACTLY 3 parts: "opsroom", type, number
        // Skip markers with extra parts (e.g. opsroom_sealane_1_port_1_wp_1)
        if (count _parts == 3) then {
            private _type = _parts select 1;
            private _number = _parts select 2;
            
            // Check if this type exists in our definitions
            if (_type in OpsRoom_LocationTypes) then {
                
                private _typeData = OpsRoom_LocationTypes get _type;
                private _pos = getMarkerPos _markerName;
                
                // Get custom name from marker text, or auto-generate
                private _customName = markerText _markerName;
                private _displayName = if (_customName != "") then {
                    _customName
                } else {
                    format ["%1 %2", _typeData get "displayName", _number]
                };
                
                // Create location ID
                private _locId = format ["loc_%1_%2", _type, _number];
                
                // Get capture config from type data
                private _captureRadius = _typeData getOrDefault ["captureRadius", 200];
                private _captureTime = _typeData getOrDefault ["captureTime", 300];
                
                // Check for mission-maker override of owner via marker variable
                // Default: NAZI (liberating scenario)
                private _defaultOwner = "NAZI";
                
                // Build location data
                private _locData = createHashMapFromArray [
                    // Identity
                    ["id", _locId],
                    ["name", _displayName],
                    ["type", _type],
                    ["pos", _pos],
                    ["markerName", _markerName],
                    
                    // Intel state
                    ["intelPercent", 0],
                    ["intelTier", 0],
                    ["discovered", false],
                    ["lastUpdated", 0],
                    
                    // Intel data (revealed at different tiers)
                    // Tier 2: type + produces
                    ["produces", _typeData get "produces"],
                    
                    // Tier 3: garrison strength (rough)
                    ["garrisonStrength", "Unknown"],    // Light / Moderate / Heavy / Fortified
                    
                    // Tier 4: exact numbers + reinforcements
                    ["garrisonCount", 0],
                    ["reinforcements", "Unknown"],
                    ["defences", "Unknown"],
                    
                    // Tier 5: real-time (SOE future)
                    ["officerName", ""],
                    ["officerRank", ""],
                    
                    // Status
                    ["status", "enemy"],        // enemy / friendly / contested / destroyed
                    ["taskTypes", _typeData get "taskTypes"],
                    
                    // Ownership
                    ["owner", _defaultOwner],          // BRITISH / NAZI / NEUTRAL
                    ["previousOwner", ""],
                    ["capturedTime", 0],
                    
                    // Capture mechanic
                    ["captureProgress", 0],            // 0-100
                    ["captureDirection", "none"],       // "british" / "nazi" / "none"
                    ["contested", false],
                    ["captureRadius", _captureRadius],
                    ["captureTime", _captureTime],     // seconds at 2:1 ratio to flip
                    
                    // Map display
                    ["mapMarkerCreated", false],
                    ["mapMarkerName", format ["opsroom_map_%1", _locId]]
                ];
                
                // Auto-discover key geographical features (ports, sea lanes)
                // These are known positions — players always know where ports and sea lanes are
                if (_type in ["port", "sealane"]) then {
                    _locData set ["discovered", true];
                    _locData set ["intelPercent", 25];
                    _locData set ["intelTier", [25] call OpsRoom_fnc_getIntelLevel];
                };
                
                // Store it
                OpsRoom_StrategicLocations set [_locId, _locData];
                _foundCount = _foundCount + 1;
                
                // Hide the original Eden marker (we'll create our own display markers)
                _markerName setMarkerAlpha 0;
                
                // Create initial map marker for auto-discovered locations
                if (_locData get "discovered") then {
                    [_locId] call OpsRoom_fnc_updateMapMarkers;
                };
                
                systemChat format ["Intel: Registered %1 (%2)", _displayName, _type];
            } else {
                systemChat format ["Intel WARNING: Unknown location type '%1' in marker '%2'", _type, _markerName];
            };
        };
    };
} forEach _allMarkers;

systemChat format ["Intel: Initialized %1 strategic locations", _foundCount];

// If no locations found, warn the mission maker
if (_foundCount == 0) then {
    systemChat "Intel WARNING: No opsroom_ markers found! Place markers named opsroom_[type]_[number] in Eden Editor.";
    systemChat "  Example: opsroom_factory_1, opsroom_port_1, opsroom_town_1";
};
