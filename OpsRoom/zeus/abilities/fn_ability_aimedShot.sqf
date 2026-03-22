/*
    OpsRoom_fnc_ability_aimedShot
    
    Aimed Shot - Main entry point.
    
    Flow:
        1. Validate selected unit has marksmanShot qualification + ammo
        2. Save current game speed, slow to near-pause (0.01x)
        3. Query unit's known enemies (max 5)
        4. Calculate hit % for each enemy (accuracy skill + distance)
        5. Start Draw3D markers on each enemy (crosshair icon + hit % text)
        6. Build dynamic expandable menu: "TARGET 1", "TARGET 2", etc.
        7. Player picks target → calls executeAimedShot
        8. ESC → calls cancelAimedShotTargeting (restores speed, removes markers)
*/

// --- VALIDATE SELECTION ---
private _selected = curatorSelected select 0;
if (typeName _selected != "ARRAY") exitWith {
    hint "Error: Invalid selection";
};
if (count _selected == 0) exitWith {
    hint "No units selected";
};

// Check capability (training variable + ammo)
private _validation = _selected call OpsRoom_fnc_checkAimedShotCapable;
_validation params ["_capable", "_failed"];

if (_capable isEqualTo []) exitWith {
    hint "Selected unit has no Marksman qualification or no ammo";
};

// Aimed Shot is a single-unit ability — take the first capable unit
private _shooter = _capable select 0;

// --- CHECK KNOWN ENEMIES ---
// OpsRoom_KnownEnemies is maintained by revealEnemy/hideEnemy.
// Each entry is [enemyObj, detectionMethod, time]. Pull live objects, filter alive, cap 5.
private _enemies = [];
{
    private _enemy = _x select 0;
    if (!isNull _enemy && {alive _enemy} && {count _enemies < 5}) then {
        _enemies pushBack _enemy;
    };
} forEach OpsRoom_KnownEnemies;

if (_enemies isEqualTo []) exitWith {
    hint format ["%1 has no known enemies", name _shooter];
};

diag_log format ["[OpsRoom] AimedShot: %1 knows %2 enemies", name _shooter, count _enemies];

// --- CALCULATE HIT % FOR EACH ENEMY ---
// (Game speed will be slowed after 1s delay - see behavior management section below)
/*
    Formula:
        basePct     = (unit skill "aimingAccuracy") * 100   → 0–100
        distancePct = distance-based multiplier:
            0–50m     → 1.0   (full)
            50–500m   → linear falloff from 1.0 to 0.30
            500–800m  → linear falloff from 0.30 to 0.10
            800m+     → 0.10  (floor)
        finalPct    = round (basePct * distancePct)
        Clamped 5–95 (never show 0% or 100%)
*/
private _shooterAccuracy = _shooter skill "aimingAccuracy";
private _shooterPos = getPosASL _shooter;

OpsRoom_AimedShot_EnemyData = [];  // Array of [enemyObj, hitPct, enemyPos]

{
    private _enemy = _x;
    private _enemyPos = getPosASL _enemy;
    private _dist = _shooterPos distance _enemyPos;

    private _distMult = 1.0;
    if (_dist > 800) then {
        _distMult = 0.10;
    } else {
        if (_dist > 500) then {
            // Linear 0.30 → 0.10 over 500–800m
            _distMult = 0.30 - ((_dist - 500) / 300) * 0.20;
        } else {
            if (_dist > 50) then {
                // Linear 1.0 → 0.30 over 50–500m
                _distMult = 1.0 - ((_dist - 50) / 450) * 0.70;
            };
            // else: 0–50m → stays 1.0
        };
    };

    private _hitPct = round ((_shooterAccuracy * 100) * _distMult);
    _hitPct = _hitPct max 5;   // floor 5%
    _hitPct = _hitPct min 95;  // cap 95%

    OpsRoom_AimedShot_EnemyData pushBack [_enemy, _hitPct, _enemyPos];

    diag_log format ["[OpsRoom] AimedShot: target %1, dist %2m, acc %3, distMult %4, hitPct %5%%",
        name _enemy, round _dist, _shooterAccuracy, round (_distMult * 100), _hitPct];
} forEach _enemies;

// --- STORE SHOOTER GLOBALLY ---
OpsRoom_AimedShot_Shooter = _shooter;

// --- BEHAVIOR MODE MANAGEMENT ---
// Save original behavior and switch to AWARE so unit raises weapon
OpsRoom_AimedShot_OriginalBehavior = behaviour _shooter;
if (OpsRoom_AimedShot_OriginalBehavior == "CARELESS") then {
    _shooter setBehaviour "AWARE";
    diag_log format ["[OpsRoom] AimedShot: %1 switched from CARELESS to AWARE", name _shooter];
};

// --- DELAY BEFORE SLOWDOWN ---
// Wait 1 second for unit to raise weapon before slowing time
[_shooter] spawn {
    params ["_shooter"];
    sleep 1;
    
    // --- SLOW GAME SPEED (after 1 second delay) ---
    private _prevSpeed = if (isNil "OpsRoom_CurrentSpeed") then {1} else {OpsRoom_CurrentSpeed};
    OpsRoom_AimedShot_PreviousSpeed = _prevSpeed;
    setTimeMultiplier 0.01;
    setAccTime 0.01;
    OpsRoom_CurrentSpeed = 0.01;
    
    diag_log "[OpsRoom] AimedShot: time slowed after 1s delay";
};

// --- START DRAW3D MARKERS ---
// Store marker data in missionNamespace so Draw3D handler can read it
// (Draw3D handlers cannot receive params — data must be in missionNamespace)
missionNamespace setVariable ["OpsRoom_AimedShot_Markers_Active", true];
missionNamespace setVariable ["OpsRoom_AimedShot_Markers_Data", OpsRoom_AimedShot_EnemyData];

OpsRoom_AimedShot_DrawHandler = addMissionEventHandler ["Draw3D", {
    if (!(missionNamespace getVariable ["OpsRoom_AimedShot_Markers_Active", false])) exitWith {};

    private _data = missionNamespace getVariable ["OpsRoom_AimedShot_Markers_Data", []];

    {
        _x params ["_enemy", "_hitPct", "_enemyPos"];

        // Skip dead/invalid — no continue in Draw3D forEach, use if-then
        if (!isNull _enemy && {alive _enemy}) then {

            // Use live position in case enemy moved (game is near-paused so minimal drift)
            private _pos = getPosASL _enemy;

            // Colour: green if >=60%, amber if 30–59%, red if <30%
            private _colour = if (_hitPct >= 60) then {[0.2, 0.9, 0.2, 1]} else {
                if (_hitPct >= 30) then {[1.0, 0.7, 0.0, 1]} else {[0.9, 0.2, 0.2, 1]}
            };

            // Draw crosshair icon on ground at enemy position
            drawIcon3D [
                "CUP\Weapons\CUP_Weapons_West_Attachments\sb_3_12x50_pmii\data\l115a1_crosshair_ca.paa",
                _colour,
                [_pos select 0, _pos select 1, (_pos select 2) + 0.15],
                2, 2,
                0,
                "",
                0,
                0.04,
                "PuristaBold",
                "center"
            ];

            // Draw hit % text above enemy (floating 3m up)
            drawIcon3D [
                "",
                _colour,
                [_pos select 0, _pos select 1, (_pos select 2) + 3.0],
                0, 0,
                0,
                format ["%1%%", _hitPct],
                2,
                0.06,
                "PuristaBold",
                "center"
            ];
        };
    } forEach _data;
}];

// --- BUILD DYNAMIC MENU ---
private _display = findDisplay 312;
if (isNull _display) exitWith {
    // Cleanup if display gone
    [] call OpsRoom_fnc_cancelAimedShotTargeting;
};

// Find the aimedShot ability button (IDC range 9350–9389)
private _aimedShotButton = controlNull;
for "_i" from 9350 to 9389 step 2 do {
    private _btn = _display displayCtrl (_i + 1);
    if (!isNull _btn) then {
        if ((_btn getVariable ["abilityID", ""]) == "aimedShot") exitWith {
            _aimedShotButton = _btn;
        };
    };
};

if (isNull _aimedShotButton) exitWith {
    [] call OpsRoom_fnc_cancelAimedShotTargeting;
    hint "Aimed Shot button not found";
};

private _btnPos = ctrlPosition _aimedShotButton;
_btnPos params ["_baseX", "_baseY", "_btnW", "_btnH"];

// Build menu items dynamically — one per known enemy
// We store the target index in a global before the menu opens, then each
// button action sets it and calls execute. Only one button fires, so no race.
private _menuItems = [];
{
    _x params ["_enemy", "_hitPct", "_enemyPos"];
    private _idx = _forEachIndex;

    // Determine the colour label based on hit %
    private _label = format ["TARGET %1  (%2%%)", _idx + 1, _hitPct];

    // We cannot capture _idx into a code block by value in SQF directly.
    // Solution: store all targets globally (already done in EnemyData).
    // Each menu action sets OpsRoom_AimedShot_SelectedIndex then calls execute.
    // We use compile to bake _idx into each code block as a literal.
    private _actionCode = compile format [
        "OpsRoom_AimedShot_SelectedIndex = %1; call OpsRoom_fnc_executeAimedShot;",
        _idx
    ];

    _menuItems pushBack [_label, "JMSSA_ger\helmets\data\ico\ico_h_m40luft.paa", _actionCode];
} forEach OpsRoom_AimedShot_EnemyData;

// Open the expandable menu
[_display, _aimedShotButton, _menuItems, _baseX, _baseY, _btnW] call OpsRoom_fnc_createButtonMenu;

// --- ADD CANCEL HANDLERS ---
// ESC key handler
OpsRoom_AimedShot_ESCHandler = _display displayAddEventHandler ["KeyDown", {
    params ["_display", "_key"];
    if (_key == 1) then {  // 1 = ESC
        [] call OpsRoom_fnc_cancelAimedShotTargeting;
        true  // Consume the key
    } else {
        false
    };
}];

// Mouse click handler - cancel if clicking outside menu buttons
OpsRoom_AimedShot_MouseHandler = _display displayAddEventHandler ["MouseButtonDown", {
    params ["_display", "_button", "_xPos", "_yPos"];
    if (_button == 0) then {  // Left click only
        // Check if click is inside any menu button
        private _clickedMenu = false;
        for "_i" from 9400 to 9420 do {  // Menu button IDC range
            private _ctrl = _display displayCtrl _i;
            if (!isNull _ctrl && {ctrlShown _ctrl}) then {
                private _ctrlPos = ctrlPosition _ctrl;
                _ctrlPos params ["_x", "_y", "_w", "_h"];
                if (_xPos >= _x && {_xPos <= (_x + _w)} && {_yPos >= _y} && {_yPos <= (_y + _h)}) then {
                    _clickedMenu = true;
                };
            };
        };
        
        // If clicked outside menu, cancel
        if (!_clickedMenu) then {
            [] call OpsRoom_fnc_cancelAimedShotTargeting;
        };
    };
    false  // Don't consume mouse events
}];

diag_log format ["[OpsRoom] AimedShot: menu created with %1 targets", count _menuItems];
