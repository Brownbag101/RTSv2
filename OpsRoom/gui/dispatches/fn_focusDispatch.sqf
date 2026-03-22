/*
    fn_focusDispatch
    
    Moves the Zeus camera to the dispatch's focus target.
    Uses position if available, otherwise focus object position.
    Reuses the proven curator camera pattern.
    
    Parameters:
        0: STRING - Dispatch ID
*/

params [["_dispatchId", "", [""]]];

// Find the dispatch
private _dispatch = objNull;
{
    if ((_x get "id") == _dispatchId) exitWith {
        _dispatch = _x;
    };
} forEach OpsRoom_Dispatches;

if (isNil "_dispatch" || {_dispatch isEqualTo objNull}) exitWith {
    diag_log format ["[OpsRoom] Focus dispatch failed - ID not found: %1", _dispatchId];
};

// Determine focus target
private _focusPos = _dispatch get "focusPos";
private _focusObj = _dispatch get "focusObj";
private _targetPos = [];

// Prefer object position if alive, otherwise use stored position
if (!isNull _focusObj && {alive _focusObj}) then {
    _targetPos = getPosATL _focusObj;
} else {
    if (!isNil "_focusPos") then {
        _targetPos = _focusPos;
    };
};

if (count _targetPos == 0) exitWith {
    diag_log format ["[OpsRoom] Focus dispatch - no valid target for: %1", _dispatchId];
};

// Move Zeus camera to target with angled view
private _curator = getAssignedCuratorLogic player;
if (isNull _curator) exitWith {};

// Position camera offset: 30m south, 50m up — looking north at target
private _cam = curatorCamera;
private _camPos = [
    (_targetPos select 0),
    (_targetPos select 1) - 30,
    (_targetPos select 2) + 50
];

_cam setPosATL _camPos;

// Point camera at target
private _dirTo = _camPos vectorFromTo [_targetPos select 0, _targetPos select 1, (_targetPos select 2) + 2];
_cam setVectorDirAndUp [
    _dirTo,
    [0, 0.6, 0.8]  // Tilted up slightly
];

// If focusing on an object, ensure visible and select it
if (!isNull _focusObj && {alive _focusObj}) then {
    _curator addCuratorEditableObjects [[_focusObj], false];
};

systemChat format ["Dispatch: Focused on %1", _dispatch get "title"];

diag_log format ["[OpsRoom] Focused on dispatch %1 at %2", _dispatchId, _targetPos];
