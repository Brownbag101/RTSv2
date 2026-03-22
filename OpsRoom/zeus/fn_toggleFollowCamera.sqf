/*
    OpsRoom_fnc_toggleFollowCamera
    
    Toggles the follow camera mode on/off for the currently selected unit
    
    Parameters: none
    
    Returns: nothing
*/

diag_log "[OpsRoom] toggleFollowCamera called!";
systemChat "[DEBUG] Follow camera toggle clicked!";

private _curator = getAssignedCuratorLogic player;
if (isNull _curator) exitWith {
    hint "No curator logic found";
};

// Initialize if needed
if (isNil "OpsRoom_FollowCameraActive") then {
    OpsRoom_FollowCameraActive = false;
};

if (isNil "OpsRoom_FollowCameraTarget") then {
    OpsRoom_FollowCameraTarget = objNull;
};

// Toggle the state
OpsRoom_FollowCameraActive = !OpsRoom_FollowCameraActive;

if (OpsRoom_FollowCameraActive) then {
    // Get selected unit
    private _selected = curatorSelected select 0;
    
    if (count _selected == 0) exitWith {
        OpsRoom_FollowCameraActive = false;
        hint "No unit selected";
    };
    
    // Store target
    OpsRoom_FollowCameraTarget = _selected select 0;
    
    // Start follow loop
    [] spawn OpsRoom_fnc_followCameraLoop;
    
    systemChat format["Follow camera: ENABLED on %1", name OpsRoom_FollowCameraTarget];
    
    // Highlight the Follow button
    private _display = findDisplay 312;
    if (!isNull _display) then {
        // Find the Follow button (search through ability button range)
        for "_i" from 9350 to 9389 step 2 do {
            private _bg = _display displayCtrl _i;
            private _btn = _display displayCtrl (_i + 1);
            
            if (!isNull _btn) then {
                private _abilityID = _btn getVariable ["abilityID", ""];
                if (_abilityID == "followCamera") exitWith {
                    // Set active background color (green tint)
                    _bg ctrlSetBackgroundColor [0.25, 0.40, 0.25, 0.95];
                };
            };
        };
    };
} else {
    OpsRoom_FollowCameraTarget = objNull;
    systemChat "Follow camera: DISABLED";
    
    // Reset Follow button color
    private _display = findDisplay 312;
    if (!isNull _display) then {
        for "_i" from 9350 to 9389 step 2 do {
            private _bg = _display displayCtrl _i;
            private _btn = _display displayCtrl (_i + 1);
            
            if (!isNull _btn) then {
                private _abilityID = _btn getVariable ["abilityID", ""];
                if (_abilityID == "followCamera") exitWith {
                    // Reset to normal background
                    _bg ctrlSetBackgroundColor [0.15, 0.15, 0.15, 0.8];
                };
            };
        };
    };
};

// Update ability buttons to reflect new state
private _selected = curatorSelected select 0;
[_selected] call OpsRoom_fnc_updateContextButtons;
