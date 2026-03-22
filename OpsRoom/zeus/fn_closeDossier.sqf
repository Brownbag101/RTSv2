/*
    OpsRoom_fnc_closeDossier
    
    Closes the unit dossier panel by deleting all controls in IDC range 9600-9799.
*/

missionNamespace setVariable ["OpsRoom_DossierOpen", false];

// Close debug panel if open
private _debugDisplay = findDisplay 312;
if (!isNull _debugDisplay) then {
    for "_i" from 9800 to 9899 do {
        private _c = _debugDisplay displayCtrl _i;
        if (!isNull _c) then { ctrlDelete _c };
    };
};
missionNamespace setVariable ["OpsRoom_DossierUnit", objNull];
missionNamespace setVariable ["OpsRoom_DossierGroupId", ""];
missionNamespace setVariable ["OpsRoom_DossierUnitList", []];
missionNamespace setVariable ["OpsRoom_DossierUnitIndex", 0];
missionNamespace setVariable ["OpsRoom_DossierTab", 0];

private _display = findDisplay 312;
if (isNull _display) exitWith {};

for "_i" from 9600 to 9799 do {
    private _ctrl = _display displayCtrl _i;
    if (!isNull _ctrl) then {
        ctrlDelete _ctrl;
    };
};

diag_log "[OpsRoom Dossier] Closed";
