/*
    OpsRoom_fnc_executeDemolish
    
    Demolishes a player-built structure, returning 50% of resources.
    Engineer must be near the object.
    
    Called from the repair ability menu (DEMOLISH option) or directly.
    
    Parameters:
        0: OBJECT - Engineer unit
        1: OBJECT - Object to demolish
*/

params ["_engineer", "_target"];

if (isNull _engineer || isNull _target) exitWith {};

// Must be a player-built object
if !(_target getVariable ["OpsRoom_IsBuiltObject", false]) exitWith {
    systemChat format ["%1: Can only demolish player-built structures", name _engineer];
};

[_engineer, _target] spawn {
    params ["_eng", "_obj"];
    
    // Move to the object
    if (_eng distance _obj > 5) then {
        _eng doMove (getPos _obj);
        waitUntil { sleep 0.5; (_eng distance _obj < 5) || !(alive _eng) };
        if !(alive _eng) exitWith {};
    };
    
    // Get object info for resource return
    private _objType = typeOf _obj;
    private _objName = getText (configFile >> "CfgVehicles" >> _objType >> "displayName");
    if (_objName == "") then { _objName = "Structure" };
    
    // Find the build data to calculate refund
    private _refundCost = [];
    {
        private _buildData = _y;
        if ((_buildData get "className") == _objType) exitWith {
            _refundCost = _buildData get "cost";
        };
    } forEach OpsRoom_Buildables;
    
    systemChat format ["%1 demolishing %2...", name _eng, _objName];
    _eng disableAI "MOVE";
    _eng playMoveNow "AinvPknlMstpSnonWnonDnon_medic4";
    sleep 10;
    
    if !(alive _eng) exitWith {
        _eng enableAI "MOVE";
        systemChat "Demolition interrupted - engineer killed";
    };
    
    _eng enableAI "MOVE";
    
    // Delete the object
    deleteVehicle _obj;
    
    // Return 50% resources
    if (count _refundCost > 0) then {
        private _refundStr = "";
        {
            _x params ["_res", "_amt"];
            private _refund = floor(_amt * 0.5);
            if (_refund > 0) then {
                private _cleanRes = _res;
                while {_cleanRes find " " != -1} do {
                    private _sp = _cleanRes find " ";
                    _cleanRes = (_cleanRes select [0, _sp]) + "_" + (_cleanRes select [_sp + 1]);
                };
                private _varName = format ["OpsRoom_Resource_%1", _cleanRes];
                private _current = missionNamespace getVariable [_varName, 0];
                missionNamespace setVariable [_varName, _current + _refund];
                
                if (_refundStr != "") then { _refundStr = _refundStr + ", " };
                _refundStr = _refundStr + format ["+%1 %2", _refund, _res];
            };
        } forEach _refundCost;
        
        [] call OpsRoom_fnc_updateResources;
        
        if (_refundStr != "") then {
            systemChat format ["%1 demolished %2 — salvaged: %3", name _eng, _objName, _refundStr];
        } else {
            systemChat format ["%1 demolished %2", name _eng, _objName];
        };
    } else {
        systemChat format ["%1 demolished %2", name _eng, _objName];
    };
    
    diag_log format ["[OpsRoom] Demolished: %1 by %2", _objName, name _eng];
};
