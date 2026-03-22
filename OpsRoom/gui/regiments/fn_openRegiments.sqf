/*
    Open Regiments Dialog
    
    Opens the regiment management interface and populates it with existing regiments.
    
    Usage:
        [] call OpsRoom_fnc_openRegiments;
*/

// Create dialog
createDialog "OpsRoom_RegimentDialog";

// Wait for dialog to be created
waitUntil {!isNull findDisplay 8000};

// Populate the grid
[] call OpsRoom_fnc_populateRegimentGrid;

// Debug
diag_log "[OpsRoom] Regiments dialog opened";
