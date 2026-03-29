/*
    fn_aiFindSpawnLocation
    
    Finds the nearest enemy-held spawn location of the given type.
    
    Parameters:
        0: STRING - Spawn type ("barracks" or "motorpool")
        1: ARRAY  - Target position [x,y,z] (finds nearest spawn to this)
    
    Returns: STRING - Location ID of nearest valid spawn, or "" if none found
*/

params [["_spawnType", "", [""]], ["_targetPos", [0,0,0], [[]]]];

if (_spawnType == "" || {_targetPos isEqualTo [0,0,0]}) exitWith { "" };

// Map spawn type to location type(s)
private _validTypes = switch (_spawnType) do {
    case "barracks":  { ["barracks"] };
    case "motorpool": { ["motorpool"] };
    case "airfield":  { ["airfield"] };
    case "port":      { ["port"] };
    default           { [_spawnType] };
};

private _bestLocId = "";
private _bestDist = 999999;

{
    private _locId = _x;
    private _locData = _y;
    private _type = _locData get "type";
    private _owner = _locData getOrDefault ["owner", "NAZI"];
    private _status = _locData get "status";
    
    // Must be enemy-held and not destroyed
    if (_owner != "NAZI") then { continue };
    if (_status == "destroyed") then { continue };
    if !(_type in _validTypes) then { continue };
    
    private _pos = _locData get "pos";
    private _dist = _targetPos distance2D _pos;
    
    if (_dist < _bestDist) then {
        _bestDist = _dist;
        _bestLocId = _locId;
    };
} forEach OpsRoom_StrategicLocations;

_bestLocId
