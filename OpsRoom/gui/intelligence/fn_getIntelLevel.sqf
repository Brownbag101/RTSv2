/*
    fn_getIntelLevel
    
    Returns the intel tier (0-5) based on intel percentage.
    
    Parameters:
        0: NUMBER - Intel percentage (0-100)
    
    Returns: NUMBER - Intel tier (0-5)
    
    Tiers:
        0 = Unknown (0%)        - Nothing known
        1 = Detected (1-19%)    - "?" on map, something is here
        2 = Identified (20-44%) - Type revealed, basic description
        3 = Observed (45-69%)   - Production/value, rough garrison
        4 = Detailed (70-89%)   - Exact numbers, defences, reinforcements
        5 = Compromised (90%+)  - Real-time intel, officer names (SOE)
    
    Photo recon caps at 75% → lands in Tier 4 (Detailed)
    Ground recon troops cap at 69% → lands in Tier 3 (Observed)
    Regular infantry cap at 44% → lands in Tier 2 (Identified)
    SOE agents can reach 100% → Tier 5 (Compromised)
*/

params [["_percent", 0, [0]]];

if (_percent <= 0) exitWith { 0 };
if (_percent < 20) exitWith { 1 };
if (_percent < 45) exitWith { 2 };
if (_percent < 70) exitWith { 3 };
if (_percent < 90) exitWith { 4 };

// 90%+
5
