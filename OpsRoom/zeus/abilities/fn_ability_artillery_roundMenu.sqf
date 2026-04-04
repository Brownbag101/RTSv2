/*
    OpsRoom_fnc_ability_artillery_roundMenu
    
    Shows round count sub-menu after player picks artillery type + ammo.
    After picking rounds, enters cursor targeting mode.
    
    Deferred via spawn because createButtonMenu's ButtonClick handler
    calls closeButtonMenu AFTER this action runs — so we must wait
    for that close to finish before opening the new menu.
    
    Parameters:
        0: STRING - Vehicle type classname
        1: STRING - Ammo type classname
        2: NUMBER - Number of guns of this type
*/

params ["_vehType", "_ammoType", "_gunCount"];

// Store selections
OpsRoom_ArtilleryTargeting_VehType = _vehType;
OpsRoom_ArtilleryTargeting_AmmoType = _ammoType;

// Defer menu creation — the ButtonClick handler in createButtonMenu
// will call closeButtonMenu after this action returns, which would
// destroy any menu we create here synchronously
[_vehType, _ammoType, _gunCount] spawn {
    params ["_vehType", "_ammoType", "_gunCount"];
    sleep 0.1;
    
    private _display = findDisplay 312;
    if (isNull _display) exitWith {};
    
    // Find the artillery button for menu positioning
    private _myButton = controlNull;
    for "_i" from 9350 to 9389 step 2 do {
        private _btn = _display displayCtrl (_i + 1);
        if (!isNull _btn) then {
            if ((_btn getVariable ["abilityID", ""]) == "artillery") exitWith {
                _myButton = _btn;
            };
        };
    };
    
    if (isNull _myButton) exitWith {
        hint "Artillery button not found — try again";
        diag_log "[OpsRoom] ERROR: Artillery button not found for round menu";
    };
    
    private _btnPos = ctrlPosition _myButton;
    _btnPos params ["_baseX", "_baseY", "_btnW", "_btnH"];
    
    // Build round count menu — each option goes straight to targeting
    private _menuItems = [
        [format ["1 ROUND (%1 guns)", _gunCount],
         "\A3\ui_f\data\IGUI\Cfg\SimpleTasks\types\destroy_ca.paa",
         compile format ["['%1', '%2', 1] call OpsRoom_fnc_startArtilleryTargeting;", _vehType, _ammoType]],
        [format ["3 ROUNDS (%1 guns)", _gunCount],
         "\A3\ui_f\data\IGUI\Cfg\SimpleTasks\types\destroy_ca.paa",
         compile format ["['%1', '%2', 3] call OpsRoom_fnc_startArtilleryTargeting;", _vehType, _ammoType]],
        [format ["5 ROUNDS (%1 guns)", _gunCount],
         "\A3\ui_f\data\IGUI\Cfg\SimpleTasks\types\destroy_ca.paa",
         compile format ["['%1', '%2', 5] call OpsRoom_fnc_startArtilleryTargeting;", _vehType, _ammoType]],
        [format ["FIRE FOR EFFECT (%1 guns)", _gunCount],
         "\A3\ui_f\data\IGUI\Cfg\SimpleTasks\types\destroy_ca.paa",
         compile format ["['%1', '%2', -1] call OpsRoom_fnc_startArtilleryTargeting;", _vehType, _ammoType]]
    ];
    
    [_display, _myButton, _menuItems, _baseX, _baseY, _btnW] call OpsRoom_fnc_createButtonMenu;
    
    diag_log format ["[OpsRoom] Artillery round menu shown: type=%1 ammo=%2 guns=%3", _vehType, _ammoType, _gunCount];
};
