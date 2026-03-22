/*
    Scan Storehouse Crates
    
    Scans for physical crates near the storehouse and updates the status text.
    Does not absorb them — just reports what's available.
    
    Usage:
        [] call OpsRoom_fnc_scanStorehouseCrates;
*/

private _display = findDisplay 11007;
if (isNull _display) exitWith {};

private _storehouseId = uiNamespace getVariable ["OpsRoom_SelectedStorehouse", ""];
if (_storehouseId == "") exitWith {};

private _storeData = OpsRoom_Storehouses get _storehouseId;
if (isNil "_storeData") exitWith {};

private _pos = _storeData get "position";
private _radius = _storeData get "radius";

// Find containers
private _searchTypes = [
    "ReammoBox_F", "ThingX", "WeaponHolder",
    "WeaponHolderSimulated", "GroundWeaponHolder"
];
private _nearObjects = nearestObjects [_pos, _searchTypes, _radius];

private _crates = [];
{
    if (!(_x isKindOf "Man") && !(_x isKindOf "Car") && !(_x isKindOf "Tank") && !(_x isKindOf "Air")) then {
        _crates pushBack _x;
    };
} forEach _nearObjects;

private _statusCtrl = _display displayCtrl 11740;

if (count _crates == 0) then {
    _statusCtrl ctrlSetStructuredText parseText "<t color='#A09A8C'>No crates detected within depot radius. Deliver supply crates to this location, then absorb.</t>";
} else {
    private _details = "";
    {
        private _crateName = getText (configFile >> "CfgVehicles" >> typeOf _x >> "displayName");
        if (_crateName == "") then { _crateName = typeOf _x };
        private _dist = (_x distance _pos) toFixed 0;
        _details = _details + format ["<br/>  • %1 (%2m)", _crateName, _dist];
    } forEach _crates;
    
    _statusCtrl ctrlSetStructuredText parseText format [
        "<t color='#F2D964'>%1 crate(s) detected in area:</t>%2<br/><br/><t color='#A09A8C'>Click ABSORB to catalogue contents into stores.</t>",
        count _crates,
        _details
    ];
};
