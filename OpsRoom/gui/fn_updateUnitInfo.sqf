/*
    Operations Room - Update Unit Info Display
    
    Updates the bottom bar with selected unit information.
    Now shows: Name, Rank, Health, Combat Mode, Behaviour, and Target Info
    Group selection shows: Group Name, Unit Count, Status, Combat Mode, Behaviour
*/

private _display = uiNamespace getVariable ["OpsRoom_HUD_Display", displayNull];
if (isNull _display) exitWith {};

private _unitInfoCtrl = _display displayCtrl 9020;
if (isNull _unitInfoCtrl) exitWith {};

// Get Zeus curator
private _curator = getAssignedCuratorLogic player;
if (isNull _curator) exitWith {
    _unitInfoCtrl ctrlSetStructuredText parseText "<t align='center' size='1.1'>NO CURATOR ASSIGNED</t>";
};

// Get selected units
private _selected = curatorSelected select 0;

if (count _selected == 0) exitWith {
    _unitInfoCtrl ctrlSetStructuredText parseText "<t align='center' size='1.1' color='#999999'>NO UNIT SELECTED</t>";
    // Clean up cargo icons when nothing selected
    [objNull] call OpsRoom_fnc_updateCargoDisplay;
};

// Get first selected unit
private _unit = _selected select 0;

// Multiple units selected - show GROUP info
if (count _selected > 1) then {
    private _group = group _unit;
    private _groupLeader = leader _group;
    
    // Get group name (OpsRoom custom name or ARMA callsign)
    private _groupName = _group getVariable ["OpsRoom_GroupName", groupId _group];
    
    // Calculate group status based on average health
    private _totalHealth = 0;
    {
        _totalHealth = _totalHealth + (1 - (damage _x));
    } forEach _selected;
    private _avgHealth = (_totalHealth / (count _selected)) * 100;
    
    private _statusText = "Healthy";
    private _statusColor = "#00FF00";
    if (_avgHealth < 75) then {
        _statusText = "Damaged";
        _statusColor = "#FFA500";
    };
    if (_avgHealth < 40) then {
        _statusText = "Critical";
        _statusColor = "#FF0000";
    };
    
    // Get combat mode from group
    private _combatMode = combatMode _group;
    private _combatModeColor = "#FFFF00";
    private _combatModeText = "Unknown";
    
    switch (_combatMode) do {
        case "BLUE": {
            _combatModeColor = "#4169E1";
            _combatModeText = "Never Fire";
        };
        case "GREEN": {
            _combatModeColor = "#32CD32";
            _combatModeText = "Hold Fire";
        };
        case "WHITE": {
            _combatModeColor = "#FFFFFF";
            _combatModeText = "Hold, Engage at Will";
        };
        case "YELLOW": {
            _combatModeColor = "#FFD700";
            _combatModeText = "Fire at Will";
        };
        case "RED": {
            _combatModeColor = "#FF0000";
            _combatModeText = "Fire, Engage at Will";
        };
    };
    
    // Get behaviour from group leader (not group itself)
    private _behaviour = behaviour _groupLeader;
    private _behaviourColor = "#00FF00";
    private _behaviourText = _behaviour;
    
    switch (_behaviour) do {
        case "SAFE": {
            _behaviourColor = "#00FF00";
            _behaviourText = "Safe";
        };
        case "AWARE": {
            _behaviourColor = "#FFFF00";
            _behaviourText = "Aware";
        };
        case "COMBAT": {
            _behaviourColor = "#FF0000";
            _behaviourText = "Combat";
        };
        case "STEALTH": {
            _behaviourColor = "#00BFFF";
            _behaviourText = "Stealth";
        };
        case "CARELESS": {
            _behaviourColor = "#999999";
            _behaviourText = "Careless";
        };
    };
    
    // Build group display
    private _text = format [
        "<t align='center' size='1.0'>%1 (%2 units)</t><br/><t align='center' size='0.9' color='#AAAAAA'>Status: <t color='%3'>%4</t>  |  <t color='%5'>%6</t>  |  <t color='%7'>%8</t></t>",
        _groupName,
        count _selected,
        _statusColor,
        _statusText,
        _combatModeColor,
        _combatModeText,
        _behaviourColor,
        _behaviourText
    ];
    
    _unitInfoCtrl ctrlSetStructuredText parseText _text;
    
    // Group selected - clean up any cargo icons
    [objNull] call OpsRoom_fnc_updateCargoDisplay;
    
} else {
    // Single unit selected - show detailed info
    
    // Get unit type
    private _unitType = "UNKNOWN";
    if (_unit isKindOf "Man") then {_unitType = "INFANTRY"};
    if (_unit isKindOf "Car" || _unit isKindOf "Motorcycle") then {_unitType = "VEHICLE"};
    if (_unit isKindOf "Tank") then {_unitType = "ARMOR"};
    if (_unit isKindOf "Air") then {_unitType = "AIRCRAFT"};
    if (_unit isKindOf "Ship") then {_unitType = "NAVAL"};
    
    // Get unit health
    private _damage = damage _unit;
    private _health = (1 - _damage) * 100;
    private _healthColor = "#00FF00";
    if (_health < 75) then {_healthColor = "#FFFF00"};
    if (_health < 50) then {_healthColor = "#FFA500"};
    if (_health < 25) then {_healthColor = "#FF0000"};
    
    // For infantry, show detailed soldier info
    if (_unit isKindOf "Man") then {
        // Get rank and format it properly
        private _rank = rank _unit;
        private _rankFormatted = switch (_rank) do {
            case "PRIVATE": {"Private"};
            case "CORPORAL": {"Corporal"};
            case "SERGEANT": {"Sergeant"};
            case "LIEUTENANT": {"Lieutenant"};
            case "CAPTAIN": {"Captain"};
            case "MAJOR": {"Major"};
            case "COLONEL": {"Colonel"};
            default {_rank};
        };
        
        // Get soldier name
        private _soldierName = name _unit;
        
        // Get combat mode (fire discipline) from group
        private _combatMode = combatMode (group _unit);
        private _combatModeColor = "#FFFF00"; // Default yellow
        private _combatModeText = "Unknown";
        
        switch (_combatMode) do {
            case "BLUE": {
                _combatModeColor = "#4169E1"; // Royal blue
                _combatModeText = "Never Fire";
            };
            case "GREEN": {
                _combatModeColor = "#32CD32"; // Lime green
                _combatModeText = "Hold Fire";
            };
            case "WHITE": {
                _combatModeColor = "#FFFFFF"; // White
                _combatModeText = "Hold, Engage at Will";
            };
            case "YELLOW": {
                _combatModeColor = "#FFD700"; // Gold
                _combatModeText = "Fire at Will";
            };
            case "RED": {
                _combatModeColor = "#FF0000"; // Red
                _combatModeText = "Fire, Engage at Will";
            };
        };
        
        // Get behaviour state
        private _behaviour = behaviour _unit;
        private _behaviourColor = "#00FF00"; // Default green (SAFE)
        private _behaviourText = _behaviour;
        
        switch (_behaviour) do {
            case "SAFE": {
                _behaviourColor = "#00FF00"; // Green
                _behaviourText = "Safe";
            };
            case "AWARE": {
                _behaviourColor = "#FFFF00"; // Yellow
                _behaviourText = "Aware";
            };
            case "COMBAT": {
                _behaviourColor = "#FF0000"; // Red
                _behaviourText = "Combat";
            };
            case "STEALTH": {
                _behaviourColor = "#00BFFF"; // Blue
                _behaviourText = "Stealth";
            };
            case "CARELESS": {
                _behaviourColor = "#999999"; // Gray
                _behaviourText = "Careless";
            };
        };
        
        // Check for targets using assignedTarget
        private _targetInfo = "";
        private _target = assignedTarget _unit;
        
        // If no assigned target, check nearest enemy when in combat
        if (isNull _target && (behaviour _unit == "COMBAT")) then {
            private _nearestEnemy = _unit findNearestEnemy _unit;
            if (!isNull _nearestEnemy) then {
                private _distance = _unit distance _nearestEnemy;
                if (_distance < 500) then {
                    _target = _nearestEnemy;
                };
            };
        };
        
        // Display target info if we found one
        if (!isNull _target) then {
            private _targetType = "Target";
            if (_target isKindOf "Man") then {_targetType = "Infantry"};
            if (_target isKindOf "Car") then {_targetType = "Vehicle"};
            if (_target isKindOf "Tank") then {_targetType = "Armor"};
            if (_target isKindOf "Air") then {_targetType = "Aircraft"};
            
            _targetInfo = format ["<br/><t align='center' size='0.85' color='#FF8C00'>ENGAGING: %1</t>", _targetType];
        };
        
        // Build display text with both combat mode and behaviour
        private _text = format [
            "<t align='center' size='1.1'>%1 %2</t><br/><t align='center' size='0.9' color='#AAAAAA'>Health: <t color='%3'>%4%%</t>  |  <t color='%5'>%6</t>  |  <t color='%7'>%8</t></t>%9",
            _rankFormatted,
            _soldierName,
            _healthColor,
            round _health,
            _combatModeColor,
            _combatModeText,
            _behaviourColor,
            _behaviourText,
            _targetInfo
        ];
        
        _unitInfoCtrl ctrlSetStructuredText parseText _text;
        
        // Infantry selected — clean up any cargo icons
        [objNull] call OpsRoom_fnc_updateCargoDisplay;
        
    } else {
        // Non-infantry unit - show basic info
        private _unitName = getText (configFile >> "CfgVehicles" >> typeOf _unit >> "displayName");
        if (_unitName == "") then {_unitName = typeOf _unit};
        
        // Check if this is a cargo carrier
        private _cargoInfo = "";
        if (!isNil "OpsRoom_CargoCarriers") then {
            private _cap = [_unit] call OpsRoom_fnc_getCargoCapacity;
            _cap params ["_usedCargo", "_maxCargo", "_isCarrier"];
            if (_isCarrier) then {
                private _cargoColor = if (_usedCargo >= _maxCargo) then {"#FF6600"} else {"#8BC34A"};
                _cargoInfo = format ["  |  CARGO: <t color='%1'>%2/%3</t>", _cargoColor, _usedCargo, _maxCargo];
            };
        };
        
        private _text = format [
            "<t align='center' size='1.0'>%1</t><br/><t align='center' size='0.9' color='#AAAAAA'>%2  |  HEALTH: <t color='%3'>%4%%</t>%5</t>",
            _unitName,
            _unitType,
            _healthColor,
            round _health,
            _cargoInfo
        ];
        _unitInfoCtrl ctrlSetStructuredText parseText _text;
        
        // Update clickable cargo icons on Zeus display
        [_unit] call OpsRoom_fnc_updateCargoDisplay;
    };
};
