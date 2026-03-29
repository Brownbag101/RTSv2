/*
    Operations Room - Settings
    
    Edit these values to customize your setup.
    These are default values - you can override them in your mission's init.sqf
    before calling the OpsRoom initialization.
*/

// Initial resource values
OpsRoom_Settings_InitialResources = [
    ["Wood", 50],
    ["Oil", 50],
    ["Aluminium", 50],
    ["Rubber", 50],
    ["Tungsten", 50],
    ["Steel", 50],
    ["Chromium", 50],
    ["Fuel", 100],
    ["Research Points", 1000],
    ["Manpower", 5]
];

// GUI refresh rates (in seconds)
OpsRoom_Settings_UnitInfoUpdateInterval = 0.5;
OpsRoom_Settings_ZeusCheckInterval = 2;

// Feature toggles
OpsRoom_Settings_ShowUnitInfo = true;
OpsRoom_Settings_ShowResources = true;
OpsRoom_Settings_AutoHideZeusUI = true;

// Delay before initializing Zeus UI hiding (seconds)
OpsRoom_Settings_ZeusInitDelay = 2;

// Mission System Settings
OpsRoom_Settings_EnableMission1 = true;  // Auto-start Mission 1: Secure Landing Zone
OpsRoom_Settings_Mission1_ClearRadius = 500;  // Radius in meters for area clear check
OpsRoom_Settings_Mission1_CheckInterval = 10;  // Seconds between area checks

// ========================================
// ZEUS CONTROL SETTINGS
// ========================================

// Selective Control (prevent ordering enemy units)
OpsRoom_Settings_SelectiveControl_Enabled = true;
OpsRoom_Settings_SelectiveControl_ShowMessages = true; // Chat feedback when selecting enemies

// Fog of War (progressive enemy visibility)
OpsRoom_Settings_FogOfWar_Enabled = true;
OpsRoom_Settings_FogOfWar_DetectionRadius = 300;      // Friendly detection range (meters)
OpsRoom_Settings_FogOfWar_ZeusDirectRadius = 200;    // Zeus camera reveal range (meters)
OpsRoom_Settings_FogOfWar_RemovalTimeout = 30;       // Seconds before hiding old contacts
OpsRoom_Settings_FogOfWar_ShowDetections = true;     // Chat notifications for new detections
OpsRoom_Settings_FogOfWar_KnowledgeThreshold = 1.5;  // AI knowledge threshold (0-4)
OpsRoom_Settings_FogOfWar_LOSThreshold = 0.2;        // Line of sight visibility threshold
OpsRoom_Settings_FogOfWar_CacheUpdateInterval = 2;   // Seconds between knowledge cache updates
OpsRoom_Settings_FogOfWar_FriendlyCacheInterval = 5; // Seconds between friendly unit cache updates

// ========================================
// RECRUITMENT SYSTEM SETTINGS
// ========================================

// Recruitment pool refresh interval
OpsRoom_Settings_RecruitmentRefreshInterval = 300;  // 5 minutes (300 seconds)

// Chance for good recruit (0.0-1.0)
OpsRoom_Settings_RecruitmentGoodChance = 0.10;  // 10% chance

// ========================================
// PRODUCTION SYSTEM SETTINGS
// ========================================

// Maximum number of factories the player can build
OpsRoom_MaxFactories = 6;

// Factory build cost [resource, amount]
OpsRoom_Settings_FactoryBuildCost = [["Steel", 10], ["Wood", 5]];

// ========================================
// SUPPLY SYSTEM SETTINGS
// ========================================

// Time in minutes for shipment to arrive
OpsRoom_Settings_DeliveryTime = 5;

// Maximum item types per shipment
OpsRoom_Settings_MaxShipmentSlots = 5;

// ========================================
// CONVOY & SEA LANE SETTINGS
// ========================================

// In-game hours delay between ordering convoy and ships spawning at map edge
OpsRoom_Settings_ConvoySpawnDelay = 0.01;  // Near-instant for testing (set to 1+ for production)

// ARMA speed mode for cargo ships
OpsRoom_Settings_ShipSpeed = "LIMITED";

// Ship classname (SAB WW2 Liberty Ship)
OpsRoom_Settings_ShipClassName = "sab_nl_liberty";

// Distance from port marker to trigger arrival (metres)
OpsRoom_Settings_ShipArrivalRadius = 100;

// Enemy shipping spawn interval range [min, max] in real-time seconds
OpsRoom_Settings_EnemyShipInterval = [120, 300];

// Enemy ship classname
OpsRoom_Settings_EnemyShipClassName = "sab_nl_liberty";

// Maximum ships per convoy
OpsRoom_Settings_MaxShipsPerConvoy = 5;

// Time in real-time seconds to unload one manifest item at port
OpsRoom_Settings_UnloadTimePerItem = 15;  // 15 seconds for testing (set to 120 for production)

// Sea lane names (assigned by index to opsroom_sealane_1, _2, _3 etc)
OpsRoom_Settings_SeaLaneNames = ["Channel Route", "Atlantic Route", "Mediterranean Route"];

// Convoy codename pool (WW2 Royal Navy convoy designations)
OpsRoom_Settings_ConvoyCodenames = [
    "PQ-17", "HX-84", "SC-7", "ON-67", "SL-125", "HG-76",
    "OB-318", "KMS-2", "JW-51", "MKS-30", "OS-44", "HX-229",
    "SC-122", "PQ-13", "QP-11", "WS-12", "KMF-1", "MKF-2",
    "UC-1", "GUS-24", "TM-1", "ET-14", "TE-16", "CU-36"
];

// ========================================
// DISPATCH SYSTEM SETTINGS
// ========================================

// Auto-dismiss times per type (seconds) - override defaults from fn_initDispatches
// Set to 0 to require manual dismiss
OpsRoom_Settings_DispatchDismiss_ROUTINE = 12;
OpsRoom_Settings_DispatchDismiss_PRIORITY = 18;
OpsRoom_Settings_DispatchDismiss_FLASH = 25;
OpsRoom_Settings_DispatchDismiss_ULTRA = 20;
OpsRoom_Settings_DispatchDismiss_SOE = 20;

// Maximum stored dispatches (oldest trimmed when exceeded)
OpsRoom_Settings_MaxDispatches = 100;

// ========================================
// CAPTURE MECHANIC SETTINGS
// ========================================

// Minimum attacker-to-defender ratio needed to make capture progress
OpsRoom_Settings_CaptureMinRatio = 2.0;

// Rate multiplier for capture speed (higher = faster captures)
OpsRoom_Settings_CaptureRateMultiplier = 1.0;

// Bleed rate when defenders retake control (fraction of capture rate)
OpsRoom_Settings_CaptureBleedRate = 0.5;

// Default owner for locations (NAZI = liberation scenario, NEUTRAL = contested)
OpsRoom_Settings_DefaultOwner = "NAZI";

// ========================================
// STOREHOUSE SYSTEM SETTINGS
// ========================================

// Radius around storehouse marker for unit/crate detection (metres)
OpsRoom_Settings_StorehouseRadius = 50;

// Maximum number of storehouses
OpsRoom_Settings_MaxStorehouses = 8;

// ========================================
// AIR OPERATIONS SETTINGS
// ========================================

// Maximum aircraft per wing
OpsRoom_Settings_MaxWingSize = 8;

// Seconds between aircraft spawns during launch sequence
OpsRoom_Settings_LaunchInterval = 8;

// Fuel resource cost per aircraft per sortie
OpsRoom_Settings_FuelPerSortie = 2;

// Minimum distance for Final Attack Heading (approach position) from target
OpsRoom_Settings_MinFAHDistance = 1500;

// Pilot skill multiplier (Drongo pattern: 3 = 300% skill)
OpsRoom_Settings_PilotSkill = 3;

// Auto-service interval (seconds between auto-repair/rearm/refuel checks)
OpsRoom_Settings_AutoServiceInterval = 30;

// ========================================
// CARGO LOGISTICS SETTINGS
// ========================================

// Seconds to load one cargo item onto a vehicle
OpsRoom_Settings_CargoLoadTime = 4;

// Seconds to unload one cargo item from a vehicle
OpsRoom_Settings_CargoUnloadTime = 3;

// Radius (metres) to scan for loadable items near vehicle
OpsRoom_Settings_CargoScanRadius = 25;

// Default cargo slot weight for items not specified in equipment DB
OpsRoom_Settings_CargoDefaultWeight = 1;

// ========================================
// BUILDING REPAIR SETTINGS
// ========================================

// Resources consumed per 10% repair step
OpsRoom_Settings_RepairCostSteel = 1;
OpsRoom_Settings_RepairCostWood = 1;

// Seconds per 10% repair step
OpsRoom_Settings_RepairTimePerStep = 5;

// ========================================
// BUILD SYSTEM SETTINGS
// ========================================

// Demolish returns this fraction of original cost (0.5 = 50%)
OpsRoom_Settings_DemolishRefundRate = 0.5;

// ========================================
// AI COMMANDER SETTINGS
// ========================================

// Enable/disable the AI commander system
OpsRoom_Settings_AICommander_Enabled = true;

// Starting enemy manpower (overrides aiCommander.sqf default)
// OpsRoom_Settings_AI_StartingManpower = 100;

// Editor markers (place these in your mission):
//   OpsRoom_hangar   - Hangar position (preview spawn + camera)
//   OpsRoom_runway   - Runway position (launch spawn + LAND waypoint)
