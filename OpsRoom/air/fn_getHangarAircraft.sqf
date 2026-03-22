/*
    Air Operations - Get Hangar Aircraft
    
    Query the hangar pool with optional filters.
    
    Parameters:
        _filterType   - Aircraft type filter ("" for all, or "Fighter", "GroundAttack", "Bomber", "Recon")
        _filterStatus - Status filter ("" for all, or "HANGARED", "READY", "AIRBORNE", etc.)
        _filterWing   - Wing filter ("" for all, "UNASSIGNED" for no wing, or specific wing ID)
    
    Returns:
        Array of [hangarId, entryHashMap] pairs
*/
params [["_filterType", ""], ["_filterStatus", ""], ["_filterWing", ""]];

private _results = [];

{
    private _hangarId = _x;
    private _entry = _y;
    
    private _match = true;
    
    // Type filter
    if (_filterType != "" && {(_entry get "aircraftType") != _filterType}) then {
        _match = false;
    };
    
    // Status filter
    if (_match && {_filterStatus != ""} && {(_entry get "status") != _filterStatus}) then {
        _match = false;
    };
    
    // Wing filter
    if (_match && {_filterWing != ""}) then {
        private _wingId = _entry get "wingId";
        if (_filterWing == "UNASSIGNED") then {
            if (_wingId != "") then { _match = false };
        } else {
            if (_wingId != _filterWing) then { _match = false };
        };
    };
    
    if (_match) then {
        _results pushBack [_hangarId, _entry];
    };
} forEach OpsRoom_Hangar;

_results
