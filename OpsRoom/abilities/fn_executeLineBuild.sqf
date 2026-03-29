/*
    OpsRoom_fnc_executeLineBuild
    
    Executes line construction. Engineer walks along line building each object.
    Resources already deducted by startLinePlacement.
    
    Parameters:
        0: OBJECT - Engineer unit
        1: STRING - Build ID
        2: ARRAY  - Array of positions
        3: NUMBER - Direction for all objects
        4: NUMBER - Total object count
*/

params ["_engineer", "_buildId", "_positions", "_dir", "_count"];

private _buildData = OpsRoom_Buildables get _buildId;
if (isNil "_buildData") exitWith { systemChat "Build: Unknown item" };

private _className = _buildData get "className";
private _displayName = _buildData get "displayName";
private _buildTime = _buildData getOrDefault ["buildTime", 10];
private _isMine = _buildData getOrDefault ["isMine", false];

// Time per object in line mode (faster than single — 60% of normal)
private _timePerObj = (_buildTime * 0.6) max 3;

[_engineer, _className, _displayName, _positions, _dir, _timePerObj, _isMine, _count] spawn {
    params ["_eng", "_cls", "_name", "_positions", "_dir", "_timePerObj", "_isMine", "_total"];
    
    systemChat format ["%1 building %2x %3...", name _eng, _total, _name];
    
    // Draw3D progress for line build
    private _lineMarkerId = format ["OpsRoom_LineBuild_%1", diag_tickTime];
    missionNamespace setVariable [_lineMarkerId, true];
    missionNamespace setVariable [_lineMarkerId + "_built", 0];
    missionNamespace setVariable [_lineMarkerId + "_total", _total];
    missionNamespace setVariable [_lineMarkerId + "_name", _name];
    missionNamespace setVariable [_lineMarkerId + "_eng", _eng];
    
    addMissionEventHandler ["Draw3D", {
        private _mid = _thisArgs select 0;
        if !(missionNamespace getVariable [_mid, false]) exitWith {
            removeMissionEventHandler ["Draw3D", _thisEventHandler];
        };
        private _engUnit = missionNamespace getVariable [_mid + "_eng", objNull];
        if (isNull _engUnit) exitWith {};
        private _blt = missionNamespace getVariable [_mid + "_built", 0];
        private _tot = missionNamespace getVariable [_mid + "_total", 0];
        private _nm = missionNamespace getVariable [_mid + "_name", ""];
        private _drawPos = (getPosATL _engUnit) vectorAdd [0, 0, 3];
        
        // Progress bar
        drawIcon3D ["\A3\ui_f\data\igui\cfg\simpletasks\types\use_ca.paa", [0.1,0.1,0.1,0.5], _drawPos, 1.5, 0.15, 0, "", 0, 0];
        private _fillW = if (_tot > 0) then { 1.5 * (_blt / _tot) } else { 0 };
        drawIcon3D ["\A3\ui_f\data\igui\cfg\simpletasks\types\use_ca.paa", [0.2,0.6,1,0.8], _drawPos, _fillW, 0.15, 0, "", 0, 0];
        drawIcon3D ["", [1,1,1,0.9], _drawPos vectorAdd [0,0,-1.5], 0, 0, 0,
            format ["Building %1: %2/%3", _nm, _blt, _tot], 2, 0.035, "PuristaMedium", "center", true];
    }, [_lineMarkerId]];
    
    private _built = 0;
    
    {
        private _pos = _x;
        
        if !(alive _eng) exitWith {};
        
        // Move to position
        _eng doMove _pos;
        waitUntil {
            sleep 0.5;
            (_eng distance _pos < 4) || !(alive _eng)
        };
        if !(alive _eng) exitWith {};
        
        // Stop and build
        _eng disableAI "MOVE";
        _eng playMoveNow "AinvPknlMstpSnonWnonDnon_medic4";
        
        sleep _timePerObj;
        
        if !(alive _eng) exitWith {};
        
        // Place the object
        private _obj = createVehicle [_cls, _pos, [], 0, "CAN_COLLIDE"];
        _obj setPosATL _pos;
        _obj setDir _dir;
        _obj setVariable ["OpsRoom_IsBuiltObject", true, true];
        
        if (_isMine) then {
            _obj setVariable ["OpsRoom_IsPlayerMine", true, true];
        };
        
        // Add to Zeus
        private _curator = getAssignedCuratorLogic player;
        if (!isNull _curator) then {
            _curator addCuratorEditableObjects [[_obj], true];
        };
        
        _built = _built + 1;
        missionNamespace setVariable [_lineMarkerId + "_built", _built];
        _eng enableAI "MOVE";
        
        systemChat format ["%1 building %2... (%3/%4)", name _eng, _name, _built, _total];
        
    } forEach _positions;
    
    // Cleanup Draw3D
    missionNamespace setVariable [_lineMarkerId, nil];
    
    if (alive _eng) then {
        systemChat format ["%1: Line construction complete! %2x %3 placed", name _eng, _built, _name];
    } else {
        systemChat format ["Construction interrupted — %1/%2 %3 placed before engineer was killed", _built, _total, _name];
    };
    
    diag_log format ["[OpsRoom] Line build complete: %1x %2 by %3 (%4 placed)", _total, _name, name _eng, _built];
};
