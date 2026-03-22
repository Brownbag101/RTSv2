/*
    OpsRoom_fnc_airStrike_scanAircraft
    
    Scans all airborne friendly aircraft that are registered in the equipment DB
    as "Ground Attack" subcategory. Checks their actual weapons/ammo to determine
    what attack types are currently available.
    
    Returns:
        [_hasGuns, _hasBombs, _hasRockets] - booleans
*/

private _hasGuns = false;
private _hasBombs = false;
private _hasRockets = false;

// Get all "Ground Attack" classnames from equipment DB
private _groundAttackClasses = [];
{
    private _itemData = _y;
    if ((_itemData get "category") == "Aircraft" && {(_itemData get "subcategory") == "Ground Attack"}) then {
        _groundAttackClasses pushBack toLower (_itemData get "className");
    };
} forEach OpsRoom_EquipmentDB;

diag_log format ["[OpsRoom] Ground Attack DB classes: %1", _groundAttackClasses];

if (count _groundAttackClasses == 0) exitWith {
    diag_log "[OpsRoom] WARNING: No Ground Attack aircraft defined in equipment database";
    [false, false, false]
};

// Find all airborne friendly aircraft matching DB classes
private _friendlySide = side player;
{
    private _vehicle = vehicle _x;
    
    // Skip non-aircraft, dead, or grounded
    if (!alive _vehicle) then { continue };
    if (isTouchingGround _vehicle) then { continue };
    if (!(_vehicle isKindOf "Air")) then { continue };
    if (side _x != _friendlySide) then { continue };
    
    // Check if this aircraft type is in our DB
    private _typeClass = toLower (typeOf _vehicle);
    private _isRegistered = false;
    {
        if (_typeClass find _x != -1 || {_x find _typeClass != -1} || {_typeClass == _x}) then {
            _isRegistered = true;
        };
    } forEach _groundAttackClasses;
    
    if (!_isRegistered) then { continue };
    
    // Aircraft is valid - check weapons
    if (!_hasGuns && {[_vehicle] call OpsRoom_fnc_airStrike_hasGuns}) then {
        _hasGuns = true;
    };
    
    if (!_hasBombs && {[_vehicle] call OpsRoom_fnc_airStrike_hasBombs}) then {
        _hasBombs = true;
    };
    
    if (!_hasRockets && {[_vehicle] call OpsRoom_fnc_airStrike_hasRockets}) then {
        _hasRockets = true;
    };
    
    // Early exit if we found everything
    if (_hasGuns && _hasBombs && _hasRockets) exitWith {};
    
} forEach allUnits;

diag_log format ["[OpsRoom] Air Strike scan result: guns=%1, bombs=%2, rockets=%3", _hasGuns, _hasBombs, _hasRockets];

[_hasGuns, _hasBombs, _hasRockets]
