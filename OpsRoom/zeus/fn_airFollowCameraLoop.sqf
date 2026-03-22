/*
    OpsRoom_fnc_airFollowCameraLoop
    
    Follow camera loop tuned for aircraft speed.
    Camera jumps 200m ahead of the aircraft in its direction of travel,
    then tracks it. Repositions when the aircraft is 200m away.
    
    Uses same BIS_fnc_setCuratorCamera pattern as ground follow camera.
    
    Parameters: none (reads OpsRoom_AirFollowCameraActive / OpsRoom_AirFollowCameraTarget)
    
    Returns: nothing
*/

private _lastCameraPos = [0,0,0];
private _needsInitialPosition = true;

while {OpsRoom_AirFollowCameraActive} do {
    // Check Zeus display still exists
    private _display = findDisplay 312;
    if (isNull _display) exitWith {
        OpsRoom_AirFollowCameraActive = false;
        systemChat "Air follow camera: DISABLED (Zeus closed)";
    };
    
    // Check target still valid
    if (isNull OpsRoom_AirFollowCameraTarget || {!alive OpsRoom_AirFollowCameraTarget}) exitWith {
        OpsRoom_AirFollowCameraActive = false;
        systemChat "Air follow camera: DISABLED (aircraft lost)";
    };
    
    private _target = OpsRoom_AirFollowCameraTarget;
    private _targetPos = getPosASL _target;
    
    // Aircraft-tuned parameters
    private _followDistance = 200;   // 200m ahead
    private _followHeight = 40;     // Slightly above
    private _triggerDistance = 200;  // Reposition when 200m away
    private _transitionTime = 3;    // Faster transitions for aircraft speed
    
    // Check if we need to reposition camera
    private _shouldReposition = false;
    
    if (_needsInitialPosition) then {
        _shouldReposition = true;
        _needsInitialPosition = false;
    } else {
        private _distanceFromCamera = _lastCameraPos distance _targetPos;
        if (_distanceFromCamera > _triggerDistance) then {
            _shouldReposition = true;
        };
    };
    
    if (_shouldReposition) then {
        // Position camera AHEAD of aircraft in its direction of travel
        private _targetDir = getDir _target;
        private _offsetX = _followDistance * sin _targetDir;
        private _offsetY = _followDistance * cos _targetDir;
        
        private _cameraPos = _targetPos vectorAdd [_offsetX, _offsetY, _followHeight];
        
        [_cameraPos, _target, _transitionTime] call BIS_fnc_setCuratorCamera;
        _lastCameraPos = _cameraPos;
    } else {
        // Keep tracking the target smoothly
        [_lastCameraPos, _target, 2] call BIS_fnc_setCuratorCamera;
    };
    
    // Check frequently — aircraft move fast
    sleep 0.5;
};

// Clean up
OpsRoom_AirFollowCameraTarget = objNull;
