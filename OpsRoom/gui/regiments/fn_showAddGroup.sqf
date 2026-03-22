/*
    Show Add Group Dialog
    
    Opens the Captain selection dialog to choose a commanding officer for the new group.
    
    Parameters:
        0: STRING - Regiment ID
    
    Usage:
        ["regiment_1"] call OpsRoom_fnc_showAddGroup;
*/

params [
    ["_regimentId", "", [""]]
];

if (_regimentId == "") exitWith {
    hint "Error: No regiment ID provided";
};

// Get available Captains
private _availableCaptains = [_regimentId] call OpsRoom_fnc_getAvailableCaptains;

if (count _availableCaptains == 0) exitWith {
    hint "No available Captains in this regiment!";
};

// Open captain selection dialog
closeDialog 0;
[_regimentId] call OpsRoom_fnc_openCaptainSelect;
