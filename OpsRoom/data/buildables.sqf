/*
    Buildable Objects Database
    
    Defines all objects that can be constructed by engineers.
    Loaded at mission start from init.sqf.
    
    Each buildable has:
        displayName      - Shown in build menu
        className        - ARMA classname to spawn
        icon             - Menu icon path
        cost             - Array of [resource, amount] pairs
        buildTime        - Seconds to construct
        category         - Menu category
        researchRequired - Research ID needed (empty = always available)
        placementType    - "single" or "line"
        lineSpacing      - Metres between objects in line mode (line only)
        isMine           - Special mine flag (optional)
*/

OpsRoom_Buildables = createHashMapFromArray [

    // =============== BASIC (no research needed) ===============
    ["sandbag_low", createHashMapFromArray [
        ["displayName", "Sandbag Wall (Low)"],
        ["className", "Land_BagFence_Long_F"],
        ["icon", "a3\ui_f\data\igui\cfg\actions\repair_ca.paa"],
        ["cost", [["Wood", 1]]],
        ["buildTime", 8],
        ["category", "Basic"],
        ["researchRequired", ""],
        ["placementType", "line"],
        ["lineSpacing", 1.5]
    ]],
    ["razor_wire", createHashMapFromArray [
        ["displayName", "Razor Wire"],
        ["className", "Land_Razorwire_F"],
        ["icon", "a3\ui_f\data\igui\cfg\actions\repair_ca.paa"],
        ["cost", [["Steel", 1]]],
        ["buildTime", 6],
        ["category", "Basic"],
        ["researchRequired", ""],
        ["placementType", "line"],
        ["lineSpacing", 2.5]
    ]],
    ["sandbag_round", createHashMapFromArray [
        ["displayName", "Sandbag Nest (Round)"],
        ["className", "Land_BagFence_Round_F"],
        ["icon", "a3\ui_f\data\igui\cfg\actions\repair_ca.paa"],
        ["cost", [["Wood", 2]]],
        ["buildTime", 12],
        ["category", "Basic"],
        ["researchRequired", ""],
        ["placementType", "single"]
    ]],

    // =============== TIER 1: Basic Fortifications ===============
    ["sandbag_long", createHashMapFromArray [
        ["displayName", "Sandbag Wall (Tall)"],
        ["className", "Land_BagFence_01_long_green_F"],
        ["icon", "a3\ui_f\data\igui\cfg\actions\repair_ca.paa"],
        ["cost", [["Wood", 2]]],
        ["buildTime", 15],
        ["category", "Tier1"],
        ["researchRequired", "field_eng_1"],
        ["placementType", "line"],
        ["lineSpacing", 3]
    ]],
    ["tank_trap", createHashMapFromArray [
        ["displayName", "Tank Trap (Hedgehog)"],
        ["className", "Land_CzechHedgehog_01_new_F"],
        ["icon", "a3\ui_f\data\igui\cfg\actions\repair_ca.paa"],
        ["cost", [["Steel", 3]]],
        ["buildTime", 15],
        ["category", "Tier1"],
        ["researchRequired", "field_eng_1"],
        ["placementType", "line"],
        ["lineSpacing", 4]
    ]],
    ["mine_ap", createHashMapFromArray [
        ["displayName", "Anti-Personnel Mine"],
        ["className", "APERSMine_Range_Ammo"],
        ["icon", "\A3\ui_f\data\IGUI\Cfg\SimpleTasks\types\mine_ca.paa"],
        ["cost", [["Steel", 1]]],
        ["buildTime", 8],
        ["category", "Tier1"],
        ["researchRequired", "field_eng_1"],
        ["placementType", "line"],
        ["lineSpacing", 3],
        ["isMine", true]
    ]],
    ["mine_at", createHashMapFromArray [
        ["displayName", "Anti-Tank Mine"],
        ["className", "ATMine_Range_Ammo"],
        ["icon", "\A3\ui_f\data\IGUI\Cfg\SimpleTasks\types\mine_ca.paa"],
        ["cost", [["Steel", 2]]],
        ["buildTime", 10],
        ["category", "Tier1"],
        ["researchRequired", "field_eng_1"],
        ["placementType", "line"],
        ["lineSpacing", 5],
        ["isMine", true]
    ]],

    // =============== TIER 2: Defensive Positions ===============
    ["mg_nest", createHashMapFromArray [
        ["displayName", "MG Nest"],
        ["className", "Land_BagBunker_Small_F"],
        ["icon", "a3\ui_f\data\igui\cfg\weaponicons\mg_ca.paa"],
        ["cost", [["Wood", 3], ["Steel", 2]]],
        ["buildTime", 30],
        ["category", "Tier2"],
        ["researchRequired", "field_eng_2"],
        ["placementType", "single"]
    ]],
    ["trench", createHashMapFromArray [
        ["displayName", "Trench Section"],
        ["className", "Land_Trench_01_grass_F"],
        ["icon", "a3\ui_f\data\igui\cfg\actions\repair_ca.paa"],
        ["cost", [["Wood", 2]]],
        ["buildTime", 20],
        ["category", "Tier2"],
        ["researchRequired", "field_eng_2"],
        ["placementType", "line"],
        ["lineSpacing", 5]
    ]],
    ["gun_pit", createHashMapFromArray [
        ["displayName", "Gun Pit"],
        ["className", "Land_BagFence_Corner_F"],
        ["icon", "a3\ui_f\data\igui\cfg\actions\repair_ca.paa"],
        ["cost", [["Wood", 2], ["Steel", 1]]],
        ["buildTime", 20],
        ["category", "Tier2"],
        ["researchRequired", "field_eng_2"],
        ["placementType", "single"]
    ]],

    // =============== TIER 3: Heavy Fortifications ===============
    ["bunker", createHashMapFromArray [
        ["displayName", "Bunker"],
        ["className", "Land_BagBunker_Large_F"],
        ["icon", "a3\ui_f\data\igui\cfg\actions\repair_ca.paa"],
        ["cost", [["Wood", 5], ["Steel", 5]]],
        ["buildTime", 60],
        ["category", "Tier3"],
        ["researchRequired", "field_eng_3"],
        ["placementType", "single"]
    ]],
    ["at_position", createHashMapFromArray [
        ["displayName", "AT Gun Position"],
        ["className", "Land_BagBunker_Tower_F"],
        ["icon", "a3\ui_f\data\igui\cfg\actions\repair_ca.paa"],
        ["cost", [["Steel", 5], ["Wood", 3]]],
        ["buildTime", 45],
        ["category", "Tier3"],
        ["researchRequired", "field_eng_3"],
        ["placementType", "single"]
    ]],
    ["obs_tower", createHashMapFromArray [
        ["displayName", "Observation Tower"],
        ["className", "Land_Cargo_Patrol_V1_F"],
        ["icon", "a3\ui_f\data\igui\cfg\simpleTasks\types\scout_ca.paa"],
        ["cost", [["Wood", 4], ["Steel", 3]]],
        ["buildTime", 45],
        ["category", "Tier3"],
        ["researchRequired", "field_eng_3"],
        ["placementType", "single"]
    ]]
];

systemChat format ["Build: Loaded %1 buildable objects", count OpsRoom_Buildables];
diag_log format ["[OpsRoom] Buildables database loaded: %1 items", count OpsRoom_Buildables];
