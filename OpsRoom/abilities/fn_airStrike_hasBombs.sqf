/*
    OpsRoom_fnc_airStrike_hasBombs
    
    Check if an aircraft has bomb-type ordnance with ammo.
    A bomb = magazine with ammo that has no thrust (gravity-dropped).
    Ported from Drongo's Air Ops GetBombs/HasBomb logic.
    
    Parameters:
        0: OBJECT - Aircraft vehicle
    
    Returns:
        BOOL - true if aircraft has bombs
*/

params ["_aircraft"];

if (isNull _aircraft) exitWith { false };

private _hasBombs = false;

{
    private _mag = _x select 0;
    private _rounds = _x select 2;
    
    if (_rounds > 0) then {
        private _ammo = getText (configFile >> "CfgMagazines" >> _mag >> "ammo");
        if (_ammo != "") then {
            private _cfg = configFile >> "CfgAmmo" >> _ammo;
            private _thrust = getNumber (_cfg >> "thrust");
            private _maneuvrability = getNumber (_cfg >> "maneuvrability");
            private _simulation = getText (_cfg >> "simulation");
            
            // Bomb = no thrust, not bullets
            if (_thrust == 0 && !(_ammo isKindOf "BulletCore") && !(_ammo isKindOf "CannonCore")) then {
                // Check if it's a bomb type (BombCore ammo or shotMissile simulation)
                if (_ammo isKindOf "BombCore" || _simulation == "shotMissile") then {
                    _hasBombs = true;
                };
            };
        };
    };
    
    if (_hasBombs) exitWith {};
} forEach (magazinesAmmo _aircraft);

_hasBombs
