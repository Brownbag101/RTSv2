/*
    Populate Group Grid
    
    Fills the group grid with groups from the selected regiment and [+] button.
    Each square shows: icon, name, unit count.
    
    Parameters:
        0: STRING - Regiment ID
    
    Usage:
        ["regiment_1"] call OpsRoom_fnc_populateGroupGrid;
*/

params [
    ["_regimentId", "", [""]]
];

private _display = findDisplay 8001;
if (isNull _display) exitWith {
    diag_log "[OpsRoom] ERROR: Cannot populate group grid - dialog not found";
};

// Delete all dynamic controls from previous population
for "_idc" from 9100 to 12111 do {
    private _ctrl = _display displayCtrl _idc;
    if (!isNull _ctrl) then {
        ctrlDelete _ctrl;
    };
};

// Get regiment data
private _regimentData = OpsRoom_Regiments get _regimentId;
if (isNil "_regimentData") exitWith {
    diag_log "[OpsRoom] ERROR: Regiment not found";
};

private _groupIds = _regimentData get "groups";

private _squareIndex = 0;
private _maxSquares = 12;

// Populate group squares
{
    if (_squareIndex >= _maxSquares) exitWith {};
    
    private _groupId = _x;
    private _groupData = OpsRoom_Groups get _groupId;
    
    if (!isNil "_groupData") then {
        private _groupName = _groupData get "name";
        private _units = _groupData get "units";
        private _unitCount = count _units;
        
        // Get the background control
        private _idc = 8100 + _squareIndex;
        private _ctrl = _display displayCtrl _idc;
        
        if (!isNull _ctrl) then {
            // Make it visible
            _ctrl ctrlShow true;
            
            // Add icon (top half of square) - use rank insignia
            private _iconCtrl = _display ctrlCreate ["RscPicture", _idc + 1000];
            _iconCtrl ctrlSetPosition [
                (ctrlPosition _ctrl) select 0,
                (ctrlPosition _ctrl) select 1,
                (ctrlPosition _ctrl) select 2,
                ((ctrlPosition _ctrl) select 3) * 0.6
            ];
            _iconCtrl ctrlSetText "\A3\ui_f\data\gui\cfg\ranks\captain_gs.paa";
            _iconCtrl ctrlCommit 0;
            
            // Add group name (bottom of square)
            private _nameCtrl = _display ctrlCreate ["RscStructuredText", _idc + 2000];
            _nameCtrl ctrlSetPosition [
                (ctrlPosition _ctrl) select 0,
                ((ctrlPosition _ctrl) select 1) + ((ctrlPosition _ctrl) select 3) * 0.62,
                (ctrlPosition _ctrl) select 2,
                ((ctrlPosition _ctrl) select 3) * 0.2
            ];
            _nameCtrl ctrlSetStructuredText parseText format [
                "<t align='center' size='0.8'>%1</t>", 
                _groupName
            ];
            _nameCtrl ctrlCommit 0;
            
            // Add unit count (very bottom)
            private _countCtrl = _display ctrlCreate ["RscStructuredText", _idc + 3000];
            _countCtrl ctrlSetPosition [
                (ctrlPosition _ctrl) select 0,
                ((ctrlPosition _ctrl) select 1) + ((ctrlPosition _ctrl) select 3) * 0.82,
                (ctrlPosition _ctrl) select 2,
                ((ctrlPosition _ctrl) select 3) * 0.18
            ];
            _countCtrl ctrlSetStructuredText parseText format [
                "<t align='center' size='0.7' color='#AAAAAA'>%1 personnel</t>", 
                _unitCount
            ];
            _countCtrl ctrlCommit 0;
            
            // Add click button overlay (entire square is clickable)
            private _btnCtrl = _display ctrlCreate ["RscButton", _idc + 4000];
            _btnCtrl ctrlSetPosition [
                (ctrlPosition _ctrl) select 0,
                (ctrlPosition _ctrl) select 1,
                (ctrlPosition _ctrl) select 2,
                (ctrlPosition _ctrl) select 3
            ];
            _btnCtrl ctrlSetText "";
            _btnCtrl ctrlSetTooltip format ["View %1 roster", _groupName];
            _btnCtrl ctrlCommit 0;
            
            // Store group ID in button for click handler
            _btnCtrl setVariable ["groupId", _groupId];
            
            // Click handler - opens unit roster grid
            _btnCtrl ctrlAddEventHandler ["ButtonClick", {
                params ["_ctrl"];
                private _groupId = _ctrl getVariable ["groupId", ""];
                
                closeDialog 0;
                [_groupId] call OpsRoom_fnc_openRosterGrid;  // Changed to new grid
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
                _bgCtrl ctrlSetBackgroundColor [0.26, 0.3, 0.21, 1];
            }];
        };
        
        _squareIndex = _squareIndex + 1;
    };
} forEach _groupIds;

// Add [+] button in next available square
if (_squareIndex < _maxSquares) then {
    private _idc = 8100 + _squareIndex;
    private _ctrl = _display displayCtrl _idc;
    
    if (!isNull _ctrl) then {
        _ctrl ctrlShow true;
        
        // Check if we have available Captains
        private _availableCaptains = [_regimentId] call OpsRoom_fnc_getAvailableCaptains;
        private _hasAvailableCaptains = count _availableCaptains > 0;
        
        // Add [+] text
        private _plusCtrl = _display ctrlCreate ["RscStructuredText", _idc + 2000];
        _plusCtrl ctrlSetPosition [
            (ctrlPosition _ctrl) select 0,
            (ctrlPosition _ctrl) select 1,
            (ctrlPosition _ctrl) select 2,
            (ctrlPosition _ctrl) select 3
        ];
        _plusCtrl ctrlSetStructuredText parseText format [
            "<t align='center' size='4.0' valign='middle'>+</t><br/><t align='center' size='0.8'>Add Group</t>"
        ];
        _plusCtrl ctrlCommit 0;
        
        // Add click button
        private _btnCtrl = _display ctrlCreate ["RscButton", _idc + 4000];
        _btnCtrl ctrlSetPosition [
            (ctrlPosition _ctrl) select 0,
            (ctrlPosition _ctrl) select 1,
            (ctrlPosition _ctrl) select 2,
            (ctrlPosition _ctrl) select 3
        ];
        _btnCtrl ctrlSetText "";
        
        if (_hasAvailableCaptains) then {
            _btnCtrl ctrlSetTooltip "Create new group (requires Captain)";
            
            _btnCtrl ctrlAddEventHandler ["ButtonClick", {
                [uiNamespace getVariable ["OpsRoom_SelectedRegiment", ""]] call OpsRoom_fnc_showAddGroup;
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
        } else {
            // Disabled state
            _btnCtrl ctrlSetTooltip "No available Captains in this regiment";
            _ctrl ctrlSetBackgroundColor [0.15, 0.15, 0.15, 1];
            _plusCtrl ctrlSetStructuredText parseText format [
                "<t align='center' size='4.0' valign='middle' color='#666666'>+</t><br/><t align='center' size='0.8' color='#666666'>Add Group</t>"
            ];
        };
        
        _btnCtrl ctrlCommit 0;
    };
};

// Hide remaining empty squares
for "_i" from (_squareIndex + 1) to (_maxSquares - 1) do {
    private _idc = 8100 + _i;
    private _ctrl = _display displayCtrl _idc;
    if (!isNull _ctrl) then {
        _ctrl ctrlShow false;
    };
};

diag_log format ["[OpsRoom] Populated group grid with %1 groups", _squareIndex];
