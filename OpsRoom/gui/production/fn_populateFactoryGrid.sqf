/*
    Populate Factory Grid
    
    Fills the factory grid with existing factories and a [+] button.
    Each factory square shows: name, current production, status.
    
    Factory data structure (each entry in OpsRoom_Factories):
        HashMap [
            "id"            - Unique factory ID
            "name"          - Display name ("Factory 1", etc.)
            "producing"     - Item ID being produced ("" if idle)
            "startTime"     - time when current cycle started
            "cycleTime"     - minutes per cycle
            "continuous"    - true = keeps producing until cancelled
        ]
    
    Usage:
        [] call OpsRoom_fnc_populateFactoryGrid;
*/

private _display = findDisplay 11003;
if (isNull _display) exitWith {};

// Delete dynamic controls
for "_idc" from 12220 to 15261 do {
    private _ctrl = _display displayCtrl _idc;
    if (!isNull _ctrl) then { ctrlDelete _ctrl };
};

private _factories = missionNamespace getVariable ["OpsRoom_Factories", []];
private _maxFactories = missionNamespace getVariable ["OpsRoom_MaxFactories", 1];

private _squareIndex = 0;
private _maxSquares = 12;

// Populate existing factories
{
    if (_squareIndex >= _maxSquares) exitWith {};
    
    private _factory = _x;
    private _factoryId = _factory get "id";
    private _factoryName = _factory get "name";
    private _producing = _factory get "producing";
    
    private _idc = 11220 + _squareIndex;
    private _ctrl = _display displayCtrl _idc;
    
    if (!isNull _ctrl) then {
        _ctrl ctrlShow true;
        
        // Factory name
        private _nameCtrl = _display ctrlCreate ["RscStructuredText", _idc + 1000];
        _nameCtrl ctrlSetPosition [
            (ctrlPosition _ctrl) select 0,
            ((ctrlPosition _ctrl) select 1) + ((ctrlPosition _ctrl) select 3) * 0.15,
            (ctrlPosition _ctrl) select 2,
            ((ctrlPosition _ctrl) select 3) * 0.25
        ];
        _nameCtrl ctrlSetStructuredText parseText format [
            "<t align='center' size='1.1' font='PuristaBold'>%1</t>",
            _factoryName
        ];
        _nameCtrl ctrlCommit 0;
        
        // Production status
        private _statusCtrl = _display ctrlCreate ["RscStructuredText", _idc + 2000];
        _statusCtrl ctrlSetPosition [
            (ctrlPosition _ctrl) select 0,
            ((ctrlPosition _ctrl) select 1) + ((ctrlPosition _ctrl) select 3) * 0.45,
            (ctrlPosition _ctrl) select 2,
            ((ctrlPosition _ctrl) select 3) * 0.35
        ];
        
        if (_producing != "") then {
            private _itemData = OpsRoom_EquipmentDB get _producing;
            private _itemName = if (!isNil "_itemData") then { _itemData get "displayName" } else { _producing };
            
            // Calculate progress
            private _startTime = _factory get "startTime";
            private _cycleTime = _factory get "cycleTime";
            private _elapsed = time - _startTime;
            private _totalSecs = _cycleTime * 60;
            private _pct = floor ((_elapsed / _totalSecs) * 100) min 100;
            private _minsLeft = ceil ((_totalSecs - _elapsed) / 60) max 0;
            
            _statusCtrl ctrlSetStructuredText parseText format [
                "<t align='center' size='0.75' color='#FFD966'>PRODUCING</t><br/><t align='center' size='0.8'>%1</t><br/><t align='center' size='0.7' color='#AAAAAA'>%2%3 — %4 min left</t>",
                _itemName, _pct, "%", _minsLeft
            ];
            
            // Tint the background to show active
            _ctrl ctrlSetBackgroundColor [0.22, 0.30, 0.18, 1.0];
        } else {
            _statusCtrl ctrlSetStructuredText parseText "<t align='center' size='0.8' color='#AAAAAA'>IDLE</t><br/><t align='center' size='0.7' color='#666666'>Click to assign production</t>";
        };
        _statusCtrl ctrlCommit 0;
        
        // Button overlay
        private _btnCtrl = _display ctrlCreate ["RscButton", _idc + 4000];
        _btnCtrl ctrlSetPosition [
            (ctrlPosition _ctrl) select 0,
            (ctrlPosition _ctrl) select 1,
            (ctrlPosition _ctrl) select 2,
            (ctrlPosition _ctrl) select 3
        ];
        _btnCtrl ctrlSetText "";
        _btnCtrl ctrlSetTooltip format ["Open %1", _factoryName];
        _btnCtrl ctrlCommit 0;
        
        _btnCtrl setVariable ["factoryIndex", _forEachIndex];
        
        _btnCtrl ctrlAddEventHandler ["ButtonClick", {
            params ["_ctrl"];
            private _idx = _ctrl getVariable ["factoryIndex", 0];
            [_idx] spawn {
                params ["_idx"];
                closeDialog 0;
                sleep 0.1;
                [_idx] call OpsRoom_fnc_openFactoryInterior;
            };
        }];
        
        // Hover effects
        private _isProducing = _producing != "";
        _btnCtrl setVariable ["isProducing", _isProducing];
        
        _btnCtrl ctrlAddEventHandler ["MouseEnter", {
            params ["_ctrl"];
            private _bgCtrl = (ctrlParent _ctrl) displayCtrl ((ctrlIDC _ctrl) - 4000);
            private _isProd = _ctrl getVariable ["isProducing", false];
            if (_isProd) then {
                _bgCtrl ctrlSetBackgroundColor [0.28, 0.38, 0.22, 1.0];
            } else {
                _bgCtrl ctrlSetBackgroundColor [0.3, 0.35, 0.25, 1];
            };
        }];
        _btnCtrl ctrlAddEventHandler ["MouseExit", {
            params ["_ctrl"];
            private _bgCtrl = (ctrlParent _ctrl) displayCtrl ((ctrlIDC _ctrl) - 4000);
            private _isProd = _ctrl getVariable ["isProducing", false];
            if (_isProd) then {
                _bgCtrl ctrlSetBackgroundColor [0.22, 0.30, 0.18, 1.0];
            } else {
                _bgCtrl ctrlSetBackgroundColor [0.26, 0.3, 0.21, 1];
            };
        }];
    };
    
    _squareIndex = _squareIndex + 1;
} forEach _factories;

// Add [+] Build Factory button if below max
if (_squareIndex < _maxSquares && _squareIndex < _maxFactories) then {
    private _idc = 11220 + _squareIndex;
    private _ctrl = _display displayCtrl _idc;
    
    if (!isNull _ctrl) then {
        _ctrl ctrlShow true;
        
        // [+] text
        private _plusCtrl = _display ctrlCreate ["RscStructuredText", _idc + 2000];
        _plusCtrl ctrlSetPosition [
            (ctrlPosition _ctrl) select 0,
            ((ctrlPosition _ctrl) select 1) + ((ctrlPosition _ctrl) select 3) * 0.15,
            (ctrlPosition _ctrl) select 2,
            ((ctrlPosition _ctrl) select 3) * 0.5
        ];
        _plusCtrl ctrlSetStructuredText parseText "<t align='center' size='4.0'>+</t><br/><t align='center' size='0.8'>Build Factory</t>";
        _plusCtrl ctrlCommit 0;
        
        // Cost info
        private _costCtrl = _display ctrlCreate ["RscStructuredText", _idc + 3000];
        _costCtrl ctrlSetPosition [
            (ctrlPosition _ctrl) select 0,
            ((ctrlPosition _ctrl) select 1) + ((ctrlPosition _ctrl) select 3) * 0.72,
            (ctrlPosition _ctrl) select 2,
            ((ctrlPosition _ctrl) select 3) * 0.25
        ];
        _costCtrl ctrlSetStructuredText parseText "<t align='center' size='0.7' color='#AAAAAA'>Cost: 10 Steel, 5 Wood</t>";
        _costCtrl ctrlCommit 0;
        
        // Button overlay
        private _btnCtrl = _display ctrlCreate ["RscButton", _idc + 4000];
        _btnCtrl ctrlSetPosition [
            (ctrlPosition _ctrl) select 0,
            (ctrlPosition _ctrl) select 1,
            (ctrlPosition _ctrl) select 2,
            (ctrlPosition _ctrl) select 3
        ];
        _btnCtrl ctrlSetText "";
        _btnCtrl ctrlSetTooltip "Build a new factory";
        _btnCtrl ctrlCommit 0;
        
        _btnCtrl ctrlAddEventHandler ["ButtonClick", {
            [] call OpsRoom_fnc_buildFactory;
        }];
        
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
};

// Hide remaining squares
for "_i" from _squareIndex to (_maxSquares - 1) do {
    private _ctrl = _display displayCtrl (11220 + _i);
    if (!isNull _ctrl) then { _ctrl ctrlShow false };
};

diag_log format ["[OpsRoom] Factory grid populated: %1 factories", count _factories];
