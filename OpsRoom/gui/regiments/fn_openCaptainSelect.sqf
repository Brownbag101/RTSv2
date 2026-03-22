/*
    Open Captain Selection Dialog
    
    Shows available Captains in a grid for player selection.
    Player chooses which Captain will lead the new group.
    
    Parameters:
        0: STRING - Regiment ID
    
    Usage:
        ["regiment_1"] call OpsRoom_fnc_openCaptainSelect;
*/

params [
    ["_regimentId", "", [""]]
];

if (_regimentId == "") exitWith {
    hint "Error: No regiment ID provided";
};

// Store regiment ID for use when creating group
uiNamespace setVariable ["OpsRoom_SelectedRegiment", _regimentId];

// Create dialog
createDialog "OpsRoom_CaptainSelectDialog";
waitUntil {!isNull findDisplay 8004};

// Populate captain grid
[_regimentId] call OpsRoom_fnc_populateCaptainGrid;

diag_log format ["[OpsRoom] Captain selection opened for regiment: %1", _regimentId];
