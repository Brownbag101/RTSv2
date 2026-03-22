/*
    Operations Room - Hide Zeus UI
    
    Configures Zeus display to hide default UI elements while preserving
    unit selection boxes and camera functionality.
    Creates clickable buttons on Zeus display.
*/

// Wait for Zeus display to open
waitUntil {!isNull (findDisplay 312)};

private _zeusDisplay = findDisplay 312;

systemChat "Configuring Zeus interface...";

// Configure showHUD to hide most elements but keep selection boxes
showHUD [
    true,   // scriptedHUD - keep our custom HUD
    true,   // info - keep unit selection boxes (green/blue/red boxes)
    false,  // radar - hide minimap
    true,   // compass - keep compass
    false,  // direction - hide direction indicator
    false,  // menu - hide action menu
    false,  // group - hide group info
    false,  // cursors - hide aiming cursors
    false,  // panels - hide vehicle panels
    false,  // kills - hide kill messages
    true    // showIcon3D - KEEP 3D icons (needed for mission markers!)
];

// List of Zeus control IDs to keep visible
private _keepVisible = [
    50     // Main camera view - CRITICAL
];

// Our custom button IDCs (don't hide these!)
private _ourButtons = [
    9100, 9101, 9102, 9103, 9104, 9105, 9106, 9107, 9108, 9109,  // Left buttons (main)
    9200, 9201, 9202, 9203, 9204, 9205, 9206, 9207, 9208, 9209,  // Right buttons (main)
    9300, 9301, 9302, 9303, 9304, 9305, 9306, 9307, 9308, 9309,  // Standard buttons (stance/combat/speed/formation/behaviour)
    9310, 9311,                                                    // Regroup button (6th standard button)
    9320, 9321,                                                    // Date/time display
    9330, 9331, 9332, 9333, 9334, 9335                            // Speed controls (moved from 9310-9314)
];

// Ability buttons (9350-9389) - dynamic range (moved from 9310-9349)
for "_i" from 9350 to 9389 do {
    _ourButtons pushBack _i;
};

// Menu buttons (9400-9449) - dynamic range for expandable menus
for "_i" from 9400 to 9449 do {
    _ourButtons pushBack _i;
};

_keepVisible append _ourButtons;

// Hide all Zeus controls except camera view and our buttons
{
    private _ctrl = _x;
    private _ctrlID = ctrlIDC _ctrl;
    
    // Keep camera view and our buttons, hide everything else
    if !(_ctrlID in _keepVisible) then {
        _ctrl ctrlShow false;
    };
} forEach (allControls _zeusDisplay);

systemChat "✓ Zeus UI configured";

// Create our custom buttons on the Zeus display
systemChat "Creating buttons...";
[] call OpsRoom_fnc_createButtonsOnZeus;
// Note: createRegroupButton removed - regroup is now a context-aware ability

// Create date/time display and speed controls
[] call OpsRoom_fnc_createDateTimeDisplay;
[] call OpsRoom_fnc_createSpeedControls;

// Maintain configuration (other systems might try to change it)
[] spawn {
    while {!isNull (findDisplay 312)} do {
        showHUD [
            true,   // scriptedHUD
            true,   // info (selection boxes)
            false,  // radar
            true,   // compass
            false,  // direction
            false,  // menu
            false,  // group
            false,  // cursors
            false,  // panels
            false,  // kills
            true    // showIcon3D - KEEP enabled!
        ];
        
        sleep OpsRoom_Settings_ZeusCheckInterval;
    };
};

// Monitor Zeus close/open and recreate buttons if needed
[] spawn {
    private _lastZeusState = false;
    while {true} do {
        private _zeusOpen = !isNull (findDisplay 312);
        
        // If Zeus just opened, recreate buttons
        if (_zeusOpen && !_lastZeusState) then {
            systemChat "Zeus reopened - recreating buttons...";
            sleep 0.5; // Wait for display to fully initialize
            [] call OpsRoom_fnc_createButtonsOnZeus;
            [] call OpsRoom_fnc_createStandardButtons;  // Recreate standard buttons
            [] call OpsRoom_fnc_createDateTimeDisplay;
            [] call OpsRoom_fnc_createSpeedControls;
        };
        
        _lastZeusState = _zeusOpen;
        sleep 1;
    };
};
