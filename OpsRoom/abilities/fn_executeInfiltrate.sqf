/*
    OpsRoom_fnc_executeInfiltrate
    
    SOE agent infiltrates to target position stealthily.
    Quick mode: faster movement, limited detection reduction
    Deep mode: very slow, near-invisible (setCaptive), prone crawl
    
    Parameters:
        0: OBJECT - SOE agent
        1: ARRAY  - Target position
        2: STRING - Mode: "quick" or "deep"
*/

params ["_unit", "_targetPos", "_mode"];

private _modeText = if (_mode == "deep") then {"Deep"} else {"Quick"};
systemChat format ["%1 beginning %2 infiltration", name _unit, _modeText];

[_unit, _targetPos, _mode] spawn {
    params ["_unit", "_targetPos", "_mode"];
    
    // Save original state
    private _origBehaviour = behaviour _unit;
    private _origSpeed = speedMode (group _unit);
    private _origPos = unitPos _unit;
    
    // Apply infiltration settings
    _unit setBehaviour "STEALTH";
    _unit setUnitPos "MIDDLE";
    
    if (_mode == "deep") then {
        // Deep infiltration: near-invisible
        _unit setCaptive true;
        _unit setUnitPos "DOWN";
        (group _unit) setSpeedMode "LIMITED";
        _unit forceSpeed 2; // Very slow crawl
    } else {
        // Quick infiltration: stealthy but faster
        (group _unit) setSpeedMode "LIMITED";
        _unit forceSpeed 6;
    };
    
    // Move to target
    _unit doMove _targetPos;
    
    // Draw3D infiltration path marker
    private _infID = format ["infiltrate_%1_%2", getPlayerUID player, diag_tickTime];
    missionNamespace setVariable [_infID + "_active", true];
    missionNamespace setVariable [_infID + "_unit", _unit];
    missionNamespace setVariable [_infID + "_target", _targetPos];
    missionNamespace setVariable [_infID + "_mode", _mode];
    
    private _drawHandler = addMissionEventHandler ["Draw3D", {
        {
            if (_x find "infiltrate_" == 0 && {_x find "_active" > 0}) then {
                private _baseID = _x select [0, (count _x) - 7];
                if (missionNamespace getVariable [_x, false]) then {
                    private _unit = missionNamespace getVariable [_baseID + "_unit", objNull];
                    private _target = missionNamespace getVariable [_baseID + "_target", [0,0,0]];
                    private _mode = missionNamespace getVariable [_baseID + "_mode", "quick"];
                    
                    if (!isNull _unit && {alive _unit}) then {
                        private _unitPos = getPos _unit;
                        private _color = if (_mode == "deep") then {[0.5, 0, 0.8, 0.4]} else {[0.5, 0.5, 0.8, 0.4]};
                        
                        // Dashed line to destination
                        drawLine3D [
                            _unitPos vectorAdd [0,0,0.5],
                            _target vectorAdd [0,0,0.3],
                            _color
                        ];
                        
                        // Status above unit
                        private _dist = round (_unitPos distance _target);
                        private _modeLabel = if (_mode == "deep") then {"DEEP"} else {"QUICK"};
                        drawIcon3D ["", _color vectorAdd [0,0,0,0.6],
                            [_unitPos select 0, _unitPos select 1, (_unitPos select 2) + 3],
                            0, 0, 0,
                            format ["INFILTRATING (%1) - %2m", _modeLabel, _dist],
                            2, 0.04, "PuristaBold", "center"
                        ];
                        
                        // Destination marker
                        drawIcon3D [
                            "a3\ui_f\data\igui\cfg\simpleTasks\types\scout_ca.paa",
                            _color,
                            _target vectorAdd [0,0,0.5],
                            1, 1, 0, "", 2, 0.04, "PuristaBold", "center"
                        ];
                    };
                };
            };
        } forEach (allVariables missionNamespace);
    }];
    
    missionNamespace setVariable [_infID + "_drawHandler", _drawHandler];
    
    // Wait until arrival or death
    waitUntil {
        sleep 1;
        
        // Re-issue move command periodically (AI can get distracted)
        if (alive _unit && {_unit distance _targetPos > 5}) then {
            if (unitReady _unit) then {
                _unit doMove _targetPos;
            };
        };
        
        (_unit distance _targetPos < 5) || !(alive _unit)
    };
    
    // Cleanup Draw3D
    missionNamespace setVariable [_infID + "_active", false];
    private _dh = missionNamespace getVariable [_infID + "_drawHandler", -1];
    if (_dh != -1) then {
        removeMissionEventHandler ["Draw3D", _dh];
    };
    
    if (!alive _unit) exitWith {
        systemChat format ["%1 was killed during infiltration", name _unit];
        // Ensure captive is reset even on death cleanup
        _unit setCaptive false;
    };
    
    // Arrived — go prone, enter overwatch
    _unit setUnitPos "DOWN";
    _unit disableAI "MOVE";
    _unit doWatch _targetPos;
    
    // Remove captive status (deep mode)
    if (_mode == "deep") then {
        _unit setCaptive false;
    };
    
    // Restore speed
    _unit forceSpeed -1;
    (group _unit) setSpeedMode _origSpeed;
    
    // Re-enable movement after 3 seconds so unit can defend itself
    sleep 3;
    _unit enableAI "MOVE";
    _unit setUnitPos "AUTO";
    
    private _modeText = if (_mode == "deep") then {"Deep"} else {"Quick"};
    
    hint parseText format [
        "<t size='1.2' color='#8800ff'>Infiltration Complete</t><br/><br/>%1 is in position",
        name _unit
    ];
    
    systemChat format ["%1 %2 infiltration complete - in position", name _unit, _modeText];
    diag_log format ["[OpsRoom] Infiltrate complete: %1 mode %2", name _unit, _mode];
};
