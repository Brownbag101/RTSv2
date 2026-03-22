/*
    OpsRoom_fnc_closeInventory
    
    Closes the custom inventory panel by deleting all controls in IDC range 9400-9599.
*/

missionNamespace setVariable ["OpsRoom_InventoryOpen", false];

private _display = findDisplay 312;
if (isNull _display) exitWith {};

// Delete all inventory panel controls
for "_i" from 9400 to 9599 do {
    private _ctrl = _display displayCtrl _i;
    if (!isNull _ctrl) then {
        ctrlDelete _ctrl;
    };
};

missionNamespace setVariable ["OpsRoom_InventoryUnit", objNull];
missionNamespace setVariable ["OpsRoom_InventoryContainer", objNull];
missionNamespace setVariable ["OpsRoom_InventoryNearContainers", []];
missionNamespace setVariable ["OpsRoom_InventoryContainerIndex", 0];
missionNamespace setVariable ["OpsRoom_InventoryExpandedLeft", ""];
missionNamespace setVariable ["OpsRoom_InventoryExpandedRight", ""];
missionNamespace setVariable ["OpsRoom_InventoryTypeOverrides", createHashMap];
