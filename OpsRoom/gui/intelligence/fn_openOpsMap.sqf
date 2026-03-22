/*
    fn_openOpsMap
    
    Opens the Operational Map dialog.
    Places clickable location buttons over map positions.
    Updates status bar with location counts.
*/

// Create the dialog
createDialog "OpsRoom_OpsMapDialog";
waitUntil {!isNull findDisplay 8010};

private _display = findDisplay 8010;

// Setup Refresh button
private _refreshBtn = _display displayCtrl 11503;
if (!isNull _refreshBtn) then {
    _refreshBtn ctrlAddEventHandler ["ButtonClick", {
        [] spawn {
            closeDialog 0;
            sleep 0.1;
            [] call OpsRoom_fnc_openOpsMap;
        };
    }];
};

// Setup Legend button
private _legendBtn = _display displayCtrl 11502;
if (!isNull _legendBtn) then {
    _legendBtn ctrlAddEventHandler ["ButtonClick", {
        hint parseText (
            "<t size='1.2' font='PuristaBold'>MAP LEGEND</t><br/><br/>" +
            "<t color='#FF4444'>? = Detected (unknown type)</t><br/>" +
            "<t color='#FF4444'>● = Enemy location (identified)</t><br/>" +
            "<t color='#4488FF'>● = Friendly location</t><br/>" +
            "<t color='#FFFF44'>● = Contested</t><br/>" +
            "<t color='#888888'>X = Destroyed</t><br/><br/>" +
            "<t size='0.9'>Intel tiers: Detected → Identified → Observed → Detailed → Compromised</t>"
        );
    }];
};

// Get the map control
private _mapCtrl = _display displayCtrl 11500;

// Centre map on the island
if (!isNull _mapCtrl) then {
    // Get world centre and size for initial map view
    private _worldSize = worldSize;
    private _centre = [_worldSize / 2, _worldSize / 2];
    
    _mapCtrl ctrlMapAnimAdd [0.5, 0.05, _centre];
    ctrlMapAnimCommit _mapCtrl;
};

// Draw sea lanes on the map
[_mapCtrl] call OpsRoom_fnc_drawSeaLanes;

// Add map click handler for location selection
_mapCtrl ctrlAddEventHandler ["MouseButtonClick", {
    params ["_ctrl", "_button", "_xPos", "_yPos", "_shift", "_ctrlKey", "_alt"];
    
    // Only left click
    if (_button != 0) exitWith {};
    
    // Convert screen position to world position
    private _worldPos = _ctrl ctrlMapScreenToWorld [_xPos, _yPos];
    
    // Find closest location to click within 800m
    private _bestLoc = "";
    private _bestDist = 800;
    
    {
        private _locId = _x;
        private _locData = _y;
        private _locPos = _locData get "pos";
        private _tier = _locData get "intelTier";
        
        // Only clickable if discovered (tier 1+)
        if (_tier > 0 || (_locData get "status") != "enemy") then {
            private _dist = _worldPos distance2D _locPos;
            if (_dist < _bestDist) then {
                _bestDist = _dist;
                _bestLoc = _locId;
            };
        };
    } forEach OpsRoom_StrategicLocations;
    
    // Found a location? Show intel card
    if (_bestLoc != "") then {
        [_bestLoc] call OpsRoom_fnc_showIntelCard;
    };
}];

// Update status bar
private _totalLocs = count OpsRoom_StrategicLocations;
private _discovered = 0;
private _friendly = 0;
private _destroyed = 0;

{
    private _locData = _y;
    if (_locData get "discovered") then { _discovered = _discovered + 1 };
    if ((_locData get "status") == "friendly") then { _friendly = _friendly + 1 };
    if ((_locData get "status") == "destroyed") then { _destroyed = _destroyed + 1 };
} forEach OpsRoom_StrategicLocations;

private _statusCtrl = _display displayCtrl 11501;
if (!isNull _statusCtrl) then {
    private _statusText = format [
        "<t align='center'>Locations: %1  |  Discovered: %2  |  Friendly: %3  |  Destroyed: %4  |  Unknown: %5</t>",
        _totalLocs,
        _discovered,
        _friendly,
        _destroyed,
        _totalLocs - _discovered
    ];
    _statusCtrl ctrlSetStructuredText parseText _statusText;
};

systemChat "Operational Map opened";
