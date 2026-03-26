/*
    Equipment Database - Single Source of Truth
    
    Every item in the game is defined here ONCE.
    Adding an entry here makes it appear in Research, Production, and Supply menus.
    
    Structure per item:
        "itemId" → HashMap [
            // Identity
            "displayName"    - Name shown in menus
            "category"       - Top level: "Weapons", "Ammunition", "Explosives", "Uniforms", "Vehicles"
            "subcategory"    - Sub level: "Rifles", "Pistols", "SMGs", "MGs", "Cars", "Trucks", "Tanks", etc.
            "className"      - ARMA classname for spawning
            "imagePath"      - Path to display image (optional, "" for default)
            
            // Research
            "researchCost"   - Research points to unlock
            "researchTime"   - Minutes to research (real time)
            "researchTier"   - Position in tree (1 = first available)
            "researchPrereqs"- Array of itemIDs that must be researched first
            "researchDesc"   - Description shown in research menu
            
            // Production
            "buildTime"      - Minutes per production cycle
            "buildCost"      - Array of [["Resource", amount], ...] per cycle
            "batchSize"      - Units produced per cycle
            "buildDesc"      - Description shown in production menu
            
            // Supply
            "supplyDesc"     - Description shown in supply menu
            "spawnType"      - "crate" = items in ammo box, "vehicle" = spawn vehicle, "single" = single item
            "crateClass"     - Container classname if spawnType is "crate"
        ]
    
    HOW TO ADD A NEW ITEM:
    1. Copy an existing entry below
    2. Change the itemId (first string) to something unique
    3. Fill in the fields
    4. Done - it appears in Research, Production, and Supply automatically
*/

if (isNil "OpsRoom_EquipmentDB") then {
    OpsRoom_EquipmentDB = createHashMap;
};

// ============================================================
// WEAPONS > RIFLES
// ============================================================

OpsRoom_EquipmentDB set ["lee_enfield", createHashMapFromArray [
    ["displayName", "Lee-Enfield No.4 MK1"],
    ["category", "Weapons"],
    ["subcategory", "Rifles"],
    ["className", "fow_w_leeenfield_no4mk1"],
    ["imagePath", ""],
    
    ["researchCost", 1],
    ["researchTime", 1],
    ["researchTier", 1],
    ["researchPrereqs", []],
    ["researchDesc", "Standard British infantry rifle. Bolt-action, .303 calibre. Accurate and reliable with a 10-round magazine."],
    
    ["buildTime", 1],
    ["buildCost", [["Steel", 3], ["Wood", 2]]],
    ["batchSize", 1],
    ["buildDesc", "Manufactured at Royal Small Arms Factory, Enfield. Crate of 5 rifles per production cycle."],
    
    ["supplyDesc", "Crate of 5 Lee-Enfield rifles, ready for deployment."],
    ["spawnType", "crate"],
    ["crateClass", "CUP_BOX_GB_Wps_F"]
]];

// ============================================================
// WEAPONS > MACHINE GUNS
// ============================================================

OpsRoom_EquipmentDB set ["bren_gun", createHashMapFromArray [
    ["displayName", "Bren Gun"],
    ["category", "Weapons"],
    ["subcategory", "Machine Guns"],
    ["className", "fow_w_bren"],
    ["imagePath", ""],
    
    ["researchCost", 1],
    ["researchTime", 1],
    ["researchTier", 2],
    ["researchPrereqs", ["lee_enfield"]],
    ["researchDesc", "Light machine gun. Gas-operated, .303 calibre. Provides squad-level suppressive fire capability."],
    
    ["buildTime", 1],
    ["buildCost", [["Steel", 5], ["Wood", 2], ["Chromium", 1]]],
    ["batchSize", 2],
    ["buildDesc", "Precision-manufactured at Royal Small Arms Factory. Crate of 2 Bren guns per cycle."],
    
    ["supplyDesc", "Crate of 2 Bren light machine guns."],
    ["spawnType", "crate"],
    ["crateClass", "CUP_BOX_GB_Wps_F"]
]];

// ============================================================
// AMMUNITION > RIFLE AMMO
// ============================================================

OpsRoom_EquipmentDB set ["303_ammo", createHashMapFromArray [
    ["displayName", ".303 Ammunition"],
    ["category", "Ammunition"],
    ["subcategory", "Rifle Ammo"],
    ["className", "fow_10Rnd_303"],
    ["imagePath", ""],
    
    ["researchCost", 1],
    ["researchTime", 1],
    ["researchTier", 1],
    ["researchPrereqs", []],
    ["researchDesc", ".303 British cartridge. Standard issue ammunition for rifles and machine guns."],
    
    ["buildTime", 1],
    ["buildCost", [["Steel", 1], ["Tungsten", 1]]],
    ["batchSize", 10],
    ["buildDesc", "Ammunition produced at Royal Ordnance Factory. Box of 10 magazines per cycle."],
    
    ["supplyDesc", "Box of 10 magazines of .303 ammunition."],
    ["spawnType", "crate"],
    ["crateClass", "JMSSA_Brit_ammo_box"]
]];

// ============================================================
// EXPLOSIVES > GRENADES
// ============================================================

OpsRoom_EquipmentDB set ["mills_bomb", createHashMapFromArray [
    ["displayName", "Mills Bomb"],
    ["category", "Explosives"],
    ["subcategory", "Grenades"],
    ["className", "fow_e_no36mk1"],
    ["imagePath", ""],
    
    ["researchCost", 1],
    ["researchTime", 1],
    ["researchTier", 1],
    ["researchPrereqs", []],
    ["researchDesc", "No. 36 fragmentation grenade. Standard British hand grenade with 4-second fuse."],
    
    ["buildTime", 1],
    ["buildCost", [["Steel", 2], ["Tungsten", 1]]],
    ["batchSize", 1],
    ["buildDesc", "Cast iron body filled with Baratol explosive. Crate of 6 grenades per cycle."],
    
    ["supplyDesc", "Crate of 6 Mills Bomb grenades."],
    ["spawnType", "crate"],
    ["crateClass", "CUP_BOX_GB_Wps_F"]
]];

// ============================================================
// VEHICLES > CARS
// ============================================================

OpsRoom_EquipmentDB set ["willys_jeep", createHashMapFromArray [
    ["displayName", "Willys Jeep"],
    ["category", "Vehicles"],
    ["subcategory", "Cars"],
    ["className", "fow_v_willys_uk"],
    ["imagePath", ""],
    
    ["researchCost", 1],
    ["researchTime", 1],
    ["researchTier", 1],
    ["researchPrereqs", []],
    ["researchDesc", "Light utility vehicle. Versatile transport for personnel and light equipment."],
    
    ["buildTime", 1],
    ["buildCost", [["Steel", 4], ["Rubber", 3], ["Oil", 2]]],
    ["batchSize", 1],
    ["buildDesc", "Assembled at vehicle depot. One jeep per production cycle."],
    
    ["supplyDesc", "One Willys Jeep, ready for deployment."],
    ["spawnType", "vehicle"],
    ["crateClass", ""],
    ["cargoCarrier", true],
    ["cargoSlots", 2]
]];


// ============================================================
// AIRCRAFT > FIGHTERS (Air-to-Air)
// ============================================================

OpsRoom_EquipmentDB set ["hurricane_mk1", createHashMapFromArray [
    ["displayName", "Hawker Hurricane Mk.I"],
    ["category", "Aircraft"],
    ["subcategory", "Fighters"],
    ["className", "sab_fl_hurricane"],
    ["imagePath", ""],
    ["aircraftType", "Fighter"],
    
    ["researchCost", 30],
    ["researchTime", 3],
    ["researchTier", 1],
    ["researchPrereqs", []],
    ["researchDesc", "Single-seat monoplane fighter. 8x .303 Browning MGs. Rugged and reliable. Backbone of Fighter Command during the Battle of Britain."],
    
    ["buildTime", 8],
    ["buildCost", [["Steel", 15], ["Aluminium", 10], ["Rubber", 3], ["Fuel", 5]]],
    ["batchSize", 1],
    ["buildDesc", "Hawker Aircraft Ltd. Metal tube and fabric construction. One airframe per production cycle."],
    
    ["supplyDesc", "One Hawker Hurricane Mk.I, ready for fighter operations."],
    ["spawnType", "vehicle"],
    ["crateClass", ""]
]];

OpsRoom_EquipmentDB set ["spitfire_mk1", createHashMapFromArray [
    ["displayName", "Supermarine Spitfire Mk.I"],
    ["category", "Aircraft"],
    ["subcategory", "Fighters"],
    ["className", "sab_fl_spitfire_mk1"],
    ["imagePath", ""],
    ["aircraftType", "Fighter"],
    
    ["researchCost", 40],
    ["researchTime", 4],
    ["researchTier", 2],
    ["researchPrereqs", ["hurricane_mk1"]],
    ["researchDesc", "Single-seat interceptor fighter. 8x .303 Browning MGs. Elliptical wing gives superior speed and climb over the Hurricane. Icon of the Battle of Britain."],
    
    ["buildTime", 10],
    ["buildCost", [["Steel", 18], ["Aluminium", 14], ["Rubber", 3], ["Fuel", 5]]],
    ["batchSize", 1],
    ["buildDesc", "Supermarine Aviation Works. Stressed-skin monocoque construction. One airframe per production cycle."],
    
    ["supplyDesc", "One Supermarine Spitfire Mk.I, ready for fighter operations."],
    ["spawnType", "vehicle"],
    ["crateClass", ""]
]];

OpsRoom_EquipmentDB set ["spitfire_mk5", createHashMapFromArray [
    ["displayName", "Supermarine Spitfire Mk.V"],
    ["category", "Aircraft"],
    ["subcategory", "Fighters"],
    ["className", "sab_fl_spitfire_mk5"],
    ["imagePath", ""],
    ["aircraftType", "Fighter"],
    
    ["researchCost", 55],
    ["researchTime", 5],
    ["researchTier", 2],
    ["researchPrereqs", ["spitfire_mk1"]],
    ["researchDesc", "Improved Spitfire with Merlin 45 engine. 2x 20mm Hispano cannon and 4x .303 Browning MGs. Most-produced Spitfire variant. Effective across all theatres."],
    
    ["buildTime", 12],
    ["buildCost", [["Steel", 20], ["Aluminium", 16], ["Rubber", 4], ["Fuel", 6]]],
    ["batchSize", 1],
    ["buildDesc", "Supermarine Mk.V variant with uprated Merlin engine. One airframe per production cycle."],
    
    ["supplyDesc", "One Supermarine Spitfire Mk.V, ready for fighter operations."],
    ["spawnType", "vehicle"],
    ["crateClass", ""]
]];

OpsRoom_EquipmentDB set ["spitfire_mkxiv", createHashMapFromArray [
    ["displayName", "Supermarine Spitfire Mk.XIV"],
    ["category", "Aircraft"],
    ["subcategory", "Fighters"],
    ["className", "sab_fl_spitfire_mkxiv"],
    ["imagePath", ""],
    ["aircraftType", "Fighter"],
    
    ["researchCost", 75],
    ["researchTime", 7],
    ["researchTier", 3],
    ["researchPrereqs", ["spitfire_mk5"]],
    ["researchDesc", "Griffon-engined Spitfire. 2x 20mm Hispano cannon and 2x .50 Browning MGs. Fastest piston-engine Spitfire variant. Capable of intercepting V-1 flying bombs. 450mph top speed."],
    
    ["buildTime", 14],
    ["buildCost", [["Steel", 22], ["Aluminium", 20], ["Rubber", 4], ["Fuel", 7]]],
    ["batchSize", 1],
    ["buildDesc", "Supermarine Griffon-engined variant. Premium alloy construction. One airframe per production cycle."],
    
    ["supplyDesc", "One Supermarine Spitfire Mk.XIV, ready for fighter operations."],
    ["spawnType", "vehicle"],
    ["crateClass", ""]
]];

OpsRoom_EquipmentDB set ["tempest_mk5", createHashMapFromArray [
    ["displayName", "Hawker Tempest Mk.V"],
    ["category", "Aircraft"],
    ["subcategory", "Fighters"],
    ["className", "sab_fl_tempest"],
    ["imagePath", ""],
    ["aircraftType", "Fighter"],
    
    ["researchCost", 85],
    ["researchTime", 8],
    ["researchTier", 3],
    ["researchPrereqs", ["spitfire_mk5"]],
    ["researchDesc", "Late-war fighter-bomber. 4x 20mm Hispano Mk.V cannon. Napier Sabre engine gives outstanding low-altitude performance. Can carry 2x 1,000lb bombs or 8x RP-3 rockets. Top scorer against V-1 flying bombs and the Luftwaffe's jets."],
    
    ["buildTime", 16],
    ["buildCost", [["Steel", 25], ["Aluminium", 22], ["Rubber", 5], ["Fuel", 8]]],
    ["batchSize", 1],
    ["buildDesc", "Hawker Aircraft Ltd. Napier Sabre-engined heavy fighter. Complex engine requires skilled assembly. One airframe per production cycle."],
    
    ["supplyDesc", "One Hawker Tempest Mk.V, ready for fighter and ground attack operations."],
    ["spawnType", "vehicle"],
    ["crateClass", ""],
    ["attackCapabilities", ["GUNS", "BOMBS", "ROCKETS"]]
]];

// ============================================================
// AIRCRAFT > GROUND ATTACK
// ============================================================

OpsRoom_EquipmentDB set ["hurricane_trop", createHashMapFromArray [
    ["displayName", "Hurricane Mk.II (Tropical)"],
    ["category", "Aircraft"],
    ["subcategory", "Ground Attack"],
    ["className", "sab_fl_hurricane_trop"],
    ["imagePath", ""],
    ["aircraftType", "GroundAttack"],
    
    ["researchCost", 40],
    ["researchTime", 4],
    ["researchTier", 2],
    ["researchPrereqs", ["hurricane_mk1"]],
    ["researchDesc", "Tropicalised Hurricane variant fitted for ground attack. Dust filters and bomb racks. Effective tank buster in the desert campaign."],
    
    ["buildTime", 10],
    ["buildCost", [["Steel", 18], ["Aluminium", 12], ["Rubber", 4], ["Fuel", 5]]],
    ["batchSize", 1],
    ["buildDesc", "Modified Hurricane with ground attack capability. One airframe per production cycle."],
    
    ["supplyDesc", "One Hurricane Mk.II (Tropical), ready for ground attack operations."],
    ["spawnType", "vehicle"],
    ["crateClass", ""],
    ["attackCapabilities", ["GUNS", "BOMBS"]]
]];

// ============================================================
// AIRCRAFT > CAS (Close Air Support)
// ============================================================

OpsRoom_EquipmentDB set ["hurricane_mk2", createHashMapFromArray [
    ["displayName", "Hurricane Mk.IIC"],
    ["category", "Aircraft"],
    ["subcategory", "CAS"],
    ["className", "sab_fl_hurricane_2"],
    ["imagePath", ""],
    ["aircraftType", "GroundAttack"],
    
    ["researchCost", 45],
    ["researchTime", 4],
    ["researchTier", 2],
    ["researchPrereqs", ["hurricane_mk1"]],
    ["researchDesc", "Four-cannon Hurricane variant. 4x 20mm Hispano cannons provide devastating close air support. Hurribomber configuration can carry 500lb bombs."],
    
    ["buildTime", 10],
    ["buildCost", [["Steel", 20], ["Aluminium", 12], ["Rubber", 4], ["Fuel", 5]]],
    ["batchSize", 1],
    ["buildDesc", "Cannon-armed Hurricane. One airframe per production cycle."],
    
    ["supplyDesc", "One Hurricane Mk.IIC, ready for close air support."],
    ["spawnType", "vehicle"],
    ["crateClass", ""],
    ["attackCapabilities", ["GUNS", "ROCKETS"]]
]];

// ============================================================
// AIRCRAFT > RECON
// ============================================================

OpsRoom_EquipmentDB set ["spitfire_pr", createHashMapFromArray [
    ["displayName", "Spitfire PR Mk.V"],
    ["category", "Aircraft"],
    ["subcategory", "Recon"],
    ["className", "spitfire_v_M"],
    ["imagePath", ""],
    ["aircraftType", "Recon"],
    
    ["researchCost", 50],
    ["researchTime", 5],
    ["researchTier", 2],
    ["researchPrereqs", ["hurricane_mk1"]],
    ["researchDesc", "Photo-reconnaissance Spitfire. Cameras replace guns. High altitude, high speed. Unarmed but fast enough to outrun anything."],
    
    ["buildTime", 12],
    ["buildCost", [["Steel", 18], ["Aluminium", 15], ["Rubber", 3], ["Fuel", 5]]],
    ["batchSize", 1],
    ["buildDesc", "Supermarine photo-recon variant. One airframe per production cycle."],
    
    ["supplyDesc", "One Spitfire PR Mk.V, ready for reconnaissance operations."],
    ["spawnType", "vehicle"],
    ["crateClass", ""]
]];

OpsRoom_EquipmentDB set ["mosquito_recon", createHashMapFromArray [
    ["displayName", "DH.98 Mosquito PR Mk.IV"],
    ["category", "Aircraft"],
    ["subcategory", "Recon"],
    ["className", "sab_fl_dh98"],
    ["imagePath", ""],
    ["aircraftType", "Recon"],
    
    ["researchCost", 60],
    ["researchTime", 6],
    ["researchTier", 3],
    ["researchPrereqs", ["spitfire_pr"]],
    ["researchDesc", "Twin-engine photo-reconnaissance aircraft. Longer range than the Spitfire PR. Can loiter over target areas for extended periods."],
    
    ["buildTime", 14],
    ["buildCost", [["Wood", 15], ["Aluminium", 10], ["Steel", 5], ["Rubber", 3], ["Fuel", 8]]],
    ["batchSize", 1],
    ["buildDesc", "De Havilland wooden construction. One aircraft per production cycle."],
    
    ["supplyDesc", "One DH.98 Mosquito PR, ready for reconnaissance operations."],
    ["spawnType", "vehicle"],
    ["crateClass", ""]
]];

// ============================================================
// AIRCRAFT > GROUND ATTACK (Fighter-Bomber)
// ============================================================

OpsRoom_EquipmentDB set ["mosquito_fb", createHashMapFromArray [
    ["displayName", "DH.98 Mosquito FB Mk.VI"],
    ["category", "Aircraft"],
    ["subcategory", "Ground Attack"],
    ["className", "sab_fl_dh98"],
    ["imagePath", ""],
    ["aircraftType", "GroundAttack"],
    
    ["researchCost", 70],
    ["researchTime", 7],
    ["researchTier", 3],
    ["researchPrereqs", ["hurricane_trop"]],
    ["researchDesc", "Twin-engine fighter-bomber. 4x 20mm Hispano cannon, 4x .303 Browning MGs. Internal bomb bay carries 2,000lb. The 'Wooden Wonder'."],
    
    ["buildTime", 14],
    ["buildCost", [["Wood", 20], ["Aluminium", 12], ["Steel", 8], ["Rubber", 4], ["Fuel", 8]]],
    ["batchSize", 1],
    ["buildDesc", "De Havilland wooden construction. One aircraft per production cycle."],
    
    ["supplyDesc", "One DH.98 Mosquito FB Mk.VI, ready for ground attack operations."],
    ["spawnType", "vehicle"],
    ["crateClass", ""],
    ["attackCapabilities", ["GUNS", "BOMBS", "ROCKETS"]]
]];

// ============================================================
// AIRCRAFT > BOMBERS (Heavy Bomber)
// ============================================================

OpsRoom_EquipmentDB set ["halifax_bomber", createHashMapFromArray [
    ["displayName", "Handley Page Halifax B Mk.III"],
    ["category", "Aircraft"],
    ["subcategory", "Bombers"],
    ["className", "sab_sw_halifax"],
    ["imagePath", ""],
    ["aircraftType", "Bomber"],
    
    ["researchCost", 80],
    ["researchTime", 8],
    ["researchTier", 3],
    ["researchPrereqs", ["mosquito_fb"]],
    ["researchDesc", "Four-engine heavy bomber. Carries up to 13,000lb bomb load. Workhorse of Bomber Command alongside the Lancaster. Bristol Hercules radial engines."],
    
    ["buildTime", 18],
    ["buildCost", [["Steel", 30], ["Aluminium", 25], ["Rubber", 6], ["Fuel", 12]]],
    ["batchSize", 1],
    ["buildDesc", "Handley Page heavy bomber. Complex construction. One airframe per production cycle."],
    
    ["supplyDesc", "One Handley Page Halifax B Mk.III, ready for strategic bombing operations."],
    ["spawnType", "vehicle"],
    ["crateClass", ""],
    ["attackCapabilities", ["BOMBS"]]
]];

// ============================================================
// AIRCRAFT > ANTI-SHIPPING
// ============================================================

OpsRoom_EquipmentDB set ["swordfish_torp", createHashMapFromArray [
    ["displayName", "Fairey Swordfish Mk.II"],
    ["category", "Aircraft"],
    ["subcategory", "Anti-Shipping"],
    ["className", "sab_nl_drone_swordfish"],
    ["imagePath", ""],
    ["aircraftType", "GroundAttack"],
    
    ["researchCost", 35],
    ["researchTime", 4],
    ["researchTier", 2],
    ["researchPrereqs", ["hurricane_mk1"]],
    ["researchDesc", "Biplane torpedo bomber. The 'Stringbag'. Outdated but deadly effective. Armed with torpedo, bombs, or 8x RP-3 rockets. 3 crew. Responsible for crippling the Bismarck and the strike on Taranto."],
    
    ["buildTime", 8],
    ["buildCost", [["Steel", 10], ["Aluminium", 5], ["Wood", 8], ["Rubber", 3], ["Fuel", 4]]],
    ["batchSize", 1],
    ["buildDesc", "Blackburn Aircraft construction. Fabric-covered metal airframe with folding wings. One aircraft per production cycle."],
    
    ["supplyDesc", "One Fairey Swordfish Mk.II, ready for anti-shipping and ground attack operations."],
    ["spawnType", "vehicle"],
    ["crateClass", ""],
    ["attackCapabilities", ["GUNS", "BOMBS", "TORPEDO"]]
]];

// ============================================================
// AIRCRAFT > TRANSPORT
// ============================================================

OpsRoom_EquipmentDB set ["c47_transport", createHashMapFromArray [
    ["displayName", "Douglas C-47 Skytrain (RAF)"],
    ["category", "Aircraft"],
    ["subcategory", "Transport"],
    ["className", "LIB_C47_RAF"],
    ["imagePath", ""],
    ["aircraftType", "Transport"],
    
    ["researchCost", 50],
    ["researchTime", 5],
    ["researchTier", 2],
    ["researchPrereqs", []],
    ["researchDesc", "Twin-engine military transport. RAF variant of the legendary Dakota. Carries 28 troops or 6,000lb cargo. Workhorse of Allied airborne and supply operations from D-Day to Arnhem."],
    
    ["buildTime", 14],
    ["buildCost", [["Steel", 20], ["Aluminium", 18], ["Rubber", 5], ["Fuel", 8]]],
    ["batchSize", 1],
    ["buildDesc", "Douglas Aircraft Company. All-metal monocoque construction. One aircraft per production cycle."],
    
    ["supplyDesc", "One Douglas C-47 Skytrain (RAF), ready for transport operations."],
    ["spawnType", "vehicle"],
    ["crateClass", ""],
    ["cargoCarrier", true],
    ["cargoSlots", 12]
]];

// ============================================================
// VEHICLES > TRUCKS
// ============================================================

OpsRoom_EquipmentDB set ["bedford_mw_ammo", createHashMapFromArray [
    ["displayName", "Bedford MW (Ammo Truck)"],
    ["category", "Vehicles"],
    ["subcategory", "Trucks"],
    ["className", "JMSSA_veh_bedfordMW_E_ammo"],
    ["imagePath", ""],
    
    ["researchCost", 1],
    ["researchTime", 1],
    ["researchTier", 1],
    ["researchPrereqs", ["willys_jeep"]],
    ["researchDesc", "Bedford MW 15cwt general service truck. Fitted with enclosed cargo bed for ammunition transport. Primary logistics vehicle for supply operations. Can load and transport supply crates between locations."],
    
    ["buildTime", 1],
    ["buildCost", [["Steel", 6], ["Rubber", 3], ["Oil", 2]]],
    ["batchSize", 1],
    ["buildDesc", "One Bedford MW truck per production cycle. Requires steel chassis, rubber tyres, and engine oil."],
    
    ["supplyDesc", "One Bedford MW ammo truck, ready for logistics operations."],
    ["spawnType", "vehicle"],
    ["crateClass", ""],
    ["cargoCarrier", true],
    ["cargoSlots", 8]
]];

// ============================================================
// UNIFORMS
// ============================================================

OpsRoom_EquipmentDB set ["uk_bd40_uniform", createHashMapFromArray [
    ["displayName", "Battledress (BD40) Uniform"],
    ["category", "Uniforms"],
    ["subcategory", "Combat Dress"],
    ["className", "fow_u_uk_bd40_01_private"],
    ["imagePath", ""],
    
    ["researchCost", 1],
    ["researchTime", 1],
    ["researchTier", 1],
    ["researchPrereqs", []],
    ["researchDesc", "Standard 1940-pattern battledress. Wool serge jacket and trousers. Issue uniform for all ranks."],
    
    ["buildTime", 1],
    ["buildCost", [["Rubber", 1]]],
    ["batchSize", 5],
    ["buildDesc", "Standard infantry battledress. Crate of 5 uniforms per cycle."],
    
    ["supplyDesc", "Crate of 5 battledress uniforms."],
    ["spawnType", "crate"],
    ["crateClass", "CUP_BOX_GB_Wps_F"]
]];

// ============================================================
// EQUIPMENT > VESTS
// ============================================================

OpsRoom_EquipmentDB set ["uk_webbing_green", createHashMapFromArray [
    ["displayName", "1937 Pattern Webbing"],
    ["category", "Equipment"],
    ["subcategory", "Vests"],
    ["className", "fow_v_uk_base_green"],
    ["imagePath", ""],
    
    ["researchCost", 1],
    ["researchTime", 1],
    ["researchTier", 1],
    ["researchPrereqs", []],
    ["researchDesc", "1937 pattern web equipment. Canvas webbing with ammunition pouches and utility straps."],
    
    ["buildTime", 1],
    ["buildCost", [["Rubber", 1]]],
    ["batchSize", 5],
    ["buildDesc", "Standard infantry webbing. Crate of 5 sets per cycle."],
    
    ["supplyDesc", "Crate of 5 webbing sets."],
    ["spawnType", "crate"],
    ["crateClass", "CUP_BOX_GB_Wps_F"]
]];

// ============================================================
// EQUIPMENT > HEADGEAR
// ============================================================

OpsRoom_EquipmentDB set ["uk_mk2_helmet", createHashMapFromArray [
    ["displayName", "Mk II Brodie Helmet"],
    ["category", "Equipment"],
    ["subcategory", "Headgear"],
    ["className", "fow_h_uk_mk2"],
    ["imagePath", ""],
    
    ["researchCost", 1],
    ["researchTime", 1],
    ["researchTier", 1],
    ["researchPrereqs", []],
    ["researchDesc", "Standard steel helmet. Distinctive wide brim. Protection against shrapnel and debris."],
    
    ["buildTime", 5],
    ["buildCost", [["Steel", 1]]],
    ["batchSize", 10],
    ["buildDesc", "Pressed steel helmets. Crate of 10 per cycle."],
    
    ["supplyDesc", "Crate of 10 Mk II helmets."],
    ["spawnType", "crate"],
    ["crateClass", "CUP_BOX_GB_Wps_F"]
]];

// ============================================================
// AMMUNITION > BREN AMMO
// ============================================================

OpsRoom_EquipmentDB set ["303_bren_ammo", createHashMapFromArray [
    ["displayName", ".303 Bren Magazine"],
    ["category", "Ammunition"],
    ["subcategory", "MG Ammo"],
    ["className", "fow_30Rnd_303_bren"],
    ["imagePath", ""],
    
    ["researchCost", 1],
    ["researchTime", 1],
    ["researchTier", 1],
    ["researchPrereqs", []],
    ["researchDesc", "30-round curved box magazine for the Bren gun. .303 British cartridge."],
    
    ["buildTime", 1],
    ["buildCost", [["Steel", 1], ["Tungsten", 1]]],
    ["batchSize", 10],
    ["buildDesc", "Bren gun magazines. Crate of 10 per cycle."],
    
    ["supplyDesc", "Crate of 10 Bren magazines."],
    ["spawnType", "crate"],
    ["crateClass", "CUP_BOX_GB_Wps_F"]
]];

OpsRoom_EquipmentDB set ["10rnd_303", createHashMapFromArray [
    ["displayName", ".303 Rifle Clip (10rnd)"],
    ["category", "Ammunition"],
    ["subcategory", "Rifle Ammo"],
    ["className", "fow_10Rnd_303"],
    ["imagePath", ""],
    
    ["researchCost", 1],
    ["researchTime", 1],
    ["researchTier", 1],
    ["researchPrereqs", []],
    ["researchDesc", "10-round stripper clip for Lee-Enfield rifles. .303 British cartridge."],
    
    ["buildTime", 1],
    ["buildCost", [["Steel", 1]]],
    ["batchSize", 20],
    ["buildDesc", "Rifle ammunition clips. Crate of 20 per cycle."],
    
    ["supplyDesc", "Crate of 20 rifle clips."],
    ["spawnType", "crate"],
    ["crateClass", "CUP_BOX_GB_Wps_F"]
]];

// ============================================================
// EQUIPMENT > MEDICAL
// ============================================================

OpsRoom_EquipmentDB set ["first_aid_kit", createHashMapFromArray [
    ["displayName", "First Aid Kit"],
    ["category", "Equipment"],
    ["subcategory", "Medical"],
    ["className", "FirstAidKit"],
    ["imagePath", ""],
    
    ["researchCost", 1],
    ["researchTime", 1],
    ["researchTier", 1],
    ["researchPrereqs", []],
    ["researchDesc", "Standard field dressing kit. Bandages, morphine syrette, sulfa powder. Every soldier carries one."],
    
    ["buildTime", 1],
    ["buildCost", [["Rubber", 1]]],
    ["batchSize", 10],
    ["buildDesc", "First aid kits. Crate of 10 per cycle."],
    
    ["supplyDesc", "Crate of 10 first aid kits."],
    ["spawnType", "crate"],
    ["crateClass", "CUP_BOX_GB_Wps_F"]
]];

// ============================================================
// NAVAL > MERCHANT SHIPS
// ============================================================

OpsRoom_EquipmentDB set ["cargo_ship", createHashMapFromArray [
    ["displayName", "Liberty Ship"],
    ["category", "Naval"],
    ["subcategory", "Merchant Ships"],
    ["className", "PLACEHOLDER_CARGO_SHIP"],
    ["imagePath", ""],
    ["spawnType", "naval"],
    
    ["researchCost", 60],
    ["researchTime", 6],
    ["researchTier", 2],
    ["researchPrereqs", []],
    ["researchDesc", "Mass-produced cargo vessel. Carries supplies along established sea lanes to forward ports. Essential for sustaining overseas operations."],
    
    ["buildTime", 1],  // 1 minute for testing (set to 20 for production)
    ["buildCost", [["Steel", 5], ["Wood", 5]]],  // Cheap for testing
    ["batchSize", 1],
    ["buildDesc", "Welded hull construction at shipyard. One vessel per production cycle. Long build time but high cargo capacity."],
    
    ["supplyDesc", "Cargo vessel for convoy operations. Added to available ship pool on delivery."],
    ["crateClass", ""]
]];

// ============================================================
// NAVAL > MERCHANT SHIPS
// ============================================================

OpsRoom_EquipmentDB set ["cargo_ship", createHashMapFromArray [
    ["displayName", "Liberty Ship"],
    ["category", "Naval"],
    ["subcategory", "Merchant Ships"],
    ["className", "PLACEHOLDER_CARGO_SHIP"],
    ["imagePath", ""],
    ["spawnType", "naval"],
    
    ["researchCost", 60],
    ["researchTime", 6],
    ["researchTier", 2],
    ["researchPrereqs", []],
    ["researchDesc", "Mass-produced cargo vessel. Backbone of Allied supply convoys. Slow but carries enormous quantities of war materiel across the seas."],
    
    ["buildTime", 20],
    ["buildCost", [["Steel", 40], ["Wood", 30], ["Rubber", 10], ["Oil", 10]]],
    ["batchSize", 1],
    ["buildDesc", "Emergency wartime construction. Welded hull for speed of assembly. One vessel per production cycle."],
    
    ["supplyDesc", "One Liberty Ship, added to convoy fleet pool."],
    ["crateClass", ""]
]];

// ============================================================
// TECHNOLOGY > AIRBORNE
// ============================================================

OpsRoom_EquipmentDB set ["paradrop_capability", createHashMapFromArray [
    ["displayName", "Paradrop Capability"],
    ["category", "Technology"],
    ["subcategory", "Airborne"],
    ["className", ""],
    ["imagePath", ""],
    
    ["researchCost", 40],
    ["researchTime", 5],
    ["researchTier", 2],
    ["researchPrereqs", ["c47_transport"]],
    ["researchDesc", "Parachute supply drop technology. Enables cargo dropped from transport aircraft to deploy parachutes, preventing damage on landing. Without this research, air-dropped supplies will free-fall."],
    
    ["buildTime", 0],
    ["buildCost", []],
    ["batchSize", 0],
    ["buildDesc", ""],
    
    ["supplyDesc", ""],
    ["spawnType", "none"],
    ["crateClass", ""]
]];

// ============================================================
// HELPER FUNCTIONS
// ============================================================

/*
    Get all items in a category
    Returns: Array of [itemId, itemData] pairs
*/
OpsRoom_fnc_getItemsByCategory = {
    params ["_category"];
    private _results = [];
    {
        private _itemId = _x;
        private _itemData = _y;
        if ((_itemData get "category") == _category) then {
            _results pushBack [_itemId, _itemData];
        };
    } forEach OpsRoom_EquipmentDB;
    _results
};

/*
    Get all items in a subcategory
    Returns: Array of [itemId, itemData] pairs
*/
OpsRoom_fnc_getItemsBySubcategory = {
    params ["_category", "_subcategory"];
    private _results = [];
    {
        private _itemId = _x;
        private _itemData = _y;
        if ((_itemData get "category") == _category && (_itemData get "subcategory") == _subcategory) then {
            _results pushBack [_itemId, _itemData];
        };
    } forEach OpsRoom_EquipmentDB;
    // Sort by research tier
    _results sort true;
    _results
};

/*
    Get all unique subcategories for a category
    Returns: Array of subcategory strings
*/
OpsRoom_fnc_getSubcategories = {
    params ["_category"];
    private _subs = [];
    {
        private _itemData = _y;
        if ((_itemData get "category") == _category) then {
            private _sub = _itemData get "subcategory";
            if !(_sub in _subs) then {
                _subs pushBack _sub;
            };
        };
    } forEach OpsRoom_EquipmentDB;
    _subs sort true;
    _subs
};

/*
    Get all unique categories
    Returns: Array of category strings
*/
OpsRoom_fnc_getCategories = {
    private _cats = [];
    {
        private _itemData = _y;
        private _cat = _itemData get "category";
        if !(_cat in _cats) then {
            _cats pushBack _cat;
        };
    } forEach OpsRoom_EquipmentDB;
    _cats sort true;
    _cats
};

/*
    Check if an item is researched
*/
OpsRoom_fnc_isResearched = {
    params ["_itemId"];
    if (isNil "OpsRoom_ResearchCompleted") exitWith { false };
    _itemId in OpsRoom_ResearchCompleted
};

/*
    Check if prerequisites are met for an item
*/
OpsRoom_fnc_prereqsMet = {
    params ["_itemId"];
    private _itemData = OpsRoom_EquipmentDB get _itemId;
    if (isNil "_itemData") exitWith { false };
    
    private _prereqs = _itemData get "researchPrereqs";
    private _allMet = true;
    {
        if !([_x] call OpsRoom_fnc_isResearched) then {
            _allMet = false;
        };
    } forEach _prereqs;
    _allMet
};

diag_log format ["[OpsRoom] Equipment database loaded: %1 items", count OpsRoom_EquipmentDB];
