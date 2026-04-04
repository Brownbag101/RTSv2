/*
    OpsRoom_fnc_artillery_getAvailable
    
    Scans the map for crewed, friendly (independent) artillery vehicles with ammo.
    Returns array of hashmaps with vehicle info and available ammo types.
    
    Supported types:
        JMSSA_vehgr_BL55inch_F      - BL 5.5-inch Medium Gun
        JMSSA_vehgr_2inchMortarAB_F - 2-inch Mortar (Airborne)
        JMSSA_vehgr_2inchMortar_F   - 2-inch Mortar
    
    Returns:
        ARRAY of HashMaps:
            "vehicle"     - Object reference
            "type"        - Classname
            "displayName" - Friendly name
            "ammoTypes"   - Array of magazine classnames from getArtilleryAmmo
            "position"    - Position of the vehicle
*/

// Define known artillery types and display names
private _knownTypes = createHashMapFromArray [
    ["JMSSA_vehgr_BL55inch_F",      "BL 5.5-inch Gun"],
    ["JMSSA_vehgr_2inchMortarAB_F", "2-inch Mortar (AB)"],
    ["JMSSA_vehgr_2inchMortar_F",   "2-inch Mortar"]
];

private _available = [];

// Scan all vehicles on the map
{
    private _veh = _x;
    private _vehType = typeOf _veh;
    
    // Check if it's a known artillery type
    if (_vehType in (keys _knownTypes)) then {
        // Must be on our side (independent / resistance)
        if (side _veh == independent) then {
            // Must be crewed — needs a gunner
            if !(isNull (gunner _veh)) then {
                // Must have artillery ammo
                private _ammo = getArtilleryAmmo [_veh];
                
                if (count _ammo > 0) then {
                    private _entry = createHashMapFromArray [
                        ["vehicle", _veh],
                        ["type", _vehType],
                        ["displayName", _knownTypes get _vehType],
                        ["ammoTypes", _ammo],
                        ["position", getPosATL _veh]
                    ];
                    
                    _available pushBack _entry;
                    
                    diag_log format ["[OpsRoom] Artillery found: %1 (%2) at %3 with ammo: %4",
                        _knownTypes get _vehType, _vehType, getPosATL _veh, _ammo];
                };
            };
        };
    };
} forEach vehicles;

diag_log format ["[OpsRoom] Artillery scan complete: %1 available", count _available];

_available
