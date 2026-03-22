/*
    OpsRoom_fnc_airStrike_findAircraft
    
    Find the best available aircraft for a given attack type.
    Picks the nearest airborne friendly aircraft (from equipment DB "Ground Attack")
    that has the required weapon type with ammo.
    
    Parameters:
        0: STRING - Attack type: "GUNS", "BOMBS", "ROCKETS", "STRAFE"
        1: ARRAY  - Target position [x,y,z]
    
    Returns:
        OBJECT - Best aircraft, or objNull if none found
*/

params ["_attackType", "_targetPos"];

// Get all Ground Attack classnames from equipment DB
private _groundAttackClasses = [];
{
    private _itemData = _y;
    if ((_itemData get "category") == "Aircraft" && {(_itemData get "subcategory") == "Ground Attack"}) then {
        _groundAttackClasses pushBack toLower (_itemData get "className");
    };
} forEach OpsRoom_EquipmentDB;

if (count _groundAttackClasses == 0) exitWith { objNull };

private _friendlySide = side player;
private _bestAircraft = objNull;
private _bestDistance = 999999;

{
    private _vehicle = vehicle _x;
    
    if (!alive _vehicle) then { continue };
    if (isTouchingGround _vehicle) then { continue };
    if (!(_vehicle isKindOf "Air")) then { continue };
    if (side _x != _friendlySide) then { continue };
    
    // Check if registered in DB
    private _typeClass = toLower (typeOf _vehicle);
    private _isRegistered = false;
    {
        if (_typeClass find _x != -1 || {_x find _typeClass != -1} || {_typeClass == _x}) then {
            _isRegistered = true;
        };
    } forEach _groundAttackClasses;
    
    if (!_isRegistered) then { continue };
    
    // Check if already on an air strike mission
    if (_vehicle getVariable ["OpsRoom_AirStrike_Active", false]) then { continue };
    
    // Check weapon capability
    private _capable = switch (_attackType) do {
        case "GUNS":    { [_vehicle] call OpsRoom_fnc_airStrike_hasGuns };
        case "BOMBS":   { [_vehicle] call OpsRoom_fnc_airStrike_hasBombs };
        case "ROCKETS": { [_vehicle] call OpsRoom_fnc_airStrike_hasRockets };
        case "STRAFE":  { 
            ([_vehicle] call OpsRoom_fnc_airStrike_hasGuns) && 
            {[_vehicle] call OpsRoom_fnc_airStrike_hasRockets}
        };
        default { false };
    };
    
    if (!_capable) then { continue };
    
    // Distance check - pick nearest
    private _dist = _vehicle distance2D _targetPos;
    if (_dist < _bestDistance) then {
        _bestDistance = _dist;
        _bestAircraft = _vehicle;
    };
    
} forEach allUnits;

diag_log format ["[OpsRoom] findAircraft: type=%1, found=%2, dist=%3", _attackType, !isNull _bestAircraft, _bestDistance];

_bestAircraft
