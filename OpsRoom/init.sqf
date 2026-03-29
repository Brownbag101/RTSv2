/*
    Operations Room - Initialization
    
    HOW TO USE:
    ===========
    Call this from your mission's init.sqf:
    [] execVM "OpsRoom\init.sqf";
    
    OPTIONAL - Custom Settings:
    ===========================
    Override settings before calling init:
    
    OpsRoom_Settings_InitialResources = [
        ["Wood", 2000],
        ["Iron", 1000],
        ["Oil", 500]
    ];
    [] execVM "OpsRoom\init.sqf";
*/

// Wait for mission to be ready
waitUntil {time > 0};

// Wait for CfgFunctions to compile
waitUntil {!isNil "OpsRoom_fnc_initRegiments"};

systemChat "Initializing Operations Room system...";

// Load default settings if not already configured
if (isNil "OpsRoom_Settings_InitialResources") then {
    call compile preprocessFileLineNumbers "OpsRoom\settings.sqf";
};

// Initialize resource variables from settings
{
    _x params ["_resourceName", "_initialValue"];
    // Replace spaces with underscores for variable names (manual implementation)
    private _cleanName = _resourceName;
    while {_cleanName find " " != -1} do {
        private _spacePos = _cleanName find " ";
        _cleanName = (_cleanName select [0, _spacePos]) + "_" + (_cleanName select [_spacePos + 1]);
    };
    private _varName = format["OpsRoom_Resource_%1", _cleanName];
    missionNamespace setVariable [_varName, _initialValue];
} forEach OpsRoom_Settings_InitialResources;

systemChat "Resources initialized";

// Initialize service records & medal system
[] call OpsRoom_fnc_initServiceRecords;

// Initialize regiments system
[] call OpsRoom_fnc_initRegiments;

// Initialize recruitment pool
OpsRoom_RecruitPool = [];
[] call OpsRoom_fnc_initRecruitmentPool;

// Start recruitment refresh loop
[] spawn OpsRoom_fnc_recruitmentRefreshLoop;

// Load training courses and initialize training system
call compile preprocessFileLineNumbers "OpsRoom\data\trainingCourses.sqf";

// Load equipment database (source of truth for Research/Production/Supply)
call compile preprocessFileLineNumbers "OpsRoom\data\equipmentDatabase.sqf";

// Initialize Research/Production/Supply state
if (isNil "OpsRoom_ResearchCompleted") then { OpsRoom_ResearchCompleted = [] };
if (isNil "OpsRoom_ResearchInProgress") then { missionNamespace setVariable ["OpsRoom_ResearchInProgress", []] };
if (isNil "OpsRoom_Warehouse") then { OpsRoom_Warehouse = createHashMap };
if (isNil "OpsRoom_Factories") then { OpsRoom_Factories = [] };
if (isNil "OpsRoom_MaxFactories") then { OpsRoom_MaxFactories = 1 };
if (isNil "OpsRoom_ActiveShipments") then { OpsRoom_ActiveShipments = [] };
if (isNil "OpsRoom_ShipmentQueue") then { OpsRoom_ShipmentQueue = [] };

systemChat "Equipment database loaded";

// Load buildable objects database
call compile preprocessFileLineNumbers "OpsRoom\data\buildables.sqf";

// Load location types and initialize strategic locations
call compile preprocessFileLineNumbers "OpsRoom\data\locationTypes.sqf";
[] call OpsRoom_fnc_initStrategicLocations;

// Load AI Commander configuration
call compile preprocessFileLineNumbers "OpsRoom\data\aiCommander.sqf";
systemChat "AI Commander config loaded";

// Initialize location buildings (bind map buildings to locations)
[] call OpsRoom_fnc_initLocationBuildings;

// Initialize storehouses
[] call OpsRoom_fnc_initStorehouses;

// Initialize Sea Lanes & Convoy system
[] call OpsRoom_fnc_initSeaLanes;
systemChat "Sea lanes initialized";

// Initialize Cargo Logistics system
[] call OpsRoom_fnc_initCargo;
[] call OpsRoom_fnc_cargoDraw3D;
systemChat "Cargo logistics initialized";

// Initialize Air Operations hangar
[] call OpsRoom_fnc_initHangar;
[] call OpsRoom_fnc_airDraw3D;
[] call OpsRoom_fnc_airReconMonitor;
[] call OpsRoom_fnc_photoReconMonitor;
[] call OpsRoom_fnc_missionScheduler;
[] call OpsRoom_fnc_autoServiceMonitor;
[] call OpsRoom_fnc_aircraftStatusMonitor;
systemChat "Air Operations hangar initialized";

// Initialize dispatch system
[] call OpsRoom_fnc_initDispatches;
systemChat "Dispatch system initialized";

// Initialize intelligence state
if (isNil "OpsRoom_StrategicLocations") then { OpsRoom_StrategicLocations = createHashMap };
if (isNil "OpsRoom_Operations") then { OpsRoom_Operations = createHashMap };
if (isNil "OpsRoom_OperationNextID") then { OpsRoom_OperationNextID = 1 };

// Start intel monitor loop
[] spawn OpsRoom_fnc_intelMonitor;

// Start location Draw3D (name labels, capture bars, radius circles)
[] call OpsRoom_fnc_locationDraw3D;

// Start capture monitor loop
[] spawn OpsRoom_fnc_captureMonitor;
systemChat "Intelligence & capture systems initialized";

// Start training monitor loop
[] spawn OpsRoom_fnc_trainingMonitor;

// Start research monitor loop
[] spawn OpsRoom_fnc_researchMonitor;

// Start production monitor loop
[] spawn OpsRoom_fnc_productionMonitor;

// Start supply monitor loop (legacy timer-based fallback)
[] spawn OpsRoom_fnc_supplyMonitor;

// Start convoy monitor (physical ship system)
[] spawn OpsRoom_fnc_convoyMonitor;

// Start convoy Draw3D labels
[] call OpsRoom_fnc_convoyDraw3D;

// Start enemy shipping monitor
[] spawn OpsRoom_fnc_enemyShippingMonitor;

// Create first factory if none exist
if (count OpsRoom_Factories == 0) then {
    private _firstFactory = createHashMapFromArray [
        ["id", "factory_1"],
        ["name", "Factory 1"],
        ["producing", ""],
        ["startTime", 0],
        ["cycleTime", 0],
        ["continuous", true]
    ];
    OpsRoom_Factories pushBack _firstFactory;
    missionNamespace setVariable ["OpsRoom_Factories", OpsRoom_Factories];
    systemChat "Factory 1 ready";
};

// Initialize GUI
[] call OpsRoom_fnc_initMainGUI;

// Initialize Zeus UI hiding (after delay)
if (OpsRoom_Settings_AutoHideZeusUI) then {
    [] spawn {
        sleep OpsRoom_Settings_ZeusInitDelay;
        [] call OpsRoom_fnc_hideZeusUI;
    };
};

// Initialize date/time display
[] spawn {
    waitUntil {!isNull (findDisplay 312)};
    [] call OpsRoom_fnc_createDateTimeDisplay;
    
    // Update date/time every second
    while {true} do {
        [] call OpsRoom_fnc_updateDateTime;
        sleep 1;
    };
};

// Initialize speed controls
[] spawn {
    waitUntil {!isNull (findDisplay 312)};
    [] call OpsRoom_fnc_createSpeedControls;
};

// Initialize ability config
[] call compile preprocessFileLineNumbers "OpsRoom\zeus\abilities\config.sqf";

// Initialize standard buttons (left side)
[] spawn OpsRoom_fnc_createStandardButtons;

// ========================================
// AI COMMANDER SYSTEM
// ========================================

// Initialize Command Intelligence (must be before AI monitors)
[] call OpsRoom_fnc_initCommandIntel;
systemChat "Command Intelligence initialized";

// Spawn radios at enemy locations
[] call OpsRoom_fnc_initLocationRadios;

// Start AI Commander monitors
[] spawn OpsRoom_fnc_aiCommanderMonitor;
[] spawn OpsRoom_fnc_radioAlarmMonitor;
[] spawn OpsRoom_fnc_aiManpowerMonitor;
[] spawn OpsRoom_fnc_commandIntelMonitor;
[] spawn OpsRoom_fnc_aiMapMarkers;
[] call OpsRoom_fnc_aiDraw3D;
systemChat "AI Commander initialized";

systemChat "✓ Operations Room system ready";

// Start unified Zeus monitor (replaces old monitorSelection)
[] spawn OpsRoom_fnc_unifiedZeusMonitor;

// Initialize mission sequence (if Mission 1 enabled)
if (OpsRoom_Settings_EnableMission1) then {
    // Show cinematic intro
    [
        "OPERATION CLEARWATER",
        "1st Essex Regiment<br/>Secure the Landing Zone",
        3
    ] spawn OpsRoom_fnc_createMissionIntro;
    
    // Start mission
    [] execVM "OpsRoom\missions\mission1_init.sqf";
};
