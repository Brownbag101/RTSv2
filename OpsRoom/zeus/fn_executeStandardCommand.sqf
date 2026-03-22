/*
    OpsRoom_fnc_executeStandardCommand
    
    Executes standard commands on selected units
    
    Parameters:
        _commandType - "stance", "combatMode", "speedMode", "formation"
*/

params ["_commandType"];

// Get currently selected units
private _selected = curatorSelected select 0;

if (count _selected == 0) exitWith {
    hint "No units selected";
};

switch (_commandType) do {
    case "stance": {
        // Cycle through stances: AUTO → STAND → CROUCH → PRONE → AUTO
        private _currentStance = unitPos (_selected select 0);
        private _newStance = switch (_currentStance) do {
            case "AUTO": {"UP"};
            case "UP": {"MIDDLE"};
            case "MIDDLE": {"DOWN"};
            case "DOWN": {"AUTO"};
            default {"AUTO"};
        };
        
        {_x setUnitPos _newStance} forEach _selected;
        
        private _stanceName = switch (_newStance) do {
            case "AUTO": {"Auto"};
            case "UP": {"Standing"};
            case "MIDDLE": {"Crouched"};
            case "DOWN": {"Prone"};
        };
        
        systemChat format ["Stance: %1", _stanceName];
    };
    
    case "combatMode": {
        // Cycle through: BLUE → GREEN → WHITE → YELLOW → RED → BLUE
        private _group = group (_selected select 0);
        private _currentMode = combatMode _group;
        private _newMode = switch (_currentMode) do {
            case "BLUE": {"GREEN"};
            case "GREEN": {"WHITE"};
            case "WHITE": {"YELLOW"};
            case "YELLOW": {"RED"};
            case "RED": {"BLUE"};
            default {"GREEN"};
        };
        
        // Apply to all groups in selection
        private _groups = [];
        {_groups pushBackUnique (group _x)} forEach _selected;
        {_x setCombatMode _newMode} forEach _groups;
        
        private _modeName = switch (_newMode) do {
            case "BLUE": {"Never Fire"};
            case "GREEN": {"Hold Fire"};
            case "WHITE": {"Hold Fire, Engage at Will"};
            case "YELLOW": {"Fire at Will"};
            case "RED": {"Fire at Will, Engage at Will"};
        };
        
        systemChat format ["Combat: %1", _modeName];
    };
    
    case "speedMode": {
        // Cycle through: LIMITED → NORMAL → FULL → LIMITED
        private _group = group (_selected select 0);
        private _currentSpeed = speedMode _group;
        private _newSpeed = switch (_currentSpeed) do {
            case "LIMITED": {"NORMAL"};
            case "NORMAL": {"FULL"};
            case "FULL": {"LIMITED"};
            default {"NORMAL"};
        };
        
        // Apply to all groups in selection
        private _groups = [];
        {_groups pushBackUnique (group _x)} forEach _selected;
        {_x setSpeedMode _newSpeed} forEach _groups;
        
        private _speedName = switch (_newSpeed) do {
            case "LIMITED": {"Slow"};
            case "NORMAL": {"Normal"};
            case "FULL": {"Fast"};
        };
        
        systemChat format ["Speed: %1", _speedName];
    };
    
    case "formation": {
        // Simple formation cycle: COLUMN → STAG COLUMN → WEDGE → LINE → COLUMN
        private _group = group (_selected select 0);
        private _currentForm = formation _group;
        private _newForm = switch (_currentForm) do {
            case "COLUMN": {"STAG COLUMN"};
            case "STAG COLUMN": {"WEDGE"};
            case "WEDGE": {"LINE"};
            case "LINE": {"COLUMN"};
            default {"WEDGE"};
        };
        
        // Apply to all groups in selection
        private _groups = [];
        {_groups pushBackUnique (group _x)} forEach _selected;
        {_x setFormation _newForm} forEach _groups;
        
        systemChat format ["Formation: %1", _newForm];
    };
};
