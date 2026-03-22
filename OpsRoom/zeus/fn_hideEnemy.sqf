/*
    OpsRoom_fnc_hideEnemy
    
    Hides an enemy unit from Zeus (scripted hide).
    Useful for mission scripting when you want to manually hide enemies.
    
    Parameters:
        _enemy - Unit to hide
    
    Example:
        [_enemyUnit] call OpsRoom_fnc_hideEnemy;
*/

params ["_enemy"];

if (isNull _enemy) exitWith {
    diag_log "[OpsRoom] ERROR: hideEnemy called with null unit";
};

// Get Zeus curator
private _zeus = getAssignedCuratorLogic player;
if (isNull _zeus) exitWith {
    diag_log "[OpsRoom] ERROR: No Zeus curator found";
};

// Remove from Zeus editability
_zeus removeCuratorEditableObjects [[_enemy], false];

// Remove from known enemies if fog of war is enabled
if (OpsRoom_Settings_FogOfWar_Enabled) then {
    OpsRoom_KnownEnemies = OpsRoom_KnownEnemies select {(_x select 0) != _enemy};
};

diag_log format ["[OpsRoom] Hidden enemy: %1", _enemy];
