/*
    Populate Captain Selection Grid
    
    Fills grid with available Captains for selection.
    Shows Captain name, kills, time in service.
    
    Parameters:
        0: STRING - Regiment ID
    
    Usage:
        ["regiment_1"] call OpsRoom_fnc_populateCaptainGrid;
*/

params [
    ["_regimentId", "", [""]]
];

private _display = findDisplay 8004;
if (isNull _display) exitWith {
    diag_log "[OpsRoom] ERROR: Cannot populate captain grid - dialog not found";
};

// Delete all dynamic controls
for "_idc" from 9100 to 12111 do {
    private _ctrl = _display displayCtrl _idc;
    if (!isNull _ctrl) then {
        ctrlDelete _ctrl;
    };
};

// Get available Captains
private _availableCaptains = [_regimentId] call OpsRoom_fnc_getAvailableCaptains;

if (count _availableCaptains == 0) exitWith {
    hint "No available Captains in this regiment!";
    closeDialog 0;
};

private _squareIndex = 0;
private _maxSquares = 12;

// Populate captain squares
{
    if (_squareIndex >= _maxSquares) exitWith {};
    
    private _captain = _x;
    private _idc = 8100 + _squareIndex;
    private _ctrl = _display displayCtrl _idc;
    
    if (!isNull _ctrl) then {
        _ctrl ctrlShow true;
        
        private _ctrlPos = ctrlPosition _ctrl;
        private _x = _ctrlPos select 0;
        private _y = _ctrlPos select 1;
        private _w = _ctrlPos select 2;
        private _h = _ctrlPos select 3;
        
        // Get captain info
        private _name = name _captain;
        private _kills = _captain getVariable ["OpsRoom_Kills", 0];
        private _timeAlive = time - (missionNamespace getVariable [format ["OpsRoom_Unit_%1_SpawnTime", _captain], time]);
        private _days = floor (_timeAlive / 86400);
        
        // Add rank icon
        private _iconCtrl = _display ctrlCreate ["RscPicture", _idc + 1000];
        _iconCtrl ctrlSetPosition [
            _x,
            _y,
            _w,
            _h * 0.5
        ];
        _iconCtrl ctrlSetText "\A3\ui_f\data\gui\cfg\ranks\captain_gs.paa";
        _iconCtrl ctrlCommit 0;
        
        // Add name and rank
        private _nameCtrl = _display ctrlCreate ["RscStructuredText", _idc + 2000];
        _nameCtrl ctrlSetPosition [
            _x,
            _y + (_h * 0.52),
            _w,
            _h * 0.25
        ];
        _nameCtrl ctrlSetStructuredText parseText format [
            "<t align='center' size='0.75'>%1</t><br/><t align='center' size='0.65'>CAPTAIN</t>", 
            _name
        ];
        _nameCtrl ctrlCommit 0;
        
        // Add stats
        private _statsCtrl = _display ctrlCreate ["RscStructuredText", _idc + 3000];
        _statsCtrl ctrlSetPosition [
            _x,
            _y + (_h * 0.77),
            _w,
            _h * 0.23
        ];
        _statsCtrl ctrlSetStructuredText parseText format [
            "<t align='center' size='0.6' color='#AAAAAA'>%1 kills | %2 days</t>", 
            _kills,
            _days
        ];
        _statsCtrl ctrlCommit 0;
        
        // Add click button
        private _btnCtrl = _display ctrlCreate ["RscButton", _idc + 4000];
        _btnCtrl ctrlSetPosition [_x, _y, _w, _h];
        _btnCtrl ctrlSetText "";
        _btnCtrl ctrlSetTooltip format ["Select %1 as group commander", _name];
        _btnCtrl ctrlCommit 0;
        
        // Store captain in button
        _btnCtrl setVariable ["captain", _captain];
        
        // Click handler - creates group with this captain
        _btnCtrl ctrlAddEventHandler ["ButtonClick", {
            params ["_ctrl"];
            private _captain = _ctrl getVariable ["captain", objNull];
            private _regimentId = uiNamespace getVariable ["OpsRoom_SelectedRegiment", ""];
            
            if (!isNull _captain && _regimentId != "") then {
                [_captain, _regimentId] spawn {
                    params ["_captain", "_regimentId"];
                    
                    closeDialog 0;
                    
                    // Create group with selected captain
                    private _groupId = [_regimentId, _captain] call OpsRoom_fnc_createGroup;
                    
                    // Return to groups view
                    sleep 0.1;
                    [_regimentId] call OpsRoom_fnc_openGroups;
                    
                    systemChat format ["✓ New group formed under %1", name _captain];
                };
            };
        }];
        
        // Hover effects
        _btnCtrl ctrlAddEventHandler ["MouseEnter", {
            params ["_ctrl"];
            private _bgCtrl = (ctrlParent _ctrl) displayCtrl ((ctrlIDC _ctrl) - 4000);
            _bgCtrl ctrlSetBackgroundColor [0.2, 0.4, 0.2, 1];
        }];
        
        _btnCtrl ctrlAddEventHandler ["MouseExit", {
            params ["_ctrl"];
            private _bgCtrl = (ctrlParent _ctrl) displayCtrl ((ctrlIDC _ctrl) - 4000);
            _bgCtrl ctrlSetBackgroundColor [0.26, 0.3, 0.21, 1];
        }];
    };
    
    _squareIndex = _squareIndex + 1;
} forEach _availableCaptains;

// Hide remaining empty squares
for "_i" from _squareIndex to (_maxSquares - 1) do {
    private _ctrl = _display displayCtrl (8100 + _i);
    if (!isNull _ctrl) then {
        _ctrl ctrlShow false;
    };
};

diag_log format ["[OpsRoom] Populated captain grid with %1 captains", _squareIndex];
