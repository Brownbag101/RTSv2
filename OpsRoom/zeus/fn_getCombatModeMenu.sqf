/*
    OpsRoom_fnc_getCombatModeMenu
    
    Returns menu items for combat mode selection
    
    Returns:
        Array of [text, icon, action]
*/

[
    ["Never Fire", "a3\ui_f\data\igui\cfg\simpletasks\types\defend_ca.paa", {
        private _selected = curatorSelected select 0;
        private _groups = [];
        {_groups pushBackUnique (group _x)} forEach _selected;
        {_x setCombatMode "BLUE"} forEach _groups;
        systemChat "Combat: Never Fire";
    }],
    
    ["Hold Fire", "a3\ui_f\data\igui\cfg\simpletasks\types\defend_ca.paa", {
        private _selected = curatorSelected select 0;
        private _groups = [];
        {_groups pushBackUnique (group _x)} forEach _selected;
        {_x setCombatMode "GREEN"} forEach _groups;
        systemChat "Combat: Hold Fire";
    }],
    
    ["Hold Fire, Engage at Will", "a3\ui_f\data\igui\cfg\simpletasks\types\defend_ca.paa", {
        private _selected = curatorSelected select 0;
        private _groups = [];
        {_groups pushBackUnique (group _x)} forEach _selected;
        {_x setCombatMode "WHITE"} forEach _groups;
        systemChat "Combat: Hold Fire, Engage at Will";
    }],
    
    ["Fire at Will", "a3\ui_f\data\igui\cfg\simpletasks\types\defend_ca.paa", {
        private _selected = curatorSelected select 0;
        private _groups = [];
        {_groups pushBackUnique (group _x)} forEach _selected;
        {_x setCombatMode "YELLOW"} forEach _groups;
        systemChat "Combat: Fire at Will";
    }],
    
    ["Fire at Will, Engage at Will", "a3\ui_f\data\igui\cfg\simpletasks\types\danger_ca.paa", {
        private _selected = curatorSelected select 0;
        private _groups = [];
        {_groups pushBackUnique (group _x)} forEach _selected;
        {_x setCombatMode "RED"} forEach _groups;
        systemChat "Combat: Fire at Will, Engage at Will";
    }]
]
