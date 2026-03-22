/*
    OpsRoom_fnc_ability_heal
    
    Medic healing ability with menu options:
    - Heal Self
    - Heal Nearest Wounded
    - Heal All Nearby (within 30m)
    
    Uses direct damage manipulation with animation delay.
*/

private _selected = curatorSelected select 0;

if (typeName _selected != "ARRAY") exitWith {};
if (count _selected == 0) exitWith { hint "No units selected"; };

// Filter for medics
private _medics = _selected select {
    _x getVariable ["OpsRoom_Ability_Heal", false]
};

if (count _medics == 0) exitWith { hint "No medics selected"; };

// Store medics globally for menu actions
OpsRoom_Heal_Units = _medics;

// Find THIS ability's button
private _display = findDisplay 312;
if (isNull _display) exitWith {};

private _myButton = controlNull;
for "_i" from 9350 to 9389 step 2 do {
    private _btn = _display displayCtrl (_i + 1);
    if (!isNull _btn) then {
        if ((_btn getVariable ["abilityID", ""]) == "heal") exitWith {
            _myButton = _btn;
        };
    };
};

if (isNull _myButton) exitWith { hint "Button not found"; };

private _btnPos = ctrlPosition _myButton;
_btnPos params ["_baseX", "_baseY", "_btnW", "_btnH"];

private _menuItems = [
    ["HEAL SELF", "a3\ui_f\data\igui\cfg\actions\heal_ca.paa", {
        private _medics = OpsRoom_Heal_Units;
        if (isNil "_medics") exitWith {};
        
        {
            private _medic = _x;
            if (damage _medic > 0.1) then {
                [_medic, _medic] spawn {
                    params ["_medic", "_target"];
                    _medic playMoveNow "AinvPknlMstpSlayWrflDnon_medic";
                    sleep 5;
                    _target setDamage ((damage _target) - 0.5) max 0;
                    systemChat format ["%1 healed self", name _medic];
                };
            } else {
                systemChat format ["%1 is not wounded", name _medic];
            };
        } forEach _medics;
        
        OpsRoom_Heal_Units = nil;
    }],
    ["HEAL NEAREST", "a3\ui_f\data\igui\cfg\actions\heal_ca.paa", {
        private _medics = OpsRoom_Heal_Units;
        if (isNil "_medics") exitWith {};
        
        {
            private _medic = _x;
            
            // Find nearest wounded within 30m (not self)
            private _nearWounded = (nearestObjects [_medic, ["CAManBase"], 30]) select {
                alive _x && damage _x > 0.1 && _x != _medic
            };
            
            if (count _nearWounded > 0) then {
                private _wounded = _nearWounded select 0;
                
                [_medic, _wounded] spawn {
                    params ["_medic", "_wounded"];
                    
                    // Move to wounded if not close enough
                    if (_medic distance _wounded > 3) then {
                        _medic doMove (getPos _wounded);
                        waitUntil { sleep 0.5; (_medic distance _wounded < 3) || !(alive _medic) };
                        if !(alive _medic) exitWith {};
                    };
                    
                    // Heal animation
                    _medic playMoveNow "AinvPknlMstpSlayWrflDnon_medic";
                    sleep 5;
                    
                    // Apply healing
                    _wounded setDamage ((damage _wounded) - 0.5) max 0;
                    systemChat format ["%1 healed %2 (HP: %3%%)", name _medic, name _wounded, round ((1 - damage _wounded) * 100)];
                };
            } else {
                systemChat format ["%1: No wounded nearby", name _medic];
            };
        } forEach _medics;
        
        OpsRoom_Heal_Units = nil;
    }],
    ["HEAL ALL NEARBY", "a3\ui_f\data\igui\cfg\actions\heal_ca.paa", {
        private _medics = OpsRoom_Heal_Units;
        if (isNil "_medics") exitWith {};
        
        {
            private _medic = _x;
            
            // Find ALL wounded within 30m
            private _allWounded = (nearestObjects [_medic, ["CAManBase"], 30]) select {
                alive _x && damage _x > 0.1 && _x != _medic
            };
            
            if (count _allWounded > 0) then {
                [_medic, _allWounded] spawn {
                    params ["_medic", "_wounded"];
                    
                    private _healed = 0;
                    {
                        private _patient = _x;
                        
                        // Move to patient if needed
                        if (_medic distance _patient > 3) then {
                            _medic doMove (getPos _patient);
                            waitUntil { sleep 0.5; (_medic distance _patient < 3) || !(alive _medic) };
                            if !(alive _medic) exitWith {};
                        };
                        
                        // Heal
                        _medic playMoveNow "AinvPknlMstpSlayWrflDnon_medic";
                        sleep 4;
                        _patient setDamage ((damage _patient) - 0.5) max 0;
                        _healed = _healed + 1;
                        systemChat format ["%1 healed %2 (%3/%4)", name _medic, name _patient, _healed, count _wounded];
                        
                    } forEach _wounded;
                    
                    systemChat format ["%1 finished healing - %2 patients treated", name _medic, _healed];
                };
            } else {
                systemChat format ["%1: No wounded nearby", name _medic];
            };
        } forEach _medics;
        
        OpsRoom_Heal_Units = nil;
    }]
];

[_display, _myButton, _menuItems, _baseX, _baseY, _btnW] call OpsRoom_fnc_createButtonMenu;
