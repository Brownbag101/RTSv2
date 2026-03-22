/*
    Open Wing Schedule
    
    Configure automated mission schedule for a wing.
    Three timing modes:
        1. Delay: "launch in X minutes (in-game time)"
        2. Repeat: "launch every X minutes (in-game time)"
        3. Fixed hour: "launch at HH:00 daily"
    
    Parameters:
        _wingId - Wing ID to schedule
*/
params ["_wingId"];

private _wingData = OpsRoom_AirWings get _wingId;
if (isNil "_wingData") exitWith { systemChat "Wing not found" };

private _wingName = _wingData get "name";
private _wingType = _wingData get "wingType";
private _status = _wingData get "status";

if (_status != "STANDBY") exitWith {
    systemChat format ["%1 must be on standby to set a schedule", _wingName];
};

private _existingSchedule = _wingData getOrDefault ["schedule", createHashMap];
private _existingEnabled = _existingSchedule getOrDefault ["enabled", false];

// Selection state
OpsRoom_Schedule_WingId = _wingId;
OpsRoom_Schedule_MissionId = _existingSchedule getOrDefault ["missionId", ""];
OpsRoom_Schedule_DelayMins = 5;
OpsRoom_Schedule_IntervalMins = 0;
OpsRoom_Schedule_FixedHour = -1;  // -1 = not using fixed hour
OpsRoom_Schedule_Mode = "delay";  // "delay" or "fixed"

// Get available missions — include strike types that work with auto-targeting
private _wingTypeData = OpsRoom_WingTypes get _wingType;
private _allMissions = _wingTypeData get "missions";

// Remove non-functional strike_bombs from ground attack (saturation bombing works via bomber wing)
// Keep: strike_guns, strike_rockets, strike_strafe, strike_bombs (for bombers)
private _availableMissions = _allMissions select {
    // Allow everything — scheduler handles strike FAH automatically
    true
};

// Build on Zeus display
private _zeusDisplay = findDisplay 312;
if (isNull _zeusDisplay) exitWith { systemChat "Zeus display not found" };

private _controls = [];

// Overlay
private _overlay = _zeusDisplay ctrlCreate ["RscText", -1];
_overlay ctrlSetPosition [safezoneX, safezoneY, safezoneW, safezoneH];
_overlay ctrlSetBackgroundColor [0, 0, 0, 0.6];
_overlay ctrlCommit 0;
_controls pushBack _overlay;

// Panel
private _panelX = 0.25 * safezoneW + safezoneX;
private _panelY = 0.10 * safezoneH + safezoneY;
private _panelW = 0.50 * safezoneW;
private _panelH = 0.80 * safezoneH;

private _bg = _zeusDisplay ctrlCreate ["RscText", -1];
_bg ctrlSetPosition [_panelX, _panelY, _panelW, _panelH];
_bg ctrlSetBackgroundColor [0.18, 0.22, 0.15, 0.97];
_bg ctrlCommit 0;
_controls pushBack _bg;

// Header
private _header = _zeusDisplay ctrlCreate ["RscText", -1];
_header ctrlSetPosition [_panelX, _panelY, _panelW, 0.04 * safezoneH];
_header ctrlSetBackgroundColor [0.20, 0.25, 0.18, 1.0];
_header ctrlCommit 0;
_controls pushBack _header;

private _headerText = _zeusDisplay ctrlCreate ["RscStructuredText", -1];
_headerText ctrlSetPosition [_panelX + 0.01 * safezoneW, _panelY + 0.005 * safezoneH, _panelW - 0.07 * safezoneW, 0.035 * safezoneH];
_headerText ctrlSetStructuredText parseText format [
    "<t font='PuristaBold' size='1.1'>MISSION SCHEDULER — %1</t>   <t size='0.9' color='#AAAAAA'>Current time: %2:%3</t>",
    _wingName,
    if (floor daytime < 10) then { format ["0%1", floor daytime] } else { str (floor daytime) },
    if (floor ((daytime - floor daytime) * 60) < 10) then { format ["0%1", floor ((daytime - floor daytime) * 60)] } else { str (floor ((daytime - floor daytime) * 60)) }
];
_headerText ctrlCommit 0;
_controls pushBack _headerText;

private _contentY = _panelY + 0.055 * safezoneH;
private _contentX = _panelX + 0.015 * safezoneW;
private _contentW = _panelW - 0.03 * safezoneW;
private _halfW = _contentW * 0.48;

// Active schedule status
if (_existingEnabled) then {
    private _existMission = _existingSchedule get "missionId";
    private _existMData = OpsRoom_AirMissionTypes getOrDefault [_existMission, createHashMap];
    private _existName = _existMData getOrDefault ["displayName", _existMission];
    private _existInterval = _existingSchedule getOrDefault ["interval", 0];
    private _existHour = _existingSchedule getOrDefault ["launchAtHour", -1];
    
    private _schedStr = if (_existHour >= 0) then {
        format ["Daily at %1:00", if (_existHour < 10) then { format ["0%1", round _existHour] } else { str (round _existHour) }]
    } else {
        if (_existInterval == 0) then { "One-shot" } else { format ["Every %1 min", round (_existInterval / 60)] }
    };
    
    private _statusLine = _zeusDisplay ctrlCreate ["RscStructuredText", -1];
    _statusLine ctrlSetPosition [_contentX, _contentY, _contentW, 0.025 * safezoneH];
    _statusLine ctrlSetStructuredText parseText format [
        "<t color='#88CC88'>ACTIVE: %1 — %2</t>", _existName, _schedStr
    ];
    _statusLine ctrlCommit 0;
    _controls pushBack _statusLine;
    _contentY = _contentY + 0.03 * safezoneH;
};

// ── SELECT MISSION ──
private _mLabel = _zeusDisplay ctrlCreate ["RscStructuredText", -1];
_mLabel ctrlSetPosition [_contentX, _contentY, _contentW, 0.022 * safezoneH];
_mLabel ctrlSetStructuredText parseText "<t font='PuristaBold' size='0.95' color='#C8C0A8'>── SELECT MISSION ──</t>";
_mLabel ctrlCommit 0;
_controls pushBack _mLabel;
_contentY = _contentY + 0.025 * safezoneH;

{
    private _missionId = _x;
    private _missionData = OpsRoom_AirMissionTypes getOrDefault [_missionId, createHashMap];
    if (count _missionData == 0) then { continue };
    
    private _btn = _zeusDisplay ctrlCreate ["RscButton", -1];
    _btn ctrlSetPosition [_contentX, _contentY, _contentW, 0.03 * safezoneH];
    _btn ctrlSetText (_missionData get "displayName");
    _btn ctrlSetFont "PuristaLight";
    _btn ctrlSetBackgroundColor (if (_missionId == OpsRoom_Schedule_MissionId) then { [0.30, 0.45, 0.25, 1.0] } else { [0.26, 0.30, 0.21, 1.0] });
    _btn setVariable ["missionId", _missionId];
    _btn ctrlCommit 0;
    _controls pushBack _btn;
    
    _btn ctrlAddEventHandler ["ButtonClick", {
        params ["_ctrl"];
        OpsRoom_Schedule_MissionId = _ctrl getVariable ["missionId", ""];
        { 
            private _mid = _x getVariable ["missionId", ""];
            if (_mid != "") then {
                _x ctrlSetBackgroundColor (if (_mid == OpsRoom_Schedule_MissionId) then { [0.30, 0.45, 0.25, 1.0] } else { [0.26, 0.30, 0.21, 1.0] });
            };
        } forEach OpsRoom_Schedule_Controls;
    }];
    
    _contentY = _contentY + 0.033 * safezoneH;
} forEach _availableMissions;

_contentY = _contentY + 0.01 * safezoneH;

// ── TIMING MODE ──
private _tLabel = _zeusDisplay ctrlCreate ["RscStructuredText", -1];
_tLabel ctrlSetPosition [_contentX, _contentY, _contentW, 0.022 * safezoneH];
_tLabel ctrlSetStructuredText parseText "<t font='PuristaBold' size='0.95' color='#C8C0A8'>── TIMING (in-game time) ──</t>";
_tLabel ctrlCommit 0;
_controls pushBack _tLabel;
_contentY = _contentY + 0.028 * safezoneH;

// Mode toggle: DELAY vs FIXED HOUR
private _delayModeBtn = _zeusDisplay ctrlCreate ["RscButton", 19810];
_delayModeBtn ctrlSetPosition [_contentX, _contentY, _halfW, 0.03 * safezoneH];
_delayModeBtn ctrlSetText "DELAY / INTERVAL";
_delayModeBtn ctrlSetFont "PuristaBold";
_delayModeBtn ctrlSetBackgroundColor [0.30, 0.45, 0.25, 1.0];
_delayModeBtn ctrlCommit 0;
_controls pushBack _delayModeBtn;

private _fixedModeBtn = _zeusDisplay ctrlCreate ["RscButton", 19811];
_fixedModeBtn ctrlSetPosition [_contentX + _halfW + 0.01 * safezoneW, _contentY, _halfW, 0.03 * safezoneH];
_fixedModeBtn ctrlSetText "FIXED HOUR (DAILY)";
_fixedModeBtn ctrlSetFont "PuristaBold";
_fixedModeBtn ctrlSetBackgroundColor [0.26, 0.30, 0.21, 1.0];
_fixedModeBtn ctrlCommit 0;
_controls pushBack _fixedModeBtn;

_delayModeBtn ctrlAddEventHandler ["ButtonClick", {
    OpsRoom_Schedule_Mode = "delay";
    OpsRoom_Schedule_FixedHour = -1;
    ((ctrlParent (_this select 0)) displayCtrl 19810) ctrlSetBackgroundColor [0.30, 0.45, 0.25, 1.0];
    ((ctrlParent (_this select 0)) displayCtrl 19811) ctrlSetBackgroundColor [0.26, 0.30, 0.21, 1.0];
}];
_fixedModeBtn ctrlAddEventHandler ["ButtonClick", {
    OpsRoom_Schedule_Mode = "fixed";
    OpsRoom_Schedule_FixedHour = 6;  // Default 0600
    ((ctrlParent (_this select 0)) displayCtrl 19810) ctrlSetBackgroundColor [0.26, 0.30, 0.21, 1.0];
    ((ctrlParent (_this select 0)) displayCtrl 19811) ctrlSetBackgroundColor [0.30, 0.45, 0.25, 1.0];
    // Update hour display
    private _hDisp = (ctrlParent (_this select 0)) displayCtrl 19803;
    if (!isNull _hDisp) then {
        private _hStr = if (OpsRoom_Schedule_FixedHour < 10) then { format ["0%1", OpsRoom_Schedule_FixedHour] } else { str OpsRoom_Schedule_FixedHour };
        _hDisp ctrlSetStructuredText parseText format ["<t align='center' color='#CCCC88'>%1:00</t>", _hStr];
    };
}];

_contentY = _contentY + 0.038 * safezoneH;

// Row 1: First launch delay
private _dlLabel = _zeusDisplay ctrlCreate ["RscStructuredText", -1];
_dlLabel ctrlSetPosition [_contentX, _contentY, 0.12 * safezoneW, 0.022 * safezoneH];
_dlLabel ctrlSetStructuredText parseText "<t size='0.9'>First launch in:</t>";
_dlLabel ctrlCommit 0;
_controls pushBack _dlLabel;

private _dlDisplay = _zeusDisplay ctrlCreate ["RscStructuredText", 19801];
_dlDisplay ctrlSetPosition [_contentX + 0.12 * safezoneW, _contentY, 0.08 * safezoneW, 0.022 * safezoneH];
_dlDisplay ctrlSetStructuredText parseText "<t align='center' color='#CCCC88'>5 min</t>";
_dlDisplay ctrlCommit 0;
_controls pushBack _dlDisplay;

{
    _x params ["_label", "_value", "_idx"];
    private _b = _zeusDisplay ctrlCreate ["RscButton", -1];
    _b ctrlSetPosition [_contentX + (0.21 + _idx * 0.035) * safezoneW, _contentY, 0.03 * safezoneW, 0.022 * safezoneH];
    _b ctrlSetText _label;
    _b ctrlSetFont "PuristaBold";
    _b ctrlSetBackgroundColor [0.26, 0.30, 0.21, 1.0];
    _b setVariable ["v", _value];
    _b ctrlCommit 0;
    _controls pushBack _b;
    _b ctrlAddEventHandler ["ButtonClick", {
        OpsRoom_Schedule_DelayMins = (OpsRoom_Schedule_DelayMins + ((_this select 0) getVariable "v")) max 1 min 480;
        private _d = (ctrlParent (_this select 0)) displayCtrl 19801;
        _d ctrlSetStructuredText parseText format ["<t align='center' color='#CCCC88'>%1 min</t>", OpsRoom_Schedule_DelayMins];
    }];
} forEach [["-10", -10, 0], ["-1", -1, 1], ["+1", 1, 2], ["+10", 10, 3]];

_contentY = _contentY + 0.028 * safezoneH;

// Row 2: Repeat interval
private _rpLabel = _zeusDisplay ctrlCreate ["RscStructuredText", -1];
_rpLabel ctrlSetPosition [_contentX, _contentY, 0.12 * safezoneW, 0.022 * safezoneH];
_rpLabel ctrlSetStructuredText parseText "<t size='0.9'>Repeat every:</t>";
_rpLabel ctrlCommit 0;
_controls pushBack _rpLabel;

private _rpDisplay = _zeusDisplay ctrlCreate ["RscStructuredText", 19802];
_rpDisplay ctrlSetPosition [_contentX + 0.12 * safezoneW, _contentY, 0.08 * safezoneW, 0.022 * safezoneH];
_rpDisplay ctrlSetStructuredText parseText "<t align='center' color='#CCCC88'>ONE-SHOT</t>";
_rpDisplay ctrlCommit 0;
_controls pushBack _rpDisplay;

{
    _x params ["_label", "_value", "_idx"];
    private _b = _zeusDisplay ctrlCreate ["RscButton", -1];
    _b ctrlSetPosition [_contentX + (0.21 + _idx * 0.035) * safezoneW, _contentY, 0.03 * safezoneW, 0.022 * safezoneH];
    _b ctrlSetText _label;
    _b ctrlSetFont "PuristaBold";
    _b ctrlSetBackgroundColor [0.26, 0.30, 0.21, 1.0];
    _b setVariable ["v", _value];
    _b ctrlCommit 0;
    _controls pushBack _b;
    _b ctrlAddEventHandler ["ButtonClick", {
        OpsRoom_Schedule_IntervalMins = (OpsRoom_Schedule_IntervalMins + ((_this select 0) getVariable "v")) max 0 min 720;
        private _d = (ctrlParent (_this select 0)) displayCtrl 19802;
        private _s = if (OpsRoom_Schedule_IntervalMins == 0) then { "ONE-SHOT" } else { format ["%1 min", OpsRoom_Schedule_IntervalMins] };
        _d ctrlSetStructuredText parseText format ["<t align='center' color='#CCCC88'>%1</t>", _s];
    }];
} forEach [["-30", -30, 0], ["-5", -5, 1], ["+5", 5, 2], ["+30", 30, 3]];

_contentY = _contentY + 0.028 * safezoneH;

// Row 3: Fixed hour picker
private _fhLabel = _zeusDisplay ctrlCreate ["RscStructuredText", -1];
_fhLabel ctrlSetPosition [_contentX, _contentY, 0.12 * safezoneW, 0.022 * safezoneH];
_fhLabel ctrlSetStructuredText parseText "<t size='0.9'>Launch at hour:</t>";
_fhLabel ctrlCommit 0;
_controls pushBack _fhLabel;

private _fhDisplay = _zeusDisplay ctrlCreate ["RscStructuredText", 19803];
_fhDisplay ctrlSetPosition [_contentX + 0.12 * safezoneW, _contentY, 0.08 * safezoneW, 0.022 * safezoneH];
_fhDisplay ctrlSetStructuredText parseText "<t align='center' color='#666666'>N/A</t>";
_fhDisplay ctrlCommit 0;
_controls pushBack _fhDisplay;

{
    _x params ["_label", "_value", "_idx"];
    private _b = _zeusDisplay ctrlCreate ["RscButton", -1];
    _b ctrlSetPosition [_contentX + (0.21 + _idx * 0.035) * safezoneW, _contentY, 0.03 * safezoneW, 0.022 * safezoneH];
    _b ctrlSetText _label;
    _b ctrlSetFont "PuristaBold";
    _b ctrlSetBackgroundColor [0.26, 0.30, 0.21, 1.0];
    _b setVariable ["v", _value];
    _b ctrlCommit 0;
    _controls pushBack _b;
    _b ctrlAddEventHandler ["ButtonClick", {
        if (OpsRoom_Schedule_Mode != "fixed") exitWith { systemChat "Select FIXED HOUR mode first" };
        OpsRoom_Schedule_FixedHour = ((OpsRoom_Schedule_FixedHour + ((_this select 0) getVariable "v")) max 0) min 23;
        private _d = (ctrlParent (_this select 0)) displayCtrl 19803;
        private _hStr2 = if (OpsRoom_Schedule_FixedHour < 10) then { format ["0%1", OpsRoom_Schedule_FixedHour] } else { str OpsRoom_Schedule_FixedHour };
        _d ctrlSetStructuredText parseText format ["<t align='center' color='#CCCC88'>%1:00</t>", _hStr2];
    }];
} forEach [["-6", -6, 0], ["-1", -1, 1], ["+1", 1, 2], ["+6", 6, 3]];

_contentY = _contentY + 0.04 * safezoneH;

// ── ACTIONS ──
// SET SCHEDULE
private _confirmBtn = _zeusDisplay ctrlCreate ["RscButton", -1];
_confirmBtn ctrlSetPosition [_contentX, _contentY, 0.22 * safezoneW, 0.035 * safezoneH];
_confirmBtn ctrlSetText "SET SCHEDULE";
_confirmBtn ctrlSetFont "PuristaBold";
_confirmBtn ctrlSetBackgroundColor [0.25, 0.40, 0.20, 1.0];
_confirmBtn ctrlCommit 0;
_controls pushBack _confirmBtn;

_confirmBtn ctrlAddEventHandler ["ButtonClick", {
    if (OpsRoom_Schedule_MissionId == "") exitWith { systemChat "Select a mission type first" };
    
    private _wingId = OpsRoom_Schedule_WingId;
    private _missionId = OpsRoom_Schedule_MissionId;
    private _mode = OpsRoom_Schedule_Mode;
    private _delayMins = OpsRoom_Schedule_DelayMins;
    private _intervalMins = OpsRoom_Schedule_IntervalMins;
    private _fixedHour = OpsRoom_Schedule_FixedHour;
    
    { ctrlDelete _x } forEach OpsRoom_Schedule_Controls;
    
    // Scramble doesn't need a map target
    if (_missionId == "scramble") then {
        private _wingData = OpsRoom_AirWings get _wingId;
        private _wingName = _wingData get "name";
        
        private _schedule = createHashMapFromArray [
            ["enabled", true],
            ["missionId", _missionId],
            ["target", getMarkerPos "OpsRoom_runway"],
            ["interval", _intervalMins * 60],
            ["fahPos", []]
        ];
        
        if (_mode == "fixed") then {
            _schedule set ["launchAtHour", _fixedHour];
            _schedule set ["nextLaunchTime", -1];
        } else {
            _schedule set ["launchAtHour", -1];
            private _nextHour = daytime + (_delayMins / 60);
            if (_nextHour >= 24) then { _nextHour = _nextHour - 24 };
            _schedule set ["nextLaunchTime", _nextHour];
        };
        
        _wingData set ["schedule", _schedule];
        
        private _mData = OpsRoom_AirMissionTypes get _missionId;
        private _mName = _mData get "displayName";
        private _fhStr = if (_fixedHour < 10) then { format ["0%1", _fixedHour] } else { str _fixedHour };
        private _timeStr = if (_mode == "fixed") then { format ["daily at %1:00", _fhStr] } else { format ["in %1 min", _delayMins] };
        systemChat format ["%1: %2 scheduled — %3", _wingName, _mName, _timeStr];
        ["PRIORITY", format ["SCHEDULE: %1", _wingName], format ["%1 scheduled for %2. %3.", _wingName, _mName, _timeStr]] call OpsRoom_fnc_dispatch;
        [_wingId] spawn OpsRoom_fnc_openWingDetail;
    } else {
        // Open map picker
        [] spawn {
            sleep 0.2;
            private _wingId = OpsRoom_Schedule_WingId;
            private _wingData = OpsRoom_AirWings get _wingId;
            private _wingName = _wingData get "name";
            private _missionId = OpsRoom_Schedule_MissionId;
            private _mode = OpsRoom_Schedule_Mode;
            private _delayMins = OpsRoom_Schedule_DelayMins;
            private _intervalMins = OpsRoom_Schedule_IntervalMins;
            private _fixedHour = OpsRoom_Schedule_FixedHour;
            
            private _mData = OpsRoom_AirMissionTypes get _missionId;
            private _mName = _mData get "displayName";
            
            // Check if this is a strike mission needing FAH
            private _mData2 = OpsRoom_AirMissionTypes getOrDefault [_missionId, createHashMap];
            private _isStrike = _mData2 getOrDefault ["isStrike", false];
            
            if (_isStrike) then {
                // Strike mission: open air strike map picker (target + FAH in one flow)
                [{
                    params ["_tgtPos", "_fahPos"];
                    private _wingId = OpsRoom_Schedule_WingId;
                    private _wingData = OpsRoom_AirWings get _wingId;
                    private _wingName = _wingData get "name";
                    private _missionId = OpsRoom_Schedule_MissionId;
                    private _mode = OpsRoom_Schedule_Mode;
                    private _delayMins = OpsRoom_Schedule_DelayMins;
                    private _intervalMins = OpsRoom_Schedule_IntervalMins;
                    private _fixedHour = OpsRoom_Schedule_FixedHour;
                    
                    private _schedule = createHashMapFromArray [
                        ["enabled", true],
                        ["missionId", _missionId],
                        ["target", _tgtPos],
                        ["interval", _intervalMins * 60],
                        ["fahPos", _fahPos]
                    ];
                    
                    if (_mode == "fixed") then {
                        _schedule set ["launchAtHour", _fixedHour];
                        _schedule set ["nextLaunchTime", -1];
                    } else {
                        _schedule set ["launchAtHour", -1];
                        private _nextHour = daytime + (_delayMins / 60);
                        if (_nextHour >= 24) then { _nextHour = _nextHour - 24 };
                        _schedule set ["nextLaunchTime", _nextHour];
                    };
                    
                    _wingData set ["schedule", _schedule];
                    
                    private _mData = OpsRoom_AirMissionTypes get _missionId;
                    private _mName = _mData get "displayName";
                    private _fhStr2 = if (_fixedHour < 10) then { format ["0%1", _fixedHour] } else { str _fixedHour };
                    private _timeStr = if (_mode == "fixed") then { format ["daily at %1:00", _fhStr2] } else { format ["in %1 min (in-game)", _delayMins] };
                    private _repeatStr = if (_intervalMins > 0) then { format [", repeat every %1 min", _intervalMins] } else { "" };
                    
                    systemChat format ["%1: %2 scheduled — %3%4", _wingName, _mName, _timeStr, _repeatStr];
                    ["PRIORITY", format ["SCHEDULE: %1", _wingName], format ["%1 scheduled for %2. %3%4.", _wingName, _mName, _timeStr, _repeatStr]] call OpsRoom_fnc_dispatch;
                    [_wingId] spawn OpsRoom_fnc_openWingDetail;
                }, format ["SCHEDULE %1 for %2", _mName, _wingName], {
                    [OpsRoom_Schedule_WingId] spawn OpsRoom_fnc_openWingDetail;
                }] call OpsRoom_fnc_openAirStrikeMapPicker;
            } else {
                // Non-strike: ops map picker for target only
                [{
                    params ["_worldPos"];
                    private _wingId = OpsRoom_Schedule_WingId;
                    private _wingData = OpsRoom_AirWings get _wingId;
                    private _wingName = _wingData get "name";
                    private _missionId = OpsRoom_Schedule_MissionId;
                    private _mode = OpsRoom_Schedule_Mode;
                    private _delayMins = OpsRoom_Schedule_DelayMins;
                    private _intervalMins = OpsRoom_Schedule_IntervalMins;
                    private _fixedHour = OpsRoom_Schedule_FixedHour;
                    
                    private _schedule = createHashMapFromArray [
                        ["enabled", true],
                        ["missionId", _missionId],
                        ["target", _worldPos],
                        ["interval", _intervalMins * 60],
                        ["fahPos", []]
                    ];
                    
                    if (_mode == "fixed") then {
                        _schedule set ["launchAtHour", _fixedHour];
                        _schedule set ["nextLaunchTime", -1];
                    } else {
                        _schedule set ["launchAtHour", -1];
                        private _nextHour = daytime + (_delayMins / 60);
                        if (_nextHour >= 24) then { _nextHour = _nextHour - 24 };
                        _schedule set ["nextLaunchTime", _nextHour];
                    };
                    
                    _wingData set ["schedule", _schedule];
                    
                    private _mData = OpsRoom_AirMissionTypes get _missionId;
                    private _mName = _mData get "displayName";
                    private _fhStr2 = if (_fixedHour < 10) then { format ["0%1", _fixedHour] } else { str _fixedHour };
                    private _timeStr = if (_mode == "fixed") then { format ["daily at %1:00", _fhStr2] } else { format ["in %1 min (in-game)", _delayMins] };
                    private _repeatStr = if (_intervalMins > 0) then { format [", repeat every %1 min", _intervalMins] } else { "" };
                    
                    systemChat format ["%1: %2 scheduled — %3%4", _wingName, _mName, _timeStr, _repeatStr];
                    ["PRIORITY", format ["SCHEDULE: %1", _wingName], format ["%1 scheduled for %2. %3%4.", _wingName, _mName, _timeStr, _repeatStr]] call OpsRoom_fnc_dispatch;
                    [_wingId] spawn OpsRoom_fnc_openWingDetail;
                },
                    format ["TARGET for scheduled %1", _mName],
                    { [OpsRoom_Schedule_WingId] spawn OpsRoom_fnc_openWingDetail; }
                ] call OpsRoom_fnc_openOpsMapPicker;
            };
        };
    };
}];

// CANCEL SCHEDULE
if (_existingEnabled) then {
    private _cancelBtn = _zeusDisplay ctrlCreate ["RscButton", -1];
    _cancelBtn ctrlSetPosition [_contentX + 0.24 * safezoneW, _contentY, 0.22 * safezoneW, 0.035 * safezoneH];
    _cancelBtn ctrlSetText "CANCEL SCHEDULE";
    _cancelBtn ctrlSetFont "PuristaBold";
    _cancelBtn ctrlSetBackgroundColor [0.50, 0.25, 0.15, 1.0];
    _cancelBtn ctrlCommit 0;
    _controls pushBack _cancelBtn;
    
    _cancelBtn ctrlAddEventHandler ["ButtonClick", {
        private _wingId = OpsRoom_Schedule_WingId;
        private _wingData = OpsRoom_AirWings get _wingId;
        _wingData set ["schedule", createHashMap];
        systemChat format ["%1: Schedule cancelled", _wingData get "name"];
        ["ROUTINE", format ["SCHEDULE CANCELLED: %1", _wingData get "name"], "Schedule cleared."] call OpsRoom_fnc_dispatch;
        { ctrlDelete _x } forEach OpsRoom_Schedule_Controls;
        [_wingId] spawn OpsRoom_fnc_openWingDetail;
    }];
};

// CLOSE
private _closeBtn = _zeusDisplay ctrlCreate ["RscButton", -1];
_closeBtn ctrlSetPosition [_panelX + _panelW - 0.055 * safezoneW, _panelY + 0.005 * safezoneH, 0.045 * safezoneW, 0.03 * safezoneH];
_closeBtn ctrlSetText "CLOSE";
_closeBtn ctrlSetFont "PuristaBold";
_closeBtn ctrlSetBackgroundColor [0.35, 0.25, 0.20, 1.0];
_closeBtn ctrlCommit 0;
_controls pushBack _closeBtn;

_closeBtn ctrlAddEventHandler ["ButtonClick", {
    { ctrlDelete _x } forEach OpsRoom_Schedule_Controls;
    [OpsRoom_Schedule_WingId] spawn OpsRoom_fnc_openWingDetail;
}];

OpsRoom_Schedule_Controls = _controls;
diag_log format ["[OpsRoom] Schedule dialog opened for %1", _wingName];
