/*
    Open Wing Detail
    
    Shows the aircraft in a specific wing.
    
    Parameters:
        _wingId - Wing ID to display
*/
params ["_wingId"];

private _wingData = OpsRoom_AirWings get _wingId;
if (isNil "_wingData") exitWith {
    systemChat "Wing not found";
};

// Store current wing for other functions
OpsRoom_CurrentWingId = _wingId;

// Create dialog
createDialog "OpsRoom_WingDetailDialog";
waitUntil {!isNull findDisplay 11001};

private _display = findDisplay 11001;

// Set title
private _titleCtrl = _display displayCtrl 11110;
private _wingName = _wingData get "name";
private _wingType = _wingData get "wingType";
_titleCtrl ctrlSetText format ["%1 (%2)", _wingName, _wingType];

// Back button
private _backBtn = _display displayCtrl 11111;
_backBtn ctrlAddEventHandler ["ButtonClick", {
    closeDialog 0;
    [] spawn OpsRoom_fnc_openAirOps;
}];

// Status bar
private _status = _wingData get "status";
private _mission = _wingData get "mission";
private _aircraft = _wingData get "aircraft";
private _currentCount = count _aircraft;

private _statusCtrl = _display displayCtrl 11121;
private _missionText = if (_mission != "") then {
    private _missionData = OpsRoom_AirMissionTypes getOrDefault [_mission, createHashMap];
    _missionData getOrDefault ["displayName", _mission]
} else {
    if (_status == "AIRBORNE") then { "Staging" } else { "No mission assigned" }
};

private _missionColor = if (_mission != "") then {"#88CC88"} else {
    if (_status == "AIRBORNE") then {"#CCCC44"} else {"#888888"}
};
private _statusColor = switch (_status) do {
    case "AIRBORNE": { "#88CC88" };
    case "LAUNCHING": { "#CCCC44" };
    case "RTB": { "#CC8844" };
    default { "#AAAAAA" };
};

_statusCtrl ctrlSetStructuredText parseText format [
    "<t align='center'>Status: <t color='%5'>%1</t>  |  Mission: <t color='%6'>%2</t>  |  Aircraft: %3/%4</t>",
    _status, _missionText, count _aircraft, OpsRoom_Settings_MaxWingSize, _statusColor, _missionColor
];

// Populate aircraft grid
[_wingId] call OpsRoom_fnc_populateWingMembers;

// ==============================
// ACTION BUTTONS
// ==============================

// SCHEDULE (IDC 11130 — replaces old ASSIGN button)
private _schedBtn = _display displayCtrl 11130;
_schedBtn setVariable ["wingId", _wingId];

// Show schedule status on button
private _schedData = _wingData getOrDefault ["schedule", createHashMap];
private _schedEnabled = _schedData getOrDefault ["enabled", false];
if (_schedEnabled) then {
    _schedBtn ctrlSetBackgroundColor [0.25, 0.40, 0.20, 1.0];
    _schedBtn ctrlSetText "SCHEDULED";
} else {
    _schedBtn ctrlSetText "SCHEDULE";
};

if (_status == "STANDBY") then {
    _schedBtn ctrlAddEventHandler ["ButtonClick", {
        params ["_ctrl"];
        private _wingId = _ctrl getVariable ["wingId", ""];
        closeDialog 0;
        [_wingId] spawn OpsRoom_fnc_openWingSchedule;
    }];
} else {
    _schedBtn ctrlEnable false;
    _schedBtn ctrlSetTooltip "Wing must be on standby to modify schedule";
};

// SET MISSION — available when STANDBY or AIRBORNE
private _missionBtn = _display displayCtrl 11131;
_missionBtn setVariable ["wingId", _wingId];
if (_status == "STANDBY" || _status == "AIRBORNE") then {
    if (_status == "AIRBORNE") then {
        _missionBtn ctrlSetText "CHANGE MISSION";
        _missionBtn ctrlSetTooltip "Redirect airborne wing to new mission/target";
    };
    _missionBtn ctrlAddEventHandler ["ButtonClick", {
        params ["_ctrl"];
        private _wingId = _ctrl getVariable ["wingId", ""];
        closeDialog 0;
        [_wingId] spawn OpsRoom_fnc_openWingMission;
    }];
} else {
    _missionBtn ctrlEnable false;
    _missionBtn ctrlSetTooltip "Wing must be on standby or airborne";
};

// LAUNCH — only when STANDBY with aircraft
private _launchBtn = _display displayCtrl 11132;
_launchBtn setVariable ["wingId", _wingId];
if (_status == "STANDBY" && {_currentCount > 0}) then {
    // If a mission is set, label says LAUNCH. If no mission, label says LAUNCH TO STAGING
    if (_mission == "") then {
        _launchBtn ctrlSetText "LAUNCH TO STAGING";
        _launchBtn ctrlSetTooltip "Launch aircraft to a staging point. Select position on map.";
        _launchBtn ctrlAddEventHandler ["ButtonClick", {
            params ["_ctrl"];
            private _wingId = _ctrl getVariable ["wingId", ""];
            closeDialog 0;
            
            // Open Ops Map picker to select staging position
            private _wingName = (OpsRoom_AirWings get _wingId) get "name";
            
            [{
                params ["_pos"];
                private _wingId = OpsRoom_StagingLaunch_WingId;
                private _wingData = OpsRoom_AirWings get _wingId;
                if (isNil "_wingData") exitWith {};
                
                // Set target position (no mission — just staging)
                _wingData set ["missionTarget", _pos];
                
                // Create marker at staging point
                private _markerName = format ["air_target_%1", _wingId];
                if (markerType _markerName != "") then { deleteMarker _markerName };
                private _marker = createMarker [_markerName, _pos];
                _marker setMarkerType "mil_objective";
                _marker setMarkerColor "ColorGreen";
                _marker setMarkerText format ["%1: Staging", _wingData get "name"];
                _marker setMarkerSize [0.7, 0.7];
                _wingData set ["loiterMarker", _markerName];
                
                // Launch
                [_wingId] call OpsRoom_fnc_launchWing;
                
            }, format ["STAGING POINT for %1", _wingName], {
                // Cancel — reopen wing detail
                [OpsRoom_StagingLaunch_WingId] spawn OpsRoom_fnc_openWingDetail;
            }] spawn {
                params ["_cb", "_title", "_cancelCb"];
                private _wingId = OpsRoom_CurrentWingId;
                OpsRoom_StagingLaunch_WingId = _wingId;
                sleep 0.2;
                [_cb, _title, _cancelCb] call OpsRoom_fnc_openOpsMapPicker;
            };
        }];
    } else {
        _launchBtn ctrlAddEventHandler ["ButtonClick", {
            params ["_ctrl"];
            private _wingId = _ctrl getVariable ["wingId", ""];
            closeDialog 0;
            [_wingId] call OpsRoom_fnc_launchWing;
        }];
    };
} else {
    _launchBtn ctrlEnable false;
    if (_currentCount == 0) then {
        _launchBtn ctrlSetTooltip "No aircraft assigned";
    };
    if (_status != "STANDBY") then {
        _launchBtn ctrlSetTooltip "Wing is already airborne";
    };
};

// LAND / RTB — only when AIRBORNE
private _landBtn = _display displayCtrl 11133;
_landBtn setVariable ["wingId", _wingId];
if (_status == "AIRBORNE") then {
    _landBtn ctrlAddEventHandler ["ButtonClick", {
        params ["_ctrl"];
        private _wingId = _ctrl getVariable ["wingId", ""];
        closeDialog 0;
        [_wingId] call OpsRoom_fnc_landWing;
    }];
} else {
    _landBtn ctrlEnable false;
};

// ORDER STRIKE is now handled via the SET MISSION / CHANGE MISSION button flow

// ==============================
// Fix #12: FOCUS ON AIRCRAFT (airborne only)
// ==============================
if (_status == "AIRBORNE" || _status == "LAUNCHING" || _status == "RTB") then {
    private _focusBtn = _display ctrlCreate ["RscButton", 11141];
    _focusBtn ctrlSetPosition [
        0.32 * safezoneW + safezoneX,
        0.89 * safezoneH + safezoneY,
        0.14 * safezoneW,
        0.04 * safezoneH
    ];
    _focusBtn ctrlSetText "FOCUS AIRCRAFT";
    _focusBtn ctrlSetBackgroundColor [0.20, 0.30, 0.45, 1.0];
    _focusBtn ctrlSetTooltip "Toggle follow camera on the first airborne aircraft in this wing";
    _focusBtn ctrlCommit 0;
    _focusBtn setVariable ["wingId", _wingId];
    
    _focusBtn ctrlAddEventHandler ["ButtonClick", {
        params ["_ctrl"];
        private _wId = _ctrl getVariable ["wingId", ""];
        private _wData = OpsRoom_AirWings get _wId;
        if (isNil "_wData") exitWith {};
        
        private _so = _wData get "spawnedObjects";
        private _target = objNull;
        { if (_x isKindOf "Air" && {alive _x}) exitWith { _target = _x } } forEach _so;
        
        if (isNull _target) exitWith {
            systemChat "No airborne aircraft found";
        };
        
        // Close dialog and toggle air follow camera
        closeDialog 0;
        
        // Disable ground follow camera if active
        OpsRoom_FollowCameraActive = false;
        
        // Initialize if needed
        if (isNil "OpsRoom_AirFollowCameraActive") then {
            OpsRoom_AirFollowCameraActive = false;
        };
        
        // Toggle air follow camera
        if (OpsRoom_AirFollowCameraActive && {OpsRoom_AirFollowCameraTarget isEqualTo _target}) then {
            // Already following this aircraft — disable
            OpsRoom_AirFollowCameraActive = false;
            OpsRoom_AirFollowCameraTarget = objNull;
            systemChat "Air follow camera: DISABLED";
        } else {
            // Start following
            OpsRoom_AirFollowCameraActive = true;
            OpsRoom_AirFollowCameraTarget = _target;
            [] spawn OpsRoom_fnc_airFollowCameraLoop;
            systemChat format ["Air follow camera: TRACKING %1", typeOf _target];
        };
    }];
};

// ==============================
// Fix #6: RETURN TO HANGAR (grounded aircraft only — NOT airborne)
// ==============================
if (_status == "AIRBORNE" || _status == "LAUNCHING" || _status == "RTB") then {
    private _returnBtn = _display ctrlCreate ["RscButton", 11142];
    _returnBtn ctrlSetPosition [
        0.47 * safezoneW + safezoneX,
        0.89 * safezoneH + safezoneY,
        0.14 * safezoneW,
        0.04 * safezoneH
    ];
    _returnBtn ctrlSetText "RECOVER STUCK";
    _returnBtn ctrlSetBackgroundColor [0.50, 0.30, 0.15, 1.0];
    _returnBtn ctrlSetTooltip "Despawn stationary/stuck aircraft and return to hangar. Only works if aircraft are on the ground and not moving.";
    _returnBtn ctrlCommit 0;
    _returnBtn setVariable ["wingId", _wingId];
    
    _returnBtn ctrlAddEventHandler ["ButtonClick", {
        params ["_ctrl"];
        private _wId = _ctrl getVariable ["wingId", ""];
        private _wData = OpsRoom_AirWings get _wId;
        if (isNil "_wData") exitWith {};
        
        private _wName = _wData get "name";
        private _so = _wData get "spawnedObjects";
        private _acIds = _wData get "aircraft";
        
        // Check ALL aircraft are stationary (speed < 5 and on/near ground)
        private _allStationary = true;
        {
            if (_x isKindOf "Air" && {alive _x}) then {
                if (speed _x > 5 || {(getPosATL _x) select 2 > 10}) then {
                    _allStationary = false;
                };
            };
        } forEach _so;
        
        if (!_allStationary) exitWith {
            systemChat "Cannot recover — aircraft are still flying. Use RTB to land them first.";
        };
        
        // Save state from live aircraft before despawning
        {
            private _hId = _x;
            private _entry = OpsRoom_Hangar get _hId;
            if (!isNil "_entry") then {
                // Find matching vehicle
                private _veh = objNull;
                { if (_x isKindOf "Air" && {(_x getVariable ["OpsRoom_HangarId", ""]) == _hId}) exitWith { _veh = _x } } forEach _so;
                
                if (!isNull _veh && alive _veh) then {
                    _entry set ["fuel", fuel _veh];
                    _entry set ["damage", damage _veh];
                    _entry set ["status", "HANGARED"];
                } else {
                    // Already destroyed — mark it
                    if ((_entry get "status") != "DESTROYED") then {
                        _entry set ["status", "HANGARED"];
                    };
                };
            };
        } forEach _acIds;
        
        // Return assigned pilots to ready point before deleting
        {
            private _entry2 = OpsRoom_Hangar get _x;
            if (!isNil "_entry2") then {
                private _ap = _entry2 getOrDefault ["assignedPilot", objNull];
                if (!isNull _ap && {alive _ap}) then {
                    if (vehicle _ap != _ap) then { moveOut _ap };
                    private _rp = if (markerType "OpsRoom_pilot_ready" != "") then { getMarkerPos "OpsRoom_pilot_ready" } else { if (markerType "OpsRoom_hangar" != "") then { getMarkerPos "OpsRoom_hangar" } else { getPos _ap } };
                    _ap setPos _rp;
                    private _pg = createGroup [independent, true]; [_ap] joinSilent _pg;
                    _so = _so - [_ap];
                };
            };
        } forEach _acIds;
        
        // Delete all remaining spawned objects (aircraft + AI crew)
        { if (!isNull _x) then { deleteVehicle _x } } forEach _so;
        
        // Clean up markers
        private _marker = _wData getOrDefault ["loiterMarker", ""];
        if (_marker != "" && {markerType _marker != ""}) then { deleteMarker _marker };
        private _fallback = format ["air_target_%1", _wId];
        if (markerType _fallback != "") then { deleteMarker _fallback };
        
        // Reset wing
        _wData set ["status", "STANDBY"];
        _wData set ["spawnedObjects", []];
        _wData set ["mission", ""];
        _wData set ["missionTarget", []];
        _wData set ["loiterMarker", ""];
        _wData set ["autoRTB_triggered", false];
        
        // Remove destroyed aircraft from wing
        private _surviving = [];
        {
            private _entry = OpsRoom_Hangar get _x;
            if (!isNil "_entry" && {(_entry get "status") != "DESTROYED"}) then {
                _surviving pushBack _x;
            };
        } forEach _acIds;
        _wData set ["aircraft", _surviving];
        
        ["ROUTINE", format ["%1 recalled", _wName],
            format ["%1 force-returned to hangar. %2 aircraft recovered.", _wName, count _surviving]
        ] call OpsRoom_fnc_dispatch;
        
        systemChat format ["%1 returned to hangar", _wName];
        closeDialog 0;
        [_wId] spawn OpsRoom_fnc_openWingDetail;
    }];
};

// ==============================
// INFO PANEL — mission + schedule summary
// ==============================
private _infoCtrl = _display displayCtrl 11136;
if (!isNull _infoCtrl) then {
    private _infoLines = [];
    
    // Current mission info
    if (_mission != "") then {
        private _missionData2 = OpsRoom_AirMissionTypes getOrDefault [_mission, createHashMap];
        private _mName2 = _missionData2 getOrDefault ["displayName", _mission];
        private _mDesc = _missionData2 getOrDefault ["description", ""];
        _infoLines pushBack format ["<t font='PuristaBold' color='#C8C0A8'>Current Mission:</t> <t color='#88CC88'>%1</t>", _mName2];
        if (_mDesc != "") then {
            _infoLines pushBack format ["<t size='0.9' color='#999988'>%1</t>", _mDesc];
        };
        
        // Target grid ref
        private _tgt = _wingData getOrDefault ["missionTarget", []];
        if (count _tgt > 0) then {
            _infoLines pushBack format ["<t color='#AAAAAA'>Target: Grid %1</t>", mapGridPosition _tgt];
        };
    } else {
        _infoLines pushBack "<t color='#888888'>No mission assigned. Use SET MISSION to assign one.</t>";
    };
    
    _infoLines pushBack "";  // Spacer
    
    // Schedule info
    private _schedInfo = _wingData getOrDefault ["schedule", createHashMap];
    if (count _schedInfo > 0 && {_schedInfo getOrDefault ["enabled", false]}) then {
        private _sMission = _schedInfo get "missionId";
        private _sMData = OpsRoom_AirMissionTypes getOrDefault [_sMission, createHashMap];
        private _sMName = _sMData getOrDefault ["displayName", _sMission];
        private _sInterval = _schedInfo getOrDefault ["interval", 0];
        private _sNextLaunch = _schedInfo getOrDefault ["nextLaunchTime", 0];
        private _sLaunchHour = _schedInfo getOrDefault ["launchAtHour", -1];
        
        private _repeatStr = if (_sInterval == 0) then { "One-shot" } else { format ["Every %1 min (in-game)", round (_sInterval / 60)] };
        
        // Time until next launch
        private _timeLeft = "";
        if (_sLaunchHour >= 0) then {
            private _hoursUntil = _sLaunchHour - daytime;
            if (_hoursUntil < 0) then { _hoursUntil = _hoursUntil + 24 };
            private _h = floor _hoursUntil;
            private _m = round ((_hoursUntil - _h) * 60);
            _timeLeft = format ["%1h %2m (in-game) — launches at %3:00", _h, _m, str (round _sLaunchHour)];
        } else {
            if (_sNextLaunch > 0) then {
                // Both _sNextLaunch and daytime are in hours (0-24)
                private _hoursLeft = _sNextLaunch - daytime;
                if (_hoursLeft < -12) then { _hoursLeft = _hoursLeft + 24 };
                if (_hoursLeft < 0) then { _hoursLeft = 0 };
                private _minsLeft = round (_hoursLeft * 60);
                private _h = floor _hoursLeft;
                private _m = _minsLeft - (_h * 60);
                if (_h > 0) then {
                    _timeLeft = format ["%1h %2m (in-game)", _h, _m];
                } else {
                    _timeLeft = format ["%1 min (in-game)", _minsLeft];
                };
            };
        };
        
        _infoLines pushBack format ["<t font='PuristaBold' color='#C8C0A8'>Schedule:</t> <t color='#CCCC88'>%1</t> — <t color='#AAAAAA'>%2</t>", _sMName, _repeatStr];
        if (_timeLeft != "") then {
            _infoLines pushBack format ["<t color='#88CC88'>Next launch: %1</t>", _timeLeft];
        };
    } else {
        _infoLines pushBack "<t color='#666666'>No schedule set. Use SCHEDULE to automate sorties.</t>";
    };
    
    // Aircraft count + assign hint
    if (_status == "STANDBY" && {_currentCount < OpsRoom_Settings_MaxWingSize}) then {
        _infoLines pushBack "";
        _infoLines pushBack format ["<t color='#666666'>Click the + card above to assign aircraft (%1/%2)</t>", _currentCount, OpsRoom_Settings_MaxWingSize];
    };
    
    _infoCtrl ctrlSetStructuredText parseText (_infoLines joinString "<br/>");
};

diag_log format ["[OpsRoom] Wing detail opened for %1", _wingName];
