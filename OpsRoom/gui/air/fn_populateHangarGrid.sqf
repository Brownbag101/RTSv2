/*
    Populate Hangar Grid
    
    Fills the hangar browser grid based on current filter.
    Each square shows aircraft icon, name, type, status, fuel/damage.
*/

private _display = findDisplay 11003;
if (isNull _display) exitWith {};

// Clean dynamic controls
for "_idc" from 12550 to 15561 do {
    private _ctrl = _display displayCtrl _idc;
    if (!isNull _ctrl) then { ctrlDelete _ctrl };
};

// Get filtered aircraft
private _filter = OpsRoom_HangarFilter;
private _aircraft = [];
{
    private _hangarId = _x;
    private _entry = _y;
    if (_filter == "" || {(_entry get "aircraftType") == _filter}) then {
        _aircraft pushBack [_hangarId, _entry];
    };
} forEach OpsRoom_Hangar;

private _squareIndex = 0;
private _maxSquares = 12;

{
    if (_squareIndex >= _maxSquares) exitWith {};
    
    _x params ["_hangarId", "_entry"];
    
    private _displayName = _entry get "displayName";
    private _acType = _entry get "aircraftType";
    private _status = _entry get "status";
    private _wingId = _entry get "wingId";
    private _fuel = _entry get "fuel";
    private _damage = _entry get "damage";
    
    private _idc = 11550 + _squareIndex;
    private _ctrl = _display displayCtrl _idc;
    
    if (!isNull _ctrl) then {
        _ctrl ctrlShow true;
        
        // Status-based background
        private _bgColor = switch (_status) do {
            case "AIRBORNE": { [0.20, 0.35, 0.20, 1.0] };
            case "DESTROYED": { [0.35, 0.15, 0.15, 1.0] };
            default { [0.26, 0.30, 0.21, 1.0] };
        };
        _ctrl ctrlSetBackgroundColor _bgColor;
        
        // Icon
        private _iconCtrl = _display ctrlCreate ["RscPicture", _idc + 1000];
        _iconCtrl ctrlSetPosition [
            ((ctrlPosition _ctrl) select 0) + 0.03 * safezoneW,
            ((ctrlPosition _ctrl) select 1) + 0.005 * safezoneH,
            0.05 * safezoneW,
            0.05 * safezoneH
        ];
        _iconCtrl ctrlSetText "\A3\ui_f\data\map\vehicleicons\iconplane_ca.paa";
        _iconCtrl ctrlCommit 0;
        
        // Name
        private _nameCtrl = _display ctrlCreate ["RscStructuredText", _idc + 2000];
        _nameCtrl ctrlSetPosition [
            (ctrlPosition _ctrl) select 0,
            ((ctrlPosition _ctrl) select 1) + 0.055 * safezoneH,
            (ctrlPosition _ctrl) select 2,
            0.025 * safezoneH
        ];
        _nameCtrl ctrlSetStructuredText parseText format ["<t align='center' size='0.75'>%1</t>", _displayName];
        _nameCtrl ctrlCommit 0;
        
        // Type + wing assignment
        private _wingText = if (_wingId != "") then {
            private _wData = OpsRoom_AirWings getOrDefault [_wingId, createHashMap];
            if (count _wData > 0) then { _wData get "name" } else { "Unknown Wing" }
        } else { "Unassigned" };
        
        private _infoCtrl = _display ctrlCreate ["RscStructuredText", _idc + 3000];
        _infoCtrl ctrlSetPosition [
            (ctrlPosition _ctrl) select 0,
            ((ctrlPosition _ctrl) select 1) + 0.08 * safezoneH,
            (ctrlPosition _ctrl) select 2,
            0.04 * safezoneH
        ];
        
        private _wingColor = if (_wingId != "") then {"#88CC88"} else {"#888888"};
        _infoCtrl ctrlSetStructuredText parseText format [
            "<t align='center' size='0.6' color='#AAAAAA'>%1</t><br/><t align='center' size='0.6' color='%3'>%2</t>",
            _acType, _wingText, _wingColor
        ];
        _infoCtrl ctrlCommit 0;
        
        // Fuel/damage
        private _fuelColor = if (_fuel > 0.5) then {"#88CC88"} else {if (_fuel > 0.2) then {"#CCCC44"} else {"#CC4444"}};
        private _dmgColor = if (_damage < 0.3) then {"#88CC88"} else {if (_damage < 0.7) then {"#CCCC44"} else {"#CC4444"}};
        
        private _barsCtrl = _display ctrlCreate ["RscStructuredText", _idc + 3500];
        _barsCtrl ctrlSetPosition [
            (ctrlPosition _ctrl) select 0,
            ((ctrlPosition _ctrl) select 1) + 0.12 * safezoneH,
            (ctrlPosition _ctrl) select 2,
            0.03 * safezoneH
        ];
        // Read weapon loadout from vehicle config (deep turret scan)
        private _className = _entry get "className";
        private _weaponText = [_className] call OpsRoom_fnc_getAircraftLoadout;
        if (_weaponText == "") then { _weaponText = "No weapons" };
        
        private _fuelLitres = round (_fuel * 100);
        
        _barsCtrl ctrlSetStructuredText parseText format [
            "<t size='0.5'>F:<t color='%1'>%2L</t>  D:<t color='%3'>%4%%</t>  %5<br/>%6</t>",
            _fuelColor, _fuelLitres,
            _dmgColor, round (_damage * 100),
            _status,
            _weaponText
        ];
        _barsCtrl ctrlCommit 0;
        
        // Click button
        private _btnCtrl = _display ctrlCreate ["RscButton", _idc + 4000];
        _btnCtrl ctrlSetPosition (ctrlPosition _ctrl);
        _btnCtrl ctrlSetText "";
        _btnCtrl ctrlSetTooltip format ["%1 (%2)", _displayName, _status];
        _btnCtrl setVariable ["hangarId", _hangarId];
        _btnCtrl ctrlCommit 0;
        
        _btnCtrl ctrlAddEventHandler ["ButtonClick", {
            params ["_ctrl"];
            private _hangarId = _ctrl getVariable ["hangarId", ""];
            [_hangarId] call OpsRoom_fnc_spawnPreviewAircraft;
        }];
        
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
} forEach _aircraft;

// Hide remaining
for "_i" from _squareIndex to (_maxSquares - 1) do {
    private _ctrl = _display displayCtrl (11550 + _i);
    if (!isNull _ctrl) then { _ctrl ctrlShow false };
};

diag_log format ["[OpsRoom] Hangar grid: %1 aircraft shown (filter: %2)", _squareIndex, _filter];
