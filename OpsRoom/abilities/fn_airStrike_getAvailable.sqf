/*
    OpsRoom_fnc_airStrike_getAvailable
    
    Scans all airborne vehicles, cross-references against equipment DB
    "Ground Attack" subcategory, checks weapon availability per aircraft.
    
    Parameters: none
    
    Returns: Array of hashmaps:
        [
            createHashMapFromArray [
                ["vehicle", _veh],
                ["displayName", "DH.98 Mosquito FB Mk.VI"],
                ["capabilities", ["GUNS", "BOMBS", "ROCKETS"]],
                ["hasGuns", true/false],
                ["hasBombs", true/false],
                ["hasRockets", true/false]
            ]
        ]
*/

// Get all Ground Attack / CAS classnames from equipment DB
private _groundAttackClasses = [];
{
    private _itemData = _y;
    private _cat = _itemData getOrDefault ["category", ""];
    private _acType = _itemData getOrDefault ["aircraftType", ""];
    // Match GroundAttack AND Bomber aircraft types
    if (_cat == "Aircraft" && {_acType == "GroundAttack" || _acType == "Bomber"}) then {
        _groundAttackClasses pushBack [
            _itemData get "className",
            _itemData get "displayName",
            _itemData getOrDefault ["attackCapabilities", ["GUNS", "BOMBS", "ROCKETS"]]
        ];
    };
} forEach OpsRoom_EquipmentDB;

if (count _groundAttackClasses == 0) exitWith {
    diag_log "[OpsRoom] AirStrike: No Ground Attack aircraft in equipment DB";
    []
};

// Build lookup: className → [displayName, capabilities]
private _classLookup = createHashMap;
{
    _x params ["_cls", "_dName", "_caps"];
    _classLookup set [toLower _cls, [_dName, _caps]];
} forEach _groundAttackClasses;

// Scan all vehicles — find airborne friendlies matching DB entries
private _friendlySide = side player;
private _available = [];

{
    private _veh = _x;
    
    // Must be alive, airborne, friendly, crewed
    if (!alive _veh) then { continue };
    if (count crew _veh == 0) then { continue };
    if (side _veh != _friendlySide) then { continue };
    if (isTouchingGround _veh) then { continue };
    if ((getPosATL _veh) select 2 < 30) then { continue };  // Must be properly airborne
    
    // Check if this vehicle's type matches any Ground Attack class
    private _typeLC = toLower (typeOf _veh);
    private _match = _classLookup getOrDefault [_typeLC, []];
    
    // Also check parent classes (in case of variants)
    if (count _match == 0) then {
        {
            private _cls = _x;
            if (_veh isKindOf _cls) then {
                _match = _classLookup get (toLower _cls);
            };
        } forEach (keys _classLookup);
    };
    
    if (count _match == 0) then { continue };
    
    _match params ["_dName", "_caps"];
    
    // Check actual weapon availability (ammo check)
    private _hasGuns = false;
    private _hasBombs = false;
    private _hasRockets = false;
    
    if ("GUNS" in _caps) then {
        _hasGuns = [_veh, "GUNS"] call OpsRoom_fnc_airStrike_hasWeaponType;
    };
    if ("BOMBS" in _caps) then {
        _hasBombs = [_veh, "BOMBS"] call OpsRoom_fnc_airStrike_hasWeaponType;
    };
    if ("ROCKETS" in _caps) then {
        _hasRockets = [_veh, "ROCKETS"] call OpsRoom_fnc_airStrike_hasWeaponType;
    };
    
    private _hasTorpedo = false;
    if ("TORPEDO" in _caps) then {
        _hasTorpedo = [_veh, "TORPEDO"] call OpsRoom_fnc_airStrike_hasWeaponType;
    };
    
    // Only include if it has at least one weapon type available
    if (!_hasGuns && !_hasBombs && !_hasRockets && !_hasTorpedo) then { continue };
    
    _available pushBack createHashMapFromArray [
        ["vehicle", _veh],
        ["displayName", _dName],
        ["capabilities", _caps],
        ["hasGuns", _hasGuns],
        ["hasBombs", _hasBombs],
        ["hasRockets", _hasRockets],
        ["hasTorpedo", _hasTorpedo]
    ];
    
} forEach vehicles;

diag_log format ["[OpsRoom] AirStrike: Found %1 available aircraft", count _available];

_available
