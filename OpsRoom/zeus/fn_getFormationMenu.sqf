/*
    OpsRoom_fnc_getFormationMenu
    
    Returns menu items for formation selection
    
    Returns:
        Array of [text, icon, action]
*/

[
    ["Column", "a3\3den\data\attributes\formation\column_ca.paa", {
        private _selected = curatorSelected select 0;
        private _groups = [];
        {_groups pushBackUnique (group _x)} forEach _selected;
        {_x setFormation "COLUMN"} forEach _groups;
        systemChat "Formation: Column";
    }],
    
    ["Staggered Column", "a3\3den\data\attributes\formation\stag_column_ca.paa", {
        private _selected = curatorSelected select 0;
        private _groups = [];
        {_groups pushBackUnique (group _x)} forEach _selected;
        {_x setFormation "STAG COLUMN"} forEach _groups;
        systemChat "Formation: Staggered Column";
    }],
    
    ["Wedge", "a3\3den\data\attributes\formation\wedge_ca.paa", {
        private _selected = curatorSelected select 0;
        private _groups = [];
        {_groups pushBackUnique (group _x)} forEach _selected;
        {_x setFormation "WEDGE"} forEach _groups;
        systemChat "Formation: Wedge";
    }],
    
    ["Echelon Left", "a3\3den\data\attributes\formation\ech_left_ca.paa", {
        private _selected = curatorSelected select 0;
        private _groups = [];
        {_groups pushBackUnique (group _x)} forEach _selected;
        {_x setFormation "ECH LEFT"} forEach _groups;
        systemChat "Formation: Echelon Left";
    }],
    
    ["Echelon Right", "a3\3den\data\attributes\formation\ech_right_ca.paa", {
        private _selected = curatorSelected select 0;
        private _groups = [];
        {_groups pushBackUnique (group _x)} forEach _selected;
        {_x setFormation "ECH RIGHT"} forEach _groups;
        systemChat "Formation: Echelon Right";
    }],
    
    ["Vee", "a3\3den\data\attributes\formation\vee_ca.paa", {
        private _selected = curatorSelected select 0;
        private _groups = [];
        {_groups pushBackUnique (group _x)} forEach _selected;
        {_x setFormation "VEE"} forEach _groups;
        systemChat "Formation: Vee";
    }],
    
    ["Line", "a3\3den\data\attributes\formation\line_ca.paa", {
        private _selected = curatorSelected select 0;
        private _groups = [];
        {_groups pushBackUnique (group _x)} forEach _selected;
        {_x setFormation "LINE"} forEach _groups;
        systemChat "Formation: Line";
    }],
    
    ["File", "a3\3den\data\attributes\formation\file_ca.paa", {
        private _selected = curatorSelected select 0;
        private _groups = [];
        {_groups pushBackUnique (group _x)} forEach _selected;
        {_x setFormation "FILE"} forEach _groups;
        systemChat "Formation: File";
    }],
    
    ["Diamond", "a3\3den\data\attributes\formation\diamond_ca.paa", {
        private _selected = curatorSelected select 0;
        private _groups = [];
        {_groups pushBackUnique (group _x)} forEach _selected;
        {_x setFormation "DIAMOND"} forEach _groups;
        systemChat "Formation: Diamond";
    }]
]
