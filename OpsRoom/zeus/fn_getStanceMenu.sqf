/*
    OpsRoom_fnc_getStanceMenu
    
    Returns menu items for stance selection
    
    Returns:
        Array of [text, icon, action]
*/

[
    ["Auto Stance", "a3\3den\data\attributes\stance\up_ca.paa", {
        private _selected = curatorSelected select 0;
        {_x setUnitPos "AUTO"} forEach _selected;
        systemChat "Stance: Auto";
    }],
    
    ["Stand", "a3\3den\data\attributes\stance\up_ca.paa", {
        private _selected = curatorSelected select 0;
        {_x setUnitPos "UP"} forEach _selected;
        systemChat "Stance: Standing";
    }],
    
    ["Crouch", "a3\3den\data\attributes\stance\middle_ca.paa", {
        private _selected = curatorSelected select 0;
        {_x setUnitPos "MIDDLE"} forEach _selected;
        systemChat "Stance: Crouched";
    }],
    
    ["Prone", "a3\3den\data\attributes\stance\down_ca.paa", {
        private _selected = curatorSelected select 0;
        {_x setUnitPos "DOWN"} forEach _selected;
        systemChat "Stance: Prone";
    }]
]
