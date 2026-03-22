/*
    OpsRoom_fnc_airStrike_hasWeaponType
    
    Checks if an aircraft has a specific weapon type WITH ammo.
    Ported from Drongo's Air Ops weapon detection logic.
    
    Parameters:
        0: OBJECT - aircraft vehicle
        1: STRING - "GUNS", "BOMBS", or "ROCKETS"
    
    Returns: BOOL
*/

params ["_aircraft", "_weaponType"];

if (isNull _aircraft) exitWith { false };

switch (toUpper _weaponType) do {

    // ===== GUNS =====
    // Check CfgWeapons parents for CannonCore or Mgun, then verify ammo exists
    case "GUNS": {
        private _weapons = weapons _aircraft;
        
        private _hasGun = false;
        
        {
            private _parents = [];
            _parents = [configFile >> "CfgWeapons" >> _x, true] call BIS_fnc_returnParents;
            if ("CannonCore" in _parents || "MGun" in _parents) exitWith {
                _hasGun = true;
            };
        } forEach _weapons;
        
        // Verify ammo exists for the gun
        if (_hasGun) then {
            _hasGun = false;
            {
                _x params ["_mag", "", "_count"];
                if (_count > 0) then {
                    private _ammo = getText (configFile >> "CfgMagazines" >> _mag >> "ammo");
                    if (_ammo isKindOf "BulletCore" || _ammo isKindOf "CannonCore") exitWith {
                        _hasGun = true;
                    };
                };
            } forEach (magazinesAllTurrets _aircraft);
        };
        
        _hasGun
    };

    // ===== BOMBS =====
    // Check for bomb-type magazines (high damage, no thrust)
    case "BOMBS": {
        private _hasBomb = false;
        
        {
            _x params ["_mag", "", "_count"];
            if (_count > 0) then {
                private _ammo = getText (configFile >> "CfgMagazines" >> _mag >> "ammo");
                if (_ammo != "") then {
                    private _cfg = configFile >> "CfgAmmo" >> _ammo;
                    private _thrust = getNumber (_cfg >> "thrust");
                    private _hit = getNumber (_cfg >> "hit");
                    private _maneuvrability = getNumber (_cfg >> "maneuvrability");
                    
                    // Bombs: high damage, no thrust (or very low), not a rocket
                    // Also check parent classes for BombCore
                    private _parents = [_cfg, true] call BIS_fnc_returnParents;
                    if ("BombCore" in _parents) exitWith {
                        _hasBomb = true;
                    };
                    // Fallback: high hit, no thrust = likely a bomb
                    if (_hit > 100 && _thrust == 0 && _maneuvrability == 0) exitWith {
                        _hasBomb = true;
                    };
                };
            };
        } forEach (magazinesAllTurrets _aircraft);
        
        _hasBomb
    };

    // ===== ROCKETS =====
    // Check for rocket magazines (has thrust, no manoeuvrability)
    case "ROCKETS": {
        private _hasRockets = false;
        
        {
            _x params ["_mag", "", "_count"];
            if (_count > 0) then {
                private _ammo = getText (configFile >> "CfgMagazines" >> _mag >> "ammo");
                if (_ammo != "") then {
                    private _cfg = configFile >> "CfgAmmo" >> _ammo;
                    private _thrust = getNumber (_cfg >> "thrust");
                    private _maneuvrability = getNumber (_cfg >> "maneuvrability");
                    
                    // Rockets: has thrust, no guidance (manoeuvrability == 0)
                    if (_thrust > 0 && _maneuvrability == 0) exitWith {
                        _hasRockets = true;
                    };
                };
            };
        } forEach (magazinesAllTurrets _aircraft);
        
        _hasRockets
    };

    // ===== TORPEDO =====
    // Check for torpedo-type munitions (self-propelled, high damage, typically waterline weapons)
    // Torpedoes have thrust (self-propelled) and high hit values, similar to rockets but much larger
    case "TORPEDO": {
        private _hasTorpedo = false;
        
        {
            _x params ["_mag", "", "_count"];
            if (_count > 0) then {
                private _ammo = getText (configFile >> "CfgMagazines" >> _mag >> "ammo");
                if (_ammo != "") then {
                    private _cfg = configFile >> "CfgAmmo" >> _ammo;
                    private _parents = [_cfg, true] call BIS_fnc_returnParents;
                    
                    // Check for torpedo parent classes
                    if ("TorpedoCore" in _parents) exitWith { _hasTorpedo = true };
                    if ("MissileCore" in _parents) then {
                        // Missiles with very high hit and low maneuvrability could be torpedoes
                        private _hit = getNumber (_cfg >> "hit");
                        private _ammoLC = toLower _ammo;
                        if (_hit > 500 || {"torp" in _ammoLC}) exitWith { _hasTorpedo = true };
                    };
                    
                    // Fallback: classname contains "torp"
                    private _ammoLC = toLower _ammo;
                    private _magLC = toLower _mag;
                    if ("torp" in _ammoLC || "torp" in _magLC) exitWith { _hasTorpedo = true };
                };
            };
        } forEach (magazinesAllTurrets _aircraft);
        
        _hasTorpedo
    };

    default { false };
};
