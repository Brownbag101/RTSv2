/*
    Author: OpsRoom
    Description: Execute suppressive fire on target position
    
    Parameters:
        0: ARRAY - Units to suppress
        1: ARRAY - Target position [x,y,z]
        2: NUMBER - Duration in seconds (-1 for endless)
    
    Returns:
        Nothing
*/

params ["_units", "_targetPos", "_duration"];

private _durationText = if (_duration == -1) then {"until out of ammo"} else {format ["%1 seconds", _duration]};
hint format ["%1 unit(s) suppressing target for %2", count _units, _durationText];

{
    private _unit = _x;
    
    // Face the target before going prone
    private _dirToTarget = _unit getDir _targetPos;
    _unit setDir _dirToTarget;
    _unit doWatch _targetPos;
    
    // Make unit go prone
    _unit setUnitPos "DOWN";
    
    // Disable AI movement temporarily
    _unit disableAI "PATH";
    _unit disableAI "MOVE";
    
    // Create invisible target helper at position
    private _targetHelper = "Land_Can_V2_F" createVehicle _targetPos;
    _targetHelper setPos _targetPos;
    _targetHelper hideObjectGlobal true;
    
    // Make unit reveal and target the helper
    _unit reveal _targetHelper;
    _unit doWatch _targetHelper;
    _unit doTarget _targetHelper;
    
    // Store marker position globally
    private _markerID = format ["suppress_%1_%2", getPlayerUID player, diag_tickTime];
    missionNamespace setVariable [_markerID + "_pos", _targetPos];
    missionNamespace setVariable [_markerID + "_active", true];
    
    // Add draw3D handler for visual feedback
    private _drawHandler = addMissionEventHandler ["Draw3D", {
        // Get all active suppression markers
        {
            if (_x find "suppress_" == 0 && {_x find "_active" > 0}) then {
                private _baseID = _x select [0, (count _x) - 7]; // Remove "_active"
                private _isActive = missionNamespace getVariable [_x, false];
                
                if (_isActive) then {
                    private _pos = missionNamespace getVariable [_baseID + "_pos", [0,0,0]];
                    
                    // Draw red circle on ground
                    private _radius = 10;
                    private _segments = 16;
                    
                    for "_i" from 0 to _segments do {
                        private _angle1 = (_i / _segments) * 360;
                        private _angle2 = ((_i + 1) / _segments) * 360;
                        
                        private _x1 = (_pos select 0) + (_radius * cos _angle1);
                        private _y1 = (_pos select 1) + (_radius * sin _angle1);
                        private _x2 = (_pos select 0) + (_radius * cos _angle2);
                        private _y2 = (_pos select 1) + (_radius * sin _angle2);
                        
                        private _p1 = [_x1, _y1, (_pos select 2) + 0.1];
                        private _p2 = [_x2, _y2, (_pos select 2) + 0.1];
                        
                        drawLine3D [_p1, _p2, [1, 0, 0, 0.8]];
                    };
                    
                    // Draw crosshairs in center
                    private _crossSize = 2;
                    drawLine3D [
                        [(_pos select 0) - _crossSize, (_pos select 1), (_pos select 2) + 0.1],
                        [(_pos select 0) + _crossSize, (_pos select 1), (_pos select 2) + 0.1],
                        [1, 0, 0, 0.8]
                    ];
                    drawLine3D [
                        [(_pos select 0), (_pos select 1) - _crossSize, (_pos select 2) + 0.1],
                        [(_pos select 0), (_pos select 1) + _crossSize, (_pos select 2) + 0.1],
                        [1, 0, 0, 0.8]
                    ];
                    
                    // Draw "SUPPRESSING" text above
                    drawIcon3D [
                        "",
                        [1, 0, 0, 1],
                        [_pos select 0, _pos select 1, (_pos select 2) + 2],
                        0,
                        0,
                        0,
                        "SUPPRESSING",
                        2,
                        0.04,
                        "PuristaBold",
                        "center"
                    ];
                };
            };
        } forEach (allVariables missionNamespace);
    }];
    
    // Store handler ID globally
    if (isNil "OpsRoom_SuppressDrawHandlers") then {
        OpsRoom_SuppressDrawHandlers = [];
    };
    OpsRoom_SuppressDrawHandlers pushBack _drawHandler;
    
    // Handle duration-based logic
    if (_duration == -1) then {
        // ENDLESS - Monitor ammo until empty
        [_unit, _targetHelper, _markerID] spawn {
            params ["_u", "_helper", "_markID"];
            
            private _weapon = primaryWeapon _u;
            
            // Wait for unit to aim at target (important!)
            sleep 2;
            
            // Initial fire command
            _u doFire _helper;
            sleep 0.5;
            
            diag_log format ["[OpsRoom] Starting endless suppression for %1 with weapon %2", name _u, _weapon];
            
            // Keep firing until ALL magazines are empty
            while {alive _u} do {
                // Count total magazines (any magazine type)
                private _totalMags = count (magazines _u);
                
                diag_log format ["[OpsRoom] %1 has %2 magazines remaining", name _u, _totalMags];
                
                // Exit if no magazines left at all
                if (_totalMags == 0) exitWith {
                    diag_log format ["[OpsRoom] %1 out of all ammo", name _u];
                };
                
                // Check current magazine ammo
                private _currentAmmo = _u ammo _weapon;
                
                diag_log format ["[OpsRoom] %1 current mag ammo: %2", name _u, _currentAmmo];
                
                if (_currentAmmo == 0) then {
                    // Magazine empty, wait for reload
                    diag_log format ["[OpsRoom] %1 reloading...", name _u];
                    sleep 5;
                } else {
                    // Fire if we have ammo
                    _u forceWeaponFire [_weapon, currentWeaponMode _u];
                    _u doFire _helper;
                };
                
                // Keep watching target
                _u doWatch _helper;
                _u doTarget _helper;
                
                // Make sure unit stays prone
                if (unitPos _u != "DOWN") then {
                    _u setUnitPos "DOWN";
                };
                
                sleep 0.3;
            };
            
            // Clean up
            missionNamespace setVariable [_markID + "_active", false];
            deleteVehicle _helper;
            _u setUnitPos "AUTO";
            _u enableAI "PATH";
            _u enableAI "MOVE";
            _u doWatch objNull;
            _u doTarget objNull;
            
            if (alive _u) then {
                hint format ["%1 ceased suppression (out of ammo)", name _u];
            };
        };
        
    } else {
        // TIMED - Stop after duration
        [_unit, _duration, _targetHelper, _markerID] spawn {
            params ["_u", "_dur", "_helper", "_markID"];
            
            private _endTime = time + _dur;
            private _weapon = primaryWeapon _u;
            
            // Wait for unit to aim at target (important!)
            sleep 2;
            
            // Initial fire command
            _u doFire _helper;
            sleep 0.5;
            
            diag_log format ["[OpsRoom] Starting timed suppression for %1 with weapon %2, duration %3s", name _u, _weapon, _dur];
            
            // Keep firing during duration
            while {time < _endTime && alive _u} do {
                // Count total magazines
                private _totalMags = count (magazines _u);
                
                // Stop if completely out of ammo
                if (_totalMags == 0) exitWith {
                    diag_log format ["[OpsRoom] %1 out of all ammo", name _u];
                };
                
                // Check current magazine ammo
                private _currentAmmo = _u ammo _weapon;
                
                if (_currentAmmo == 0) then {
                    // Magazine empty, wait for reload
                    diag_log format ["[OpsRoom] %1 reloading...", name _u];
                    sleep 5;
                } else {
                    // Fire if we have ammo
                    _u forceWeaponFire [_weapon, currentWeaponMode _u];
                    _u doFire _helper;
                };
                
                // Keep watching target
                _u doWatch _helper;
                _u doTarget _helper;
                
                // Make sure unit stays prone
                if (unitPos _u != "DOWN") then {
                    _u setUnitPos "DOWN";
                };
                
                sleep 0.3;
            };
            
            // Clean up after duration
            missionNamespace setVariable [_markID + "_active", false];
            deleteVehicle _helper;
            _u setUnitPos "AUTO";
            _u enableAI "PATH";
            _u enableAI "MOVE";
            _u doWatch objNull;
            _u doTarget objNull;
        };
    };
    
} forEach _units;

diag_log format ["[OpsRoom] Suppression executed: %1 units, target %2, duration %3", count _units, _targetPos, _duration];
