/*
    OpsRoom_fnc_ability_repair
    
    Engineer repair ability with menu options:
    - Repair Nearest Vehicle (instant)
    - Repair Nearest Building (gradual, costs resources)
    - Repair All Nearby (vehicles + buildings)
    - Demolish Structure (player-built only, returns 50% resources)
    
    Building repair: 10% increments, 5s per step, 1 Steel + 1 Wood per step.
*/

private _selected = curatorSelected select 0;

if (typeName _selected != "ARRAY") exitWith {};
if (count _selected == 0) exitWith { hint "No units selected" };

// Filter for engineers
private _engineers = _selected select {
    _x getVariable ["OpsRoom_Ability_Repair", false]
};

if (count _engineers == 0) exitWith { hint "No engineers selected" };

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

if (isNull _myButton) exitWith { hint "Button not found" };

private _btnPos = ctrlPosition _myButton;
_btnPos params ["_baseX", "_baseY", "_btnW", "_btnH"];

// Resource cost settings
private _steelPerStep = missionNamespace getVariable ["OpsRoom_Settings_RepairCostSteel", 1];
private _woodPerStep = missionNamespace getVariable ["OpsRoom_Settings_RepairCostWood", 1];
private _timePerStep = missionNamespace getVariable ["OpsRoom_Settings_RepairTimePerStep", 5];

private _menuItems = [
    // ========================================
    // REPAIR VEHICLE (instant — unchanged)
    // ========================================
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
    
    // ========================================
    // REPAIR BUILDING (gradual + resource cost)
    // ========================================
    ["REPAIR BUILDING", "a3\ui_f\data\igui\cfg\actions\repair_ca.paa", {
        private _engineers = OpsRoom_Repair_Units;
        if (isNil "_engineers") exitWith {};
        
        private _steelCost = missionNamespace getVariable ["OpsRoom_Settings_RepairCostSteel", 1];
        private _woodCost = missionNamespace getVariable ["OpsRoom_Settings_RepairCostWood", 1];
        private _stepTime = missionNamespace getVariable ["OpsRoom_Settings_RepairTimePerStep", 5];
        
        {
            private _engineer = _x;
            
            // Find damaged buildings within 50m
            private _nearBuildings = (nearestObjects [_engineer, ["Building", "House"], 50]) select {
                damage _x > 0.1
            };
            
            if (count _nearBuildings > 0) then {
                private _building = _nearBuildings select 0;
                
                [_engineer, _building, _steelCost, _woodCost, _stepTime] spawn {
                    params ["_eng", "_bld", "_steelCost", "_woodCost", "_stepTime"];
                    
                    private _bldName = getText (configFile >> "CfgVehicles" >> typeOf _bld >> "displayName");
                    if (_bldName == "") then { _bldName = "Building" };
                    
                    if (_eng distance _bld > 8) then {
                        _eng doMove (getPos _bld);
                        waitUntil { sleep 0.5; (_eng distance _bld < 8) || !(alive _eng) };
                        if !(alive _eng) exitWith {};
                    };
                    
                    // Calculate repair steps needed (10% per step)
                    private _currentDmg = damage _bld;
                    private _repairSteps = ceil(_currentDmg * 10);
                    
                    systemChat format ["%1 repairing %2 (%3 steps needed, %4 Steel + %5 Wood per step)", 
                        name _eng, _bldName, _repairSteps, _steelCost, _woodCost];
                    
                    for "_step" from 1 to _repairSteps do {
                        if !(alive _eng) exitWith {};
                        if (damage _bld < 0.05) exitWith {};  // Already repaired
                        
                        // Check resources
                        private _haveSteel = missionNamespace getVariable ["OpsRoom_Resource_Steel", 0];
                        private _haveWood = missionNamespace getVariable ["OpsRoom_Resource_Wood", 0];
                        
                        if (_haveSteel < _steelCost || _haveWood < _woodCost) exitWith {
                            systemChat format ["%1: Insufficient resources — need %2 Steel + %3 Wood per step", 
                                name _eng, _steelCost, _woodCost];
                        };
                        
                        // Deduct resources
                        OpsRoom_Resource_Steel = OpsRoom_Resource_Steel - _steelCost;
                        OpsRoom_Resource_Wood = OpsRoom_Resource_Wood - _woodCost;
                        [] call OpsRoom_fnc_updateResources;
                        
                        // Play animation + wait
                        _eng playMoveNow "AinvPknlMstpSnonWnonDnon_medic4";
                        sleep _stepTime;
                        
                        // Reduce damage by 10%
                        private _newDmg = (damage _bld) - 0.1;
                        _bld setDamage (_newDmg max 0);
                        
                        private _integrity = round((1 - damage _bld) * 100);
                        systemChat format ["%1 repairing %2... %3%% integrity (%4/%5)", 
                            name _eng, _bldName, _integrity, _step, _repairSteps];
                    };
                    
                    if (damage _bld < 0.05) then {
                        systemChat format ["%1: %2 fully repaired!", name _eng, _bldName];
                    };
                    
                    // Update location building count if this is a location building
                    private _locId = _bld getVariable ["OpsRoom_LocationId", ""];
                    if (_locId != "") then {
                        private _locData = OpsRoom_StrategicLocations getOrDefault [_locId, createHashMap];
                        if (count _locData > 0) then {
                            private _buildings = _locData getOrDefault ["buildings", []];
                            private _aliveCount = 0;
                            {
                                private _obj = _x;
                                private _checkObj = if (_obj getVariable ["OpsRoom_Replaced", false]) then {
                                    _obj getVariable ["OpsRoom_Replacement", objNull]
                                } else { _obj };
                                if (!isNull _checkObj && {alive _checkObj && {damage _checkObj < 1}}) then {
                                    _aliveCount = _aliveCount + 1;
                                };
                            } forEach _buildings;
                            _locData set ["buildingsAlive", _aliveCount];
                            OpsRoom_StrategicLocations set [_locId, _locData];
                            
                            // Check if location recovers from destroyed
                            if ((_locData get "status") == "destroyed" && _aliveCount > 0) then {
                                private _prevStatus = _locData getOrDefault ["previousStatus", "friendly"];
                                _locData set ["status", _prevStatus];
                                OpsRoom_StrategicLocations set [_locId, _locData];
                                [_locId] call OpsRoom_fnc_updateMapMarkers;
                                ["PRIORITY", "LOCATION RESTORED",
                                    format ["%1 partially rebuilt", _locData get "name"],
                                    _locData get "pos"
                                ] call OpsRoom_fnc_dispatch;
                            };
                        };
                    };
                };
            } else {
                systemChat format ["%1: No damaged buildings nearby", name _engineer];
            };
        } forEach _engineers;
        
        OpsRoom_Repair_Units = nil;
    }],
    
    // ========================================
    // REPAIR ALL NEARBY
    // ========================================
    ["REPAIR ALL NEARBY", "a3\ui_f\data\igui\cfg\actions\repair_ca.paa", {
        private _engineers = OpsRoom_Repair_Units;
        if (isNil "_engineers") exitWith {};
        
        {
            private _engineer = _x;
            
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
                        if (_targetName == "") then { _targetName = "Object" };
                        
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
    }],
    
    // ========================================
    // DEMOLISH STRUCTURE (player-built only, returns 50% resources)
    // ========================================
    ["DEMOLISH", "\A3\ui_f\data\IGUI\Cfg\SimpleTasks\types\destroy_ca.paa", {
        private _engineers = OpsRoom_Repair_Units;
        if (isNil "_engineers") exitWith {};
        
        {
            private _engineer = _x;
            
            // Find player-built structures within 50m
            private _nearBuilt = (nearestObjects [_engineer, [], 50]) select {
                _x getVariable ["OpsRoom_IsBuiltObject", false]
            };
            
            if (count _nearBuilt > 0) then {
                private _target = _nearBuilt select 0;
                [_engineer, _target] call OpsRoom_fnc_executeDemolish;
            } else {
                systemChat format ["%1: No player-built structures nearby to demolish", name _engineer];
            };
        } forEach _engineers;
        
        OpsRoom_Repair_Units = nil;
    }]
];

[_display, _myButton, _menuItems, _baseX, _baseY, _btnW] call OpsRoom_fnc_createButtonMenu;
