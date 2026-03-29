/*
    fn_initCommandIntel
    
    Initialises the Command Intelligence system.
    
    This tracks how much the player knows about the enemy AI commander's
    decisions, troop movements, and strategic planning.
    
    OpsRoom_AI_IntelLevel (0-100):
        0%   = Blind — no enemy dispatches, no Draw3D markers
        1-29 = Minimal — occasional vague dispatches about large movements
        30-59 = Partial — delayed dispatches, Draw3D within 1000m
        60-79 = Good — most dispatches visible, Draw3D within 3000m
        80-99 = Excellent — all dispatches, all Draw3D markers, manpower estimate
        100% = Total — everything visible including AI turn reasoning
    
    Intel sources:
        - Base level: 10% (basic frontline observation)
        - Location capture: +5% per capture (one-time, fades)
        - Signals Intelligence research tiers: permanent bonuses
        - Spies: future hook (OpsRoom_AI_SpyIntelBonus)
        - Document capture: future hook (one-time boosts)
    
    Intel decay:
        - 1% per in-game hour without active intel gathering
        - Cannot decay below base level (10%) + permanent research bonuses
    
    Called from init.sqf after AI Commander config loads.
*/

// Base intel level — what you know just from frontline observation
OpsRoom_AI_IntelBase = 10;

// Current intel level (starts at base)
OpsRoom_AI_IntelLevel = OpsRoom_AI_IntelBase;

// Permanent bonus from Signals Intelligence research
OpsRoom_AI_IntelResearchBonus = 0;

// Temporary bonus from captures, spies, documents (decays)
OpsRoom_AI_IntelTempBonus = 0;

// Spy bonus hook (set by future spy system)
OpsRoom_AI_SpyIntelBonus = 0;

// Track captures for one-time intel boosts
if (isNil "OpsRoom_AI_IntelCaptureLog") then {
    OpsRoom_AI_IntelCaptureLog = [];
};

// Decay rate: percent per in-game hour
OpsRoom_AI_IntelDecayRate = 1;

// Intel gained per location capture
OpsRoom_AI_IntelPerCapture = 5;

// Signals Intelligence research tier bonuses (cumulative)
// These are the item IDs from the equipment database
OpsRoom_AI_SigIntTiers = createHashMapFromArray [
    ["sigint_radio_intercepts", 15],     // Tier 1: +15%
    ["sigint_enigma_analysis", 25],      // Tier 2: +25%
    ["sigint_ultra_decrypts", 35],       // Tier 3: +35%
    ["sigint_strategic_deception", 25]   // Tier 4: +25% (total possible: 100%)
];

systemChat "Command Intelligence: System initialised";
diag_log format ["[OpsRoom] Command Intel initialised. Base level: %1%%", OpsRoom_AI_IntelBase];
