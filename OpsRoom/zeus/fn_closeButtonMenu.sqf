/*
    OpsRoom_fnc_closeButtonMenu
    
    Closes any active button menu
*/

if (isNil "OpsRoom_ActiveMenuControls") exitWith {};

// Delete all menu controls
{
    if (!isNull _x) then {
        ctrlDelete _x;
    };
} forEach OpsRoom_ActiveMenuControls;

OpsRoom_ActiveMenuControls = [];
