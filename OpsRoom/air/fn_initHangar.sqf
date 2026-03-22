/*
    Air Operations - Initialize Hangar
    
    Creates the virtual hangar pool and air wing data structures.
    Aircraft are stored virtually and only spawned when inspected or launched.
    
    Required editor markers:
        OpsRoom_hangar       - Hangar position (preview spawn + camera target)
        OpsRoom_runway       - Runway position (launch spawn + LAND waypoint target)
*/

// Initialize Hangar pool (virtual aircraft inventory)
if (isNil "OpsRoom_Hangar") then {
    OpsRoom_Hangar = createHashMap;
};

// Initialize Air Wings
if (isNil "OpsRoom_AirWings") then {
    OpsRoom_AirWings = createHashMap;
};

// Next IDs for hangar entries and wings
if (isNil "OpsRoom_HangarNextID") then { OpsRoom_HangarNextID = 1 };
if (isNil "OpsRoom_WingNextID") then { OpsRoom_WingNextID = 1 };

// Preview aircraft reference (for hangar inspection)
if (isNil "OpsRoom_HangarPreview") then { OpsRoom_HangarPreview = objNull };

// Wing type definitions - determines what missions each wing type can fly
OpsRoom_WingTypes = createHashMapFromArray [
    ["Fighter", createHashMapFromArray [
        ["displayName", "Fighter Wing"],
        ["description", "Air-to-air combat. Scramble, air superiority, escort."],
        ["missions", ["scramble", "airsup", "escort", "patrol", "sealane_patrol"]],
        ["allowedAircraftTypes", ["Fighter"]],
        ["icon", "\A3\ui_f\data\map\vehicleicons\iconplane_ca.paa"]
    ]],
    ["GroundAttack", createHashMapFromArray [
        ["displayName", "Ground Attack Wing"],
        ["description", "Close air support and ground attack. Feeds into Air Strike ability."],
        ["missions", ["cas", "groundattack", "patrol", "strike_guns", "strike_bombs", "strike_rockets", "strike_strafe", "strike_torpedo"]],
        ["allowedAircraftTypes", ["GroundAttack"]],
        ["icon", "\A3\ui_f\data\map\vehicleicons\iconplane_ca.paa"]
    ]],
    ["Bomber", createHashMapFromArray [
        ["displayName", "Bomber Wing"],
        ["description", "Strategic bombing of enemy positions and infrastructure."],
        ["missions", ["bombing", "patrol", "strike_bombs"]],
        ["allowedAircraftTypes", ["Bomber"]],
        ["icon", "\A3\ui_f\data\map\vehicleicons\iconplane_ca.paa"]
    ]],
    ["Recon", createHashMapFromArray [
        ["displayName", "Recon Wing"],
        ["description", "Aerial reconnaissance. Photo recon and enemy spotting."],
        ["missions", ["recon_photo_high", "recon_photo_low", "recon_spotting", "patrol", "sealane_patrol"]],
        ["allowedAircraftTypes", ["Recon"]],
        ["icon", "\A3\ui_f\data\map\vehicleicons\iconplane_ca.paa"]
    ]],
    ["Transport", createHashMapFromArray [
        ["displayName", "Transport Wing"],
        ["description", "Troop and supply transport. Paradrop and resupply operations."],
        ["missions", ["patrol"]],
        ["allowedAircraftTypes", ["Transport"]],
        ["icon", "\A3\ui_f\data\map\vehicleicons\iconplane_ca.paa"]
    ]]
];

// Mission type definitions
OpsRoom_AirMissionTypes = createHashMapFromArray [
    ["scramble", createHashMapFromArray [
        ["displayName", "Scramble"],
        ["description", "Quick launch to defend airfield. Fighters orbit home base and engage threats."],
        ["altitude", 300],
        ["speed", "FULL"],
        ["combatMode", "RED"],
        ["behaviour", "COMBAT"],
        ["waypointType", "SAD"],
        ["loiterRadius", 1500]
    ]],
    ["airsup", createHashMapFromArray [
        ["displayName", "Air Superiority"],
        ["description", "Establish air dominance over a designated area. Engage all enemy aircraft."],
        ["altitude", 500],
        ["speed", "FULL"],
        ["combatMode", "RED"],
        ["behaviour", "COMBAT"],
        ["waypointType", "SAD"],
        ["loiterRadius", 2000]
    ]],
    ["escort", createHashMapFromArray [
        ["displayName", "Escort"],
        ["description", "Protect a designated ground force or air wing from enemy air attack."],
        ["altitude", 400],
        ["speed", "NORMAL"],
        ["combatMode", "GREEN"],
        ["behaviour", "AWARE"],
        ["waypointType", "LOITER"],
        ["loiterRadius", 800]
    ]],
    ["cas", createHashMapFromArray [
        ["displayName", "Close Air Support"],
        ["description", "Loiter at target area and provide fire support when called by ground troops."],
        ["altitude", 250],
        ["speed", "NORMAL"],
        ["combatMode", "GREEN"],
        ["behaviour", "AWARE"],
        ["waypointType", "LOITER"],
        ["loiterRadius", 1000]
    ]],
    ["groundattack", createHashMapFromArray [
        ["displayName", "Ground Attack"],
        ["description", "Attack enemy ground positions. Strafe and bomb designated targets."],
        ["altitude", 200],
        ["speed", "NORMAL"],
        ["combatMode", "RED"],
        ["behaviour", "COMBAT"],
        ["waypointType", "SAD"],
        ["loiterRadius", 800]
    ]],
    ["bombing", createHashMapFromArray [
        ["displayName", "Bombing Run"],
        ["description", "High altitude bombing of enemy positions. Deliver payload and RTB."],
        ["altitude", 500],
        ["speed", "NORMAL"],
        ["combatMode", "GREEN"],
        ["behaviour", "AWARE"],
        ["waypointType", "LOITER"],
        ["loiterRadius", 500]
    ]],
    ["recon_photo_high", createHashMapFromArray [
        ["displayName", "High-Level Photo Recon"],
        ["description", "High altitude recon. Photographs locations within 2km. +10% intel per pass, cap 75%. Intel delivered on landing."],
        ["altitude", 500],
        ["speed", "FULL"],
        ["combatMode", "GREEN"],
        ["behaviour", "CARELESS"],
        ["waypointType", "LOITER"],
        ["loiterRadius", 1500],
        ["isPhotoRecon", true]
    ]],
    ["recon_photo_low", createHashMapFromArray [
        ["displayName", "Low-Level Photo Recon"],
        ["description", "Low-altitude recon. Photographs locations within 800m. +30% intel per pass, cap 75%. Intel delivered on landing."],
        ["altitude", 300],
        ["speed", "NORMAL"],
        ["combatMode", "GREEN"],
        ["behaviour", "CARELESS"],
        ["waypointType", "LOITER"],
        ["loiterRadius", 600],
        ["isPhotoRecon", true]
    ]],
    ["recon_spotting", createHashMapFromArray [
        ["displayName", "Enemy Movement Spotting"],
        ["description", "Circle target area at medium altitude. Reveals enemy positions to command in real-time. Does not gather location intel."],
        ["altitude", 300],
        ["speed", "NORMAL"],
        ["combatMode", "GREEN"],
        ["behaviour", "CARELESS"],
        ["waypointType", "LOITER"],
        ["loiterRadius", 1000]
    ]],
    ["patrol", createHashMapFromArray [
        ["displayName", "Combat Air Patrol"],
        ["description", "Patrol designated area. Report and engage contacts."],
        ["altitude", 350],
        ["speed", "NORMAL"],
        ["combatMode", "GREEN"],
        ["behaviour", "AWARE"],
        ["waypointType", "LOITER"],
        ["loiterRadius", 1200]
    ]],
    ["strike_guns", createHashMapFromArray [
        ["displayName", "Gun Run Strike"],
        ["description", "Order a strafing gun run on the designated target. Select target and approach heading."],
        ["isStrike", true],
        ["attackType", "GUNS"],
        ["altitude", 250],
        ["speed", "NORMAL"],
        ["combatMode", "GREEN"],
        ["behaviour", "AWARE"],
        ["waypointType", "LOITER"],
        ["loiterRadius", 1000]
    ]],
    ["strike_bombs", createHashMapFromArray [
        ["displayName", "Saturation Bombing"],
        ["description", "Drop entire bomb payload on the designated target. All bombs released in a single pass."],
        ["isStrike", true],
        ["attackType", "BOMBS"],
        ["altitude", 250],
        ["speed", "NORMAL"],
        ["combatMode", "GREEN"],
        ["behaviour", "AWARE"],
        ["waypointType", "LOITER"],
        ["loiterRadius", 1000]
    ]],
    ["strike_rockets", createHashMapFromArray [
        ["displayName", "Rocket Run Strike"],
        ["description", "Order a rocket salvo on the designated target. Select target and approach heading."],
        ["isStrike", true],
        ["attackType", "ROCKETS"],
        ["altitude", 250],
        ["speed", "NORMAL"],
        ["combatMode", "GREEN"],
        ["behaviour", "AWARE"],
        ["waypointType", "LOITER"],
        ["loiterRadius", 1000]
    ]],
    ["strike_torpedo", createHashMapFromArray [
        ["displayName", "Torpedo Attack"],
        ["description", "Low-level torpedo run. Aircraft flies in at wave-top height and releases torpedo at close range. Devastating against ships and large targets."],
        ["isStrike", true],
        ["attackType", "TORPEDO"],
        ["altitude", 250],
        ["speed", "NORMAL"],
        ["combatMode", "GREEN"],
        ["behaviour", "AWARE"],
        ["waypointType", "LOITER"],
        ["loiterRadius", 1000]
    ]],
    ["strike_strafe", createHashMapFromArray [
        ["displayName", "Strafe Run (Guns + Rockets)"],
        ["description", "Combined guns and rockets strafing pass on the designated target."],
        ["isStrike", true],
        ["attackType", "STRAFE"],
        ["altitude", 250],
        ["speed", "NORMAL"],
        ["combatMode", "GREEN"],
        ["behaviour", "AWARE"],
        ["waypointType", "LOITER"],
        ["loiterRadius", 1000]
    ]],
    ["sealane_patrol", createHashMapFromArray [
        ["displayName", "Sea Lane Patrol"],
        ["description", "Patrol a sea lane route. Aircraft follows waypoints along the shipping lane, spotting enemies and providing convoy escort. Select the sea lane on the Ops Map."],
        ["altitude", 250],
        ["speed", "NORMAL"],
        ["combatMode", "GREEN"],
        ["behaviour", "AWARE"],
        ["waypointType", "MOVE"],
        ["loiterRadius", 800],
        ["isSeaLanePatrol", true]
    ]]
];

// Pilot rank progression
OpsRoom_PilotRanks = [
    "Pilot Officer",
    "Flying Officer",
    "Flight Lieutenant",
    "Squadron Leader"
];

diag_log "[OpsRoom] Air Operations hangar initialized";
