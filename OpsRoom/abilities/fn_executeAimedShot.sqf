/*
    OpsRoom_fnc_executeAimedShot
    
    Executes the aimed shot after player selected a target from the menu.
    
    Flow:
        1. Close menu, remove Draw3D markers immediately (target is chosen)
        2. Read selected target index from OpsRoom_AimedShot_SelectedIndex
        3. Validate shooter + target still alive
        4. Restore game speed NOW (camera transition + shot must play at normal speed)
        5. Transition camera to focus on the target enemy (2s smooth move)
        6. Wait for camera to settle (real-time wait via diag_tickTime)
        7. Command the unit to face and fire at the target (single shot)
        8. Short real-time delay for the shot to resolve
        9. Clean up remaining globals
    
    Globals consumed (set by fn_ability_aimedShot):
        OpsRoom_AimedShot_Shooter          - the unit firing
        OpsRoom_AimedShot_EnemyData        - array of [enemy, hitPct, pos]
        OpsRoom_AimedShot_SelectedIndex    - index into EnemyData (set by menu action)
        OpsRoom_AimedShot_PreviousSpeed    - game speed before we slowed it
        OpsRoom_AimedShot_DrawHandler      - Draw3D event handler ID
*/

// Close the expandable menu
[] call OpsRoom_fnc_closeButtonMenu;

// --- VALIDATION & EXECUTION BLOCK (scopeBreak pattern for early exit) ---
private _scopeBreak = false;
while {!_scopeBreak} do {
    _scopeBreak = true;  // Only runs once unless we explicitly continue

    // --- VALIDATE GLOBALS EXIST ---
    if (isNil "OpsRoom_AimedShot_Shooter" || {isNil "OpsRoom_AimedShot_EnemyData"} || {isNil "OpsRoom_AimedShot_SelectedIndex"}) exitWith {
        diag_log "[OpsRoom] AimedShot: globals missing — aborting";
        [] call OpsRoom_fnc_cancelAimedShotTargeting;
    };

    // --- READ STATE ---
    private _shooter       = OpsRoom_AimedShot_Shooter;
    private _enemyData     = OpsRoom_AimedShot_EnemyData;
    private _targetIndex   = OpsRoom_AimedShot_SelectedIndex;
    private _prevSpeed     = if (isNil "OpsRoom_AimedShot_PreviousSpeed") then {1} else {OpsRoom_AimedShot_PreviousSpeed};

    // --- VALIDATE SHOOTER ---
    if (isNull _shooter || {!alive _shooter}) exitWith {
        diag_log "[OpsRoom] AimedShot: shooter invalid/dead — aborting";
        [] call OpsRoom_fnc_cancelAimedShotTargeting;
    };

    // --- VALIDATE TARGET INDEX ---
    if (_targetIndex >= count _enemyData) exitWith {
        diag_log "[OpsRoom] AimedShot: target index out of range — aborting";
        [] call OpsRoom_fnc_cancelAimedShotTargeting;
    };

    // --- EXTRACT TARGET DATA ---
    private _targetData = _enemyData select _targetIndex;
    private _target    = _targetData select 0;
    private _hitPct    = _targetData select 1;
    private _targetPos = _targetData select 2;

    if (isNull _target || {!alive _target}) exitWith {
        diag_log format ["[OpsRoom] AimedShot: target %1 is dead/invalid — aborting", _targetIndex];
        [] call OpsRoom_fnc_cancelAimedShotTargeting;
    };

diag_log format ["[OpsRoom] AimedShot: shooter %1 firing at %2 (hit chance %3%%)", name _shooter, name _target, _hitPct];

// Re-read _prevSpeed in case slowdown completed after initial read
_prevSpeed = if (isNil "OpsRoom_AimedShot_PreviousSpeed") then {1} else {OpsRoom_AimedShot_PreviousSpeed};

// --- REMOVE DRAW3D MARKERS NOW ---
// Target is chosen — markers served their purpose. Remove before restoring speed
// so there's no flicker of markers playing back at normal speed.
if (!isNil "OpsRoom_AimedShot_DrawHandler") then {
    removeMissionEventHandler ["Draw3D", OpsRoom_AimedShot_DrawHandler];
    OpsRoom_AimedShot_DrawHandler = nil;
};
missionNamespace setVariable ["OpsRoom_AimedShot_Markers_Active", false];
missionNamespace setVariable ["OpsRoom_AimedShot_Markers_Data", []];

// --- RESTORE GAME SPEED ---
// Must happen BEFORE the spawned scope — sleep/camera transition must run at
// normal speed. (sleep uses game time; at 0.01x a 2s sleep = 200 real seconds.)
setTimeMultiplier _prevSpeed;
setAccTime _prevSpeed;
OpsRoom_CurrentSpeed = _prevSpeed;
diag_log format ["[OpsRoom] AimedShot: speed restored to %1 before camera", _prevSpeed];

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
            if (_mult == _prevSpeed) then {
                _btn ctrlSetBackgroundColor [0.75, 0.65, 0.45, 1];
            } else {
                _btn ctrlSetBackgroundColor [0.25, 0.22, 0.18, 0.8];
            };
            _btn ctrlCommit 0;
        };
    } forEach _speeds;
};

// --- RUN CAMERA + SHOT IN SPAWNED SCOPE (needs sleep) ---
[_shooter, _target] spawn {
    params ["_unit", "_enemy"];

    // --- CAMERA TRANSITION TO OVER-THE-SHOULDER VIEW ---
    // Position camera behind shooter at low ground level, looking at target.
    private _enemyPos   = getPosASL _enemy;
    private _shooterPosATL = getPosATL _unit;
    private _shooterDir = getDir _unit;
    
    // Calculate horizontal position: 4m behind shooter, 1m to the right
    private _offsetBack = 4;   // meters behind
    private _offsetRight = 1;  // meters to the right
    
    // Convert shooter direction to radians and calculate offset vector
    private _dirRad = _shooterDir * (pi / 180);
    private _backX = -(_offsetBack * sin _dirRad);
    private _backY = -(_offsetBack * cos _dirRad);
    
    // Right vector (perpendicular to direction)
    private _rightX = _offsetRight * cos _dirRad;
    private _rightY = -(_offsetRight * sin _dirRad);
    
    // Calculate XY position
    private _camX = (_shooterPosATL select 0) + _backX + _rightX;
    private _camY = (_shooterPosATL select 1) + _backY + _rightY;
    
    // For VR map: use low fixed Z value (1.5m for ground-level view)
    // ATLtoASL was adding 5m on VR terrain!
    private _camZ = 1.5;
    
    // Camera position in ASL (for BIS_fnc_setCuratorCamera)
    private _camPos = [_camX, _camY, _camZ];
    
    diag_log format ["[OpsRoom] AimedShot Camera: shooterATL=%1, camPos=%2", _shooterPosATL, _camPos];

    // Smooth 2-second camera transition, looking at the enemy target
    [_camPos, _enemy, 2] call BIS_fnc_setCuratorCamera;

    // Wait for camera to settle (2s transition + 0.5s buffer)
    sleep 2.5;

    // --- FIRE THE SHOT ---
    _unit doWatch _enemy;
    _unit doTarget _enemy;

    // Brief pause for the unit to physically turn and aim
    sleep 0.8;

    // Single shot
    private _weapon = primaryWeapon _unit;
    _unit forceWeaponFire [_weapon, currentWeaponMode _unit];

    diag_log format ["[OpsRoom] AimedShot: %1 fired at %2", name _unit, name _enemy];

    // Wait for the bullet to travel and hit/miss to register
    sleep 2;

    // --- CLEANUP UNIT STATE ---
    _unit doWatch objNull;
    _unit doTarget objNull;
    
    // Restore behavior to original (stored globally at start)
    if (!isNil "OpsRoom_AimedShot_OriginalBehavior") then {
        private _originalBehavior = OpsRoom_AimedShot_OriginalBehavior;
        if (_originalBehavior == "CARELESS") then {
            _unit setBehaviour "CARELESS";
            diag_log format ["[OpsRoom] AimedShot: %1 restored to CARELESS", name _unit];
        };
    };

    // --- CLEAR REMAINING GLOBALS ---
    OpsRoom_AimedShot_Shooter = nil;
    OpsRoom_AimedShot_EnemyData = nil;
    OpsRoom_AimedShot_SelectedIndex = nil;
    OpsRoom_AimedShot_PreviousSpeed = nil;
    OpsRoom_AimedShot_OriginalBehavior = nil;

    diag_log "[OpsRoom] AimedShot: complete";
};

};  // End while loop
