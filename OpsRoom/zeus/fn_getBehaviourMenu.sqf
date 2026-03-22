/*
    OpsRoom_fnc_getBehaviourMenu
    
    Returns menu items for behaviour selection
    
    Returns:
        Array of [text, icon, action]
*/

[
    ["Safe", "a3\ui_f\data\igui\cfg\simpletasks\types\defend_ca.paa", {
        private _selected = curatorSelected select 0;
        private _groups = [];
        {_groups pushBackUnique (group _x)} forEach _selected;
        {_x setBehaviour "SAFE"} forEach _groups;
        systemChat "Behaviour: Safe";
    }],
    
    ["Aware", "a3\ui_f\data\igui\cfg\simpletasks\types\search_ca.paa", {
        private _selected = curatorSelected select 0;
        private _groups = [];
        {_groups pushBackUnique (group _x)} forEach _selected;
        {_x setBehaviour "AWARE"} forEach _groups;
        systemChat "Behaviour: Aware";
    }],
    
    ["Combat", "a3\ui_f\data\igui\cfg\simpletasks\types\danger_ca.paa", {
        private _selected = curatorSelected select 0;
        private _groups = [];
        {_groups pushBackUnique (group _x)} forEach _selected;
        {_x setBehaviour "COMBAT"} forEach _groups;
        systemChat "Behaviour: Combat";
    }],
    
    ["Stealth", "a3\ui_f\data\igui\cfg\simpletasks\types\scout_ca.paa", {
        private _selected = curatorSelected select 0;
        private _groups = [];
        {_groups pushBackUnique (group _x)} forEach _selected;
        {_x setBehaviour "STEALTH"} forEach _groups;
        systemChat "Behaviour: Stealth";
    }],
    
    ["Careless", "a3\ui_f\data\igui\cfg\simpletasks\types\whiteboard_ca.paa", {
        private _selected = curatorSelected select 0;
        private _groups = [];
        {_groups pushBackUnique (group _x)} forEach _selected;
        {_x setBehaviour "CARELESS"} forEach _groups;
        systemChat "Behaviour: Careless";
    }]
]
