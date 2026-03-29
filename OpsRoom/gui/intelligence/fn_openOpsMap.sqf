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

// ========================================
// COMMAND INTELLIGENCE PANEL
// ========================================
// Hide panel by default
private _intelPanelBg = _display displayCtrl 11510;
private _intelPanelTitle = _display displayCtrl 11511;
private _intelPanelBody = _display displayCtrl 11512;

_intelPanelBg ctrlShow false;
_intelPanelTitle ctrlShow false;
_intelPanelBody ctrlShow false;

// Intelligence button toggles the panel
private _intelBtn = _display displayCtrl 11504;
if (!isNull _intelBtn) then {
    _intelBtn ctrlAddEventHandler ["ButtonClick", {
        private _display = findDisplay 8010;
        private _bg = _display displayCtrl 11510;
        private _title = _display displayCtrl 11511;
        private _body = _display displayCtrl 11512;
        private _map = _display displayCtrl 11500;
        
        private _visible = ctrlShown _bg;
        
        if (_visible) then {
            // Hide panel, restore full map width
            _bg ctrlShow false;
            _title ctrlShow false;
            _body ctrlShow false;
            _map ctrlSetPosition [
                0.05 * safezoneW + safezoneX,
                0.09 * safezoneH + safezoneY,
                0.90 * safezoneW,
                0.82 * safezoneH
            ];
            _map ctrlCommit 0.2;
        } else {
            // Show panel, shrink map
            _bg ctrlShow true;
            _title ctrlShow true;
            _body ctrlShow true;
            _map ctrlSetPosition [
                0.05 * safezoneW + safezoneX,
                0.09 * safezoneH + safezoneY,
                0.67 * safezoneW,
                0.82 * safezoneH
            ];
            _map ctrlCommit 0.2;
            
            // Populate intel panel
            private _intel = if (!isNil "OpsRoom_AI_IntelLevel") then { [] call OpsRoom_fnc_getCommandIntelLevel } else { 0 };
            private _base = if (!isNil "OpsRoom_AI_IntelBase") then { OpsRoom_AI_IntelBase } else { 10 };
            private _research = if (!isNil "OpsRoom_AI_IntelResearchBonus") then { OpsRoom_AI_IntelResearchBonus } else { 0 };
            private _temp = if (!isNil "OpsRoom_AI_IntelTempBonus") then { OpsRoom_AI_IntelTempBonus } else { 0 };
            private _spy = if (!isNil "OpsRoom_AI_SpyIntelBonus") then { OpsRoom_AI_SpyIntelBonus } else { 0 };
            
            // Intel level colour
            private _intelColor = if (_intel >= 80) then { "#66FF66" } else {
                if (_intel >= 60) then { "#FFFF44" } else {
                    if (_intel >= 30) then { "#FF8844" } else { "#FF4444" }
                }
            };
            
            // Rating text
            private _ratingText = if (_intel >= 80) then { "EXCELLENT" } else {
                if (_intel >= 60) then { "GOOD" } else {
                    if (_intel >= 30) then { "PARTIAL" } else { "MINIMAL" }
                }
            };
            
            // Build breakdown text
            private _text = format [
                "<t size='1.3' color='%1'>%2%%</t><br/>" +
                "<t size='0.9' color='%1'>%3</t><br/><br/>" +
                "<t size='1.0' color='#D9D5C9'>SOURCES</t><br/>" +
                "<t size='0.9'>Frontline Observation: %4%%</t><br/>" +
                "<t size='0.9'>Signals Intelligence: %5%%</t><br/>" +
                "<t size='0.9'>Field Intelligence: %6%%</t><br/>" +
                "<t size='0.9'>Spy Network: %7%%</t><br/><br/>",
                _intelColor, round _intel, _ratingText,
                round _base, round _research, round _temp, round _spy
            ];
            
            // Visibility breakdown
            _text = _text + "<t size='1.0' color='#D9D5C9'>VISIBILITY</t><br/>";
            _text = _text + format ["<t size='0.9'>Enemy Dispatches: %1</t><br/>",
                if (_intel >= 60) then { "<t color='#66FF66'>FULL</t>" } else {
                    if (_intel >= 30) then { "<t color='#FFFF44'>VAGUE</t>" } else { "<t color='#FF4444'>NONE</t>" }
                }
            ];
            _text = _text + format ["<t size='0.9'>Troop Markers: %1</t><br/>",
                if (_intel >= 80) then { "<t color='#66FF66'>FULL DETAIL</t>" } else {
                    if (_intel >= 50) then { "<t color='#FFFF44'>NEARBY ONLY</t>" } else { "<t color='#FF4444'>NONE</t>" }
                }
            ];
            _text = _text + format ["<t size='0.9'>Map Movements: %1</t><br/>",
                if (_intel >= 80) then { "<t color='#66FF66'>ROUTES SHOWN</t>" } else {
                    if (_intel >= 60) then { "<t color='#FFFF44'>POSITIONS ONLY</t>" } else { "<t color='#FF4444'>NONE</t>" }
                }
            ];
            _text = _text + format ["<t size='0.9'>Manpower Estimate: %1</t><br/><br/>",
                if (_intel >= 100) then { "<t color='#66FF66'>EXACT</t>" } else {
                    if (_intel >= 80) then { "<t color='#FFFF44'>ESTIMATED</t>" } else { "<t color='#FF4444'>UNKNOWN</t>" }
                }
            ];
            
            // Manpower display if available
            if (_intel >= 80 && !isNil "OpsRoom_AI_Manpower") then {
                private _mp = OpsRoom_AI_Manpower;
                if (_intel >= 100) then {
                    _text = _text + format ["<t size='1.0' color='#D9D5C9'>ENEMY MANPOWER</t><br/><t size='1.2' color='#FF6644'>%1</t><br/><br/>", _mp];
                } else {
                    private _fuzz = (_mp * 0.2) max 5;
                    _text = _text + format ["<t size='1.0' color='#D9D5C9'>EST. ENEMY MANPOWER</t><br/><t size='1.2' color='#FF6644'>%1 - %2</t><br/><br/>", round ((_mp - _fuzz) max 0), round (_mp + _fuzz)];
                };
            };
            
            // Tips
            _text = _text + "<t size='1.0' color='#D9D5C9'>HOW TO IMPROVE</t><br/>";
            _text = _text + "<t size='0.85'>- Capture enemy locations (+5%%)</t><br/>";
            _text = _text + "<t size='0.85'>- Capture intact radios (+3%%)</t><br/>";
            _text = _text + "<t size='0.85'>- Research Signals Intelligence</t><br/>";
            _text = _text + "<t size='0.85'>- Deploy spies (coming soon)</t><br/>";
            
            // Active groups count at max intel
            if (_intel >= 80 && !isNil "OpsRoom_AI_ActiveGroups") then {
                _text = _text + format ["<br/><t size='1.0' color='#D9D5C9'>ENEMY ACTIVE GROUPS</t><br/><t size='1.2' color='#FF6644'>%1</t>", count OpsRoom_AI_ActiveGroups];
            };
            
            _body ctrlSetStructuredText parseText _text;
        };
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
