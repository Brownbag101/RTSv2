/*
    Cargo System - Update Cargo Display
    
    Creates clickable cargo unload icons on the Zeus display (312).
    Icons are half-size and double-stacked to the RIGHT of the unit info box.
    
    Includes change detection to prevent flicker from the 0.5s update loop.
    
    Parameters:
        0: OBJECT - The selected vehicle (objNull to clear)
        1: BOOL   - (Optional) Force refresh, default false
    
    Usage:
        [_vehicle] call OpsRoom_fnc_updateCargoDisplay;
        [_vehicle, true] call OpsRoom_fnc_updateCargoDisplay;
*/

params [["_vehicle", objNull], ["_forceRefresh", false]];

private _display = findDisplay 312;
if (isNull _display) exitWith {};

// ============================================================
// CHANGE DETECTION
// ============================================================

private _currentCargoCount = 0;
private _isCarrier = false;

if (!isNull _vehicle && !isNil "OpsRoom_CargoCarriers") then {
    private _cargo = _vehicle getVariable ["OpsRoom_CargoItems", []];
    _currentCargoCount = count _cargo;
    _isCarrier = (OpsRoom_CargoCarriers getOrDefault [typeOf _vehicle, -1]) > 0;
};

private _lastVehicle = missionNamespace getVariable ["OpsRoom_CargoDisplay_LastVehicle", objNull];
private _lastCount = missionNamespace getVariable ["OpsRoom_CargoDisplay_LastCount", -1];

if (!_forceRefresh && {_vehicle == _lastVehicle && _currentCargoCount == _lastCount}) exitWith {};

missionNamespace setVariable ["OpsRoom_CargoDisplay_LastVehicle", _vehicle];
missionNamespace setVariable ["OpsRoom_CargoDisplay_LastCount", _currentCargoCount];

// ============================================================
// CLEANUP
// ============================================================

for "_i" from 9500 to 9579 do {
    private _ctrl = _display displayCtrl _i;
    if (!isNull _ctrl) then {
        ctrlDelete _ctrl;
    };
};

if (isNull _vehicle || !_isCarrier || _currentCargoCount == 0) exitWith {};

private _cargo = _vehicle getVariable ["OpsRoom_CargoItems", []];

// ============================================================
// CREATE CARGO ICONS
// Half-size, double-stacked, to the RIGHT of the unit info box
// ============================================================

// Half the size of ability buttons
private _iconSize = 0.018 * safezoneH;
private _iconPadding = 0.002 * safezoneW;

// Unit info box right edge: safezoneX + safezoneW * 0.5 + 0.15 * safezoneW
// Add a small gap after the box
private _startX = safezoneX + (safezoneW * 0.65) + (0.008 * safezoneW);

// Two rows: top row and bottom row, vertically centred in the bottom bar
// Bottom bar Y = safezoneY + safezoneH - 0.08 * safezoneH
// Bottom bar height = 0.08 * safezoneH
// Centre two rows: total height = 2 * iconSize + padding
private _barTopY = safezoneY + safezoneH - (0.07 * safezoneH);
private _totalGridH = (_iconSize * 2) + (0.002 * safezoneH);
private _topRowY = _barTopY + (0.06 * safezoneH - _totalGridH) * 0.5;
private _bottomRowY = _topRowY + _iconSize + (0.002 * safezoneH);

// Calculate how many columns we need (2 rows)
private _maxPerRow = ceil ((count _cargo) / 2);

{
    _x params ["_obj", "_className", "_displayName", "_weight", "_isUnit"];
    private _index = _forEachIndex;
    
    // Grid position: column = index / 2, row = index mod 2 (fill top then bottom)
    private _col = floor (_index / 2);
    private _row = _index mod 2;
    
    private _xPos = _startX + (_col * (_iconSize + _iconPadding));
    private _yPos = if (_row == 0) then {_topRowY} else {_bottomRowY};
    
    private _bgIDC = 9500 + (_index * 2);
    private _btnIDC = 9501 + (_index * 2);
    
    // Choose icon
    private _icon = if (_isUnit) then {
        "a3\ui_f\data\igui\cfg\simpleTasks\types\meet_ca.paa"
    } else {
        "a3\ui_f\data\igui\cfg\simpleTasks\types\use_ca.paa"
    };
    
    private _iconColor = if (_isUnit) then {[0.7, 0.85, 0.7, 1.0]} else {[0.85, 0.82, 0.74, 1.0]};
    
    // Background
    private _bg = _display ctrlCreate ["RscText", _bgIDC];
    _bg ctrlSetPosition [_xPos, _yPos, _iconSize, _iconSize];
    _bg ctrlSetBackgroundColor [0.15, 0.15, 0.15, 0.8];
    _bg ctrlCommit 0;
    
    // Clickable icon
    private _btn = _display ctrlCreate ["RscActivePicture", _btnIDC];
    _btn ctrlSetPosition [_xPos, _yPos, _iconSize, _iconSize];
    _btn ctrlSetText _icon;
    _btn ctrlSetTooltip format ["%1 (%2 slot%3) - Click to unload", _displayName, _weight, if (_weight > 1) then {"s"} else {""}];
    _btn ctrlSetTextColor _iconColor;
    _btn ctrlCommit 0;
    
    _btn setVariable ["buttonBG", _bg];
    _btn setVariable ["cargoVehicle", _vehicle];
    _btn setVariable ["cargoIndex", _index];
    
    _btn ctrlAddEventHandler ["MouseButtonClick", {
        params ["_ctrl", "_button"];
        if (_button != 0) exitWith {};
        
        private _veh = _ctrl getVariable ["cargoVehicle", objNull];
        private _idx = _ctrl getVariable ["cargoIndex", -1];
        
        if (!isNull _veh && _idx >= 0) then {
            [_veh, _idx] call OpsRoom_fnc_unloadCargo;
        };
    }];
    
    _btn ctrlAddEventHandler ["MouseEnter", {
        params ["_ctrl"];
        private _bg = _ctrl getVariable ["buttonBG", controlNull];
        if (!isNull _bg) then {
            _bg ctrlSetBackgroundColor [0.40, 0.35, 0.25, 0.95];
        };
    }];
    
    _btn ctrlAddEventHandler ["MouseExit", {
        params ["_ctrl"];
        private _bg = _ctrl getVariable ["buttonBG", controlNull];
        if (!isNull _bg) then {
            _bg ctrlSetBackgroundColor [0.15, 0.15, 0.15, 0.8];
        };
    }];
    
} forEach _cargo;

// ============================================================
// UNLOAD ALL BUTTON (after the cargo icons)
// ============================================================

if (count _cargo > 1) then {
    // Position after the last column of cargo icons
    private _maxCol = floor ((count _cargo - 1) / 2);
    private _unloadAllX = _startX + ((_maxCol + 1) * (_iconSize + _iconPadding)) + (0.003 * safezoneW);
    // Centre vertically between the two rows
    private _unloadAllY = _topRowY + (_totalGridH - _iconSize) * 0.5;
    
    private _uaBgIDC = 9570;
    private _uaBtnIDC = 9571;
    
    private _uaBg = _display ctrlCreate ["RscText", _uaBgIDC];
    _uaBg ctrlSetPosition [_unloadAllX, _unloadAllY, _iconSize, _iconSize];
    _uaBg ctrlSetBackgroundColor [0.5, 0.2, 0.2, 0.8];
    _uaBg ctrlCommit 0;
    
    private _uaBtn = _display ctrlCreate ["RscActivePicture", _uaBtnIDC];
    _uaBtn ctrlSetPosition [_unloadAllX, _unloadAllY, _iconSize, _iconSize];
    _uaBtn ctrlSetText "a3\ui_f\data\igui\cfg\simpleTasks\types\use_ca.paa";
    _uaBtn ctrlSetTooltip "UNLOAD ALL";
    _uaBtn ctrlSetTextColor [1.0, 0.5, 0.5, 1.0];
    _uaBtn ctrlCommit 0;
    
    _uaBtn setVariable ["buttonBG", _uaBg];
    _uaBtn setVariable ["cargoVehicle", _vehicle];
    
    _uaBtn ctrlAddEventHandler ["MouseButtonClick", {
        params ["_ctrl", "_button"];
        if (_button != 0) exitWith {};
        private _veh = _ctrl getVariable ["cargoVehicle", objNull];
        if (!isNull _veh) then {
            [_veh] call OpsRoom_fnc_unloadAllCargo;
        };
    }];
    
    _uaBtn ctrlAddEventHandler ["MouseEnter", {
        params ["_ctrl"];
        private _bg = _ctrl getVariable ["buttonBG", controlNull];
        if (!isNull _bg) then { _bg ctrlSetBackgroundColor [0.6, 0.3, 0.3, 0.95] };
    }];
    
    _uaBtn ctrlAddEventHandler ["MouseExit", {
        params ["_ctrl"];
        private _bg = _ctrl getVariable ["buttonBG", controlNull];
        if (!isNull _bg) then { _bg ctrlSetBackgroundColor [0.5, 0.2, 0.2, 0.8] };
    }];
};
