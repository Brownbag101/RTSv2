/*
    Air Operations - Scramble Combat Monitor
    
    Drongo-inspired dogfight loop for scrambled Fighter wings.
    ARMA's native AI is terrible at persistent air-to-air gun engagement,
    so we take manual control: detect → reveal → close → force-fire → guide bullets.
    
    Called from fn_launchWing.sqf after all aircraft are airborne (scramble only).
    Runs one loop per aircraft in the wing.
    
    Parameters:
        _wingId - Wing ID (must be airborne scramble wing)
*/
params ["_wingId"];

private _wingData = OpsRoom_AirWings get _wingId;
if (isNil "_wingData") exitWith {};

private _spawnedObjects = _wingData get "spawnedObjects";
private _wingName = _wingData get "name";

// Get all aircraft from spawned objects
private _aircraft = _spawnedObjects select { _x isKindOf "Air" && alive _x };

if (count _aircraft == 0) exitWith {
    diag_log format ["[OpsRoom] ScrambleCombat: No aircraft found for wing %1", _wingId];
};

diag_log format ["[OpsRoom] ScrambleCombat: Starting combat monitor for %1 (%2 aircraft)", _wingName, count _aircraft];

// --- Helper: find the forward gun weapon name on an aircraft ---
OpsRoom_fnc_getAircraftGun = {
    params ["_vehicle"];
    private _gun = "";
    private _weapons = weapons _vehicle;
    {
        private _parents = [(configFile >> "CfgWeapons" >> _x), true] call BIS_fnc_returnParents;
        // Check for cannon first (20mm+), then MG
        if ("CannonCore" in _parents) exitWith { _gun = _x };
    } forEach _weapons;
    if (_gun == "") then {
        {
            private _parents = [(configFile >> "CfgWeapons" >> _x), true] call BIS_fnc_returnParents;
            if ("MGun" in _parents) exitWith { _gun = _x };
        } forEach _weapons;
    };
    _gun
};

// --- Helper: check if target is within forward cone of aircraft ---
OpsRoom_fnc_targetInCone = {
    params ["_aircraft", "_target", "_coneAngle"];
    private _refPos = getPosASL _aircraft;
    private _targetPos = getPosASL _target;
    private _vectorToTarget = vectorNormalized (_targetPos vectorDiff _refPos);
    private _refDir = getDir _aircraft;
    private _forwardVector = [sin _refDir, cos _refDir, 0];
    private _dotProduct = _forwardVector vectorDotProduct _vectorToTarget;
    // Clamp dot product to avoid NaN from acos
    _dotProduct = (-1) max (_dotProduct min 1);
    private _angle = acos _dotProduct;
    (_angle <= (_coneAngle / 2))
};

// --- Spawn one combat loop per aircraft ---
{
    private _vehicle = _x;
    
    [_vehicle, _wingId, _wingName] spawn {
        params ["_vehicle", "_wingId", "_wingName"];
        
        private _displayName = getText (configFile >> "CfgVehicles" >> typeOf _vehicle >> "displayName");
        private _pilot = driver _vehicle;
        private _pilotGroup = group _pilot;
        
        // Get the gun weapon name
        private _gun = [_vehicle] call OpsRoom_fnc_getAircraftGun;
        if (_gun == "") exitWith {
            diag_log format ["[OpsRoom] ScrambleCombat: %1 has no guns — skipping combat monitor", _displayName];
        };
        
        diag_log format ["[OpsRoom] ScrambleCombat: %1 combat loop started (gun: %2)", _displayName, _gun];
        
        // Engagement settings
        private _detectionRange = 5000;   // Scan range for enemies
        private _gunRange = 800;          // Open fire range
        private _coneAngle = 70;          // Forward cone for firing (degrees, full width)
        
        // Bullet guidance scales by pilot rank — rookies spray, aces hit
        // PRIVATE=0.05, CORPORAL=0.10, SERGEANT=0.15, LIEUTENANT=0.20, CAPTAIN=0.25, MAJOR=0.30, COLONEL=0.35
        private _rankFactors = createHashMapFromArray [
            ["PRIVATE", 0.05],
            ["CORPORAL", 0.10],
            ["SERGEANT", 0.15],
            ["LIEUTENANT", 0.20],
            ["CAPTAIN", 0.25],
            ["MAJOR", 0.30],
            ["COLONEL", 0.35]
        ];
        private _pilotRank = rank _pilot;
        private _bulletGuideFactor = _rankFactors getOrDefault [_pilotRank, 0.10];
        
        diag_log format ["[OpsRoom] ScrambleCombat: %1 pilot %2 (rank: %3, guidance: %4)", _displayName, name _pilot, _pilotRank, _bulletGuideFactor];
        
        // Fired EH to guide bullets toward current target
        private _currentTarget = objNull;
        _vehicle setVariable ["OpsRoom_ScrambleTarget", objNull];
        
        _vehicle setVariable ["OpsRoom_ScrambleGuideFactor", _bulletGuideFactor];
        
        private _firedEH = _vehicle addEventHandler ["Fired", {
            params ["_vehicle", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];
            
            private _target = _vehicle getVariable ["OpsRoom_ScrambleTarget", objNull];
            if (isNull _target || !alive _target) exitWith {};
            
            // Only guide forward-facing guns (not turrets etc)
            private _parents = [(configFile >> "CfgWeapons" >> _weapon), true] call BIS_fnc_returnParents;
            if !("CannonCore" in _parents || "MGun" in _parents) exitWith {};
            
            // Spawn guidance on the projectile — factor set by pilot rank
            private _factor = _vehicle getVariable ["OpsRoom_ScrambleGuideFactor", 0.10];
            [_projectile, _target, _factor] spawn {
                params ["_bullet", "_target", "_factor"];
                
                private _ttl = diag_tickTime + 3; // Max 3 second guidance
                
                while { !isNull _bullet && alive _target && diag_tickTime < _ttl } do {
                    private _bulletPos = getPosASL _bullet;
                    private _targetPos = getPosASL _target;
                    private _currentVel = velocity _bullet;
                    private _speed = vectorMagnitude _currentVel;
                    
                    // Direction to target
                    private _toTarget = vectorNormalized (_targetPos vectorDiff _bulletPos);
                    // Current direction
                    private _currentDir = vectorNormalized _currentVel;
                    
                    // Blend current direction with target direction
                    private _newDir = vectorNormalized (
                        (_currentDir vectorMultiply (1 - _factor)) vectorAdd (_toTarget vectorMultiply _factor)
                    );
                    
                    _bullet setVelocity (_newDir vectorMultiply _speed);
                    
                    sleep 0.05;
                };
            };
        }];
        
        // Main combat loop
        private _noTargetCount = 0;
        
        while { alive _vehicle } do {
            // Check wing is still airborne scramble
            private _wd = OpsRoom_AirWings get _wingId;
            if (isNil "_wd") exitWith {};
            private _status = _wd get "status";
            if (_status != "AIRBORNE") exitWith {};
            private _mission = _wd getOrDefault ["mission", ""];
            if (_mission != "scramble") exitWith {};
            
            // --- DETECT: Find enemy air targets ---
            private _side = side _pilot;
            
            // Combine sensor targets + nearEntities for redundancy
            private _threats = [];
            {
                if (_x isKindOf "Air" && alive _x && !([_side, side _x] call BIS_fnc_sideIsFriendly)) then {
                    _threats pushBackUnique _x;
                };
            } forEach (_vehicle targets [true, _detectionRange, [], 0]);
            
            // Also scan nearby in case sensors missed them (WW2 planes have no radar)
            {
                if (alive _x && !([_side, side _x] call BIS_fnc_sideIsFriendly)) then {
                    _threats pushBackUnique _x;
                };
            } forEach (_vehicle nearEntities [["Air"], _detectionRange]);
            
            // Remove friendly
            _threats = _threats select { !([_side, side _x] call BIS_fnc_sideIsFriendly) && alive _x };
            
            // Sort by distance (closest first)
            _threats = [_threats, [], { _vehicle distance _x }, "ASCEND"] call BIS_fnc_sortBy;
            
            if (count _threats == 0) then {
                _noTargetCount = _noTargetCount + 1;
                _vehicle setVariable ["OpsRoom_ScrambleTarget", objNull];
                _currentTarget = objNull;
                
                // No targets — return to loiter behaviour
                if (_noTargetCount == 1) then {
                    _pilotGroup setCombatMode "YELLOW";
                    _pilotGroup setBehaviour "AWARE";
                    _pilotGroup setSpeedMode "NORMAL";
                    // Re-enable AI targeting as fallback while loitering
                    { _x enableAI "TARGET"; _x enableAI "AUTOTARGET" } forEach (units _pilotGroup);
                };
                
                sleep 5;
                continue;
            };
            
            // --- ENGAGE: We have targets ---
            _noTargetCount = 0;
            _currentTarget = _threats select 0;
            _vehicle setVariable ["OpsRoom_ScrambleTarget", _currentTarget];
            
            // Full reveal — force the AI to know exactly where the enemy is
            _pilot reveal [_currentTarget, 4];
            _pilotGroup reveal [_currentTarget, 4];
            
            // Aggressive posture
            _pilotGroup setCombatMode "RED";
            _pilotGroup setBehaviour "COMBAT";
            _pilotGroup setSpeedMode "FULL";
            
            // Disable native targeting so we have full control
            { _x disableAI "TARGET"; _x disableAI "AUTOTARGET" } forEach (units _pilotGroup);
            
            // Force the AI to watch, target, and fly toward the enemy
            _pilot doWatch _currentTarget;
            _pilot doTarget _currentTarget;
            _pilot doMove (getPosATL _currentTarget);
            
            // Clear existing waypoints and set a move WP to the target
            while { count waypoints _pilotGroup > 0 } do {
                deleteWaypoint [_pilotGroup, 0];
            };
            private _wp = _pilotGroup addWaypoint [getPosATL _currentTarget, 0];
            _wp setWaypointType "MOVE";
            _wp setWaypointSpeed "FULL";
            _wp setWaypointBehaviour "COMBAT";
            _wp setWaypointCombatMode "RED";
            
            private _range = _vehicle distance _currentTarget;
            
            // --- FIRE: If in range and in cone, force guns ---
            if (_range < _gunRange) then {
                if ([_vehicle, _currentTarget, _coneAngle] call OpsRoom_fnc_targetInCone) then {
                    // Burst fire: 3-6 rounds
                    private _burstCount = 3 + floor random 4;
                    for "_i" from 1 to _burstCount do {
                        if (!alive _vehicle || !alive _currentTarget) exitWith {};
                        _vehicle fireAtTarget [objNull, _gun];
                        sleep 0.08; // ~12 rounds/sec burst
                    };
                };
            };
            
            // Tick rate — faster when engaged close, slower when closing distance
            if (_range < 1500) then {
                sleep 1;
            } else {
                sleep 3;
            };
        };
        
        // Cleanup
        if (!isNull _vehicle && alive _vehicle) then {
            _vehicle removeEventHandler ["Fired", _firedEH];
            _vehicle setVariable ["OpsRoom_ScrambleTarget", nil];
            // Re-enable AI targeting
            { _x enableAI "TARGET"; _x enableAI "AUTOTARGET" } forEach (units (group (driver _vehicle)));
        };
        
        diag_log format ["[OpsRoom] ScrambleCombat: %1 combat loop ended", _displayName];
    };
} forEach _aircraft;
