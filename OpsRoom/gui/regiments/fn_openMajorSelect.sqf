/*
    Open Major Selection Dialog
    
    Shows dialog to select a Major for a new regiment from available units.
    Similar to captain selection but for Majors.
    
    Parameters:
        None
    
    Usage:
        [] call OpsRoom_fnc_openMajorSelect;
*/

// Create dialog
createDialog "OpsRoom_MajorSelectDialog";
waitUntil {!isNull findDisplay 8010};

private _display = findDisplay 8010;

// Populate the grid with available majors
[] call OpsRoom_fnc_populateMajorGrid;

diag_log "[OpsRoom] Major selection dialog opened";
