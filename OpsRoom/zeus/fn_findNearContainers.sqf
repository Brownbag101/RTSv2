/*
    OpsRoom_fnc_findNearContainers
    
    Finds lootable containers/bodies/vehicles near a unit.
    
    Parameters:
        _unit   - Unit to search around
        _radius - Search radius (default 5)
    
    Returns: Array of [object, distance, displayName, type] sorted by distance
    Types: "body", "container", "vehicle", "unit"
*/

params ["_unit", ["_radius", 5]];

private _pos = getPosATL _unit;
private _nearObjects = nearestObjects [_pos, ["Man", "Car", "Tank", "Air", "Ship", "ReammoBox_F", "ThingX", "WeaponHolder", "WeaponHolderSimulated", "GroundWeaponHolder"], _radius];

private _containers = [];

{
    private _obj = _x;
    
    // Skip the unit itself
    if (_obj == _unit) then {continue};
    
    private _dist = _obj distance _unit;
    private _name = "";
    private _type = "";
    
    if (_obj isKindOf "Man") then {
        if (!alive _obj) then {
            // Dead body
            _name = format ["%1 (Dead)", name _obj];
            _type = "body";
            _containers pushBack [_obj, _dist, _name, _type];
        } else {
            // Alive friendly unit - allow gear swap
            if (side _obj == side _unit || {side _obj == side player}) then {
                _name = format ["%1", name _obj];
                _type = "unit";
                _containers pushBack [_obj, _dist, _name, _type];
            };
        };
    } else {
        if (_obj isKindOf "Car" || {_obj isKindOf "Tank"} || {_obj isKindOf "Air"} || {_obj isKindOf "Ship"}) then {
            // Vehicle
            private _displayName = getText (configFile >> "CfgVehicles" >> typeOf _obj >> "displayName");
            if (_displayName == "") then {_displayName = typeOf _obj};
            _name = _displayName;
            _type = "vehicle";
            _containers pushBack [_obj, _dist, _name, _type];
        } else {
            // Ground item / ammo box / weapon holder
            private _displayName = getText (configFile >> "CfgVehicles" >> typeOf _obj >> "displayName");
            if (_displayName == "") then {_displayName = typeOf _obj};
            _name = _displayName;
            _type = "container";
            _containers pushBack [_obj, _dist, _name, _type];
        };
    };
} forEach _nearObjects;

// Already sorted by distance since nearestObjects returns distance-sorted
_containers
