/*
    OpsRoom_fnc_cancelAimedShotTargeting
    
    Full cleanup for Aimed Shot. Called on:
        - ESC while menu is open (player cancels)
        - Shooter/target validation failure
        - After the shot resolves (normal completion)
    
    Cleans up:
        - Draw3D handler (crosshair + hit % markers)
        - missionNamespace marker variables
        - All OpsRoom_AimedShot_* globals
        - Restores game speed if it hasn't been restored yet
*/

// --- REMOVE DRAW3D HANDLER ---
if (!isNil "OpsRoom_AimedShot_DrawHandler") then {
    removeMissionEventHandler ["Draw3D", OpsRoom_AimedShot_DrawHandler];
    OpsRoom_AimedShot_DrawHandler = nil;
};

// --- REMOVE ESC/MOUSE HANDLERS ---
private _display = findDisplay 312;
if (!isNull _display) then {
    if (!isNil "OpsRoom_AimedShot_ESCHandler") then {
        _display displayRemoveEventHandler ["KeyDown", OpsRoom_AimedShot_ESCHandler];
        OpsRoom_AimedShot_ESCHandler = nil;
    };
    if (!isNil "OpsRoom_AimedShot_MouseHandler") then {
        _display displayRemoveEventHandler ["MouseButtonDown", OpsRoom_AimedShot_MouseHandler];
        OpsRoom_AimedShot_MouseHandler = nil;
    };
};

// --- CLEAR MISSIONNAMESPACE MARKER DATA ---
missionNamespace setVariable ["OpsRoom_AimedShot_Markers_Active", false];
missionNamespace setVariable ["OpsRoom_AimedShot_Markers_Data", []];

// --- CLOSE THE MENU ---
[] call OpsRoom_fnc_closeButtonMenu;

// --- RESTORE GAME SPEED (safety net) ---
// executeAimedShot restores speed itself after the shot, but if we're
// cancelling early (ESC / validation fail) we must restore here.
if (!isNil "OpsRoom_AimedShot_PreviousSpeed") then {
    private _restoreSpeed = OpsRoom_AimedShot_PreviousSpeed;
    setTimeMultiplier _restoreSpeed;
    setAccTime _restoreSpeed;
    OpsRoom_CurrentSpeed = _restoreSpeed;

    // Update speed button highlights
    private _display = findDisplay 312;
    if (!isNull _display) then {
        private _speeds = [
            [9331, 0.1],
            [9332, 0.5],
            [9333, 1],
            [9334, 2],
            [9335, 4]
        ];
        {
            _x params ["_idc", "_mult"];
            private _btn = _display displayCtrl _idc;
            if (!isNull _btn) then {
                if (_mult == _restoreSpeed) then {
                    _btn ctrlSetBackgroundColor [0.75, 0.65, 0.45, 1];
                } else {
                    _btn ctrlSetBackgroundColor [0.25, 0.22, 0.18, 0.8];
                };
                _btn ctrlCommit 0;
            };
        } forEach _speeds;
    };
};

// --- RESTORE BEHAVIOR ---
if (!isNil "OpsRoom_AimedShot_Shooter" && {!isNil "OpsRoom_AimedShot_OriginalBehavior"}) then {
    private _shooter = OpsRoom_AimedShot_Shooter;
    private _originalBehavior = OpsRoom_AimedShot_OriginalBehavior;
    if (!isNull _shooter && {_originalBehavior == "CARELESS"}) then {
        _shooter setBehaviour "CARELESS";
        diag_log format ["[OpsRoom] AimedShot: %1 restored to CARELESS (cancelled)", name _shooter];
    };
};

// --- CLEAR ALL GLOBALS ---
OpsRoom_AimedShot_Shooter = nil;
OpsRoom_AimedShot_EnemyData = nil;
OpsRoom_AimedShot_SelectedIndex = nil;
OpsRoom_AimedShot_PreviousSpeed = nil;
OpsRoom_AimedShot_OriginalBehavior = nil;

diag_log "[OpsRoom] AimedShot: cleanup complete";
