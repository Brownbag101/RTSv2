/*
    OpsRoom_fnc_ability_artillery
    
    Main entry point — called when the Artillery ability button is clicked.
    Validates selected units have radio operator training,
    scans for available crewed artillery, builds dynamic menu
    showing artillery types and ammo options.
    
    Flow: Pick type+ammo → Pick round count → Cursor targeting → Click fires
*/

private _selected = curatorSelected select 0;

if (typeName _selected != "ARRAY") exitWith { hint "Error: Invalid selection" };
if (count _selected == 0) exitWith { hint "No units selected" };

// Filter for Radio Operator trained units with artillery ability
private _capable = _selected select {
    _x getVariable ["OpsRoom_Ability_Artillery", false]
};

if (count _capable == 0) exitWith { hint "No Radio Operators selected" };

// Scan for available artillery
private _available = [] call OpsRoom_fnc_artillery_getAvailable;

if (count _available == 0) exitWith {
    hint "No artillery available.\nArtillery must be crewed (gunner) and have ammunition.";
};

// Store for targeting phase
OpsRoom_Artillery_RadioOperator = _capable select 0;
OpsRoom_Artillery_Available = _available;

// Group available artillery by type and collect unique ammo types per type
private _byType = createHashMap;

{
    private _entry = _x;
    private _vehType = _entry get "type";
    private _displayName = _entry get "displayName";
    private _ammo = _entry get "ammoTypes";
    private _veh = _entry get "vehicle";
    
    if !(_vehType in (keys _byType)) then {
        _byType set [_vehType, createHashMapFromArray [
            ["displayName", _displayName],
            ["vehicles", []],
            ["ammoTypes", []]
        ]];
    };
    
    private _typeData = _byType get _vehType;
    (_typeData get "vehicles") pushBack _veh;
    
    // Merge ammo types (unique)
    private _existingAmmo = _typeData get "ammoTypes";
    {
        if !(_x in _existingAmmo) then { _existingAmmo pushBack _x };
    } forEach _ammo;
} forEach _available;

// Find this ability's button on Zeus display
private _display = findDisplay 312;
if (isNull _display) exitWith {};

private _myButton = controlNull;
for "_i" from 9350 to 9389 step 2 do {
    private _btn = _display displayCtrl (_i + 1);
    if (!isNull _btn) then {
        if ((_btn getVariable ["abilityID", ""]) == "artillery") exitWith {
            _myButton = _btn;
        };
    };
};

if (isNull _myButton) exitWith { hint "Button not found" };

private _btnPos = ctrlPosition _myButton;
_btnPos params ["_baseX", "_baseY", "_btnW", "_btnH"];

// Build menu — one entry per artillery type + ammo combination
private _menuItems = [];

{
    private _vehType = _x;
    private _typeData = _y;
    private _displayName = _typeData get "displayName";
    private _vehicleList = _typeData get "vehicles";
    private _ammoList = _typeData get "ammoTypes";
    private _count = count _vehicleList;
    
    {
        private _ammoClass = _x;
        
        // Get friendly ammo name from config
        private _ammoDisplayName = getText (configFile >> "CfgMagazines" >> _ammoClass >> "displayName");
        if (_ammoDisplayName == "") then { _ammoDisplayName = _ammoClass };
        
        private _label = format ["%1 (%2) — %3", _displayName, _count, _ammoDisplayName];
        
        // This menu item opens the ROUND COUNT sub-menu
        _menuItems pushBack [
            _label,
            "\A3\ui_f\data\IGUI\Cfg\SimpleTasks\types\destroy_ca.paa",
            compile format [
                "['%1', '%2', %3] call OpsRoom_fnc_ability_artillery_roundMenu;",
                _vehType,
                _ammoClass,
                _count
            ]
        ];
    } forEach _ammoList;
} forEach _byType;

if (count _menuItems == 0) exitWith { hint "No artillery options available" };

[_display, _myButton, _menuItems, _baseX, _baseY, _btnW] call OpsRoom_fnc_createButtonMenu;
