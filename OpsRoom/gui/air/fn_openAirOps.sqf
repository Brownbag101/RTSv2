/*
    Open Air Operations - Air Wings View
    
    Entry point for Air Operations.
    Opens the wing grid dialog and populates it.
*/

// Close any existing dialog
if (!isNull findDisplay 11000) then { closeDialog 0 };

// Create dialog
createDialog "OpsRoom_AirWingsDialog";

// Wait for dialog
waitUntil {!isNull findDisplay 11000};

// Populate the grid
[] call OpsRoom_fnc_populateWingGrid;

// Set up Hangar button handler
private _display = findDisplay 11000;
private _hangarBtn = _display displayCtrl 11030;
_hangarBtn ctrlAddEventHandler ["ButtonClick", {
    closeDialog 0;
    [] spawn {
        sleep 0.1;
        [] call OpsRoom_fnc_openHangar;
    };
}];

// Pilot Roster button handler
private _pilotBtn = _display displayCtrl 11032;
_pilotBtn ctrlAddEventHandler ["ButtonClick", {
    closeDialog 0;
    [] spawn {
        sleep 0.1;
        [] call OpsRoom_fnc_openPilotRoster;
    };
}];

// Aircrew Roster button handler
private _crewBtn = _display displayCtrl 11033;
_crewBtn ctrlAddEventHandler ["ButtonClick", {
    closeDialog 0;
    [] spawn {
        sleep 0.1;
        [] call OpsRoom_fnc_openCrewRoster;
    };
}];

// Update fuel display
private _fuelCtrl = _display displayCtrl 11031;
_fuelCtrl ctrlSetStructuredText parseText format [
    "<t align='right'>Fuel: <t color='#88CC88'>%1</t></t>",
    OpsRoom_Resource_Fuel
];

// Update summary bar
private _totalAircraft = count OpsRoom_Hangar;
private _totalWings = count OpsRoom_AirWings;
private _airborneCount = 0;
{
    if ((_y get "status") == "AIRBORNE") then { _airborneCount = _airborneCount + 1 };
} forEach OpsRoom_AirWings;

private _summaryCtrl = _display displayCtrl 11021;
_summaryCtrl ctrlSetStructuredText parseText format [
    "<t align='center'>Aircraft: %1  |  Wings: %2  |  Airborne: %3</t>",
    _totalAircraft, _totalWings, _airborneCount
];

diag_log "[OpsRoom] Air Operations dialog opened";
