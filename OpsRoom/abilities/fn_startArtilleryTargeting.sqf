/*
    OpsRoom_fnc_startArtilleryTargeting
    
    Enters cursor-follow targeting mode for artillery fire missions.
    Player has already chosen type, ammo, and round count.
    Click fires immediately — no second menu needed.
    
    Parameters:
        0: STRING - Vehicle type classname
        1: STRING - Ammo type classname
        2: NUMBER - Round count (-1 = fire for effect)
*/

params ["_vehType", "_ammoType", "_roundCount"];

// Close the menu after selection
[] call OpsRoom_fnc_closeButtonMenu;

// Get matching crewed vehicles of this type
private _available = OpsRoom_Artillery_Available;
private _guns = [];
{
    if ((_x get "type") == _vehType) then {
        private _veh = _x get "vehicle";
        if (alive _veh && {!(isNull (gunner _veh))} && {_ammoType in (getArtilleryAmmo [_veh])}) then {
            _guns pushBack _veh;
        };
    };
} forEach _available;

if (count _guns == 0) exitWith {
    hint "No artillery of this type available anymore.";
};

private _display = findDisplay 312;
if (isNull _display) exitWith { hint "Zeus display not found" };

// Store targeting state
OpsRoom_ArtilleryTargeting_Active = true;
OpsRoom_ArtilleryTargeting_Guns = _guns;
OpsRoom_ArtilleryTargeting_VehType = _vehType;
OpsRoom_ArtilleryTargeting_AmmoType = _ammoType;
OpsRoom_ArtilleryTargeting_RoundCount = _roundCount;

// Get display names
private _knownTypes = createHashMapFromArray [
    ["JMSSA_vehgr_BL55inch_F",      "BL 5.5-inch Gun"],
    ["JMSSA_vehgr_2inchMortarAB_F", "2-inch Mortar (AB)"],
    ["JMSSA_vehgr_2inchMortar_F",   "2-inch Mortar"]
];
private _gunName = _knownTypes getOrDefault [_vehType, "Artillery"];

private _ammoDisplayName = getText (configFile >> "CfgMagazines" >> _ammoType >> "displayName");
if (_ammoDisplayName == "") then { _ammoDisplayName = _ammoType };

OpsRoom_ArtilleryTargeting_GunName = _gunName;
OpsRoom_ArtilleryTargeting_AmmoName = _ammoDisplayName;

private _roundText = if (_roundCount == -1) then {"FFE"} else {format ["%1 rnd(s)", _roundCount]};

// Draw3D handler — cursor-follow targeting
OpsRoom_ArtilleryTargeting_DrawEH = addMissionEventHandler ["Draw3D", {
    if !(OpsRoom_ArtilleryTargeting_Active isEqualTo true) exitWith {
        removeMissionEventHandler ["Draw3D", _thisEventHandler];
    };
    
    private _guns = OpsRoom_ArtilleryTargeting_Guns;
    private _ammoType = OpsRoom_ArtilleryTargeting_AmmoType;
    if (count _guns == 0) exitWith {};
    
    // Get cursor world position from mouse
    private _mousePos = getMousePosition;
    private _cursorPos = screenToWorld _mousePos;
    _cursorPos set [2, 0];
    
    // Check if ANY gun can reach target
    private _inRange = _cursorPos inRangeOfArtillery [_guns, _ammoType];
    
    // Count how many guns are in range
    private _gunsInRange = 0;
    {
        if (_cursorPos inRangeOfArtillery [[_x], _ammoType]) then {
            _gunsInRange = _gunsInRange + 1;
        };
    } forEach _guns;
    
    private _color = if (_inRange) then {[1, 0.5, 0, 0.8]} else {[1, 0, 0, 0.8]};
    
    // Draw targeting circle at cursor
    private _pulse = 0.5 + (sin(time * 300) * 0.3);
    private _circleColor = if (_inRange) then {[1, 0.5, 0, _pulse]} else {[1, 0, 0, _pulse]};
    private _segments = 24;
    private _circleRadius = 5;
    for "_s" from 0 to (_segments - 1) do {
        private _a1 = (_s / _segments) * 360;
        private _a2 = ((_s + 1) / _segments) * 360;
        private _p1 = _cursorPos vectorAdd [_circleRadius * sin _a1, _circleRadius * cos _a1, 0.1];
        private _p2 = _cursorPos vectorAdd [_circleRadius * sin _a2, _circleRadius * cos _a2, 0.1];
        drawLine3D [_p1, _p2, _circleColor];
    };
    
    // Draw crosshair
    private _chSize = 2;
    drawLine3D [
        _cursorPos vectorAdd [-_chSize, 0, 0.1],
        _cursorPos vectorAdd [_chSize, 0, 0.1],
        [1, 0.5, 0, 0.7]
    ];
    drawLine3D [
        _cursorPos vectorAdd [0, -_chSize, 0.1],
        _cursorPos vectorAdd [0, _chSize, 0.1],
        [1, 0.5, 0, 0.7]
    ];
    
    // Get ETA from first gun in range
    private _etaText = "---";
    if (_inRange) then {
        {
            if (_cursorPos inRangeOfArtillery [[_x], _ammoType]) exitWith {
                private _eta = _x getArtilleryETA [_cursorPos, _ammoType];
                _etaText = format ["%.0fs", _eta];
            };
        } forEach _guns;
    };
    
    // Distance to nearest gun
    private _nearestDist = 99999;
    {
        private _d = _x distance2D _cursorPos;
        if (_d < _nearestDist) then { _nearestDist = _d };
    } forEach _guns;
    
    private _gunName = OpsRoom_ArtilleryTargeting_GunName;
    private _ammoName = OpsRoom_ArtilleryTargeting_AmmoName;
    private _roundCount = OpsRoom_ArtilleryTargeting_RoundCount;
    private _roundText = if (_roundCount == -1) then {"FFE"} else {format ["%1 rnd(s)", _roundCount]};
    
    if (_inRange) then {
        drawIcon3D ["", _color, _cursorPos vectorAdd [0,0,4], 0, 0, 0,
            format ["FIRE MISSION — %1 (%2)", _gunName, _ammoName], 2, 0.04, "PuristaMedium", "center", true];
        drawIcon3D ["", [1, 0.8, 0.3, 0.9], _cursorPos vectorAdd [0,0,3.3], 0, 0, 0,
            format ["%1/%2 guns in range — %3 — ETA %4 — CLICK to fire", _gunsInRange, count _guns, _roundText, _etaText],
            2, 0.03, "PuristaMedium", "center", true];
    } else {
        drawIcon3D ["", _color, _cursorPos vectorAdd [0,0,4], 0, 0, 0,
            format ["OUT OF RANGE — %1 (%.0fm)", _gunName, _nearestDist], 2, 0.04, "PuristaMedium", "center", true];
        drawIcon3D ["", [1, 0.3, 0.3, 0.7], _cursorPos vectorAdd [0,0,3.3], 0, 0, 0,
            format ["%1 gun(s) — move closer to target", count _guns],
            2, 0.03, "PuristaMedium", "center", true];
    };
    
    drawIcon3D ["", [1,1,1,0.5], _cursorPos vectorAdd [0,0,2.6], 0, 0, 0,
        "RMB / ESC to cancel", 2, 0.03, "PuristaMedium", "center", true];
    
    // Draw lines from each gun to cursor
    {
        private _gunPos = getPosATL _x;
        _gunPos set [2, (_gunPos select 2) + 2];
        private _lineColor = if (_cursorPos inRangeOfArtillery [[_x], _ammoType]) then {
            [1, 0.5, 0, 0.3]
        } else {
            [1, 0, 0, 0.15]
        };
        drawLine3D [_gunPos, _cursorPos vectorAdd [0,0,0.5], _lineColor];
    } forEach _guns;
}];

// Mouse click handler — click fires immediately
OpsRoom_ArtilleryTargeting_ClickHandler = _display displayAddEventHandler ["MouseButtonDown", {
    params ["_display", "_button"];
    
    // Right click = cancel
    if (_button == 1) exitWith {
        [] call OpsRoom_fnc_cancelArtilleryTargeting;
        hint "Artillery targeting cancelled";
        true
    };
    
    // Only left click
    if (_button != 0) exitWith {};
    
    private _guns = OpsRoom_ArtilleryTargeting_Guns;
    private _ammoType = OpsRoom_ArtilleryTargeting_AmmoType;
    private _roundCount = OpsRoom_ArtilleryTargeting_RoundCount;
    
    // Get target position from mouse
    private _targetPos = screenToWorld (getMousePosition);
    
    // Check range
    private _inRange = _targetPos inRangeOfArtillery [_guns, _ammoType];
    
    if (!_inRange) exitWith {
        hint "Target out of range! Move target closer to artillery.";
    };
    
    // Get guns that can reach
    private _gunsInRange = [];
    {
        if (_targetPos inRangeOfArtillery [[_x], _ammoType]) then {
            _gunsInRange pushBack _x;
        };
    } forEach _guns;
    
    // Store for execution
    OpsRoom_ArtilleryTargeting_TargetPos = _targetPos;
    OpsRoom_ArtilleryTargeting_GunsInRange = _gunsInRange;
    
    // Clean up targeting
    [] call OpsRoom_fnc_cancelArtilleryTargeting;
    
    // Fire immediately
    [_roundCount] call OpsRoom_fnc_executeArtillery;
    
    true
}];

// ESC key handler
OpsRoom_ArtilleryTargeting_ESCHandler = _display displayAddEventHandler ["KeyDown", {
    params ["_display", "_key"];
    
    if (_key == 1) then {
        [] call OpsRoom_fnc_cancelArtilleryTargeting;
        hint "Artillery targeting cancelled";
        true
    } else {
        false
    };
}];

systemChat format ["Artillery targeting — %1 x %2 (%3, %4) — CLICK to fire, RMB/ESC to cancel",
    count _guns, _gunName, _ammoDisplayName, _roundText];
