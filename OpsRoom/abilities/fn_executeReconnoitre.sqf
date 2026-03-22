/*
    OpsRoom_fnc_executeReconnoitre
    
    Unit moves to position, goes prone, scans for enemies over 15 seconds.
    Discovered enemies added to OpsRoom_KnownEnemies and revealed to Zeus.
    
    Parameters:
        0: OBJECT - Forward Observer unit
        1: ARRAY  - Observation position
        2: NUMBER - Scan radius in metres
*/

params ["_unit", "_targetPos", "_scanRadius"];

systemChat format ["%1 moving to observation position (%2m scan)", name _unit, _scanRadius];

[_unit, _targetPos, _scanRadius] spawn {
    params ["_unit", "_targetPos", "_scanRadius"];
    
    // Move to position
    _unit doMove _targetPos;
    
    waitUntil {
        sleep 0.5;
        (_unit distance _targetPos < 10) || !(alive _unit)
    };
    
    if (!alive _unit) exitWith {
        systemChat format ["%1 was killed en route", name _unit];
    };
    
    // Go prone, stop moving
    _unit setUnitPos "DOWN";
    _unit disableAI "MOVE";
    _unit setBehaviour "STEALTH";
    _unit doWatch _targetPos;
    
    systemChat format ["%1 in position. Scanning...", name _unit];
    
    // Draw3D scanning circle
    private _reconID = format ["recon_%1_%2", getPlayerUID player, diag_tickTime];
    missionNamespace setVariable [_reconID + "_active", true];
    missionNamespace setVariable [_reconID + "_pos", getPos _unit];
    missionNamespace setVariable [_reconID + "_radius", _scanRadius];
    missionNamespace setVariable [_reconID + "_progress", 0];
    
    private _drawHandler = addMissionEventHandler ["Draw3D", {
        {
            if (_x find "recon_" == 0 && {_x find "_active" > 0}) then {
                private _baseID = _x select [0, (count _x) - 7];
                if (missionNamespace getVariable [_x, false]) then {
                    private _pos = missionNamespace getVariable [_baseID + "_pos", [0,0,0]];
                    private _radius = missionNamespace getVariable [_baseID + "_radius", 200];
                    private _progress = missionNamespace getVariable [_baseID + "_progress", 0];
                    
                    // Draw scan radius circle
                    private _segments = 24;
                    for "_i" from 0 to _segments do {
                        private _a1 = (_i / _segments) * 360;
                        private _a2 = ((_i + 1) / _segments) * 360;
                        drawLine3D [
                            [(_pos select 0) + (_radius * cos _a1), (_pos select 1) + (_radius * sin _a1), (_pos select 2) + 0.1],
                            [(_pos select 0) + (_radius * cos _a2), (_pos select 1) + (_radius * sin _a2), (_pos select 2) + 0.1],
                            [0, 0.8, 1, 0.4]
                        ];
                    };
                    
                    // Animated sweep line (rotating)
                    private _sweepAngle = (time * 60) mod 360;
                    drawLine3D [
                        _pos vectorAdd [0,0,0.2],
                        [(_pos select 0) + (_radius * cos _sweepAngle), (_pos select 1) + (_radius * sin _sweepAngle), (_pos select 2) + 0.2],
                        [0, 1, 1, 0.7]
                    ];
                    
                    // Progress text
                    drawIcon3D ["", [0, 0.8, 1, 1],
                        [_pos select 0, _pos select 1, (_pos select 2) + 4],
                        0, 0, 0,
                        format ["SCANNING %1%%", round (_progress * 100)],
                        2, 0.05, "PuristaBold", "center"
                    ];
                };
            };
        } forEach (allVariables missionNamespace);
    }];
    
    missionNamespace setVariable [_reconID + "_drawHandler", _drawHandler];
    
    // Initialize known enemies array if needed
    if (isNil "OpsRoom_KnownEnemies") then {
        OpsRoom_KnownEnemies = [];
    };
    
    // Scan over 15 seconds, gradually discovering enemies
    private _scanDuration = 15;
    private _scanSteps = 5;
    private _stepDuration = _scanDuration / _scanSteps;
    private _totalFound = 0;
    private _unitPos = getPos _unit;
    private _unitSide = side (group _unit);
    
    for "_step" from 1 to _scanSteps do {
        sleep _stepDuration;
        
        if (!alive _unit) exitWith {};
        
        // Update progress
        missionNamespace setVariable [_reconID + "_progress", _step / _scanSteps];
        
        // Scan for enemies in range
        // Each step reveals enemies within (step/total * radius)
        private _currentRadius = (_step / _scanSteps) * _scanRadius;
        
        private _nearUnits = _unitPos nearEntities ["CAManBase", _currentRadius];
        
        {
            private _enemy = _x;
            private _enemySide = side (group _enemy);
            
            // Only detect hostile units
            if (alive _enemy && {_enemySide != _unitSide} && {_enemySide != civilian}) then {
                // Check not already known
                private _alreadyKnown = false;
                {
                    if ((_x select 0) == _enemy) exitWith { _alreadyKnown = true; };
                } forEach OpsRoom_KnownEnemies;
                
                if (!_alreadyKnown) then {
                    // Add to known enemies
                    OpsRoom_KnownEnemies pushBack [_enemy, "recon", time];
                    _totalFound = _totalFound + 1;
                    
                    // Reveal to Zeus
                    private _curator = getAssignedCuratorLogic player;
                    if (!isNull _curator) then {
                        _curator addCuratorEditableObjects [[_enemy], false];
                    };
                    
                    // Reveal to unit's side
                    (group _unit) reveal [_enemy, 4];
                    
                    systemChat format ["CONTACT: Enemy spotted at %1m (%2)", round (_unitPos distance _enemy), name _enemy];
                };
            };
        } forEach _nearUnits;
    };
    
    // Cleanup Draw3D
    missionNamespace setVariable [_reconID + "_active", false];
    private _dh = missionNamespace getVariable [_reconID + "_drawHandler", -1];
    if (_dh != -1) then {
        removeMissionEventHandler ["Draw3D", _dh];
    };
    
    // Restore unit
    _unit setUnitPos "AUTO";
    _unit enableAI "MOVE";
    
    if (_totalFound > 0) then {
        hint parseText format [
            "<t size='1.2' color='#00ccff'>Reconnaissance Complete</t><br/><br/><t color='#ffcc66'>%1</t> enemy contacts identified within %2m",
            _totalFound, _scanRadius
        ];
    } else {
        hint parseText format [
            "<t size='1.2' color='#00ccff'>Reconnaissance Complete</t><br/><br/>No enemy contacts within %1m",
            _scanRadius
        ];
    };
    
    systemChat format ["%1 recon complete: %2 contacts found", name _unit, _totalFound];
    diag_log format ["[OpsRoom] Recon complete: %1 found %2 enemies in %3m radius", name _unit, _totalFound, _scanRadius];
};
