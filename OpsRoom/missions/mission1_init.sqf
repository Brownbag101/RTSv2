/*
    Mission 1 Initialization
    
    Initializes the first mission: Secure Landing Zone
    - Spawns 1st Essex Regiment
    - Creates regiment in OpsRoom system
    - Creates task to clear area
    - Triggers Mission 2 on completion
    
    Called automatically from OpsRoom\init.sqf if enabled in settings.
*/

// Wait for OpsRoom to initialize
waitUntil {
    !isNil "OpsRoom_Regiments" && 
    !isNil "OpsRoom_Groups"
};

diag_log "[OpsRoom Mission1] Starting Mission 1 initialization";
systemChat "◆ MISSION 1: Secure Landing Zone";

// Load marker icon library
call compile preprocessFileLineNumbers "OpsRoom\missions\markerIcons.sqf";

// Spawn starting regiment
private _spawnedUnits = [] call OpsRoom_fnc_spawnStartingRegiment;

// Store units for regiment system
OpsRoom_StartingUnits = _spawnedUnits;

// Re-initialize regiment system to create regiment from spawned units
[] call OpsRoom_fnc_initRegiments;

diag_log format ["[OpsRoom Mission1] Regiment system initialized with %1 units", count _spawnedUnits];

// Wait for GUI to settle
sleep 5;

// Create the clear area task
[] call OpsRoom_fnc_createClearAreaTask;

diag_log "[OpsRoom Mission1] Mission 1 initialization complete";
