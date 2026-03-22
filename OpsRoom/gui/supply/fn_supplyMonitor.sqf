/*
    Supply Monitor
    
    Background loop that checks active shipment timers.
    When delivery time expires, calls deliverItems to spawn them.
    Cleans up completed shipments.
    
    Runs every 10 seconds.
    
    Usage:
        [] spawn OpsRoom_fnc_supplyMonitor;
*/

diag_log "[OpsRoom] Supply monitor started";

while {true} do {
    private _activeShipments = missionNamespace getVariable ["OpsRoom_ActiveShipments", []];
    private _completedIndices = [];
    
    {
        _x params ["_items", "_startTime", "_deliveryTime"];
        
        private _elapsed = time - _startTime;
        private _totalSecs = _deliveryTime * 60;
        
        if (_elapsed >= _totalSecs) then {
            // Deliver!
            [_items] call OpsRoom_fnc_deliverItems;
            _completedIndices pushBack _forEachIndex;
        };
    } forEach _activeShipments;
    
    // Remove completed shipments (reverse order to preserve indices)
    if (count _completedIndices > 0) then {
        _completedIndices sort false;  // Descending
        {
            _activeShipments deleteAt _x;
        } forEach _completedIndices;
        missionNamespace setVariable ["OpsRoom_ActiveShipments", _activeShipments];
    };
    
    sleep 10;
};
