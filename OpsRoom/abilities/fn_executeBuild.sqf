/*
    OpsRoom_fnc_executeBuild
    
    Executes single-object construction.
    Engineer moves to position, plays animation, object appears over time.
    
    Parameters:
        0: OBJECT - Engineer unit
        1: STRING - Build ID
        2: ARRAY  - Position [x,y,z]
        3: NUMBER - Direction
*/

params ["_engineer", "_buildId", "_pos", "_dir"];

private _buildData = OpsRoom_Buildables get _buildId;
if (isNil "_buildData") exitWith { systemChat "Build: Unknown item" };

private _className = _buildData get "className";
private _displayName = _buildData get "displayName";
private _cost = _buildData get "cost";
private _buildTime = _buildData getOrDefault ["buildTime", 10];
private _isMine = _buildData getOrDefault ["isMine", false];

// Deduct resources
{
    _x params ["_res", "_amt"];
    private _cleanRes = _res;
    while {_cleanRes find " " != -1} do {
        private _sp = _cleanRes find " ";
        _cleanRes = (_cleanRes select [0, _sp]) + "_" + (_cleanRes select [_sp + 1]);
    };
    private _varName = format ["OpsRoom_Resource_%1", _cleanRes];
    private _current = missionNamespace getVariable [_varName, 0];
    missionNamespace setVariable [_varName, _current - _amt];
} forEach _cost;
[] call OpsRoom_fnc_updateResources;

[_engineer, _className, _displayName, _pos, _dir, _buildTime, _isMine] spawn {
    params ["_eng", "_cls", "_name", "_pos", "_dir", "_time", "_isMine"];
    
    // Move engineer to build site
    systemChat format ["%1 moving to build %2...", name _eng, _name];
    _eng doMove _pos;
    
    waitUntil {
        sleep 0.5;
        (_eng distance _pos < 5) || !(alive _eng)
    };
    
    if !(alive _eng) exitWith {
        systemChat format ["%1 was killed before construction started", name _eng];
    };
    
    // Stop and face the build direction
    _eng disableAI "MOVE";
    _eng setDir (_eng getDir _pos);
    
    // Create the object (hidden during construction)
    private _built = createVehicle [_cls, _pos, [], 0, "CAN_COLLIDE"];
    _built setPosATL _pos;
    _built setDir _dir;
    
    if (_isMine) then {
        // Mines: set side ownership for triggering
        _built setVariable ["OpsRoom_IsPlayerMine", true, true];
        _built setVariable ["OpsRoom_IsBuiltObject", true, true];
    } else {
        // Building: start hidden, reveal on completion
        _built hideObjectGlobal true;
        _built setVariable ["OpsRoom_IsBuiltObject", true, true];
        _built setVariable ["OpsRoom_BuildId", _cls, true];
    };
    
    // Draw3D progress marker
    private _markerId = format ["OpsRoom_BuildProgress_%1", diag_tickTime];
    missionNamespace setVariable [_markerId, true];
    missionNamespace setVariable [_markerId + "_pct", 0];
    missionNamespace setVariable [_markerId + "_pos", _pos];
    missionNamespace setVariable [_markerId + "_name", _name];
    
    private _buildDrawEH = addMissionEventHandler ["Draw3D", {
        private _mid = _thisArgs select 0;
        if !(missionNamespace getVariable [_mid, false]) exitWith {
            removeMissionEventHandler ["Draw3D", _thisEventHandler];
        };
        private _progress = missionNamespace getVariable [_mid + "_pct", 0];
        private _bPos = missionNamespace getVariable [_mid + "_pos", [0,0,0]];
        private _bName = missionNamespace getVariable [_mid + "_name", ""];
        private _drawPos = _bPos vectorAdd [0,0,3];
        
        drawIcon3D ["\A3\ui_f\data\igui\cfg\simpletasks\types\use_ca.paa", [0.1,0.1,0.1,0.5], _drawPos, 1.5, 0.15, 0, "", 0, 0];
        private _fillW = 1.5 * (_progress / 100);
        drawIcon3D ["\A3\ui_f\data\igui\cfg\simpletasks\types\use_ca.paa", [0.2,0.6,1,0.8], _drawPos, _fillW, 0.15, 0, "", 0, 0];
        drawIcon3D ["", [1,1,1,0.9], _drawPos vectorAdd [0,0,-1.5], 0, 0, 0,
            format ["Building: %1... %2%%", _bName, _progress], 2, 0.035, "PuristaMedium", "center", true];
    }, [_markerId]];
    
    // Build loop
    private _steps = (_time / 5) max 1;
    for "_step" from 1 to _steps do {
        if !(alive _eng) exitWith {};
        
        _eng playMoveNow "AinvPknlMstpSnonWnonDnon_medic4";
        sleep 5;
        
        private _pct = round((_step / _steps) * 100);
        missionNamespace setVariable [_markerId + "_pct", _pct];
        systemChat format ["%1 building %2... %3%%", name _eng, _name, _pct];
    };
    
    // Re-enable engineer movement
    _eng enableAI "MOVE";
    
    // Check if engineer survived
    if !(alive _eng) exitWith {
        // Delete partially built object
        if (!_isMine) then { deleteVehicle _built };
        missionNamespace setVariable [_markerId, nil];
        systemChat format ["Construction of %1 failed - engineer killed", _name];
    };
    
    // Complete: reveal the object
    if (!_isMine) then {
        _built hideObjectGlobal false;
    };
    _built enableSimulationGlobal true;
    
    // Add to Zeus curator
    private _curator = getAssignedCuratorLogic player;
    if (!isNull _curator) then {
        _curator addCuratorEditableObjects [[_built], true];
    };
    
    // Cleanup Draw3D
    missionNamespace setVariable [_markerId, nil];
    
    systemChat format ["%1: %2 construction complete!", name _eng, _name];
    diag_log format ["[OpsRoom] Built: %1 at %2 by %3", _name, _pos, name _eng];
};
