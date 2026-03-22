/*
    OpsRoom_fnc_revealEnemy
    
    Reveals an enemy unit to Zeus immediately (scripted reveal).
    Useful for mission scripting when you want to manually reveal enemies.
    
    Parameters:
        _enemy - Unit to reveal
        _method - (Optional) Detection method string for notification (default: "Scripted")
    
    Example:
        [_enemyUnit] call OpsRoom_fnc_revealEnemy;
        [_enemyUnit, "Intel report"] call OpsRoom_fnc_revealEnemy;
*/

params ["_enemy", ["_method", "Scripted"]];

if (isNull _enemy) exitWith {
    diag_log "[OpsRoom] ERROR: revealEnemy called with null unit";
};

// Get Zeus curator
private _zeus = getAssignedCuratorLogic player;
if (isNull _zeus) exitWith {
    diag_log "[OpsRoom] ERROR: No Zeus curator found";
};

// Add to Zeus editability
_zeus addCuratorEditableObjects [[_enemy], false];

// Add to known enemies if fog of war is enabled
if (OpsRoom_Settings_FogOfWar_Enabled) then {
    // Check if already in known enemies
    private _alreadyKnown = false;
    {
        if (_x select 0 == _enemy) exitWith {
            _alreadyKnown = true;
        };
    } forEach OpsRoom_KnownEnemies;
    
    // Add if not already known
    if (!_alreadyKnown) then {
        OpsRoom_KnownEnemies pushBack [_enemy, _method, time];
        
        // Notification
        if (OpsRoom_Settings_FogOfWar_ShowDetections) then {
            private _enemyName = if (_enemy isKindOf "CAManBase") then {
                name _enemy
            } else {
                getText (configOf _enemy >> "displayName")
            };
            systemChat format ["[OpsRoom] Enemy revealed: %1 (%2)", _enemyName, _method];
        };
    };
};

diag_log format ["[OpsRoom] Revealed enemy: %1 via %2", _enemy, _method];
