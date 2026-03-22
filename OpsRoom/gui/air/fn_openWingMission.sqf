/*
    Open Wing Mission Assignment
    
    Shows available missions for the wing type and lets the player
    select one, then opens the Ops Map to pick a target position.
    
    Works for both STANDBY and AIRBORNE wings.
    - STANDBY: sets mission ready for launch
    - AIRBORNE: reassigns waypoints in-flight
    
    Parameters:
        _wingId - Wing ID to assign mission to
*/
params ["_wingId"];

private _wingData = OpsRoom_AirWings get _wingId;
if (isNil "_wingData") exitWith {
    systemChat "Wing not found";
};

private _wingName = _wingData get "name";
private _wingType = _wingData get "wingType";
private _status = _wingData get "status";

// Can assign missions when STANDBY or AIRBORNE
if (_status != "STANDBY" && _status != "AIRBORNE") exitWith {
    systemChat format ["%1 must be on standby or airborne to assign a mission", _wingName];
};

// Get available missions for this wing type
private _wingTypeData = OpsRoom_WingTypes get _wingType;
if (isNil "_wingTypeData") exitWith {
    systemChat "Invalid wing type";
};
private _availableMissions = _wingTypeData get "missions";

// Store selection globally
OpsRoom_MissionAssign_WingId = _wingId;
OpsRoom_MissionAssign_SelectedMission = "";
OpsRoom_MissionAssign_IsAirborne = (_status == "AIRBORNE");

// Create dialog
createDialog "OpsRoom_WingMissionDialog";
waitUntil {!isNull findDisplay 11002};

private _display = findDisplay 11002;

// Set title
private _titleCtrl = _display displayCtrl 11400;
if (_status == "AIRBORNE") then {
    _titleCtrl ctrlSetText format ["REASSIGN MISSION - %1 (AIRBORNE)", _wingName];
} else {
    _titleCtrl ctrlSetText format ["ASSIGN MISSION - %1", _wingName];
};

// Create mission buttons dynamically
private _btnIndex = 0;
{
    private _missionId = _x;
    private _missionData = OpsRoom_AirMissionTypes getOrDefault [_missionId, createHashMap];
    
    if (count _missionData > 0) then {
        private _missionName = _missionData get "displayName";
        private _missionDesc = _missionData get "description";
        
        private _btn = _display ctrlCreate ["RscButton", 11450 + _btnIndex];
        _btn ctrlSetPosition [
            0.32 * safezoneW + safezoneX,
            (0.26 + (_btnIndex * 0.045)) * safezoneH + safezoneY,
            0.36 * safezoneW,
            0.038 * safezoneH
        ];
        _btn ctrlSetText _missionName;
        _btn ctrlSetBackgroundColor [0.26, 0.30, 0.21, 1.0];
        _btn setVariable ["missionId", _missionId];
        _btn setVariable ["missionDesc", _missionDesc];
        _btn ctrlCommit 0;
        
        _btn ctrlAddEventHandler ["ButtonClick", {
            params ["_ctrl"];
            private _missionId = _ctrl getVariable ["missionId", ""];
            private _missionDesc = _ctrl getVariable ["missionDesc", ""];
            
            OpsRoom_MissionAssign_SelectedMission = _missionId;
            
            // Highlight selected, unhighlight others
            private _display = ctrlParent _ctrl;
            for "_i" from 0 to 9 do {
                private _otherBtn = _display displayCtrl (11450 + _i);
                if (!isNull _otherBtn) then {
                    _otherBtn ctrlSetBackgroundColor [0.26, 0.30, 0.21, 1.0];
                };
            };
            _ctrl ctrlSetBackgroundColor [0.30, 0.45, 0.25, 1.0];
            
            // Update description
            private _descCtrl = _display displayCtrl 11411;
            _descCtrl ctrlSetStructuredText parseText format [
                "<t size='0.9'>%1</t>", _missionDesc
            ];
        }];
        
        _btnIndex = _btnIndex + 1;
    };
} forEach _availableMissions;

// Confirm button — closes dialog and opens Ops Map picker
private _confirmBtn = _display displayCtrl 11420;
_confirmBtn ctrlAddEventHandler ["ButtonClick", {
    if (OpsRoom_MissionAssign_SelectedMission == "") exitWith {
        systemChat "Select a mission type first";
    };
    
    closeDialog 0;
    
    [] spawn {
        sleep 0.2;
        
        private _wingId = OpsRoom_MissionAssign_WingId;
        private _wingData = OpsRoom_AirWings get _wingId;
        if (isNil "_wingData") exitWith {};
        
        private _wingName = _wingData get "name";
        private _missionId = OpsRoom_MissionAssign_SelectedMission;
        private _missionData = OpsRoom_AirMissionTypes get _missionId;
        private _missionName = _missionData get "displayName";
        private _isAirborne = OpsRoom_MissionAssign_IsAirborne;
        
        // If mission is a STRIKE type, use the air strike map picker (target + approach heading)
        private _missionData2 = OpsRoom_AirMissionTypes get _missionId;
        private _isStrike = _missionData2 getOrDefault ["isStrike", false];
        if (_isStrike) exitWith {
            private _attackType = _missionData2 get "attackType";
            OpsRoom_WingStrike_WingId = _wingId;
            OpsRoom_WingStrike_AttackType = _attackType;
            
            [{
                params ["_tgtPos", "_fahPos"];
                private _attackType = OpsRoom_WingStrike_AttackType;
                private _wingId = OpsRoom_WingStrike_WingId;
                // Pass wingId so executeAirStrike only picks aircraft from THIS wing
                [objNull, _tgtPos, _attackType, _fahPos, _wingId] call OpsRoom_fnc_executeAirStrike;
                [_wingId] spawn OpsRoom_fnc_openWingDetail;
            }, format ["ORDER %1", _missionData2 get "displayName"], {
                [OpsRoom_WingStrike_WingId] spawn OpsRoom_fnc_openWingDetail;
            }] call OpsRoom_fnc_openAirStrikeMapPicker;
        };
        
        // If mission is "scramble", target is the airfield — no map click needed
        if (_missionId == "scramble") exitWith {
            private _runwayPos = getMarkerPos "OpsRoom_runway";
            _wingData set ["mission", _missionId];
            _wingData set ["missionTarget", _runwayPos];
            
            if (_isAirborne) then {
                [_wingId] call OpsRoom_fnc_reassignAirborneMission;
            } else {
                systemChat format ["%1 assigned to %2", _wingName, _missionName];
                ["ROUTINE", format ["%1: %2", _wingName, _missionName],
                    format ["%1 assigned to %2. Ready for launch.", _wingName, _missionName]
                ] call OpsRoom_fnc_dispatch;
            };
            
            // Reopen wing detail
            [_wingId] spawn OpsRoom_fnc_openWingDetail;
        };
        
        // Open Ops Map as a position picker
        [
            // Callback: position selected
            {
                params ["_worldPos"];
                
                private _wingId = OpsRoom_MissionAssign_WingId;
                private _wingData = OpsRoom_AirWings get _wingId;
                if (isNil "_wingData") exitWith {};
                
                private _missionId = OpsRoom_MissionAssign_SelectedMission;
                private _isAirborne = OpsRoom_MissionAssign_IsAirborne;
                private _wingName = _wingData get "name";
                private _missionData = OpsRoom_AirMissionTypes get _missionId;
                private _missionName = _missionData get "displayName";
                
                // Set mission and target on wing
                _wingData set ["mission", _missionId];
                _wingData set ["missionTarget", _worldPos];
                
                if (_isAirborne) then {
                    // Airborne — reassign waypoints in-flight
                    [_wingId] call OpsRoom_fnc_reassignAirborneMission;
                } else {
                    // Standby — just set it, create marker, ready for launch
                    // Clean old marker
                    private _oldMarker = _wingData getOrDefault ["loiterMarker", ""];
                    if (_oldMarker != "" && {markerType _oldMarker != ""}) then {
                        deleteMarker _oldMarker;
                    };
                    
                    private _markerName = format ["air_target_%1", _wingId];
                    if (markerType _markerName != "") then { deleteMarker _markerName };
                    private _marker = createMarker [_markerName, _worldPos];
                    _marker setMarkerType "mil_objective";
                    _marker setMarkerColor "ColorGreen";
                    _marker setMarkerText format ["%1: %2", _wingName, _missionName];
                    _marker setMarkerSize [0.7, 0.7];
                    _wingData set ["loiterMarker", _markerName];
                    
                    systemChat format ["%1 assigned to %2. Target set.", _wingName, _missionName];
                    
                    ["ROUTINE", format ["%1: %2 assigned", _wingName, _missionName],
                        format ["%1 assigned to %2. Target position marked. Ready for launch.", _wingName, _missionName]
                    ] call OpsRoom_fnc_dispatch;
                };
                
                // Reopen wing detail
                [_wingId] spawn OpsRoom_fnc_openWingDetail;
            },
            // Title for the map picker
            format ["%1 TARGET for %2", _missionName, _wingName],
            // Cancel callback
            {
                [OpsRoom_MissionAssign_WingId] spawn OpsRoom_fnc_openWingDetail;
            }
        ] call OpsRoom_fnc_openOpsMapPicker;
    };
}];

// Cancel button
private _cancelBtn = _display displayCtrl 11421;
_cancelBtn setVariable ["wingId", _wingId];
_cancelBtn ctrlAddEventHandler ["ButtonClick", {
    params ["_ctrl"];
    private _wingId = _ctrl getVariable ["wingId", ""];
    closeDialog 0;
    [_wingId] spawn OpsRoom_fnc_openWingDetail;
}];

diag_log format ["[OpsRoom] Mission assignment opened for %1 (status: %2)", _wingName, _status];
