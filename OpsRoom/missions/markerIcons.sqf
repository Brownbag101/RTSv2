/*
    3D Marker Icon Library
    
    Standardized icon paths and presets for Zeus 3D markers.
    Use these for consistent marker appearance across missions.
*/

// Icon texture paths
OpsRoom_MarkerIcons = createHashMapFromArray [
    // Military objectives
    ["objective", "\A3\ui_f\data\map\markers\military\objective_CA.paa"],
    ["destroy", "\A3\ui_f\data\IGUI\Cfg\SimpleTasks\types\destroy_ca.paa"],
    ["defend", "\A3\ui_f\data\IGUI\Cfg\SimpleTasks\types\defend_ca.paa"],
    ["attack", "\A3\ui_f\data\IGUI\Cfg\SimpleTasks\types\attack_ca.paa"],
    ["secure", "\A3\ui_f\data\IGUI\Cfg\SimpleTasks\types\search_ca.paa"],
    
    // Support markers
    ["repair", "\A3\ui_f\data\IGUI\Cfg\SimpleTasks\types\repair_ca.paa"],
    ["rearm", "\A3\ui_f\data\IGUI\Cfg\SimpleTasks\types\rearm_ca.paa"],
    ["refuel", "\A3\ui_f\data\IGUI\Cfg\SimpleTasks\types\refuel_ca.paa"],
    ["heal", "\A3\ui_f\data\IGUI\Cfg\SimpleTasks\types\heal_ca.paa"],
    
    // Special markers
    ["mine", "\A3\ui_f\data\IGUI\Cfg\SimpleTasks\types\mine_ca.paa"],
    ["boat", "\A3\ui_f\data\IGUI\Cfg\SimpleTasks\types\boat_ca.paa"],
    ["heli", "\A3\ui_f\data\IGUI\Cfg\SimpleTasks\types\heli_ca.paa"],
    ["plane", "\A3\ui_f\data\IGUI\Cfg\SimpleTasks\types\plane_ca.paa"],
    ["car", "\A3\ui_f\data\IGUI\Cfg\SimpleTasks\types\car_ca.paa"],
    
    // Warning/danger
    ["danger", "\A3\ui_f\data\map\markers\military\warning_CA.paa"],
    ["explosion", "\A3\ui_f\data\map\markers\military\destroy_CA.paa"],
    
    // Info markers
    ["meet", "\A3\ui_f\data\IGUI\Cfg\SimpleTasks\types\meet_ca.paa"],
    ["talk", "\A3\ui_f\data\IGUI\Cfg\SimpleTasks\types\talk_ca.paa"],
    ["intel", "\A3\ui_f\data\IGUI\Cfg\SimpleTasks\types\documents_ca.paa"],
    ["container", "\A3\ui_f\data\IGUI\Cfg\SimpleTasks\types\container_ca.paa"]
];

// Color presets
OpsRoom_MarkerColors = createHashMapFromArray [
    ["blue", [0.2, 0.6, 1, 1]],      // Friendly/Objective
    ["green", [0.2, 1, 0.3, 1]],     // Safe/Complete
    ["yellow", [1, 0.9, 0.2, 1]],    // Warning/Caution
    ["orange", [1, 0.5, 0.1, 1]],    // Alert
    ["red", [1, 0.2, 0.2, 1]],       // Danger/Enemy
    ["purple", [0.8, 0.3, 1, 1]],    // Special/VIP
    ["white", [1, 1, 1, 1]],         // Neutral/Info
    ["black", [0.1, 0.1, 0.1, 1]]    // Dark/Stealth
];

/*
    USAGE EXAMPLES:
    ===============
    
    // Using preset icon
    private _icon = OpsRoom_MarkerIcons get "objective";
    private _color = OpsRoom_MarkerColors get "blue";
    [
        "myMarker",
        [0,0,0],
        "TEXT",
        _icon,
        _color,
        2
    ] call OpsRoom_fnc_create3DMarker;
    
    // Quick objective marker
    [
        "objective1",
        getPos player,
        "SECURE AREA",
        OpsRoom_MarkerIcons get "objective",
        OpsRoom_MarkerColors get "blue",
        2
    ] call OpsRoom_fnc_create3DMarker;
    
    // Danger marker
    [
        "danger1",
        [100,200,10],
        "MINES",
        OpsRoom_MarkerIcons get "mine",
        OpsRoom_MarkerColors get "red",
        1.5
    ] call OpsRoom_fnc_create3DMarker;
    
    // Follow an object (e.g., engineer)
    [
        "engineer1",
        _engineerUnit,  // Object reference
        "ENGINEER",
        OpsRoom_MarkerIcons get "repair",
        OpsRoom_MarkerColors get "green",
        1.5
    ] call OpsRoom_fnc_create3DMarker;
*/

diag_log "[OpsRoom] Marker icon library initialized";
