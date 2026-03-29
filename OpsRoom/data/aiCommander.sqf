/*
    AI Commander Configuration
    
    Defines group templates, unit classnames, and AI behaviour settings.
    Loaded from init.sqf at mission start.
    
    The AI Commander uses these templates to spawn and deploy groups.
    Group templates define what units to spawn and where (barracks vs motorpool).
    
    NOTE: observation_post uses underscore — matches locationTypes.sqf key.
    Eden marker would be: opsroom_observation_post_1
    BUT initStrategicLocations requires exactly 3 underscore-separated parts.
    So observation_post markers use: opsroom_observationpost_1
    We handle this with an alias in initStrategicLocations.
*/

// ========================================
// ENEMY MANPOWER & BUDGET
// ========================================

// Starting enemy manpower pool
OpsRoom_AI_Manpower = 100;

// Manpower gained per enemy cargo ship arrival at enemy port
OpsRoom_AI_ManpowerPerShip = 25;

// Maximum active AI commander groups at once (scales with locations held)
// New formula: base + per-type bonuses from enemy locations
//   +1 per barracks, motorpool, airfield, HQ
//   +2 per port
//   +0.5 per town/village (floored)
OpsRoom_AI_BaseMaxGroups = 2;

// Legacy — kept for radio callback urgency override calculation
OpsRoom_AI_GroupsPerBarracks = 1;

// ========================================
// TURN SETTINGS
// ========================================

// AI commander turn interval in in-game HOURS (uses daytime, not time)
// At 1x speed: 5 real minutes ≈ 5 in-game minutes
// Set to fraction of an hour for testing, increase for production
OpsRoom_AI_TurnInterval = 0.0833;  // ~5 in-game minutes

// ========================================
// RADIO ALARM SETTINGS
// ========================================

// Radio object classname (SAB/FOW WW2 radio — verify in-game)
// Fallback chain: try SAB first, then FOW, then vanilla
OpsRoom_AI_RadioClassname = "Land_DataTerminal_01_F";  // PLACEHOLDER — replace with SAB/FOW radio

// Time in seconds for radioman to transmit after reaching radio
OpsRoom_AI_RadioTransmitTime = 30;

// Maximum distance a unit will run to reach the radio (metres)
OpsRoom_AI_RadioMaxRunDistance = 150;

// Location types that get auto-spawned radios
OpsRoom_AI_RadioLocationTypes = [
    "town", "village", "port", "airfield", "barracks", "hq",
    "factory", "camp", "motorpool", "fuel_depot", "ammo_dump",
    "bunker", "radar", "rail"
];

// ========================================
// RESPONSE PRIORITIES
// ========================================

// Priority weights for AI decision making (higher = more urgent)
OpsRoom_AI_Priority_CounterAttack = 10;    // Lost location — recapture it
OpsRoom_AI_Priority_Reinforce = 7;         // Location under attack (radio alarm)
OpsRoom_AI_Priority_Garrison = 3;          // Undefended location needs troops
OpsRoom_AI_Priority_Patrol = 1;            // Routine patrol between locations

// ========================================
// UNIT CLASSNAMES (SAB/FOW WW2 German)
// ========================================

// Infantry classnames for group templates
OpsRoom_AI_Infantry = [
    "JMSSA_ger40_rifle_unter",       // Unteroffizier (NCO)
    "JMSSA_ger40_rifle_ogefr",       // Obergefreiter
    "JMSSA_ger40_rifle",             // Rifleman
    "JMSSA_ger40_rifle_gefr",        // Gefreiter
    "JMSSA_ger40_rifle_mg",          // MG Rifleman
    "LIB_GER_unterofficer",          // Unteroffizier (LIB)
    "LIB_GER_mgunner",              // MG Gunner
    "LIB_GER_medic",                // Medic
    "LIB_GER_rifleman",             // Rifleman (LIB)
    "LIB_GER_ober_rifleman",        // Obergefreiter Rifleman
    "LIB_GER_AT_grenadier",         // AT Grenadier
    "LIB_GER_scout_sniper",         // Sniper
    "LIB_GER_scout_mgunner",        // Scout MG
    "LIB_GER_scout_smgunner",       // Scout SMG
    "LIB_GER_scout_rifleman",       // Scout Rifleman
    "LIB_GER_scout_ober_rifleman",  // Scout Ober Rifleman
    "LIB_GER_scout_unterofficer"    // Scout NCO
];

// Vehicle classnames for motorised groups
OpsRoom_AI_Vehicles = [
    "LIB_SdKfz251",                  // Sdkfz 251 halftrack
    "JMSSA_veh_opelblitz_flak38_F",  // Opel Blitz with Flak 38
    "JMSSA_veh_pz38a_F",             // Panzer 38(t) light tank
    "JMSSA_veh_pz3e_F",              // Panzer III Ausf. E medium tank
    "JMSSA_veh_hetzer_F"             // Jagdpanzer 38 (Hetzer) tank destroyer
];

// Aircraft classnames for enemy air groups
OpsRoom_AI_Aircraft = [
    "sab_fl_bf109k",                 // Bf 109K fighter
    "sab_fl_ju86",                   // Ju 86 medium bomber
    "sab_sw_ju87"                    // Ju 87 Stuka dive bomber
];

// Naval classnames for enemy naval groups
OpsRoom_AI_Naval = [
    "sab_nl_t22",                    // T22 torpedo boat (destroyer)
    "sab_nl_u557"                    // U-557 submarine
];

// ========================================
// GROUP TEMPLATES
// ========================================
// Each template defines:
//   name        - Display name for dispatch log
//   spawnType   - "barracks" or "motorpool"
//   manpower    - Cost to spawn this group
//   units       - Array of [classname, count] pairs
//   vehicle     - (optional) Vehicle classname for motorised groups
//   description - Flavour text for dispatch log

OpsRoom_AI_GroupTemplates = createHashMapFromArray [

    // === INFANTRY (spawn at barracks) ===
    
    ["rifle_section", createHashMapFromArray [
        ["name", "Rifle Section"],
        ["spawnType", "barracks"],
        ["manpower", 8],
        ["units", [
            ["JMSSA_ger40_rifle_unter", 1],
            ["JMSSA_ger40_rifle", 3],
            ["JMSSA_ger40_rifle_gefr", 1],
            ["JMSSA_ger40_rifle_ogefr", 1],
            ["JMSSA_ger40_rifle_mg", 1],
            ["LIB_GER_rifleman", 1]
        ]],
        ["description", "Standard infantry section with MG support"]
    ]],
    
    ["assault_section", createHashMapFromArray [
        ["name", "Assault Section"],
        ["spawnType", "barracks"],
        ["manpower", 10],
        ["units", [
            ["LIB_GER_unterofficer", 1],
            ["JMSSA_ger40_rifle", 3],
            ["JMSSA_ger40_rifle_mg", 1],
            ["LIB_GER_mgunner", 1],
            ["LIB_GER_AT_grenadier", 1],
            ["LIB_GER_ober_rifleman", 2],
            ["LIB_GER_medic", 1]
        ]],
        ["description", "Reinforced assault section for counter-attacks"]
    ]],
    
    ["mg_team", createHashMapFromArray [
        ["name", "MG Team"],
        ["spawnType", "barracks"],
        ["manpower", 4],
        ["units", [
            ["JMSSA_ger40_rifle_unter", 1],
            ["LIB_GER_mgunner", 1],
            ["JMSSA_ger40_rifle_mg", 1],
            ["JMSSA_ger40_rifle", 1]
        ]],
        ["description", "Machine gun fire team"]
    ]],
    
    ["sniper_team", createHashMapFromArray [
        ["name", "Sniper Team"],
        ["spawnType", "barracks"],
        ["manpower", 3],
        ["units", [
            ["LIB_GER_scout_sniper", 1],
            ["LIB_GER_scout_rifleman", 1],
            ["LIB_GER_scout_unterofficer", 1]
        ]],
        ["description", "Sniper and spotter team"]
    ]],
    
    // === SCOUT SECTION (barracks — light recon infantry) ===
    
    ["scout_section", createHashMapFromArray [
        ["name", "Scout Section"],
        ["spawnType", "barracks"],
        ["manpower", 6],
        ["units", [
            ["LIB_GER_scout_unterofficer", 1],
            ["LIB_GER_scout_smgunner", 2],
            ["LIB_GER_scout_rifleman", 1],
            ["LIB_GER_scout_ober_rifleman", 1],
            ["LIB_GER_scout_mgunner", 1]
        ]],
        ["description", "Light scout infantry section"]
    ]],
    
    // === MOTORISED (spawn at motorpool) ===
    
    ["halftrack_section", createHashMapFromArray [
        ["name", "Halftrack Section"],
        ["spawnType", "motorpool"],
        ["manpower", 12],
        ["units", [
            ["LIB_GER_unterofficer", 1],
            ["LIB_GER_ober_rifleman", 2],
            ["JMSSA_ger40_rifle", 3],
            ["LIB_GER_mgunner", 1],
            ["JMSSA_ger40_rifle_mg", 1],
            ["LIB_GER_AT_grenadier", 1],
            ["LIB_GER_medic", 1]
        ]],
        ["vehicle", "LIB_SdKfz251"],
        ["description", "Halftrack-mounted assault section"]
    ]],
    
    ["halftrack_scouts", createHashMapFromArray [
        ["name", "Halftrack Scouts"],
        ["spawnType", "motorpool"],
        ["manpower", 8],
        ["units", [
            ["LIB_GER_scout_unterofficer", 1],
            ["LIB_GER_scout_smgunner", 3],
            ["LIB_GER_scout_rifleman", 2],
            ["LIB_GER_scout_mgunner", 1]
        ]],
        ["vehicle", "LIB_SdKfz251"],
        ["description", "Halftrack-mounted scout section"]
    ]],
    
    // === ARMOUR (spawn at motorpool) ===
    
    ["flak_truck", createHashMapFromArray [
        ["name", "Flak Truck"],
        ["spawnType", "motorpool"],
        ["manpower", 5],
        ["units", [
            ["LIB_GER_unterofficer", 1],
            ["JMSSA_ger40_rifle", 2]
        ]],
        ["vehicle", "JMSSA_veh_opelblitz_flak38_F"],
        ["description", "Opel Blitz truck with Flak 38 anti-aircraft gun"]
    ]],
    
    ["light_tank", createHashMapFromArray [
        ["name", "Light Tank"],
        ["spawnType", "motorpool"],
        ["manpower", 6],
        ["units", [
            ["LIB_GER_unterofficer", 1],
            ["JMSSA_ger40_rifle", 1]
        ]],
        ["vehicle", "JMSSA_veh_pz38a_F"],
        ["description", "Panzer 38(t) light tank"]
    ]],
    
    ["medium_tank", createHashMapFromArray [
        ["name", "Medium Tank"],
        ["spawnType", "motorpool"],
        ["manpower", 10],
        ["units", [
            ["LIB_GER_unterofficer", 1],
            ["JMSSA_ger40_rifle", 2]
        ]],
        ["vehicle", "JMSSA_veh_pz3e_F"],
        ["description", "Panzer III medium tank with infantry escort"]
    ]],
    
    ["tank_destroyer", createHashMapFromArray [
        ["name", "Tank Destroyer"],
        ["spawnType", "motorpool"],
        ["manpower", 8],
        ["units", [
            ["LIB_GER_unterofficer", 1],
            ["JMSSA_ger40_rifle", 1]
        ]],
        ["vehicle", "JMSSA_veh_hetzer_F"],
        ["description", "Jagdpanzer 38 Hetzer tank destroyer"]
    ]],
    
    // === AIR (spawn at airfield) ===
    
    ["fighter_patrol", createHashMapFromArray [
        ["name", "Fighter Patrol"],
        ["spawnType", "airfield"],
        ["manpower", 4],
        ["aircraft", [
            ["sab_fl_bf109k", 2]
        ]],
        ["description", "Bf 109K fighter patrol over friendly territory"]
    ]],
    
    ["bomber_strike", createHashMapFromArray [
        ["name", "Bomber Strike"],
        ["spawnType", "airfield"],
        ["manpower", 8],
        ["aircraft", [
            ["sab_sw_ju87", 1],
            ["sab_fl_bf109k", 1]
        ]],
        ["description", "Stuka dive bomber with fighter escort"]
    ]],
    
    ["medium_bomber", createHashMapFromArray [
        ["name", "Medium Bomber"],
        ["spawnType", "airfield"],
        ["manpower", 6],
        ["aircraft", [
            ["sab_fl_ju86", 1]
        ]],
        ["description", "Ju 86 medium bomber on strategic bombing run"]
    ]],
    
    ["recon_flight", createHashMapFromArray [
        ["name", "Recon Flight"],
        ["spawnType", "airfield"],
        ["manpower", 2],
        ["aircraft", [
            ["sab_fl_bf109k", 1]
        ]],
        ["description", "Single fighter on reconnaissance sweep"]
    ]],
    
    // === NAVAL (spawn at port) ===
    
    ["torpedo_destroyer", createHashMapFromArray [
        ["name", "Torpedo Boat"],
        ["spawnType", "port"],
        ["manpower", 5],
        ["boat", "sab_nl_t22"],
        ["description", "T22 torpedo boat on coastal patrol"]
    ]],
    
    ["uboat_patrol", createHashMapFromArray [
        ["name", "U-Boat"],
        ["spawnType", "port"],
        ["manpower", 8],
        ["boat", "sab_nl_u557"],
        ["description", "U-boat submarine on shipping interdiction"]
    ]]
];

// ========================================
// TEMPLATE SELECTION RULES
// ========================================

// Which templates to use for each mission type
// AI commander picks randomly from the appropriate list
OpsRoom_AI_TemplatesByMission = createHashMapFromArray [
    ["counter_attack", ["assault_section", "halftrack_section", "halftrack_scouts", "medium_tank", "tank_destroyer"]],
    ["reinforce", ["rifle_section", "halftrack_section", "mg_team", "light_tank", "flak_truck"]],
    ["garrison", ["rifle_section", "mg_team", "sniper_team"]],
    ["patrol", ["scout_section", "sniper_team", "halftrack_scouts"]],
    ["air_patrol", ["fighter_patrol", "recon_flight"]],
    ["air_strike", ["bomber_strike", "medium_bomber"]],
    ["naval_patrol", ["torpedo_destroyer"]],
    ["naval_attack", ["torpedo_destroyer", "uboat_patrol"]]
];

systemChat format ["AI Commander: Loaded %1 group templates", count OpsRoom_AI_GroupTemplates];
