/*
    TEST: Simple 3D Marker
    
    Super simple test to see if Draw3D works at all.
*/

params [
    ["_position", [0,0,0], [[]]]
];

// Store position globally
missionNamespace setVariable ["TEST_Marker_Pos", _position];

diag_log format ["[TEST] Creating test marker at: %1", _position];
systemChat format ["TEST: Creating marker at %1", _position];

// Simple Draw3D handler
private _handlerId = addMissionEventHandler ["Draw3D", {
    private _pos = missionNamespace getVariable ["TEST_Marker_Pos", []];
    
    if (count _pos < 3) exitWith {};
    
    // Draw big red icon
    drawIcon3D [
        "\A3\ui_f\data\map\markers\military\objective_CA.paa",
        [1, 0, 0, 1],  // RED
        _pos,
        3,  // BIG
        3,
        0,
        "TEST MARKER",
        2,
        0.1,
        "PuristaBold"
    ];
}];

systemChat format ["TEST: Handler created: %1", _handlerId];
diag_log format ["[TEST] Handler ID: %1", _handlerId];

_handlerId
