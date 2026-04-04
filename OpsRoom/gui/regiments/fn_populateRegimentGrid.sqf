/*
    Populate Regiment Grid
    
    Fills the regiment grid with existing regiments and [+] button.
    Each square shows: badge, name, unit count.
    
    Usage:
        [] call OpsRoom_fnc_populateRegimentGrid;
*/

private _display = findDisplay 8000;
if (isNull _display) exitWith {
    diag_log "[OpsRoom] ERROR: Cannot populate grid - dialog not found";
};

// Delete all dynamic controls from previous population
// Dynamic controls have IDCs in these ranges:
// - Badges: 9100-9111 (8100+1000 to 8111+1000)
// - Names: 10100-10111 (8100+2000 to 8111+2000)
// - Counts: 11100-11111 (8100+3000 to 8111+3000)
// - Buttons: 12100-12111 (8100+4000 to 8111+4000)
for "_idc" from 9100 to 12111 do {
    private _ctrl = _display displayCtrl _idc;
    if (!isNull _ctrl) then {
        ctrlDelete _ctrl;
    };
};

// Get all regiments
private _regiments = [];
{
    _regiments pushBack _y;
} forEach OpsRoom_Regiments;

// Sort by date formed (oldest first)
_regiments sort true;

private _squareIndex = 0;
private _maxSquares = 12;

// Populate regiment squares
{
    if (_squareIndex >= _maxSquares) exitWith {};
    
    private _regimentData = _x;
    private _regimentId = _regimentData get "id";
    private _regimentName = _regimentData get "name";
    private _groups = _regimentData get "groups";
    
    // Count total units in all groups
    private _totalUnits = 0;
    {
        private _groupData = OpsRoom_Groups get _x;
        if (!isNil "_groupData") then {
            private _units = _groupData get "units";
            _totalUnits = _totalUnits + count _units;
        };
    } forEach _groups;
    
    // Get the background control
    private _idc = 8100 + _squareIndex;
    private _ctrl = _display displayCtrl _idc;
    
    if (!isNull _ctrl) then {
        // Make it visible
        _ctrl ctrlShow true;
        
        // Add badge image (top half of square)
        private _badgeCtrl = _display ctrlCreate ["RscPicture", _idc + 1000];
        _badgeCtrl ctrlSetPosition [
            (ctrlPosition _ctrl) select 0,
            (ctrlPosition _ctrl) select 1,
            (ctrlPosition _ctrl) select 2,
            ((ctrlPosition _ctrl) select 3) * 0.6
        ];
        _badgeCtrl ctrlSetText "\A3\ui_f\data\gui\cfg\ranks\major_gs.paa";
        _badgeCtrl ctrlCommit 0;
        
        // Add regiment name (bottom of square)
        private _nameCtrl = _display ctrlCreate ["RscStructuredText", _idc + 2000];
        _nameCtrl ctrlSetPosition [
            (ctrlPosition _ctrl) select 0,
            ((ctrlPosition _ctrl) select 1) + ((ctrlPosition _ctrl) select 3) * 0.62,
            (ctrlPosition _ctrl) select 2,
            ((ctrlPosition _ctrl) select 3) * 0.2
        ];
        _nameCtrl ctrlSetStructuredText parseText format [
            "<t align='center' size='0.8'>%1</t>", 
            _regimentName
        ];
        _nameCtrl ctrlCommit 0;
        
        // Add regiment type label (below name)
        private _regType = _regimentData getOrDefault ["type", "regular"];
        private _typeData = OpsRoom_RegimentTypes getOrDefault [_regType, createHashMap];
        private _typeLabel = if (count _typeData > 0) then { _typeData get "displayName" } else { "Infantry" };
        
        // Colour-code by type
        private _typeColor = switch (_regType) do {
            case "commando": { "#66CC66" };
            case "airborne": { "#6699CC" };
            case "soe": { "#CC9966" };
            case "sas": { "#CC6666" };
            case "armoured": { "#CCCC66" };
            case "pioneer": { "#99CCCC" };
            default { "#AAAAAA" };
        };
        
        // Add unit count + type (very bottom)
        private _countCtrl = _display ctrlCreate ["RscStructuredText", _idc + 3000];
        _countCtrl ctrlSetPosition [
            (ctrlPosition _ctrl) select 0,
            ((ctrlPosition _ctrl) select 1) + ((ctrlPosition _ctrl) select 3) * 0.78,
            (ctrlPosition _ctrl) select 2,
            ((ctrlPosition _ctrl) select 3) * 0.22
        ];
        _countCtrl ctrlSetStructuredText parseText format [
            "<t align='center' size='0.65' color='%1'>%2</t><br/><t align='center' size='0.6' color='#AAAAAA'>%3 personnel</t>", 
            _typeColor, _typeLabel, _totalUnits
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
        _btnCtrl ctrlSetTooltip format ["Open %1", _regimentName];
        _btnCtrl ctrlCommit 0;
        
        // Store regiment ID in button for click handler
        _btnCtrl setVariable ["regimentId", _regimentId];
        
        // Click handler - opens group view
        _btnCtrl ctrlAddEventHandler ["ButtonClick", {
        params ["_ctrl"];
        private _regimentId = _ctrl getVariable ["regimentId", ""];
        
        closeDialog 0;
        [_regimentId] call OpsRoom_fnc_openGroups;
        }];
        
        // Hover effects
        _btnCtrl ctrlAddEventHandler ["MouseEnter", {
            params ["_ctrl"];
            private _bgCtrl = (ctrlParent _ctrl) displayCtrl ((ctrlIDC _ctrl) - 4000);
            _bgCtrl ctrlSetBackgroundColor [0.3, 0.35, 0.25, 1]; // Lighter on hover
        }];
        
        _btnCtrl ctrlAddEventHandler ["MouseExit", {
            params ["_ctrl"];
            private _bgCtrl = (ctrlParent _ctrl) displayCtrl ((ctrlIDC _ctrl) - 4000);
            _bgCtrl ctrlSetBackgroundColor [0.26, 0.3, 0.21, 1]; // Back to normal
        }];
    };
    
    _squareIndex = _squareIndex + 1;
} forEach _regiments;

// Add [+] button in next available square
if (_squareIndex < _maxSquares) then {
    private _idc = 8100 + _squareIndex;
    private _ctrl = _display displayCtrl _idc;
    
    if (!isNull _ctrl) then {
        _ctrl ctrlShow true;
        
        // Check if we have available Majors
        private _availableMajors = [] call OpsRoom_fnc_getAvailableMajors;
        private _hasAvailableMajors = count _availableMajors > 0;
        
        // Add [+] text
        private _plusCtrl = _display ctrlCreate ["RscStructuredText", _idc + 2000];
        _plusCtrl ctrlSetPosition [
            (ctrlPosition _ctrl) select 0,
            (ctrlPosition _ctrl) select 1,
            (ctrlPosition _ctrl) select 2,
            (ctrlPosition _ctrl) select 3
        ];
        _plusCtrl ctrlSetStructuredText parseText format [
            "<t align='center' size='4.0' valign='middle'>+</t><br/><t align='center' size='0.8'>Add Regiment</t>"
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
        
        if (_hasAvailableMajors) then {
            _btnCtrl ctrlSetTooltip "Create new regiment (requires Major)";
            
            _btnCtrl ctrlAddEventHandler ["ButtonClick", {
                closeDialog 8000;  // Close Regiments dialog first
                [] spawn {
                    sleep 0.1;
                    [] call OpsRoom_fnc_showAddRegiment;
                };
            }];
            
            // Hover effects
            _btnCtrl ctrlAddEventHandler ["MouseEnter", {
                params ["_ctrl"];
                private _bgCtrl = (ctrlParent _ctrl) displayCtrl ((ctrlIDC _ctrl) - 4000);
                _bgCtrl ctrlSetBackgroundColor [0.2, 0.4, 0.2, 1]; // Green hover
            }];
            
            _btnCtrl ctrlAddEventHandler ["MouseExit", {
                params ["_ctrl"];
                private _bgCtrl = (ctrlParent _ctrl) displayCtrl ((ctrlIDC _ctrl) - 4000);
                _bgCtrl ctrlSetBackgroundColor [0.26, 0.3, 0.21, 1];
            }];
        } else {
            // Disabled state - no available Majors
            _btnCtrl ctrlSetTooltip "No available Majors to command new regiment";
            _ctrl ctrlSetBackgroundColor [0.15, 0.15, 0.15, 1]; // Darker/grayed out
            _plusCtrl ctrlSetStructuredText parseText format [
                "<t align='center' size='4.0' valign='middle' color='#666666'>+</t><br/><t align='center' size='0.8' color='#666666'>Add Regiment</t>"
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

diag_log format ["[OpsRoom] Populated regiment grid with %1 regiments", count _regiments];
