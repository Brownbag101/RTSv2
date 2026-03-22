/*
    OpsRoom_fnc_executeTimebomb
    
    Unit moves to target, places explosive, countdown starts, BOOM.
    
    Parameters:
        0: OBJECT - Unit placing the bomb
        1: ARRAY  - Target position
        2: NUMBER - Fuse time in seconds
*/

params ["_unit", "_targetPos", "_fuseTime"];

// Format fuse time for display
private _fnc_formatTime = {
    params ["_seconds"];
    if (_seconds < 60) then {
        format ["%1s", _seconds]
    } else {
        if (_seconds < 3600) then {
            format ["%1m", floor(_seconds / 60)]
        } else {
            format ["%1h", floor(_seconds / 3600)]
        };
    };
};

private _fuseText = [_fuseTime] call _fnc_formatTime;
systemChat format ["%1 moving to place explosive (fuse: %2)", name _unit, _fuseText];

[_unit, _targetPos, _fuseTime, _fnc_formatTime] spawn {
    params ["_unit", "_targetPos", "_fuseTime", "_fnc_formatTime"];
    
    // Move unit to target
    _unit doMove _targetPos;
    
    // Wait until unit arrives or dies
    waitUntil {
        sleep 0.5;
        (_unit distance _targetPos < 3) || !(alive _unit)
    };
    
    if (!alive _unit) exitWith {
        systemChat format ["%1 was killed before placing the bomb", name _unit];
    };
    
    // Unit stops and plays placement animation
    _unit disableAI "MOVE";
    _unit playMoveNow "AinvPknlMstpSnonWnonDnon_medic4";
    
    systemChat format ["%1 placing explosive...", name _unit];
    sleep 5;
    
    // Re-enable movement
    _unit enableAI "MOVE";
    
    // Create the explosive
    private _bomb = createVehicle ["DemoCharge_Remote_Ammo", _targetPos, [], 0, "CAN_COLLIDE"];
    _bomb setPosATL [_targetPos select 0, _targetPos select 1, (_targetPos select 2) + 0.05];
    
    // Move unit away
    private _moveDir = (_unit getDir _bomb) + 180;
    private _safePos = _unit getPos [50, _moveDir];
    _unit doMove _safePos;
    
    // Make bomb visible to Zeus
    private _curator = getAssignedCuratorLogic player;
    if (!isNull _curator) then {
        _curator addCuratorEditableObjects [[_bomb], true];
    };
    
    // Store bomb data in missionNamespace for Draw3D
    private _bombID = format ["timebomb_%1_%2", getPlayerUID player, diag_tickTime];
    missionNamespace setVariable [_bombID + "_active", true];
    missionNamespace setVariable [_bombID + "_pos", _targetPos];
    missionNamespace setVariable [_bombID + "_bomb", _bomb];
    missionNamespace setVariable [_bombID + "_endTime", time + _fuseTime];
    
    // Draw3D handler — countdown marker on the bomb
    private _drawHandler = addMissionEventHandler ["Draw3D", {
        {
            if (_x find "timebomb_" == 0 && {_x find "_active" > 0}) then {
                private _baseID = _x select [0, (count _x) - 7];
                if (missionNamespace getVariable [_x, false]) then {
                    private _pos = missionNamespace getVariable [_baseID + "_pos", [0,0,0]];
                    private _endTime = missionNamespace getVariable [_baseID + "_endTime", 0];
                    private _remaining = _endTime - time;
                    
                    if (_remaining < 0) then { _remaining = 0; };
                    
                    // Format remaining time
                    private _timeText = if (_remaining < 60) then {
                        format ["%1s", round _remaining]
                    } else {
                        format ["%1m %2s", floor(_remaining / 60), round(_remaining mod 60)]
                    };
                    
                    // Colour: green > 30s, amber 10-30s, red < 10s, flashing < 5s
                    private _color = if (_remaining > 30) then {
                        [0.2, 0.9, 0.2, 1]
                    } else {
                        if (_remaining > 10) then {
                            [1, 0.7, 0, 1]
                        } else {
                            // Flash red when < 5s
                            if (_remaining < 5 && {(floor(time * 4)) mod 2 == 0}) then {
                                [1, 0, 0, 0.3]
                            } else {
                                [1, 0, 0, 1]
                            };
                        };
                    };
                    
                    // Bomb icon
                    drawIcon3D [
                        "\A3\ui_f\data\IGUI\Cfg\SimpleTasks\types\destroy_ca.paa",
                        _color,
                        [_pos select 0, _pos select 1, (_pos select 2) + 0.5],
                        1.5, 1.5, 0, "", 2, 0.05, "PuristaBold", "center"
                    ];
                    
                    // Countdown text
                    drawIcon3D [
                        "", _color,
                        [_pos select 0, _pos select 1, (_pos select 2) + 3],
                        0, 0, 0,
                        format ["BOMB - %1", _timeText],
                        2, 0.06, "PuristaBold", "center"
                    ];
                    
                    // Blast radius circle
                    private _radius = 10;
                    private _segments = 16;
                    for "_i" from 0 to _segments do {
                        private _a1 = (_i / _segments) * 360;
                        private _a2 = ((_i + 1) / _segments) * 360;
                        drawLine3D [
                            [(_pos select 0) + (_radius * cos _a1), (_pos select 1) + (_radius * sin _a1), (_pos select 2) + 0.1],
                            [(_pos select 0) + (_radius * cos _a2), (_pos select 1) + (_radius * sin _a2), (_pos select 2) + 0.1],
                            [_color select 0, _color select 1, _color select 2, 0.4]
                        ];
                    };
                };
            };
        } forEach (allVariables missionNamespace);
    }];
    
    // Store draw handler for cleanup
    missionNamespace setVariable [_bombID + "_drawHandler", _drawHandler];
    
    private _fuseText = if (_fuseTime < 60) then {
        format ["%1 seconds", _fuseTime]
    } else {
        format ["%1 minutes", floor(_fuseTime / 60)]
    };
    
    hint parseText format [
        "<t size='1.2' color='#ff6633'>Explosive Placed</t><br/><br/>Fuse: <t color='#ffcc66'>%1</t><br/>Get clear!",
        _fuseText
    ];
    
    // Countdown loop
    for [{private _i = _fuseTime}, {_i > 0}, {_i = _i - 1}] do {
        // Announcements at key intervals
        if (_i == 60 || _i == 30 || _i == 20 || _i == 10 || _i <= 5) then {
            systemChat format ["Bomb detonates in %1 seconds", _i];
        };
        sleep 1;
    };
    
    // BOOM
    if (!isNull _bomb) then {
        // Cleanup Draw3D
        missionNamespace setVariable [_bombID + "_active", false];
        private _dh = missionNamespace getVariable [_bombID + "_drawHandler", -1];
        if (_dh != -1) then {
            removeMissionEventHandler ["Draw3D", _dh];
        };
        
        systemChat "BOOM! Explosive detonated!";
        _bomb setDamage 1;
    };
    
    diag_log format ["[OpsRoom] Timebomb detonated at %1", _targetPos];
};
