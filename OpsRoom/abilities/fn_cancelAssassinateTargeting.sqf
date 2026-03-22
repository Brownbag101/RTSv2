/*
    OpsRoom_fnc_cancelAssassinateTargeting
    
    Cleanup assassination targeting state, markers, and handlers.
*/

// Remove Draw3D markers
missionNamespace setVariable ["OpsRoom_Assassinate_Markers_Active", false];

if (!isNil "OpsRoom_Assassinate_DrawHandler") then {
    removeMissionEventHandler ["Draw3D", OpsRoom_Assassinate_DrawHandler];
    OpsRoom_Assassinate_DrawHandler = nil;
};

// Remove ESC handler
if (!isNil "OpsRoom_Assassinate_ESCHandler") then {
    private _display = findDisplay 312;
    if (!isNull _display) then {
        _display displayRemoveEventHandler ["KeyDown", OpsRoom_Assassinate_ESCHandler];
    };
    OpsRoom_Assassinate_ESCHandler = nil;
};

// Remove Mouse handler
if (!isNil "OpsRoom_Assassinate_MouseHandler") then {
    private _display = findDisplay 312;
    if (!isNull _display) then {
        _display displayRemoveEventHandler ["MouseButtonDown", OpsRoom_Assassinate_MouseHandler];
    };
    OpsRoom_Assassinate_MouseHandler = nil;
};

// Close menu
[] call OpsRoom_fnc_closeButtonMenu;

// Clear state
OpsRoom_Assassinate_Agent = nil;
OpsRoom_Assassinate_Targets = nil;
OpsRoom_Assassinate_SelectedIndex = nil;
