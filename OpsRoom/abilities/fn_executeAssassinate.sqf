/*
    OpsRoom_fnc_executeAssassinate
    
    SOE agent moves to selected target and performs silent kill.
    Uses OpsRoom_Assassinate_SelectedIndex set by the dynamic menu.
*/

private _idx = OpsRoom_Assassinate_SelectedIndex;
if (isNil "_idx") exitWith { hint "No target selected"; };

private _targets = OpsRoom_Assassinate_Targets;
if (isNil "_targets" || {_idx >= count _targets}) exitWith { hint "Invalid target"; };

private _targetData = _targets select _idx;
_targetData params ["_enemy", "_dist"];

private _agent = OpsRoom_Assassinate_Agent;
if (isNil "_agent" || {isNull _agent}) exitWith { hint "No agent available"; };

// Cleanup targeting UI
[] call OpsRoom_fnc_cancelAssassinateTargeting;

if (!alive _enemy) exitWith {
    hint "Target is already dead";
};

systemChat format ["%1 moving to eliminate target", name _agent];

[_agent, _enemy] spawn {
    params ["_agent", "_target"];
    
    // Save original state
    private _origBehaviour = behaviour _agent;
    
    // Go stealth
    _agent setBehaviour "STEALTH";
    _agent setCaptive true;
    _agent setUnitPos "MIDDLE";
    (group _agent) setSpeedMode "NORMAL";
    
    // Draw3D marker on target during approach
    private _assID = format ["assassinate_%1_%2", getPlayerUID player, diag_tickTime];
    missionNamespace setVariable [_assID + "_active", true];
    missionNamespace setVariable [_assID + "_agent", _agent];
    missionNamespace setVariable [_assID + "_target", _target];
    
    private _drawHandler = addMissionEventHandler ["Draw3D", {
        {
            if (_x find "assassinate_" == 0 && {_x find "_active" > 0}) then {
                private _baseID = _x select [0, (count _x) - 7];
                if (missionNamespace getVariable [_x, false]) then {
                    private _agent = missionNamespace getVariable [_baseID + "_agent", objNull];
                    private _target = missionNamespace getVariable [_baseID + "_target", objNull];
                    
                    if (!isNull _agent && {!isNull _target} && {alive _agent} && {alive _target}) then {
                        private _aPos = getPos _agent;
                        private _tPos = getPos _target;
                        private _dist = round (_aPos distance _tPos);
                        
                        // Line from agent to target
                        drawLine3D [
                            _aPos vectorAdd [0,0,0.5],
                            _tPos vectorAdd [0,0,0.5],
                            [1, 0, 0, 0.3]
                        ];
                        
                        // Kill marker on target
                        drawIcon3D [
                            "\A3\ui_f\data\IGUI\Cfg\SimpleTasks\types\kill_ca.paa",
                            [1, 0, 0, 0.8],
                            _tPos vectorAdd [0,0,2.5],
                            1.5, 1.5, 0, "", 2, 0.05, "PuristaBold", "center"
                        ];
                        
                        // Distance text
                        drawIcon3D ["", [1, 0, 0, 1],
                            _tPos vectorAdd [0,0,4],
                            0, 0, 0,
                            format ["ELIMINATING - %1m", _dist],
                            2, 0.04, "PuristaBold", "center"
                        ];
                    };
                };
            };
        } forEach (allVariables missionNamespace);
    }];
    
    missionNamespace setVariable [_assID + "_drawHandler", _drawHandler];
    
    // Move to target
    _agent doMove (getPos _target);
    
    // Wait until close enough (3m) or death
    waitUntil {
        sleep 0.5;
        
        // Re-issue move if AI gets stuck
        if (alive _agent && alive _target && {_agent distance _target > 3}) then {
            if (unitReady _agent) then {
                _agent doMove (getPos _target);
            };
        };
        
        (_agent distance _target < 3) || !(alive _agent) || !(alive _target)
    };
    
    // Cleanup Draw3D
    missionNamespace setVariable [_assID + "_active", false];
    private _dh = missionNamespace getVariable [_assID + "_drawHandler", -1];
    if (_dh != -1) then {
        removeMissionEventHandler ["Draw3D", _dh];
    };
    
    // Restore captive
    _agent setCaptive false;
    
    if (!alive _agent) exitWith {
        systemChat format ["%1 was killed during assassination attempt", name _agent];
    };
    
    if (!alive _target) exitWith {
        systemChat "Target already eliminated";
        _agent setBehaviour _origBehaviour;
    };
    
    // Perform the kill
    // Agent plays melee animation, target dies silently
    _agent playMoveNow "AinvPknlMstpSnonWnonDnon_AinvPknlMstpSnonWnonDnon_medic";
    sleep 1;
    
    // Silent kill — set damage directly
    _target setDamage 1;
    
    // Remove from known enemies
    if (!isNil "OpsRoom_KnownEnemies") then {
        OpsRoom_KnownEnemies = OpsRoom_KnownEnemies select {
            (_x select 0) != _target
        };
    };
    
    // Restore agent
    _agent setBehaviour "STEALTH";
    _agent setUnitPos "AUTO";
    
    hint parseText format [
        "<t size='1.2' color='#ff0000'>Target Eliminated</t><br/><br/>%1 completed assassination",
        name _agent
    ];
    
    systemChat format ["%1 eliminated target", name _agent];
    diag_log format ["[OpsRoom] Assassination complete: %1 killed %2", name _agent, name _target];
};
