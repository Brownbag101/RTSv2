/*
    fn_getCommandIntelLevel
    
    Calculates and returns the current effective Command Intelligence level.
    
    Effective level = base + research bonus + temp bonus + spy bonus
    Clamped to 0-100.
    
    Also updates OpsRoom_AI_IntelLevel global for other systems to read.
    
    Returns: NUMBER (0-100)
    
    Usage:
        private _intel = [] call OpsRoom_fnc_getCommandIntelLevel;
*/

// Calculate research bonus from completed Signals Intelligence tiers
private _researchBonus = 0;
{
    private _itemId = _x;
    private _bonus = _y;
    if ([_itemId] call OpsRoom_fnc_isResearched) then {
        _researchBonus = _researchBonus + _bonus;
    };
} forEach OpsRoom_AI_SigIntTiers;
OpsRoom_AI_IntelResearchBonus = _researchBonus;

// Calculate effective level
private _effective = OpsRoom_AI_IntelBase 
    + OpsRoom_AI_IntelResearchBonus 
    + OpsRoom_AI_IntelTempBonus 
    + OpsRoom_AI_SpyIntelBonus;

// Clamp 0-100
_effective = (_effective max 0) min 100;

// Update global
OpsRoom_AI_IntelLevel = _effective;

_effective
