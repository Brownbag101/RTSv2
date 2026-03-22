/*
    OpsRoom_fnc_ability_repair
    
    Engineer repair ability with menu options:
    - Repair Nearest Vehicle
    - Repair Nearest Building
    - Repair All Nearby (vehicles + buildings within 50m)
    
    Uses direct damage manipulation with animation delay.
*/

private _selected = curatorSelected select 0;

if (typeName _selected != "ARRAY") exitWith {};
if (count _selected == 0) exitWith { hint "No units selected"; };

// Filter for engineers
private _engineers = _selected select {
    _x getVariable ["OpsRoom_Ability_Repair", false]
};

if (count _engineers == 0) exitWith { hint "No engineers selected"; };

// Store globally for menu actions
OpsRoom_Repair_Units = _engineers;

// Find THIS ability's button
private _display = findDisplay 312;
if (isNull _display) exitWith {};

private _myButton = controlNull;
for "_i" from 9350 to 9389 step 2 do {
    private _btn = _display displayCtrl (_i + 1);
    if (!isNull _btn) then {
        if ((_btn getVariable ["abilityID", ""]) == "repair") exitWith {
            _myButton = _btn;
        };
    };
};

if (isNull _myButton) exitWith { hint "Button not found"; };

private _btnPos = ctrlPosition _myButton;
_btnPos params ["_baseX", "_baseY", "_btnW", "_btnH"];

private _menuItems = [
    ["REPAIR VEHICLE", "a3\ui_f\data\igui\cfg\actions\repair_ca.paa", {
        private _engineers = OpsRoom_Repair_Units;
        if (isNil "_engineers") exitWith {};
        
        {
            private _engineer = _x;
            
            private _nearVehicles = (nearestObjects [_engineer, ["LandVehicle", "Air", "Ship"], 50]) select {
                damage _x > 0.1 && damage _x < 1
            };
            
            if (count _nearVehicles > 0) then {
                private _vehicle = _nearVehicles select 0;
                
                [_engineer, _vehicle] spawn {
                    params ["_eng", "_veh"];
                    
                    private _vehName = getText (configFile >> "CfgVehicles" >> typeOf _veh >> "displayName");
                    
                    if (_eng distance _veh > 5) then {
                        _eng doMove (getPos _veh);
                        waitUntil { sleep 0.5; (_eng distance _veh < 5) || !(alive _eng) };
                        if !(alive _eng) exitWith {};
                    };
                    
                    systemChat format ["%1 repairing %2...", name _eng, _vehName];
                    _eng playMoveNow "AinvPknlMstpSnonWnonDnon_medic4";
                    sleep 8;
                    
                    _veh setDamage 0;
                    systemChat format ["%1 repaired %2 to full", name _eng, _vehName];
                };
            } else {
                systemChat format ["%1: No damaged vehicles nearby", name _engineer];
            };
        } forEach _engineers;
        
        OpsRoom_Repair_Units = nil;
    }],
    ["REPAIR BUILDING", "a3\ui_f\data\igui\cfg\actions\repair_ca.paa", {
        private _engineers = OpsRoom_Repair_Units;
        if (isNil "_engineers") exitWith {};
        
        {
            private _engineer = _x;
            
            // Find damaged buildings within 50m
            private _nearBuildings = (nearestObjects [_engineer, ["Building", "House"], 50]) select {
                damage _x > 0.1 && damage _x < 1
            };
            
            if (count _nearBuildings > 0) then {
                private _building = _nearBuildings select 0;
                
                [_engineer, _building] spawn {
                    params ["_eng", "_bld"];
                    
                    private _bldName = getText (configFile >> "CfgVehicles" >> typeOf _bld >> "displayName");
                    if (_bldName == "") then { _bldName = "Building"; };
                    
                    if (_eng distance _bld > 8) then {
                        _eng doMove (getPos _bld);
                        waitUntil { sleep 0.5; (_eng distance _bld < 8) || !(alive _eng) };
                        if !(alive _eng) exitWith {};
                    };
                    
                    systemChat format ["%1 repairing %2...", name _eng, _bldName];
                    _eng playMoveNow "AinvPknlMstpSnonWnonDnon_medic4";
                    sleep 10;
                    
                    _bld setDamage 0;
                    systemChat format ["%1 repaired %2", name _eng, _bldName];
                };
            } else {
                systemChat format ["%1: No damaged buildings nearby", name _engineer];
            };
        } forEach _engineers;
        
        OpsRoom_Repair_Units = nil;
    }],
    ["REPAIR ALL NEARBY", "a3\ui_f\data\igui\cfg\actions\repair_ca.paa", {
        private _engineers = OpsRoom_Repair_Units;
        if (isNil "_engineers") exitWith {};
        
        {
            private _engineer = _x;
            
            // Find ALL damaged objects within 50m
            private _nearDamaged = (nearestObjects [_engineer, ["LandVehicle", "Air", "Ship", "Building", "House"], 50]) select {
                damage _x > 0.1 && damage _x < 1
            };
            
            if (count _nearDamaged > 0) then {
                [_engineer, _nearDamaged] spawn {
                    params ["_eng", "_targets"];
                    
                    private _repaired = 0;
                    {
                        private _target = _x;
                        private _targetName = getText (configFile >> "CfgVehicles" >> typeOf _target >> "displayName");
                        if (_targetName == "") then { _targetName = "Object"; };
                        
                        if (_eng distance _target > 5) then {
                            _eng doMove (getPos _target);
                            waitUntil { sleep 0.5; (_eng distance _target < 5) || !(alive _eng) };
                            if !(alive _eng) exitWith {};
                        };
                        
                        systemChat format ["%1 repairing %2 (%3/%4)...", name _eng, _targetName, _repaired + 1, count _targets];
                        _eng playMoveNow "AinvPknlMstpSnonWnonDnon_medic4";
                        sleep 6;
                        _target setDamage 0;
                        _repaired = _repaired + 1;
                        
                    } forEach _targets;
                    
                    systemChat format ["%1 finished repairs - %2 objects fixed", name _eng, _repaired];
                };
            } else {
                systemChat format ["%1: Nothing damaged nearby", name _engineer];
            };
        } forEach _engineers;
        
        OpsRoom_Repair_Units = nil;
    }]
];

[_display, _myButton, _menuItems, _baseX, _baseY, _btnW] call OpsRoom_fnc_createButtonMenu;
