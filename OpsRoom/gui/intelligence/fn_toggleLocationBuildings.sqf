/*
    fn_toggleLocationBuildings
    
    Adds or removes a location's registered buildings from Zeus curator.
    Called when ownership flips in the capture monitor.
    
    Parameters:
        0: STRING - Location ID
        1: STRING - "add" or "remove"
    
    Usage:
        ["loc_factory_1", "add"] call OpsRoom_fnc_toggleLocationBuildings;
        ["loc_factory_1", "remove"] call OpsRoom_fnc_toggleLocationBuildings;
*/

params [["_locId", "", [""]], ["_action", "", [""]]];

if (_locId == "" || _action == "") exitWith {
    diag_log "[OpsRoom] toggleLocationBuildings: missing locId or action";
};

private _locData = OpsRoom_StrategicLocations getOrDefault [_locId, createHashMap];
if (count _locData == 0) exitWith {
    diag_log format ["[OpsRoom] toggleLocationBuildings: location '%1' not found", _locId];
};

private _buildings = _locData getOrDefault ["buildings", []];
private _name = _locData getOrDefault ["name", _locId];

if (count _buildings == 0) exitWith {
    systemChat format ["Buildings: No buildings registered for %1", _name];
    diag_log format ["[OpsRoom] toggleLocationBuildings: no buildings registered for '%1'", _locId];
};

// Filter out null/deleted objects
private _validBuildings = _buildings select { !isNull _x };

if (count _validBuildings == 0) exitWith {
    systemChat format ["Buildings: All buildings null/deleted at %1", _name];
    diag_log format ["[OpsRoom] toggleLocationBuildings: all buildings null at '%1'", _locId];
};

// Find curator — try getAssignedCuratorLogic first, fall back to allCurators
private _curator = getAssignedCuratorLogic player;
if (isNull _curator) then {
    {
        if (_x isKindOf "ModuleCurator_F") exitWith {
            _curator = _x;
        };
    } forEach allCurators;
};

if (isNull _curator) exitWith {
    systemChat format ["Buildings: No curator found — cannot toggle for %1", _name];
    diag_log "[OpsRoom] toggleLocationBuildings: no curator found";
};

if (_action == "add") then {
    // Replace terrain buildings with spawned mission objects
    // Terrain-baked buildings cannot be made Zeus-editable via addCuratorEditableObjects.
    // Solution: hide the terrain building + spawn an identical object at the same position.
    // The spawned object IS a mission entity and CAN be edited in Zeus.
    private _replacements = [];
    {
        private _building = _x;
        
        // Skip if already replaced
        if (_building getVariable ["OpsRoom_Replaced", false]) then {
            // Already replaced — just re-add the replacement to curator
            private _rep = _building getVariable ["OpsRoom_Replacement", objNull];
            if (!isNull _rep) then {
                _replacements pushBack _rep;
            };
        } else {
            // Check if this is an Eden-placed object (already a mission entity)
            // getObjectType: 1 = terrain-placed, 8 = mission/editor-placed
            private _objType = getObjectType _building;
            private _isEditorPlaced = (_objType == 8);
            
            if (_isEditorPlaced) then {
                // Eden-placed: add directly without replacement
                _building setVariable ["OpsRoom_LocationId", _locId];
                _building setVariable ["OpsRoom_IsLocationBuilding", true];
                _building setVariable ["OpsRoom_OriginalPos", getPosATL _building];
                _replacements pushBack _building;
                diag_log format ["[OpsRoom] Eden building added directly: %1", typeOf _building];
            } else {
                // Terrain object: hide original and spawn mission entity replacement
                private _type = typeOf _building;
                private _bPos = getPosATL _building;
                private _bDir = getDir _building;
                private _bVecUp = vectorUp _building;
                private _bDmg = damage _building;
                
                _building hideObjectGlobal true;
                _building enableSimulationGlobal false;
                
                private _replacement = createVehicle [_type, _bPos, [], 0, "CAN_COLLIDE"];
                _replacement setPosATL _bPos;
                _replacement setDir _bDir;
                _replacement setVectorUp _bVecUp;
                _replacement setDamage _bDmg;
                
                _replacement setVariable ["OpsRoom_LocationId", _locId];
                _replacement setVariable ["OpsRoom_IsLocationBuilding", true];
                
                _building setVariable ["OpsRoom_Replaced", true];
                _building setVariable ["OpsRoom_Replacement", _replacement];
                _replacement setVariable ["OpsRoom_OriginalBuilding", _building];
                
                _replacement addEventHandler ["Killed", {
                    params ["_building"];
                    private _locId = _building getVariable ["OpsRoom_LocationId", ""];
                    if (_locId == "") exitWith {};
                    
                    private _locData = OpsRoom_StrategicLocations getOrDefault [_locId, createHashMap];
                    if (count _locData == 0) exitWith {};
                    
                    private _buildings = _locData getOrDefault ["buildings", []];
                    private _aliveCount = 0;
                    {
                        private _obj = _x;
                        private _checkObj = if (_obj getVariable ["OpsRoom_Replaced", false]) then {
                            _obj getVariable ["OpsRoom_Replacement", objNull]
                        } else { _obj };
                        if (!isNull _checkObj && {alive _checkObj && {damage _checkObj < 1}}) then {
                            _aliveCount = _aliveCount + 1;
                        };
                    } forEach _buildings;
                    
                    _locData set ["buildingsAlive", _aliveCount];
                    private _name = _locData get "name";
                    private _total = _locData getOrDefault ["buildingsTotal", 0];
                    
                    diag_log format ["[OpsRoom] Buildings: Building destroyed at %1 (%2/%3 remaining)", _name, _aliveCount, _total];
                    
                    if (_aliveCount == 0) then {
                        _locData set ["status", "destroyed"];
                        OpsRoom_StrategicLocations set [_locId, _locData];
                        [_locId] call OpsRoom_fnc_updateMapMarkers;
                        ["FLASH", "LOCATION DESTROYED",
                            format ["%1 has been completely destroyed!", _name],
                            _locData get "pos"
                        ] call OpsRoom_fnc_dispatch;
                    } else {
                        if (_aliveCount == 1) then {
                            ["PRIORITY", "LOCATION CRITICAL",
                                format ["%1 critically damaged! 1 structure remaining.", _name],
                                _locData get "pos"
                            ] call OpsRoom_fnc_dispatch;
                        };
                    };
                    OpsRoom_StrategicLocations set [_locId, _locData];
                }];
                
                _replacements pushBack _replacement;
                diag_log format ["[OpsRoom] Building replaced: %1 at %2 (original hidden)", _type, _bPos];
            };
        };
    } forEach _validBuildings;
    
    // Add spawned replacements to curator
    if (count _replacements > 0) then {
        _curator addCuratorEditableObjects [_replacements, true];
    };
    
    systemChat format ["Buildings: %1 buildings now editable at %2", count _replacements, _name];
    diag_log format ["[OpsRoom] Buildings REPLACED and added to Zeus for %1 (%2 buildings)", _name, count _replacements];
} else {
    if (_action == "remove") then {
        _curator removeCuratorEditableObjects [_validBuildings, true];
        systemChat format ["Buildings: %1 buildings locked at %2", count _validBuildings, _name];
        diag_log format ["[OpsRoom] Buildings REMOVED from Zeus for %1 (%2 buildings)", _name, count _validBuildings];
    } else {
        diag_log format ["[OpsRoom] toggleLocationBuildings: invalid action '%1' (use 'add' or 'remove')", _action];
    };
};

// Update stored array (remove nulls)
_locData set ["buildings", _validBuildings];
OpsRoom_StrategicLocations set [_locId, _locData];
