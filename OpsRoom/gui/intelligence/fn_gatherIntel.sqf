/*
    fn_gatherIntel
    
    Calculates intel gain for a location based on nearby friendly GROUND units.
    Called by the intel monitor every tick (~30 seconds).
    
    Aerial reconnaissance is handled separately by fn_photoReconMonitor
    and fn_processReconPhotos (intel applied on landing).
    
    Parameters:
        0: STRING - Location ID
    
    Returns: NUMBER - Intel percentage gained this tick
    
    Rules:
        - Regular infantry: +2% per tick, caps at 44% (tier 2)
        - Recon-trained units: +4% per tick, caps at 69% (tier 3)
        - SOE agents: +6% per tick, can reach 100% (tier 5)
        - Distance: full rate < 200m, half 200-400m, quarter 400-600m
        - Best rate used (not cumulative)
        - Intel decays slowly if no friendly units nearby (-0.5% per tick, min stays at tier threshold)
*/

params [["_locId", "", [""]]];

if (_locId == "") exitWith { 0 };

private _locData = OpsRoom_StrategicLocations getOrDefault [_locId, createHashMap];
if (count _locData == 0) exitWith { 0 };

private _pos = _locData get "pos";
private _currentPercent = _locData get "intelPercent";
private _status = _locData get "status";

// Don't gather intel on friendly locations (already known)
if (_status == "friendly") exitWith { 0 };

// Scan for friendly GROUND units within 600m (excludes air — handled by recon system)
private _nearUnits = _pos nearEntities [["Man", "Car", "Tank"], 600];
private _friendlyUnits = _nearUnits select { side group _x == side player };

// No friendlies nearby? Intel decays slowly
if (count _friendlyUnits == 0) exitWith {
    // Decay: -0.5% per tick, minimum stays at last tier threshold
    private _decay = -0.5;
    private _newPercent = (_currentPercent + _decay) max 0;
    
    // Don't decay below tier thresholds once reached
    private _currentTier = [_currentPercent] call OpsRoom_fnc_getIntelLevel;
    private _tierMinimums = [0, 1, 20, 45, 70, 90];
    private _minPercent = _tierMinimums select _currentTier;
    _newPercent = _newPercent max _minPercent;
    
    _newPercent - _currentPercent
};

// Find the best intel gatherer nearby
private _bestRate = 0;
private _bestCap = 44;  // Default cap for regular units (tier 2)

{
    private _unit = _x;
    if (!alive _unit) then { continue };
    
    // Skip units in aircraft (aerial recon handled separately)
    if (vehicle _unit != _unit && {(vehicle _unit) isKindOf "Air"}) then { continue };
    
    private _dist = _pos distance2D (getPosATL _unit);
    
    // Determine unit intel capability
    private _baseRate = 2;   // Regular infantry
    private _cap = 44;       // Regular cap (tier 2 max)
    
    // Check for recon training
    private _trainedCourses = _unit getVariable ["OpsRoom_TrainedCourses", []];
    
    if ("recon" in _trainedCourses || "sas" in _trainedCourses) then {
        _baseRate = 4;
        _cap = 69;   // Recon cap (tier 3 max)
    };
    
    // SOE agents
    if ("soe" in _trainedCourses) then {
        _baseRate = 6;
        _cap = 100;  // Full intel (tier 5)
    };
    
    // Distance modifier
    private _distMod = if (_dist < 200) then { 1.0 }
        else { if (_dist < 400) then { 0.5 }
        else { 0.25 }};
    
    private _effectiveRate = _baseRate * _distMod;
    
    // Take the best rate and highest cap
    if (_effectiveRate > _bestRate) then {
        _bestRate = _effectiveRate;
    };
    if (_cap > _bestCap) then {
        _bestCap = _cap;
    };
    
} forEach _friendlyUnits;

// Apply rate, respecting cap
private _newPercent = (_currentPercent + _bestRate) min _bestCap;
private _gain = _newPercent - _currentPercent;

// Mark as discovered if first contact
if (!(_locData get "discovered") && _gain > 0) then {
    _locData set ["discovered", true];
    OpsRoom_StrategicLocations set [_locId, _locData];
    
    ["PRIORITY", "CONTACT", format ["New location detected near grid %1!", mapGridPosition (_locData get "pos")], _locData get "pos"] call OpsRoom_fnc_dispatch;
};

_gain
