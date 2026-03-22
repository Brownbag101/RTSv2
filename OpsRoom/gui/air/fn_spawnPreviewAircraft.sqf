/*
    Spawn Preview Aircraft
    
    Spawns an aircraft at the hangar marker for 3D inspection.
    Deletes any previous preview first.
    Camera moves to look at it.
    
    Parameters:
        _hangarId - Hangar ID to preview
*/
params ["_hangarId"];

private _entry = OpsRoom_Hangar get _hangarId;
if (isNil "_entry") exitWith {
    systemChat "Aircraft not found in hangar";
};

// Check hangar marker exists
if (markerType "OpsRoom_hangar" == "") exitWith {
    systemChat "No OpsRoom_hangar marker placed in editor";
};

// Delete previous preview
if (!isNull OpsRoom_HangarPreview) then {
    deleteVehicle OpsRoom_HangarPreview;
    OpsRoom_HangarPreview = objNull;
};

// Get spawn position from marker
private _spawnPos = getMarkerPos "OpsRoom_hangar";
_spawnPos set [2, 0];

// Spawn the aircraft
private _className = _entry get "className";
private _vehicle = createVehicle [_className, _spawnPos, [], 0, "NONE"];
_vehicle setPos _spawnPos;
_vehicle setDir (markerDir "OpsRoom_hangar");
_vehicle engineOn false;
_vehicle setFuel 0;  // Prevent AI from flying it off
_vehicle lock 2;

// Apply damage/fuel state visually
_vehicle setDamage (_entry get "damage");

OpsRoom_HangarPreview = _vehicle;

// Move Zeus camera to look at it
private _curator = getAssignedCuratorLogic player;
if (!isNull _curator) then {
    private _camPos = _spawnPos vectorAdd [10, 10, 6];
    _curator setCuratorCameraAreaCeiling 500;
    curatorCamera setPosASL (AGLToASL _camPos);
    curatorCamera setVectorDirAndUp [
        (AGLToASL _spawnPos) vectorDiff (AGLToASL _camPos) call BIS_fnc_unitVector,
        [0,0,1]
    ];
};

systemChat format ["Preview: %1", _entry get "displayName"];

diag_log format ["[OpsRoom] Air: Spawned preview of %1 at hangar", _entry get "displayName"];
