/*
    OpsRoom_fnc_airStrike_cleanup
    
    Removes Draw3D marker and associated variables after an air strike.
    
    Parameters:
        0: STRING - marker ID
*/

params ["_markerID"];

// Deactivate marker
missionNamespace setVariable [_markerID + "_active", false];

// Remove Draw3D handler
private _handler = missionNamespace getVariable [_markerID + "_drawHandler", -1];
if (_handler >= 0) then {
    removeMissionEventHandler ["Draw3D", _handler];
};

// Clean up variables
missionNamespace setVariable [_markerID + "_pos", nil];
missionNamespace setVariable [_markerID + "_type", nil];
missionNamespace setVariable [_markerID + "_active", nil];
missionNamespace setVariable [_markerID + "_drawHandler", nil];
missionNamespace setVariable ["OpsRoom_AirStrike_ActiveMarker", nil];

diag_log format ["[OpsRoom] AirStrike marker cleaned up: %1", _markerID];
