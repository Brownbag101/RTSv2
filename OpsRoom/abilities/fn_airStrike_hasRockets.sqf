/*
    OpsRoom_fnc_airStrike_hasRockets
    
    Check if an aircraft has rocket-type ordnance with ammo.
    A rocket = magazine with ammo that has thrust but NO manoeuvrability (unguided).
    Ported from Drongo's Air Ops HasRockets/IsRocketMagazine logic.
    
    Parameters:
        0: OBJECT - Aircraft vehicle
    
    Returns:
        BOOL - true if aircraft has rockets
*/

params ["_aircraft"];

if (isNull _aircraft) exitWith { false };

private _hasRockets = false;

{
    private _mag = _x select 0;
    private _rounds = _x select 2;
    
    if (_rounds > 0) then {
        private _ammo = getText (configFile >> "CfgMagazines" >> _mag >> "ammo");
        if (_ammo != "") then {
            private _cfg = configFile >> "CfgAmmo" >> _ammo;
            private _thrust = getNumber (_cfg >> "thrust");
            private _maneuvrability = getNumber (_cfg >> "maneuvrability");
            
            // Rocket = has thrust, no guidance (manoeuvrability 0)
            if (_thrust > 0 && _maneuvrability == 0) then {
                // Verify it's from a RocketPods-type launcher
                {
                    private _parents = [configFile >> "CfgWeapons" >> _x, true] call BIS_fnc_returnParents;
                    if ("RocketPods" in _parents) exitWith {
                        _hasRockets = true;
                    };
                } forEach (weapons _aircraft);
            };
        };
    };
    
    if (_hasRockets) exitWith {};
} forEach (magazinesAmmo _aircraft);

_hasRockets
