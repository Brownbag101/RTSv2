/*
    On Ship Destroyed
    
    Called via Killed EH when a convoy ship is sunk.
    Cargo on that ship is LOST. Ship is NOT returned to pool.
    
    Parameters:
        0: NUMBER - Convoy index in OpsRoom_ActiveConvoys
        1: NUMBER - Ship index within convoy
        2: STRING - Ship name
        3: ARRAY  - Ship manifest [[itemId, qty], ...]
    
    Usage:
        [_convoyIndex, _shipIndex, _shipName, _manifest] call OpsRoom_fnc_onShipDestroyed;
*/

params [
    ["_convoyIndex", -1, [0]],
    ["_shipIndex", -1, [0]],
    ["_shipName", "Unknown vessel", [""]],
    ["_manifest", [], [[]]]
];

if (_convoyIndex < 0 || _convoyIndex >= count OpsRoom_ActiveConvoys) exitWith {
    diag_log format ["[OpsRoom] Convoy: Ship destroyed but invalid convoy index %1", _convoyIndex];
};

private _convoy = OpsRoom_ActiveConvoys select _convoyIndex;
private _codename = _convoy select 1;

// Build cargo loss summary
private _lossSummary = "";
{
    _x params ["_itemId", "_qty"];
    private _itemData = OpsRoom_EquipmentDB get _itemId;
    private _name = if (!isNil "_itemData") then { _itemData get "displayName" } else { _itemId };
    _lossSummary = _lossSummary + format ["\n  %1x %2 — LOST", _qty, _name];
} forEach _manifest;

// Decrement alive count
private _shipsAlive = (_convoy select 8) - 1;
_convoy set [8, _shipsAlive max 0];

// Mark ship as null in convoy data
private _ships = _convoy select 2;
if (_shipIndex >= 0 && _shipIndex < count _ships) then {
    (_ships select _shipIndex) set [1, objNull];
    // Update unload state
    if (count (_ships select _shipIndex) > 2) then {
        private _state = (_ships select _shipIndex) select 2;
        if (!isNil "_state" && {typeName _state == "HASHMAP"}) then {
            _state set ["status", "destroyed"];
        };
    };
};

// FLASH dispatch
["FLASH", format ["%1 SUNK!", _shipName],
    format ["%1 (Convoy %2) has been sunk! All cargo lost:%3", _shipName, _codename, _lossSummary]
] call OpsRoom_fnc_dispatch;

systemChat format ["WARNING: %1 has been sunk! Cargo lost!", _shipName];

// Check if entire convoy lost
if (_shipsAlive <= 0) then {
    _convoy set [7, "destroyed"];
    
    ["FLASH", format ["CONVOY %1 LOST", _codename],
        format ["All ships in Convoy %1 have been sunk. Convoy destroyed.", _codename]
    ] call OpsRoom_fnc_dispatch;
    
    diag_log format ["[OpsRoom] Convoy %1: ALL ships destroyed", _codename];
} else {
    ["PRIORITY", format ["CONVOY %1 UNDER ATTACK", _codename],
        format ["Convoy %1 has lost a ship. %2 ship(s) remaining.", _codename, _shipsAlive]
    ] call OpsRoom_fnc_dispatch;
};

diag_log format ["[OpsRoom] Convoy: %1 sunk (convoy %2), %3 ships remaining", _shipName, _codename, _shipsAlive];
