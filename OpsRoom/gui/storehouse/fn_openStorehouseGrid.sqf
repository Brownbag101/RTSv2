/*
    Open Storehouse Grid
    
    Opens the storehouse selection interface showing all supply depots.
    Click a storehouse to enter its interior.
    
    Usage:
        [] call OpsRoom_fnc_openStorehouseGrid;
*/

createDialog "OpsRoom_StorehouseGridDialog";
waitUntil {!isNull findDisplay 11006};

[] call OpsRoom_fnc_populateStorehouseGrid;

diag_log "[OpsRoom] Storehouse grid opened";
