/*
    OpsRoom_fnc_followCameraLoop
    
    Main follow camera loop - leapfrogs ahead of target every 50m
    
    Parameters: none
    
    Returns: nothing
*/

// Initialize camera position on first frame
private _lastCameraPos = [0,0,0];
private _needsInitialPosition = true;

while {OpsRoom_FollowCameraActive} do {
    // Check Zeus display still exists
    private _display = findDisplay 312;
    if (isNull _display) exitWith {
        OpsRoom_FollowCameraActive = false;
        systemChat "Follow camera: DISABLED (Zeus closed)";
    };
    
    // Check target still valid
    if (isNull OpsRoom_FollowCameraTarget || {!alive OpsRoom_FollowCameraTarget}) exitWith {
        OpsRoom_FollowCameraActive = false;
        systemChat "Follow camera: DISABLED (target invalid)";
    };
    
    // Get target position
    private _target = OpsRoom_FollowCameraTarget;
    private _targetPos = getPosASL _target;
    
    // Check if target is in vehicle
    private _targetVehicle = vehicle _target;
    if (_targetVehicle != _target) then {
        // Following vehicle instead
        _targetPos = getPosASL _targetVehicle;
    };
    
    // Calculate camera position based on target type
    private _followDistance = 50;  // Position 50m ahead
    private _followHeight = 15;
    private _triggerDistance = 50; // Move when unit gets 50m away from camera
    
    // Adjust for vehicles
    if (_targetVehicle != _target) then {
        _followDistance = 60;
        _followHeight = 20;
        _triggerDistance = 60;
        
        // Further adjust for aircraft
        if (_targetVehicle isKindOf "Air") then {
            _followDistance = 100;
            _followHeight = 30;
            _triggerDistance = 80;
        };
    };
    
    // Check if we need to reposition camera
    private _shouldReposition = false;
    
    if (_needsInitialPosition) then {
        _shouldReposition = true;
        _needsInitialPosition = false;
    } else {
        // Check distance from last camera position to target
        private _distanceFromCamera = _lastCameraPos distance _targetPos;
        
        if (_distanceFromCamera > _triggerDistance) then {
            _shouldReposition = true;
            systemChat format["Camera repositioning (target %1m away)", round _distanceFromCamera];
        };
    };
    
    // Reposition if needed
    if (_shouldReposition) then {
        // Position camera AHEAD of target in their direction of travel
        private _targetDir = getDir _target;
        private _offsetX = _followDistance * sin _targetDir;
        private _offsetY = _followDistance * cos _targetDir;
        
        private _cameraPos = _targetPos vectorAdd [_offsetX, _offsetY, _followHeight];
        
        // Use BIS_fnc_setCuratorCamera for smooth transition
        // Parameters: [position, target, transition_time]
        [_cameraPos, _target, 6] call BIS_fnc_setCuratorCamera;
        
        // Store this position
        _lastCameraPos = _cameraPos;
    } else {
        // Just keep looking at target (update target reference slowly)
        [_lastCameraPos, _target, 5] call BIS_fnc_setCuratorCamera;
    };
    
    // Check less frequently since transitions are long
    sleep 1;
};

// Clean up when exiting
OpsRoom_FollowCameraTarget = objNull;
