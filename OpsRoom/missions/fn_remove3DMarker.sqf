/*
    Remove 3D Marker
    
    Removes a Draw3D marker by clearing its data variable.
    The handler will auto-remove itself when it detects no data.
    
    Parameters:
        0: STRING - Marker ID to remove
    
    Usage:
        ["myMarker"] call OpsRoom_fnc_remove3DMarker;
*/

params [
    ["_markerId", "", [""]]
];

if (_markerId == "") exitWith {
    diag_log "[OpsRoom] Cannot remove 3D marker: no ID provided";
};

// Clear the marker data - handler will auto-remove itself
private _markerVarName = format ["OpsRoom_3DMarker_%1", _markerId];
missionNamespace setVariable [_markerVarName, nil];

diag_log format ["[OpsRoom] 3D Marker data cleared: %1", _markerId];
