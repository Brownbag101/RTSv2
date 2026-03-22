/*
    fn_openOpsMapPicker
    
    Opens the Operational Map in "picker" mode.
    Player clicks a position on the map and it is returned via callback.
    Strategic locations are visible as reference points.
    
    Parameters:
        _callback   - Code block called with [_worldPos] when position selected
        _title      - (Optional) Title hint shown to player
        _cancelCode - (Optional) Code block called if player cancels (ESC / Back)
    
    Usage:
        [{
            params ["_pos"];
            systemChat format ["Selected position: %1", _pos];
        }, "Select staging position"] call OpsRoom_fnc_openOpsMapPicker;
*/
params ["_callback", ["_title", "SELECT POSITION"], ["_cancelCode", {}]];

// Store callback globally for the dialog event handlers
OpsRoom_MapPicker_Callback = _callback;
OpsRoom_MapPicker_CancelCode = _cancelCode;
OpsRoom_MapPicker_Active = true;

// Create the dialog (reuses the same Ops Map dialog)
createDialog "OpsRoom_OpsMapDialog";
waitUntil {!isNull findDisplay 8010};

private _display = findDisplay 8010;

// Get the map control
private _mapCtrl = _display displayCtrl 11500;

// Centre map on the island
if (!isNull _mapCtrl) then {
    private _worldSize = worldSize;
    private _centre = [_worldSize / 2, _worldSize / 2];
    _mapCtrl ctrlMapAnimAdd [0.5, 0.05, _centre];
    ctrlMapAnimCommit _mapCtrl;
};

// Draw sea lanes on the map
[_mapCtrl] call OpsRoom_fnc_drawSeaLanes;

// Override status bar with picker instructions
private _statusCtrl = _display displayCtrl 11501;
if (!isNull _statusCtrl) then {
    _statusCtrl ctrlSetStructuredText parseText format [
        "<t align='center' color='#88CC88'>%1</t>  <t align='center'>— Click the map to select a position. Press BACK to cancel.</t>",
        _title
    ];
};

// Override Refresh button to act as confirm (hidden — map click is the confirm)
private _refreshBtn = _display displayCtrl 11503;
if (!isNull _refreshBtn) then {
    _refreshBtn ctrlShow false;
};

// Legend button still works for reference
private _legendBtn = _display displayCtrl 11502;
if (!isNull _legendBtn) then {
    _legendBtn ctrlAddEventHandler ["ButtonClick", {
        hint parseText (
            "<t size='1.2' font='PuristaBold'>MAP LEGEND</t><br/><br/>" +
            "<t color='#FF4444'>? = Detected (unknown type)</t><br/>" +
            "<t color='#FF4444'>● = Enemy location (identified)</t><br/>" +
            "<t color='#4488FF'>● = Friendly location</t><br/>" +
            "<t color='#FFFF44'>● = Contested</t><br/>" +
            "<t color='#888888'>X = Destroyed</t><br/><br/>" +
            "<t size='0.9'>Click any position on the map to select it.</t>"
        );
    }];
};

// Override map click handler — return position via callback instead of intel card
_mapCtrl ctrlRemoveAllEventHandlers "MouseButtonClick";

_mapCtrl ctrlAddEventHandler ["MouseButtonClick", {
    params ["_ctrl", "_button", "_xPos", "_yPos"];
    
    // Only left click
    if (_button != 0) exitWith {};
    
    // Must be active
    if !(OpsRoom_MapPicker_Active) exitWith {};
    
    // Convert screen position to world position
    private _worldPos = _ctrl ctrlMapScreenToWorld [_xPos, _yPos];
    
    // Validate position is on the map (not [0,0])
    if (_worldPos isEqualTo [0,0]) exitWith {};
    
    // Deactivate
    OpsRoom_MapPicker_Active = false;
    
    // Close the map dialog
    closeDialog 0;
    hint "";
    
    // Call the callback with the selected position
    [_worldPos] call OpsRoom_MapPicker_Callback;
}];

// Handle dialog close (Back button / ESC) as cancel
_display displayAddEventHandler ["Unload", {
    if (OpsRoom_MapPicker_Active) then {
        OpsRoom_MapPicker_Active = false;
        hint "";
        [] call OpsRoom_MapPicker_CancelCode;
    };
}];

diag_log format ["[OpsRoom] Ops Map picker opened: %1", _title];
