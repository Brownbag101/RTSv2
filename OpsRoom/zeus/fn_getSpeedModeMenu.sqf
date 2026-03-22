/*
    OpsRoom_fnc_getSpeedModeMenu
    
    Returns menu items for speed mode selection
    
    Returns:
        Array of [text, icon, action]
*/

[
    ["Limited Speed", "a3\3den\data\attributes\speedmode\limited_ca.paa", {
        private _selected = curatorSelected select 0;
        private _groups = [];
        {_groups pushBackUnique (group _x)} forEach _selected;
        {_x setSpeedMode "LIMITED"} forEach _groups;
        systemChat "Speed: Limited (Slow)";
    }],
    
    ["Normal Speed", "a3\3den\data\attributes\speedmode\normal_ca.paa", {
        private _selected = curatorSelected select 0;
        private _groups = [];
        {_groups pushBackUnique (group _x)} forEach _selected;
        {_x setSpeedMode "NORMAL"} forEach _groups;
        systemChat "Speed: Normal";
    }],
    
    ["Full Speed", "a3\3den\data\attributes\speedmode\full_ca.paa", {
        private _selected = curatorSelected select 0;
        private _groups = [];
        {_groups pushBackUnique (group _x)} forEach _selected;
        {_x setSpeedMode "FULL"} forEach _groups;
        systemChat "Speed: Full (Fast)";
    }]
]
