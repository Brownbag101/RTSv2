/*
    Location Types - Definitions for strategic locations
    
    Called from init.sqf at mission start.
    
    Each type defines:
        displayName  - Shown on intel card
        category     - Grouping for map icons  
        description  - Flavour text
        taskTypes    - Available operations for this target
        produces     - What resource/value this location provides (empty = none)
        iconUnknown  - Map icon when undiscovered (tier 0-1)
        iconKnown    - Map icon when identified (tier 2+)
        iconDestroyed - Map icon when destroyed
*/

OpsRoom_LocationTypes = createHashMapFromArray [
    ["factory", createHashMapFromArray [
        ["displayName", "Factory"],
        ["category", "Industrial"],
        ["description", "Industrial facility producing war materials"],
        ["taskTypes", ["Capture", "Destroy", "Reconnoitre", "Sabotage"]],
        ["produces", "Equipment"],
        ["captureRadius", 200],
        ["captureTime", 300],
        ["iconUnknown", "\A3\ui_f\data\map\markers\military\unknown_ca.paa"],
        ["iconKnown", "\A3\ui_f\data\map\markers\nato\n_installation.paa"],
        ["iconDestroyed", "\A3\ui_f\data\map\markers\military\destroy_ca.paa"]
    ]],
    ["port", createHashMapFromArray [
        ["displayName", "Port"],
        ["category", "Maritime"],
        ["description", "Harbour facility for shipping and naval supply"],
        ["taskTypes", ["Capture", "Destroy", "Reconnoitre", "Blockade"]],
        ["produces", "Supply Routes"],
        ["captureRadius", 250],
        ["captureTime", 480],
        ["iconUnknown", "\A3\ui_f\data\map\markers\military\unknown_ca.paa"],
        ["iconKnown", "\A3\ui_f\data\map\markers\nato\n_installation.paa"],
        ["iconDestroyed", "\A3\ui_f\data\map\markers\military\destroy_ca.paa"]
    ]],
    ["town", createHashMapFromArray [
        ["displayName", "Town"],
        ["category", "Settlement"],
        ["description", "Population centre under enemy occupation"],
        ["taskTypes", ["Capture", "Reconnoitre", "Patrol", "Liberate"]],
        ["produces", "Manpower"],
        ["captureRadius", 300],
        ["captureTime", 300],
        ["iconUnknown", "\A3\ui_f\data\map\markers\military\unknown_ca.paa"],
        ["iconKnown", "\A3\ui_f\data\map\markers\nato\n_installation.paa"],
        ["iconDestroyed", "\A3\ui_f\data\map\markers\military\destroy_ca.paa"]
    ]],
    ["airfield", createHashMapFromArray [
        ["displayName", "Airfield"],
        ["category", "Aviation"],
        ["description", "Airstrip and hangars for air operations"],
        ["taskTypes", ["Capture", "Destroy", "Reconnoitre"]],
        ["produces", "Air Support"],
        ["captureRadius", 300],
        ["captureTime", 480],
        ["iconUnknown", "\A3\ui_f\data\map\markers\military\unknown_ca.paa"],
        ["iconKnown", "\A3\ui_f\data\map\markers\nato\n_installation.paa"],
        ["iconDestroyed", "\A3\ui_f\data\map\markers\military\destroy_ca.paa"]
    ]],
    ["camp", createHashMapFromArray [
        ["displayName", "Camp"],
        ["category", "Military"],
        ["description", "Enemy military encampment"],
        ["taskTypes", ["Destroy", "Reconnoitre", "Raid"]],
        ["produces", ""],
        ["captureRadius", 150],
        ["captureTime", 180],
        ["iconUnknown", "\A3\ui_f\data\map\markers\military\unknown_ca.paa"],
        ["iconKnown", "\A3\ui_f\data\map\markers\nato\n_installation.paa"],
        ["iconDestroyed", "\A3\ui_f\data\map\markers\military\destroy_ca.paa"]
    ]],
    ["emplacement", createHashMapFromArray [
        ["displayName", "Emplacement"],
        ["category", "Fortified"],
        ["description", "Fortified defensive position"],
        ["taskTypes", ["Destroy", "Reconnoitre", "Suppress"]],
        ["produces", ""],
        ["captureRadius", 100],
        ["captureTime", 180],
        ["iconUnknown", "\A3\ui_f\data\map\markers\military\unknown_ca.paa"],
        ["iconKnown", "\A3\ui_f\data\map\markers\nato\n_installation.paa"],
        ["iconDestroyed", "\A3\ui_f\data\map\markers\military\destroy_ca.paa"]
    ]],
    ["bridge", createHashMapFromArray [
        ["displayName", "Bridge"],
        ["category", "Infrastructure"],
        ["description", "Key river or ravine crossing point"],
        ["taskTypes", ["Capture", "Destroy", "Guard", "Reconnoitre"]],
        ["produces", ""],
        ["captureRadius", 100],
        ["captureTime", 120],
        ["iconUnknown", "\A3\ui_f\data\map\markers\military\unknown_ca.paa"],
        ["iconKnown", "\A3\ui_f\data\map\markers\nato\n_installation.paa"],
        ["iconDestroyed", "\A3\ui_f\data\map\markers\military\destroy_ca.paa"]
    ]],
    ["crossroads", createHashMapFromArray [
        ["displayName", "Crossroads"],
        ["category", "Infrastructure"],
        ["description", "Strategic road junction"],
        ["taskTypes", ["Patrol", "Guard", "Ambush", "Reconnoitre"]],
        ["produces", ""],
        ["captureRadius", 100],
        ["captureTime", 120],
        ["iconUnknown", "\A3\ui_f\data\map\markers\military\unknown_ca.paa"],
        ["iconKnown", "\A3\ui_f\data\map\markers\nato\n_installation.paa"],
        ["iconDestroyed", "\A3\ui_f\data\map\markers\military\destroy_ca.paa"]
    ]],
    ["rail", createHashMapFromArray [
        ["displayName", "Rail Station"],
        ["category", "Infrastructure"],
        ["description", "Railway hub for transport and logistics"],
        ["taskTypes", ["Capture", "Destroy", "Reconnoitre", "Sabotage"]],
        ["produces", "Logistics"],
        ["captureRadius", 150],
        ["captureTime", 300],
        ["iconUnknown", "\A3\ui_f\data\map\markers\military\unknown_ca.paa"],
        ["iconKnown", "\A3\ui_f\data\map\markers\nato\n_installation.paa"],
        ["iconDestroyed", "\A3\ui_f\data\map\markers\military\destroy_ca.paa"]
    ]],
    ["stores", createHashMapFromArray [
        ["displayName", "Supply Stores"],
        ["category", "Logistics"],
        ["description", "Forward supply depot for storing and distributing equipment"],
        ["taskTypes", ["Guard", "Patrol"]],
        ["produces", "Equipment"],
        ["captureRadius", 50],
        ["captureTime", 120],
        ["iconUnknown", "\A3\ui_f\data\map\markers\military\unknown_ca.paa"],
        ["iconKnown", "\A3\ui_f\data\map\markers\nato\n_supply.paa"],
        ["iconDestroyed", "\A3\ui_f\data\map\markers\military\destroy_ca.paa"]
    ]],
    ["barracks", createHashMapFromArray [
        ["displayName", "Barracks"],
        ["category", "Military"],
        ["description", "Enemy troop staging and training facility"],
        ["taskTypes", ["Capture", "Destroy", "Reconnoitre", "Raid"]],
        ["produces", "Manpower"],
        ["captureRadius", 200],
        ["captureTime", 300],
        ["iconUnknown", "\A3\ui_f\data\map\markers\military\unknown_ca.paa"],
        ["iconKnown", "\A3\ui_f\data\map\markers\nato\n_installation.paa"],
        ["iconDestroyed", "\A3\ui_f\data\map\markers\military\destroy_ca.paa"]
    ]],
    ["gun_emplacement", createHashMapFromArray [
        ["displayName", "Gun Emplacement"],
        ["category", "Fortified"],
        ["description", "Fixed artillery or anti-aircraft position"],
        ["taskTypes", ["Destroy", "Reconnoitre", "Suppress", "Raid"]],
        ["produces", ""],
        ["captureRadius", 80],
        ["captureTime", 120],
        ["iconUnknown", "\A3\ui_f\data\map\markers\military\unknown_ca.paa"],
        ["iconKnown", "\A3\ui_f\data\map\markers\nato\n_art.paa"],
        ["iconDestroyed", "\A3\ui_f\data\map\markers\military\destroy_ca.paa"]
    ]],
    ["radar", createHashMapFromArray [
        ["displayName", "Radar Station"],
        ["category", "Military"],
        ["description", "Early warning and air detection facility"],
        ["taskTypes", ["Destroy", "Reconnoitre", "Sabotage"]],
        ["produces", ""],
        ["captureRadius", 100],
        ["captureTime", 180],
        ["iconUnknown", "\A3\ui_f\data\map\markers\military\unknown_ca.paa"],
        ["iconKnown", "\A3\ui_f\data\map\markers\nato\n_installation.paa"],
        ["iconDestroyed", "\A3\ui_f\data\map\markers\military\destroy_ca.paa"]
    ]],
    ["fuel_depot", createHashMapFromArray [
        ["displayName", "Fuel Depot"],
        ["category", "Logistics"],
        ["description", "Bulk fuel storage for vehicles and aircraft"],
        ["taskTypes", ["Capture", "Destroy", "Reconnoitre", "Sabotage"]],
        ["produces", "Fuel"],
        ["captureRadius", 150],
        ["captureTime", 240],
        ["iconUnknown", "\A3\ui_f\data\map\markers\military\unknown_ca.paa"],
        ["iconKnown", "\A3\ui_f\data\map\markers\nato\n_supply.paa"],
        ["iconDestroyed", "\A3\ui_f\data\map\markers\military\destroy_ca.paa"]
    ]],
    ["ammo_dump", createHashMapFromArray [
        ["displayName", "Ammunition Dump"],
        ["category", "Logistics"],
        ["description", "Forward ammunition and ordnance storage"],
        ["taskTypes", ["Capture", "Destroy", "Reconnoitre", "Sabotage"]],
        ["produces", "Ammunition"],
        ["captureRadius", 120],
        ["captureTime", 180],
        ["iconUnknown", "\A3\ui_f\data\map\markers\military\unknown_ca.paa"],
        ["iconKnown", "\A3\ui_f\data\map\markers\nato\n_supply.paa"],
        ["iconDestroyed", "\A3\ui_f\data\map\markers\military\destroy_ca.paa"]
    ]],
    ["bunker", createHashMapFromArray [
        ["displayName", "Bunker Complex"],
        ["category", "Fortified"],
        ["description", "Hardened underground command and defensive position"],
        ["taskTypes", ["Destroy", "Reconnoitre", "Capture"]],
        ["produces", "Command"],
        ["captureRadius", 100],
        ["captureTime", 480],
        ["iconUnknown", "\A3\ui_f\data\map\markers\military\unknown_ca.paa"],
        ["iconKnown", "\A3\ui_f\data\map\markers\nato\n_installation.paa"],
        ["iconDestroyed", "\A3\ui_f\data\map\markers\military\destroy_ca.paa"]
    ]],
    ["sealane", createHashMapFromArray [
        ["displayName", "Sea Lane Entry"],
        ["category", "Maritime"],
        ["description", "Coastal entry point for shipping convoys. Control this position to open the sea route for supply operations."],
        ["taskTypes", ["Capture", "Patrol", "Escort", "Reconnoitre"]],
        ["produces", "Supply Routes"],
        ["captureRadius", 200],
        ["captureTime", 300],
        ["iconUnknown", "\A3\ui_f\data\map\markers\military\unknown_ca.paa"],
        ["iconKnown", "\A3\ui_f\data\map\markers\nato\n_installation.paa"],
        ["iconDestroyed", "\A3\ui_f\data\map\markers\military\destroy_ca.paa"]
    ]],
    ["hq", createHashMapFromArray [
        ["displayName", "Headquarters"],
        ["category", "Military"],
        ["description", "Enemy command and control centre"],
        ["taskTypes", ["Capture", "Destroy", "Reconnoitre", "Raid"]],
        ["produces", "Command"],
        ["captureRadius", 200],
        ["captureTime", 480],
        ["iconUnknown", "\A3\ui_f\data\map\markers\military\unknown_ca.paa"],
        ["iconKnown", "\A3\ui_f\data\map\markers\nato\n_installation.paa"],
        ["iconDestroyed", "\A3\ui_f\data\map\markers\military\destroy_ca.paa"]
    ]]
];

systemChat format ["Intel: Loaded %1 location types", count OpsRoom_LocationTypes];
