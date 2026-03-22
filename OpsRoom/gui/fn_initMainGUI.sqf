/*
    Operations Room - Main GUI Initialization
    
    Initializes the HUD display and starts update loops.
*/

// Display the HUD
cutRsc ["OpsRoom_HUD", "PLAIN"];

// Wait for display to be created
private _display = displayNull;
private _timeout = time + 5;
waitUntil {
    _display = uiNamespace getVariable ["OpsRoom_HUD_Display", displayNull];
    !isNull _display || time > _timeout
};

if (isNull _display) exitWith {
    systemChat "✗ Failed to create HUD display";
};

systemChat "✓ HUD Display created successfully";

// Initialize resources display
[] call OpsRoom_fnc_updateResources;

// NOTE: Buttons are created by fn_hideZeusUI.sqf when Zeus opens
// We don't create them here anymore as they need to be on Zeus display (312)

// Start unit info update loop
[] spawn {
    while {!isNull (uiNamespace getVariable ["OpsRoom_HUD_Display", displayNull])} do {
        [] call OpsRoom_fnc_updateUnitInfo;
        sleep OpsRoom_Settings_UnitInfoUpdateInterval;
    };
};

// Monitor Zeus display and refresh GUI when it opens/closes
[] spawn {
    private _wasZeusOpen = false;
    while {true} do {
        private _zeusDisplay = findDisplay 312;
        private _isZeusOpen = !isNull _zeusDisplay;
        
        if (_isZeusOpen != _wasZeusOpen) then {
            if (_isZeusOpen) then {
                systemChat "Zeus opened - refreshing GUI...";
                sleep 0.5;
                
                // NOTE: Buttons are now created by fn_hideZeusUI.sqf
                // which handles Zeus display (312) properly
            };
            _wasZeusOpen = _isZeusOpen;
        };
        
        sleep 1;
    };
};

systemChat "✓ GUI initialization complete";
