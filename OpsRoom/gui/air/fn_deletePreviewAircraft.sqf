/*
    Delete Preview Aircraft
    
    Cleans up any preview aircraft at the hangar.
*/

if (!isNull OpsRoom_HangarPreview) then {
    deleteVehicle OpsRoom_HangarPreview;
    OpsRoom_HangarPreview = objNull;
    diag_log "[OpsRoom] Air: Preview aircraft deleted";
};
