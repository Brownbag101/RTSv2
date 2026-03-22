/*
    Populate Storehouse Grid
    
    Fills the grid squares with storehouse data.
    Shows name, item count, and nearby unit count per storehouse.
    
    Usage:
        [] call OpsRoom_fnc_populateStorehouseGrid;
*/

private _display = findDisplay 11006;
if (isNull _display) exitWith {};

private _maxSquares = 8;

// Clean up any previous dynamic controls
for "_i" from 0 to (_maxSquares - 1) do {
    { 
        private _ctrl = _display displayCtrl (11600 + _i + _x);
        if (!isNull _ctrl && _x > 0) then { ctrlDelete _ctrl };
    } forEach [0, 1000, 2000, 3000, 4000];
};

// Collect storehouse data
private _storehouses = [];
{
    _storehouses pushBack [_x, _y];
} forEach OpsRoom_Storehouses;

// Sort by name
_storehouses sort true;

private _squareIndex = 0;

{
    if (_squareIndex >= _maxSquares) exitWith {};
    
    _x params ["_storeId", "_storeData"];
    
    private _name = _storeData get "name";
    private _pos = _storeData get "position";
    private _radius = _storeData get "radius";
    private _inv = _storeData get "inventory";
    
    // Count total items in storehouse
    private _totalItems = 0;
    { _totalItems = _totalItems + _y } forEach _inv;
    
    // Count unique item types
    private _typeCount = count _inv;
    
    // Count friendly units near this storehouse
    private _nearUnits = _pos nearEntities ["Man", _radius];
    private _friendlyCount = 0;
    {
        if (alive _x && {side _x == side player}) then {
            _friendlyCount = _friendlyCount + 1;
        };
    } forEach _nearUnits;
    
    // Get the square background IDC
    private _squareIDC = 11600 + _squareIndex;
    private _squareCtrl = _display displayCtrl _squareIDC;
    
    if (!isNull _squareCtrl) then {
        _squareCtrl ctrlShow true;
        
        // Get square position for overlays
        private _sqPos = ctrlPosition _squareCtrl;
        _sqPos params ["_sqX", "_sqY", "_sqW", "_sqH"];
        
        // Icon (supply crate icon)
        private _imgCtrl = _display ctrlCreate ["RscPicture", _squareIDC + 1000];
        _imgCtrl ctrlSetPosition [
            _sqX + (_sqW / 2) - (0.02 * safezoneW),
            _sqY + (0.015 * safezoneH),
            0.04 * safezoneW,
            0.04 * safezoneH
        ];
        _imgCtrl ctrlSetText "\A3\ui_f\data\map\markers\nato\n_supply.paa";
        _imgCtrl ctrlSetTextColor [0.95, 0.85, 0.40, 1.0];
        _imgCtrl ctrlCommit 0;
        
        // Text overlay
        private _textCtrl = _display ctrlCreate ["RscStructuredText", _squareIDC + 2000];
        _textCtrl ctrlSetPosition [
            _sqX + (0.005 * safezoneW),
            _sqY + (0.06 * safezoneH),
            _sqW - (0.01 * safezoneW),
            _sqH - (0.06 * safezoneH)
        ];
        
        private _itemText = if (_totalItems > 0) then {
            format ["%1 items (%2 types)", _totalItems, _typeCount]
        } else {
            "Empty"
        };
        
        _textCtrl ctrlSetStructuredText parseText format [
            "<t align='center' size='1.1'>%1</t><br/><t align='center' size='0.9' color='#A09A8C'>%2</t><br/><t align='center' size='0.9' color='#A09A8C'>%3 units nearby</t>",
            _name,
            _itemText,
            _friendlyCount
        ];
        _textCtrl ctrlCommit 0;
        
        // Clickable button overlay
        private _btnCtrl = _display ctrlCreate ["RscButton", _squareIDC + 4000];
        _btnCtrl ctrlSetPosition [_sqX, _sqY, _sqW, _sqH];
        _btnCtrl ctrlSetText "";
        _btnCtrl ctrlSetBackgroundColor [0, 0, 0, 0.01];
        _btnCtrl ctrlSetActiveColor [0.35, 0.40, 0.28, 0.3];
        _btnCtrl ctrlCommit 0;
        
        _btnCtrl setVariable ["storehouseId", _storeId];
        
        _btnCtrl ctrlAddEventHandler ["ButtonClick", {
            params ["_ctrl"];
            private _id = _ctrl getVariable ["storehouseId", ""];
            if (_id != "") then {
                _ctrl spawn {
                    private _id = _this getVariable ["storehouseId", ""];
                    closeDialog 0;
                    sleep 0.1;
                    [_id] call OpsRoom_fnc_openStorehouseInterior;
                };
            };
        }];
        
        _btnCtrl ctrlAddEventHandler ["MouseEnter", {
            params ["_ctrl"];
            private _idc = ctrlIDC _ctrl;
            private _bgCtrl = (ctrlParent _ctrl) displayCtrl (_idc - 4000);
            if (!isNull _bgCtrl) then {
                _bgCtrl ctrlSetBackgroundColor [0.35, 0.40, 0.28, 1.0];
            };
        }];
        
        _btnCtrl ctrlAddEventHandler ["MouseExit", {
            params ["_ctrl"];
            private _idc = ctrlIDC _ctrl;
            private _bgCtrl = (ctrlParent _ctrl) displayCtrl (_idc - 4000);
            if (!isNull _bgCtrl) then {
                _bgCtrl ctrlSetBackgroundColor [0.26, 0.30, 0.21, 1.0];
            };
        }];
    };
    
    _squareIndex = _squareIndex + 1;
} forEach _storehouses;

// Hide unused squares
for "_i" from _squareIndex to (_maxSquares - 1) do {
    private _ctrl = _display displayCtrl (11600 + _i);
    if (!isNull _ctrl) then { _ctrl ctrlShow false };
};

// Show message if no storehouses
if (_squareIndex == 0) then {
    private _ctrl = _display displayCtrl 11600;
    if (!isNull _ctrl) then {
        _ctrl ctrlShow true;
        private _textCtrl = _display ctrlCreate ["RscStructuredText", 11600 + 2000];
        private _sqPos = ctrlPosition _ctrl;
        _textCtrl ctrlSetPosition [_sqPos select 0, (_sqPos select 1) + 0.04 * safezoneH, _sqPos select 2, _sqPos select 3];
        _textCtrl ctrlSetStructuredText parseText "<t align='center' size='1.1'>No Storehouses</t><br/><t align='center' size='0.9' color='#A09A8C'>Place markers named<br/>opsroom_stores_1 etc.<br/>in Eden Editor</t>";
        _textCtrl ctrlCommit 0;
    };
};

diag_log format ["[OpsRoom] Storehouse grid populated: %1 storehouses", _squareIndex];
