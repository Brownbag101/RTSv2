/*
    Create 3D Marker for Zeus
    
    Creates a persistent Draw3D marker visible in Zeus interface.
    Pattern proven to work - stores data in missionNamespace, Draw3D reads it.
    
    Parameters:
        0: STRING - Marker ID (unique identifier)
        1: ARRAY/OBJECT - Position [x,y,z] or Object to follow
        2: STRING - Text to display
        3: STRING - Icon texture path (default: objective icon)
        4: ARRAY - Color [R,G,B,A] (default: blue)
        5: NUMBER - Icon size multiplier (default: 2)
    
    Returns:
        NUMBER - Event handler ID
    
    Usage:
        private _handlerId = [
            "myMarker",
            [x, y, z],
            "OBJECTIVE",
            "\A3\ui_f\data\map\markers\military\objective_CA.paa",
            [0.2, 0.6, 1, 1],
            2
        ] call OpsRoom_fnc_create3DMarker;
        
        // Later, to remove:
        ["myMarker"] call OpsRoom_fnc_remove3DMarker;
*/

params [
    ["_markerId", "", [""]],
    ["_position", [0,0,0], [[], objNull]],
    ["_text", "", [""]],
    ["_iconPath", "\A3\ui_f\data\map\markers\military\objective_CA.paa", [""]],
    ["_color", [0.2, 0.6, 1, 1], [[]]],
    ["_iconSize", 2, [0]]
];

if (_markerId == "") exitWith {
    diag_log "[OpsRoom] ERROR: 3D Marker ID not provided";
    -1
};

// Store marker data in missionNamespace variable
private _markerVarName = format ["OpsRoom_3DMarker_%1", _markerId];
missionNamespace setVariable [_markerVarName, [_position, _text, _iconPath, _color, _iconSize]];

diag_log format ["[OpsRoom] 3D Marker data stored: %1 at %2", _markerId, _position];

// Create Draw3D event handler
// Note: We capture _markerVarName in the closure so the handler knows which variable to read
private _handlerId = addMissionEventHandler ["Draw3D", {
    // Get the marker variable name from the captured closure
    private _varName = _thisArgs select 0;
    private _markerData = missionNamespace getVariable [_varName, []];
    
    // If marker data is gone, remove this handler
    if (count _markerData == 0) exitWith {
        removeMissionEventHandler ["Draw3D", _thisEventHandler];
        diag_log format ["[OpsRoom] 3D Marker handler auto-removed: %1", _varName];
    };
    
    _markerData params ["_pos", "_txt", "_icon", "_col", "_size"];
    
    // Handle position (can be array or object)
    private _drawPos = _pos;
    if (_pos isEqualType objNull) then {
        if (!isNull _pos) then {
            _drawPos = ASLToAGL (AGLToASL (getPos _pos));
        } else {
            _drawPos = [];
        };
    };
    
    // Draw icon if we have a valid position
    if (count _drawPos >= 3) then {
        drawIcon3D [
            _icon,
            _col,
            _drawPos,
            _size,
            _size,
            0,
            _txt,
            2,          // shadow (2 = outline)
            0.05,       // text size
            "PuristaMedium",
            "center",
            true
        ];
    };
}, [_markerVarName]];  // Pass variable name as argument

diag_log format ["[OpsRoom] 3D Marker created: %1 (handler: %2)", _markerId, _handlerId];

_handlerId
