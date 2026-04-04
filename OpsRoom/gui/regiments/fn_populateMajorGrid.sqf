/*
    Populate Major Selection Grid
    
    Fills grid with available Majors for selection as regiment CO.
    Shows Major name, rank, and stats.
    
    Usage:
        [] call OpsRoom_fnc_populateMajorGrid;
*/

private _display = findDisplay 8010;
if (isNull _display) exitWith {
    diag_log "[OpsRoom] ERROR: Cannot populate major grid - dialog not found";
};

// Delete all dynamic controls
for "_idc" from 9100 to 12111 do {
    private _ctrl = _display displayCtrl _idc;
    if (!isNull _ctrl) then {
        ctrlDelete _ctrl;
    };
};

// Get required qualification from selected regiment type (if any)
private _requiredQual = "";
private _selectedType = uiNamespace getVariable ["OpsRoom_SelectedRegimentType", ""];
if (_selectedType != "") then {
    private _typeData = OpsRoom_RegimentTypes getOrDefault [_selectedType, createHashMap];
    if (count _typeData > 0) then {
        _requiredQual = _typeData getOrDefault ["requiresQualification", ""];
    };
};

// Get available Majors (filtered by qualification if needed)
private _availableMajors = [_requiredQual] call OpsRoom_fnc_getAvailableMajors;

if (count _availableMajors == 0) exitWith {
    private _hintMsg = if (_requiredQual != "") then {
        format ["No available Majors with '%1' qualification!\nTrain a Major through the required course first.", _requiredQual]
    } else {
        "No available Majors! Promote a unit to Major first."
    };
    hint _hintMsg;
    closeDialog 0;
    // Return to type picker
    [] spawn {
        sleep 0.1;
        uiNamespace setVariable ["OpsRoom_SelectedRegimentType", nil];
        [] call OpsRoom_fnc_showAddRegiment;
    };
};

private _squareIndex = 0;
private _maxSquares = 12;

// Populate major squares
{
    if (_squareIndex >= _maxSquares) exitWith {};
    
    private _major = _x;
    private _idc = 8100 + _squareIndex;
    private _ctrl = _display displayCtrl _idc;
    
    if (!isNull _ctrl) then {
        _ctrl ctrlShow true;
        
        private _ctrlPos = ctrlPosition _ctrl;
        private _x = _ctrlPos select 0;
        private _y = _ctrlPos select 1;
        private _w = _ctrlPos select 2;
        private _h = _ctrlPos select 3;
        
        // Get major info
        private _name = name _major;
        private _kills = _major getVariable ["OpsRoom_Kills", 0];
        private _timeAlive = time - (missionNamespace getVariable [format ["OpsRoom_Unit_%1_SpawnTime", _major], time]);
        private _days = floor (_timeAlive / 86400);
        
        // Add rank icon
        private _iconCtrl = _display ctrlCreate ["RscPicture", _idc + 1000];
        _iconCtrl ctrlSetPosition [
            _x,
            _y,
            _w,
            _h * 0.5
        ];
        _iconCtrl ctrlSetText "\A3\ui_f\data\gui\cfg\ranks\major_gs.paa";
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
            "<t align='center' size='0.75'>%1</t><br/><t align='center' size='0.65'>MAJOR</t>", 
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
        _btnCtrl ctrlSetTooltip format ["Select %1 as regiment commander", _name];
        _btnCtrl ctrlCommit 0;
        
        // Store major in button
        _btnCtrl setVariable ["major", _major];
        
        // Click handler - stores major selection
        _btnCtrl ctrlAddEventHandler ["ButtonClick", {
            params ["_ctrl"];
            private _major = _ctrl getVariable ["major", objNull];
            
            if (!isNull _major) then {
                // Store selected major
                uiNamespace setVariable ["OpsRoom_SelectedMajor", _major];
                
                // Close dialog and return to add regiment
                closeDialog 0;
                
                // Reopen add regiment dialog
                [] spawn {
                    sleep 0.1;
                    [] call OpsRoom_fnc_showAddRegiment;
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
} forEach _availableMajors;

// Hide remaining empty squares
for "_i" from _squareIndex to (_maxSquares - 1) do {
    private _ctrl = _display displayCtrl (8100 + _i);
    if (!isNull _ctrl) then {
        _ctrl ctrlShow false;
    };
};

diag_log format ["[OpsRoom] Populated major grid with %1 majors", _squareIndex];
