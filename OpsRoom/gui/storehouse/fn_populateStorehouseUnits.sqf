/*
    Populate Storehouse Units
    
    Fills the unit listbox with friendly units near the storehouse.
    
    Usage:
        [] call OpsRoom_fnc_populateStorehouseUnits;
*/

private _display = findDisplay 11007;
if (isNull _display) exitWith {};

private _storehouseId = uiNamespace getVariable ["OpsRoom_SelectedStorehouse", ""];
if (_storehouseId == "") exitWith {};

private _storeData = OpsRoom_Storehouses get _storehouseId;
if (isNil "_storeData") exitWith {};

private _pos = _storeData get "position";
private _radius = _storeData get "radius";

private _listbox = _display displayCtrl 11710;
lbClear _listbox;

// Find friendly units in radius
private _nearEntities = _pos nearEntities ["Man", _radius];
private _friendlyUnits = [];

{
    if (alive _x && {side _x == side player}) then {
        _friendlyUnits pushBack _x;
    };
} forEach _nearEntities;

// Sort by name
_friendlyUnits = [_friendlyUnits, [], { name _x }] call BIS_fnc_sortBy;

// Store unit list for selection handler
uiNamespace setVariable ["OpsRoom_StorehouseUnitList", _friendlyUnits];

if (count _friendlyUnits == 0) then {
    private _idx = _listbox lbAdd "No units in area";
    _listbox lbSetColor [_idx, [0.5, 0.5, 0.5, 0.7]];
    private _idx2 = _listbox lbAdd format ["(within %1m of depot)", _radius];
    _listbox lbSetColor [_idx2, [0.5, 0.5, 0.5, 0.5]];
} else {
    {
        private _unit = _x;
        private _rankStr = rank _unit;
        private _name = name _unit;
        private _health = if (damage _unit < 0.25) then { "" } else { " [WOUNDED]" };
        
        private _idx = _listbox lbAdd format ["%1 %2%3", _rankStr, _name, _health];
        
        // Colour by health
        if (damage _unit >= 0.75) then {
            _listbox lbSetColor [_idx, [0.8, 0.3, 0.3, 1.0]];
        } else {
            if (damage _unit >= 0.25) then {
                _listbox lbSetColor [_idx, [0.9, 0.7, 0.3, 1.0]];
            } else {
                _listbox lbSetColor [_idx, [0.85, 0.82, 0.74, 1.0]];
            };
        };
    } forEach _friendlyUnits;
};

// Update unit inventory header
private _headerCtrl = _display displayCtrl 11721;
_headerCtrl ctrlSetText "SELECT A UNIT";

diag_log format ["[OpsRoom] Storehouse units: %1 friendly in radius", count _friendlyUnits];
