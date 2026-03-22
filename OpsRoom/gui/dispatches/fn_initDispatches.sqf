/*
    fn_initDispatches
    
    Initializes the dispatch message system.
    Sets up globals, message types, and IDC reservations.
    
    Called from init.sqf at mission start.
*/

// Message storage - array of hashmaps, newest first
if (isNil "OpsRoom_Dispatches") then { OpsRoom_Dispatches = [] };

// Next dispatch ID counter
if (isNil "OpsRoom_DispatchNextID") then { OpsRoom_DispatchNextID = 1 };

// Unread count (for button badge)
if (isNil "OpsRoom_DispatchUnread") then { OpsRoom_DispatchUnread = 0 };

// Currently showing popup (nil if none)
OpsRoom_DispatchPopupActive = false;

// Dispatch queue (if popup already showing, queue the next one)
if (isNil "OpsRoom_DispatchQueue") then { OpsRoom_DispatchQueue = [] };

/*
    Message Type Definitions
    
    Format: [headerColor, soundClass, autoDismissSeconds, displayName, iconPath]
    
    Header colors match WW2 British signals priority system:
        ROUTINE  - Standard reports, non-urgent
        PRIORITY - Important but not time-critical  
        FLASH    - Immediate action required
        ULTRA    - Bletchley Park decrypt (special intelligence)
        SOE      - Agent reports from behind enemy lines (future)
*/
OpsRoom_DispatchTypes = createHashMapFromArray [
    ["ROUTINE",  createHashMapFromArray [
        ["color", [0.55, 0.50, 0.40, 0.95]],
        ["sound", "FD_CP_Not_Icon_F"],
        ["dismissTime", 12],
        ["displayName", "ROUTINE"],
        ["icon", "\A3\ui_f\data\map\markers\military\dot_CA.paa"]
    ]],
    ["PRIORITY", createHashMapFromArray [
        ["color", [0.70, 0.60, 0.20, 0.95]],
        ["sound", "FD_Finish_F"],
        ["dismissTime", 18],
        ["displayName", "PRIORITY"],
        ["icon", "\A3\ui_f\data\map\markers\military\warning_CA.paa"]
    ]],
    ["FLASH",    createHashMapFromArray [
        ["color", [0.70, 0.20, 0.15, 0.95]],
        ["sound", "alarm"],
        ["dismissTime", 25],
        ["displayName", "FLASH"],
        ["icon", "\A3\ui_f\data\map\markers\military\destroy_CA.paa"]
    ]],
    ["ULTRA",    createHashMapFromArray [
        ["color", [0.45, 0.20, 0.60, 0.95]],
        ["sound", "FD_CP_Not_Icon_F"],
        ["dismissTime", 20],
        ["displayName", "ULTRA DECRYPT"],
        ["icon", "\A3\ui_f\data\map\markers\military\unknown_CA.paa"]
    ]],
    ["SOE",      createHashMapFromArray [
        ["color", [0.20, 0.40, 0.25, 0.95]],
        ["sound", "FD_CP_Not_Icon_F"],
        ["dismissTime", 20],
        ["displayName", "SOE SIGNAL"],
        ["icon", "\A3\ui_f\data\map\markers\military\circle_CA.paa"]
    ]]
];

// Apply settings overrides for dismiss times
{
    private _type = _x;
    private _settingVar = format ["OpsRoom_Settings_DispatchDismiss_%1", _type];
    private _settingVal = missionNamespace getVariable [_settingVar, -1];
    if (_settingVal >= 0) then {
        private _typeData = OpsRoom_DispatchTypes get _type;
        _typeData set ["dismissTime", _settingVal];
    };
} forEach ["ROUTINE", "PRIORITY", "FLASH", "ULTRA", "SOE"];

systemChat "Dispatches: System initialized";
diag_log "[OpsRoom] Dispatch system initialized";
