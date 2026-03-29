/*
    fn_initLocationRadios
    
    Auto-spawns a radio object at each enemy-owned strategic location
    that is in the OpsRoom_AI_RadioLocationTypes list.
    
    The radio is placed near the centre of the location.
    Its reference is stored in the location data hashmap.
    
    Called from init.sqf after initStrategicLocations.
*/

if (isNil "OpsRoom_AI_RadioLocationTypes") exitWith {
    systemChat "AI Radio: No radio config loaded";
};

private _radioClass = OpsRoom_AI_RadioClassname;
private _validTypes = OpsRoom_AI_RadioLocationTypes;
private _count = 0;

{
    private _locId = _x;
    private _locData = _y;
    private _type = _locData get "type";
    private _owner = _locData getOrDefault ["owner", "NAZI"];
    
    // Only place radios at enemy locations of valid types
    if (_owner != "NAZI") then { continue };
    if !(_type in _validTypes) then { continue };
    
    private _pos = _locData get "pos";
    
    // Find a suitable position near centre (slightly offset so it's findable)
    private _radioPos = _pos getPos [3 + random 5, random 360];
    
    // Spawn the radio object
    private _radio = createVehicle [_radioClass, _radioPos, [], 0, "NONE"];
    _radio setDir (random 360);
    _radio setPos _radioPos;  // Ensure exact placement
    
    // Make it non-moveable but destructible
    _radio enableSimulation true;
    _radio allowDamage true;
    
    // Store reference in location data
    _locData set ["radioObject", _radio];
    _locData set ["radioAlarmSent", false];
    OpsRoom_StrategicLocations set [_locId, _locData];
    
    _count = _count + 1;
    
    diag_log format ["[OpsRoom] Radio: Placed at %1 (%2)", _locData get "name", _type];
    
} forEach OpsRoom_StrategicLocations;

systemChat format ["AI Radio: %1 field radios deployed", _count];
diag_log format ["[OpsRoom] Radio: %1 radios placed at enemy locations", _count];
