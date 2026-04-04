/*
    OpsRoom_fnc_executeArtillery
    
    Executes an artillery fire mission using native ARMA 3 doArtilleryFire.
    All guns in range fire the specified number of rounds with slight scatter.
    Shows Draw3D countdown marker at impact zone.
    
    Parameters:
        0: NUMBER - Rounds per gun (-1 = fire for effect / all ammo)
*/

params ["_roundCount"];

// Close the menu
[] call OpsRoom_fnc_closeButtonMenu;

// Retrieve stored targeting data
private _targetPos = OpsRoom_ArtilleryTargeting_TargetPos;
private _gunsInRange = OpsRoom_ArtilleryTargeting_GunsInRange;
private _ammoType = OpsRoom_ArtilleryTargeting_AmmoType;
private _gunName = OpsRoom_ArtilleryTargeting_GunName;
private _ammoName = OpsRoom_ArtilleryTargeting_AmmoName;

diag_log format ["[OpsRoom] executeArtillery called: rounds=%1 targetPos=%2 gunsInRange=%3 ammoType=%4",
    _roundCount, _targetPos, _gunsInRange, _ammoType];

if (isNil "_targetPos" || isNil "_gunsInRange") exitWith {
    hint "Error: No target data. Try again.";
    diag_log "[OpsRoom] ERROR: Artillery target data is nil!";
};

if (count _gunsInRange == 0) exitWith {
    hint "No artillery in range of target.";
};

// Validate guns still alive and crewed
private _validGuns = _gunsInRange select {
    alive _x && {!(isNull (gunner _x))} && {_ammoType in (getArtilleryAmmo [_x])}
};

if (count _validGuns == 0) exitWith {
    hint "Artillery no longer available (destroyed or abandoned).";
};

// Calculate ETA from first gun
private _eta = (_validGuns select 0) getArtilleryETA [_targetPos, _ammoType];

// Determine actual round count
private _actualRounds = _roundCount;
if (_roundCount == -1) then {
    // Fire for effect: count total magazines of this type on the first gun
    private _magCount = {_x == _ammoType} count (magazines (_validGuns select 0));
    // Get rounds per mag from config
    private _roundsPerMag = getNumber (configFile >> "CfgMagazines" >> _ammoType >> "count");
    if (_roundsPerMag <= 0) then { _roundsPerMag = 8 }; // Fallback
    _actualRounds = _magCount * _roundsPerMag;
    if (_actualRounds <= 0) then { _actualRounds = 1 };
};

// Get rounds per magazine (doArtilleryFire can only fire up to mag capacity per call)
private _roundsPerMag = getNumber (configFile >> "CfgMagazines" >> _ammoType >> "count");
if (_roundsPerMag <= 0) then { _roundsPerMag = 8 };

private _roundText = if (_roundCount == -1) then {
    format ["FIRE FOR EFFECT (~%1 rounds)", _actualRounds]
} else {
    format ["%1 ROUND(S)", _actualRounds]
};

private _gunCount = count _validGuns;

// Dispatch notification
hint format ["FIRE MISSION\n%1 x %2\n%3 — %4\nETA: %.0f seconds\nTarget: %5",
    _gunCount, _gunName, _roundText, _ammoName, _eta, _targetPos];

systemChat format ["Fire mission — %1 x %2 firing %3 at target — splash in %.0fs",
    _gunCount, _gunName, _roundText, _eta];

// Draw3D impact zone marker with countdown
private _startTime = time;
private _impactTime = time + _eta;

OpsRoom_Artillery_FireMission_Active = true;
OpsRoom_Artillery_FireMission_Pos = _targetPos;
OpsRoom_Artillery_FireMission_ImpactTime = _impactTime;
OpsRoom_Artillery_FireMission_Splashed = false;

OpsRoom_Artillery_FireMission_DrawEH = addMissionEventHandler ["Draw3D", {
    if !(OpsRoom_Artillery_FireMission_Active isEqualTo true) exitWith {
        removeMissionEventHandler ["Draw3D", _thisEventHandler];
    };
    
    private _pos = OpsRoom_Artillery_FireMission_Pos;
    private _impactTime = OpsRoom_Artillery_FireMission_ImpactTime;
    private _splashed = OpsRoom_Artillery_FireMission_Splashed;
    private _timeLeft = _impactTime - time;
    
    // Draw red impact zone circle
    private _pulse = 0.5 + (sin(time * 400) * 0.4);
    private _segments = 24;
    private _radius = 8;
    for "_s" from 0 to (_segments - 1) do {
        private _a1 = (_s / _segments) * 360;
        private _a2 = ((_s + 1) / _segments) * 360;
        private _p1 = _pos vectorAdd [_radius * sin _a1, _radius * cos _a1, 0.1];
        private _p2 = _pos vectorAdd [_radius * sin _a2, _radius * cos _a2, 0.1];
        drawLine3D [_p1, _p2, [1, 0.2, 0, _pulse]];
    };
    
    // Crosshair
    drawLine3D [_pos vectorAdd [-3, 0, 0.1], _pos vectorAdd [3, 0, 0.1], [1, 0.2, 0, 0.7]];
    drawLine3D [_pos vectorAdd [0, -3, 0.1], _pos vectorAdd [0, 3, 0.1], [1, 0.2, 0, 0.7]];
    
    if (!_splashed && {_timeLeft > 0}) then {
        // Countdown
        drawIcon3D ["", [1, 0.3, 0, 1], _pos vectorAdd [0,0,5], 0, 0, 0,
            "FIRE MISSION INBOUND", 2, 0.05, "PuristaBold", "center", true];
        drawIcon3D ["", [1, 0.6, 0.2, 1], _pos vectorAdd [0,0,4], 0, 0, 0,
            format ["SPLASH IN %.0fs", _timeLeft], 2, 0.04, "PuristaMedium", "center", true];
    } else {
        if (!_splashed) then {
            OpsRoom_Artillery_FireMission_Splashed = true;
            systemChat "SPLASH SPLASH SPLASH!";
        };
        
        // Show "IMPACT" briefly, then fade out
        private _timeSinceSplash = time - _impactTime;
        if (_timeSinceSplash < 10) then {
            private _alpha = 1 - (_timeSinceSplash / 10);
            drawIcon3D ["", [1, 0, 0, _alpha], _pos vectorAdd [0,0,5], 0, 0, 0,
                "IMPACT", 2, 0.05, "PuristaBold", "center", true];
        } else {
            // Done, remove handler
            OpsRoom_Artillery_FireMission_Active = nil;
        };
    };
}];

// Execute fire mission (spawned so we can sleep between rounds)
[_validGuns, _targetPos, _ammoType, _actualRounds] spawn {
    params ["_guns", "_pos", "_ammo", "_totalRounds"];
    
    // Scatter radius — larger for big guns, smaller for mortars
    private _scatter = if ("55inch" in _ammo || "140mm" in _ammo) then {20} else {8};
    
    // Fire one round at a time per gun, with delay between rounds
    // Uses commandArtilleryFire for all gun types (native ARMA 3 artillery)
    for "_r" from 1 to _totalRounds do {
        {
            private _gun = _x;
            
            if (alive _gun && {!(isNull (gunner _gun))} && {_ammo in (getArtilleryAmmo [_gun])}) then {
                // Apply scatter per round
                private _scatteredPos = [
                    (_pos select 0) + (random _scatter) - (_scatter / 2),
                    (_pos select 1) + (random _scatter) - (_scatter / 2),
                    0
                ];
                
                _gun commandArtilleryFire [_scatteredPos, _ammo, 1];
                
                diag_log format ["[OpsRoom] Artillery fire: %1 round %2/%3 of %4 at %5",
                    typeOf _gun, _r, _totalRounds, _ammo, _scatteredPos];
            };
        } forEach _guns;
        
        // Delay between rounds
        if (_r < _totalRounds) then {
            sleep 5;
        };
    };
    
    diag_log format ["[OpsRoom] Artillery fire mission complete: %1 total rounds from %2 guns",
        _totalRounds, count _guns];
};

// Clean up all remaining targeting state
OpsRoom_ArtilleryTargeting_TargetPos = nil;
OpsRoom_ArtilleryTargeting_GunsInRange = nil;
OpsRoom_ArtilleryTargeting_AmmoType = nil;
OpsRoom_ArtilleryTargeting_GunName = nil;
OpsRoom_ArtilleryTargeting_AmmoName = nil;
OpsRoom_Artillery_RadioOperator = nil;
OpsRoom_Artillery_Available = nil;

diag_log format ["[OpsRoom] Artillery fire mission initiated: %1 rounds from %2 guns at %3",
    _actualRounds, _gunCount, _targetPos];
