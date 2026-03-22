/*
    Populate Roster Grid
    
    Fills the roster grid with units from the selected group.
    Each square shows: rank icon, name, status.
    
    Parameters:
        0: STRING - Group ID
    
    Usage:
        ["group_1"] call OpsRoom_fnc_populateRosterGrid;
*/

params [
    ["_groupId", "", [""]]
];

private _display = findDisplay 8002;
if (isNull _display) exitWith {
    diag_log "[OpsRoom] ERROR: Cannot populate roster - dialog not found";
};

// Delete all dynamic controls
for "_idc" from 9100 to 12111 do {
    private _ctrl = _display displayCtrl _idc;
    if (!isNull _ctrl) then {
        ctrlDelete _ctrl;
    };
};

// Get group data
private _groupData = OpsRoom_Groups get _groupId;
if (isNil "_groupData") exitWith {
    diag_log "[OpsRoom] ERROR: Group not found";
};

private _units = _groupData get "units";
private _squareIndex = 0;
private _maxSquares = 12;

// Populate unit squares
{
    if (_squareIndex >= _maxSquares) exitWith {};
    
    private _unit = _x;
    
    if (!isNull _unit) then {
        private _idc = 8100 + _squareIndex;
        private _ctrl = _display displayCtrl _idc;
        
        if (!isNull _ctrl) then {
            _ctrl ctrlShow true;
            
            private _ctrlPos = ctrlPosition _ctrl;
            private _x = _ctrlPos select 0;
            private _y = _ctrlPos select 1;
            private _w = _ctrlPos select 2;
            private _h = _ctrlPos select 3;
            
            // Get unit info
            private _name = name _unit;
            private _rank = rank _unit;
            private _rankId = rankId _unit;
            
            // Determine rank icon
            private _rankIcon = switch (_rankId) do {
                case 0: {"\A3\ui_f\data\gui\cfg\ranks\private_gs.paa"};
                case 1: {"\A3\ui_f\data\gui\cfg\ranks\corporal_gs.paa"};
                case 2: {"\A3\ui_f\data\gui\cfg\ranks\sergeant_gs.paa"};
                case 3: {"\A3\ui_f\data\gui\cfg\ranks\lieutenant_gs.paa"};
                case 4: {"\A3\ui_f\data\gui\cfg\ranks\captain_gs.paa"};
                case 5: {"\A3\ui_f\data\gui\cfg\ranks\major_gs.paa"};
                case 6: {"\A3\ui_f\data\gui\cfg\ranks\colonel_gs.paa"};
                default {"\A3\ui_f\data\gui\cfg\ranks\private_gs.paa"};
            };
            
            // Determine status
            private _status = "ACTIVE";
            private _statusColor = "#00FF00";
            if (!alive _unit) then {
                _status = "KIA";
                _statusColor = "#FF0000";
            } else {
                if (_unit getVariable ["ACE_isUnconscious", false]) then {
                    _status = "DOWN";
                    _statusColor = "#FF8800";
                };
            };
            
            // Add rank icon (top 50%)
            private _iconCtrl = _display ctrlCreate ["RscPicture", _idc + 1000];
            _iconCtrl ctrlSetPosition [
                _x,
                _y,
                _w,
                _h * 0.5
            ];
            _iconCtrl ctrlSetText _rankIcon;
            _iconCtrl ctrlCommit 0;
            
            // Add name (middle 30%)
            private _nameCtrl = _display ctrlCreate ["RscStructuredText", _idc + 2000];
            _nameCtrl ctrlSetPosition [
                _x,
                _y + (_h * 0.52),
                _w,
                _h * 0.3
            ];
            _nameCtrl ctrlSetStructuredText parseText format [
                "<t align='center' size='0.75'>%1</t><br/><t align='center' size='0.65'>%2</t>", 
                _name,
                _rank
            ];
            _nameCtrl ctrlCommit 0;
            
            // Add status (bottom 18%)
            private _statusCtrl = _display ctrlCreate ["RscStructuredText", _idc + 3000];
            _statusCtrl ctrlSetPosition [
                _x,
                _y + (_h * 0.82),
                _w,
                _h * 0.18
            ];
            _statusCtrl ctrlSetStructuredText parseText format [
                "<t align='center' size='0.65' color='%1'>%2</t>", 
                _statusColor,
                _status
            ];
            _statusCtrl ctrlCommit 0;
            
            // Add click button overlay
            private _btnCtrl = _display ctrlCreate ["RscButton", _idc + 4000];
            _btnCtrl ctrlSetPosition [_x, _y, _w, _h];
            _btnCtrl ctrlSetText "";
            _btnCtrl ctrlSetTooltip format ["View %1 details", _name];
            _btnCtrl ctrlCommit 0;
            
            // Store unit in button
            _btnCtrl setVariable ["unit", _unit];
            
            // Click handler - opens unit dossier on Zeus display
            _btnCtrl setVariable ["groupId", _groupId];
            _btnCtrl ctrlAddEventHandler ["ButtonClick", {
                params ["_ctrl"];
                private _unit = _ctrl getVariable ["unit", objNull];
                private _gId = _ctrl getVariable ["groupId", ""];
                if (!isNull _unit) then {
                    closeDialog 0;
                    [_unit, _gId] spawn OpsRoom_fnc_openUnitDossier;
                };
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
} forEach _units;

// Hide remaining empty squares
for "_i" from _squareIndex to (_maxSquares - 1) do {
    private _ctrl = _display displayCtrl (8100 + _i);
    if (!isNull _ctrl) then {
        _ctrl ctrlShow false;
    };
};

diag_log format ["[OpsRoom] Populated roster grid with %1 units", _squareIndex];
