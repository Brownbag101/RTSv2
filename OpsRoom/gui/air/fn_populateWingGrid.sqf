/*
    Populate Wing Grid
    
    Fills the air wings grid with existing wings and [+] button.
    Each square shows: icon, wing name, type, aircraft count, status.
    
    Usage:
        [] call OpsRoom_fnc_populateWingGrid;
*/

private _display = findDisplay 11000;
if (isNull _display) exitWith {
    diag_log "[OpsRoom] ERROR: Cannot populate wing grid - dialog not found";
};

// Clean up dynamic controls from previous population
for "_idc" from 12100 to 15107 do {
    private _ctrl = _display displayCtrl _idc;
    if (!isNull _ctrl) then {
        ctrlDelete _ctrl;
    };
};

// Gather wings into array
private _wings = [];
{
    _wings pushBack [_x, _y];
} forEach OpsRoom_AirWings;

private _squareIndex = 0;
private _maxSquares = 8;

// Populate wing squares
{
    if (_squareIndex >= _maxSquares) exitWith {};
    
    _x params ["_wingId", "_wingData"];
    
    private _wingName = _wingData get "name";
    private _wingType = _wingData get "wingType";
    private _aircraft = _wingData get "aircraft";
    private _status = _wingData get "status";
    private _mission = _wingData get "mission";
    
    // Get type display info
    private _typeData = OpsRoom_WingTypes get _wingType;
    private _typeDisplayName = _typeData get "displayName";
    
    // Get the background control
    private _idc = 11100 + _squareIndex;
    private _ctrl = _display displayCtrl _idc;
    
    if (!isNull _ctrl) then {
        _ctrl ctrlShow true;
        
        // Status colour on the background
        private _bgColor = switch (_status) do {
            case "AIRBORNE": { [0.20, 0.35, 0.20, 1.0] };  // Green tint
            case "LAUNCHING": { [0.35, 0.35, 0.15, 1.0] };  // Yellow tint
            case "RTB": { [0.35, 0.25, 0.15, 1.0] };  // Orange tint
            default { [0.26, 0.30, 0.21, 1.0] };  // Standard khaki
        };
        _ctrl ctrlSetBackgroundColor _bgColor;
        
        // Icon (top portion)
        private _iconCtrl = _display ctrlCreate ["RscPicture", _idc + 1000];
        _iconCtrl ctrlSetPosition [
            ((ctrlPosition _ctrl) select 0) + 0.03 * safezoneW,
            ((ctrlPosition _ctrl) select 1) + 0.01 * safezoneH,
            0.05 * safezoneW,
            0.06 * safezoneH
        ];
        _iconCtrl ctrlSetText "\A3\ui_f\data\map\vehicleicons\iconplane_ca.paa";
        _iconCtrl ctrlCommit 0;
        
        // Wing name
        private _nameCtrl = _display ctrlCreate ["RscStructuredText", _idc + 2000];
        _nameCtrl ctrlSetPosition [
            (ctrlPosition _ctrl) select 0,
            ((ctrlPosition _ctrl) select 1) + 0.08 * safezoneH,
            (ctrlPosition _ctrl) select 2,
            0.03 * safezoneH
        ];
        _nameCtrl ctrlSetStructuredText parseText format [
            "<t align='center' size='0.85'>%1</t>", _wingName
        ];
        _nameCtrl ctrlCommit 0;
        
        // Type + aircraft count
        private _infoCtrl = _display ctrlCreate ["RscStructuredText", _idc + 3000];
        _infoCtrl ctrlSetPosition [
            (ctrlPosition _ctrl) select 0,
            ((ctrlPosition _ctrl) select 1) + 0.11 * safezoneH,
            (ctrlPosition _ctrl) select 2,
            0.03 * safezoneH
        ];
        _infoCtrl ctrlSetStructuredText parseText format [
            "<t align='center' size='0.7' color='#AAAAAA'>%1<br/>%2 aircraft</t>",
            _wingType, count _aircraft
        ];
        _infoCtrl ctrlCommit 0;
        
        // Status line
        private _statusColor = switch (_status) do {
            case "AIRBORNE": { "#88CC88" };
            case "LAUNCHING": { "#CCCC44" };
            case "RTB": { "#CC8844" };
            default { "#888888" };
        };
        
        private _statusCtrl = _display ctrlCreate ["RscStructuredText", _idc + 3500];
        _statusCtrl ctrlSetPosition [
            (ctrlPosition _ctrl) select 0,
            ((ctrlPosition _ctrl) select 1) + 0.155 * safezoneH,
            (ctrlPosition _ctrl) select 2,
            0.025 * safezoneH
        ];
        
        private _statusText = if (_mission != "") then {
            private _missionData = OpsRoom_AirMissionTypes getOrDefault [_mission, createHashMap];
            private _missionName = _missionData getOrDefault ["displayName", _mission];
            format ["<t align='center' size='0.65' color='%1'>%2 - %3</t>", _statusColor, _status, _missionName]
        } else {
            format ["<t align='center' size='0.65' color='%1'>%2</t>", _statusColor, _status]
        };
        _statusCtrl ctrlSetStructuredText parseText _statusText;
        _statusCtrl ctrlCommit 0;
        
        // Click button overlay
        private _btnCtrl = _display ctrlCreate ["RscButton", _idc + 4000];
        _btnCtrl ctrlSetPosition [
            (ctrlPosition _ctrl) select 0,
            (ctrlPosition _ctrl) select 1,
            (ctrlPosition _ctrl) select 2,
            (ctrlPosition _ctrl) select 3
        ];
        _btnCtrl ctrlSetText "";
        _btnCtrl ctrlSetTooltip format ["Open %1", _wingName];
        _btnCtrl ctrlCommit 0;
        
        _btnCtrl setVariable ["wingId", _wingId];
        
        _btnCtrl ctrlAddEventHandler ["ButtonClick", {
            params ["_ctrl"];
            private _wingId = _ctrl getVariable ["wingId", ""];
            closeDialog 0;
            [_wingId] spawn OpsRoom_fnc_openWingDetail;
        }];
        
        // Hover effects
        _btnCtrl ctrlAddEventHandler ["MouseEnter", {
            params ["_ctrl"];
            private _bgCtrl = (ctrlParent _ctrl) displayCtrl ((ctrlIDC _ctrl) - 4000);
            _bgCtrl ctrlSetBackgroundColor [0.3, 0.35, 0.25, 1];
        }];
        _btnCtrl ctrlAddEventHandler ["MouseExit", {
            params ["_ctrl"];
            private _bgCtrl = (ctrlParent _ctrl) displayCtrl ((ctrlIDC _ctrl) - 4000);
            _bgCtrl ctrlSetBackgroundColor [0.26, 0.30, 0.21, 1];
        }];
    };
    
    _squareIndex = _squareIndex + 1;
} forEach _wings;

// Add [+] Create Wing button in next available square
if (_squareIndex < _maxSquares) then {
    private _idc = 11100 + _squareIndex;
    private _ctrl = _display displayCtrl _idc;
    
    if (!isNull _ctrl) then {
        _ctrl ctrlShow true;
        
        private _plusCtrl = _display ctrlCreate ["RscStructuredText", _idc + 2000];
        _plusCtrl ctrlSetPosition [
            (ctrlPosition _ctrl) select 0,
            (ctrlPosition _ctrl) select 1,
            (ctrlPosition _ctrl) select 2,
            (ctrlPosition _ctrl) select 3
        ];
        _plusCtrl ctrlSetStructuredText parseText "<t align='center' size='3.5' valign='middle'>+</t><br/><t align='center' size='0.8'>Create Wing</t>";
        _plusCtrl ctrlCommit 0;
        
        private _btnCtrl = _display ctrlCreate ["RscButton", _idc + 4000];
        _btnCtrl ctrlSetPosition [
            (ctrlPosition _ctrl) select 0,
            (ctrlPosition _ctrl) select 1,
            (ctrlPosition _ctrl) select 2,
            (ctrlPosition _ctrl) select 3
        ];
        _btnCtrl ctrlSetText "";
        _btnCtrl ctrlSetTooltip "Create a new Air Wing";
        _btnCtrl ctrlCommit 0;
        
        _btnCtrl ctrlAddEventHandler ["ButtonClick", {
            closeDialog 0;
            [] spawn OpsRoom_fnc_showCreateWing;
        }];
        
        _btnCtrl ctrlAddEventHandler ["MouseEnter", {
            params ["_ctrl"];
            private _bgCtrl = (ctrlParent _ctrl) displayCtrl ((ctrlIDC _ctrl) - 4000);
            _bgCtrl ctrlSetBackgroundColor [0.2, 0.4, 0.2, 1];
        }];
        _btnCtrl ctrlAddEventHandler ["MouseExit", {
            params ["_ctrl"];
            private _bgCtrl = (ctrlParent _ctrl) displayCtrl ((ctrlIDC _ctrl) - 4000);
            _bgCtrl ctrlSetBackgroundColor [0.26, 0.30, 0.21, 1];
        }];
    };
    
    _squareIndex = _squareIndex + 1;
};

// Hide remaining empty squares
for "_i" from _squareIndex to (_maxSquares - 1) do {
    private _idc = 11100 + _i;
    private _ctrl = _display displayCtrl _idc;
    if (!isNull _ctrl) then {
        _ctrl ctrlShow false;
    };
};

diag_log format ["[OpsRoom] Populated wing grid with %1 wings", count _wings];
