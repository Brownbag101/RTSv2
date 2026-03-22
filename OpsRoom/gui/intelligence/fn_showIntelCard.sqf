/*
    fn_showIntelCard
    
    Displays an intelligence card popup for a strategic location.
    Shows information based on current intel tier.
    Overlaid on the operational map dialog.
    
    Parameters:
        0: STRING - Location ID
    
    Creates dynamic controls on the map dialog (IDD 8010).
    IDC Range: 11520-11560 for intel card elements.
*/

params [["_locId", "", [""]]];

if (_locId == "") exitWith {};

private _locData = OpsRoom_StrategicLocations getOrDefault [_locId, createHashMap];
if (count _locData == 0) exitWith { systemChat "Intel: Location not found" };

private _display = findDisplay 8010;
if (isNull _display) exitWith {};

// Delete any existing intel card controls
for "_idc" from 11520 to 11560 do {
    private _ctrl = _display displayCtrl _idc;
    if (!isNull _ctrl) then { ctrlDelete _ctrl };
};

// Shrink the map to the left side to make room for the intel card
private _mapCtrl = _display displayCtrl 11500;
if (!isNull _mapCtrl) then {
    _mapCtrl ctrlSetPosition [
        0.05 * safezoneW + safezoneX,
        0.09 * safezoneH + safezoneY,
        0.56 * safezoneW,
        0.82 * safezoneH
    ];
    _mapCtrl ctrlCommit 0.2;
};

// Get location data
private _name = _locData get "name";
private _type = _locData get "type";
private _tier = _locData get "intelTier";
private _percent = _locData get "intelPercent";
private _status = _locData get "status";
private _pos = _locData get "pos";
private _lastUpdated = _locData get "lastUpdated";

// Get type data
private _typeData = OpsRoom_LocationTypes getOrDefault [_type, createHashMap];

// Card dimensions - positioned centre-right of screen
private _cardX = 0.62 * safezoneW + safezoneX;
private _cardY = 0.12 * safezoneH + safezoneY;
private _cardW = 0.30 * safezoneW;
private _cardH = 0.72 * safezoneH;
private _rowH = 0.028 * safezoneH;
private _padding = 0.008 * safezoneW;

// ========================================
// CARD BACKGROUND
// ========================================
private _bg = _display ctrlCreate ["RscText", 11520];
_bg ctrlSetPosition [_cardX, _cardY, _cardW, _cardH];
_bg ctrlSetBackgroundColor [0.18, 0.22, 0.15, 0.95];
_bg ctrlCommit 0;

// Card border
private _border = _display ctrlCreate ["RscText", 11521];
_border ctrlSetPosition [_cardX - 0.001, _cardY - 0.001, _cardW + 0.002, _cardH + 0.002];
_border ctrlSetBackgroundColor [0.35, 0.30, 0.20, 1.0];
_border ctrlCommit 0;
ctrlSetFocus _bg;  // Bring to front
// Re-create bg on top of border
ctrlDelete (_display displayCtrl 11520);
private _bg = _display ctrlCreate ["RscText", 11520];
_bg ctrlSetPosition [_cardX, _cardY, _cardW, _cardH];
_bg ctrlSetBackgroundColor [0.18, 0.22, 0.15, 0.95];
_bg ctrlCommit 0;

// ========================================
// CARD HEADER
// ========================================
private _header = _display ctrlCreate ["RscText", 11522];
_header ctrlSetPosition [_cardX, _cardY, _cardW, 0.04 * safezoneH];
_header ctrlSetBackgroundColor [0.20, 0.25, 0.18, 1.0];
_header ctrlCommit 0;

private _headerText = _display ctrlCreate ["RscStructuredText", 11523];
_headerText ctrlSetPosition [_cardX + _padding, _cardY + 0.005 * safezoneH, _cardW - (2 * _padding), 0.035 * safezoneH];
_headerText ctrlSetStructuredText parseText format [
    "<t font='PuristaBold' size='1.1'>INTELLIGENCE REPORT</t>"
];
_headerText ctrlCommit 0;

// Close card button
private _closeBtn = _display ctrlCreate ["RscButton", 11524];
_closeBtn ctrlSetPosition [_cardX + _cardW - 0.025 * safezoneW, _cardY + 0.005 * safezoneH, 0.02 * safezoneW, 0.03 * safezoneH];
_closeBtn ctrlSetText "X";
_closeBtn ctrlSetFont "PuristaBold";
_closeBtn ctrlCommit 0;
_closeBtn ctrlAddEventHandler ["ButtonClick", {
    private _display = findDisplay 8010;
    if (!isNull _display) then {
        // Delete all intel card controls
        for "_idc" from 11520 to 11560 do {
            private _ctrl = _display displayCtrl _idc;
            if (!isNull _ctrl) then { ctrlDelete _ctrl };
        };
        // Restore map to full width
        private _mapCtrl = _display displayCtrl 11500;
        if (!isNull _mapCtrl) then {
            _mapCtrl ctrlSetPosition [
                0.05 * safezoneW + safezoneX,
                0.09 * safezoneH + safezoneY,
                0.90 * safezoneW,
                0.82 * safezoneH
            ];
            _mapCtrl ctrlCommit 0.2;
        };
    };
}];

// ========================================
// CARD BODY - Build content based on tier
// ========================================
private _contentY = _cardY + 0.05 * safezoneH;
private _contentX = _cardX + _padding;
private _contentW = _cardW - (2 * _padding);
private _lineIDC = 11530;

// Helper: add a labelled line
private _fnc_addLine = {
    params ["_label", "_value", "_color"];
    if (isNil "_color") then { _color = "#D9D5C9" };
    
    private _ctrl = _display ctrlCreate ["RscStructuredText", _lineIDC];
    _ctrl ctrlSetPosition [_contentX, _contentY, _contentW, _rowH];
    _ctrl ctrlSetStructuredText parseText format [
        "<t font='PuristaBold' color='#A0A090'>%1:</t>  <t color='%3'>%2</t>",
        _label, _value, _color
    ];
    _ctrl ctrlCommit 0;
    _contentY = _contentY + _rowH;
    _lineIDC = _lineIDC + 1;
};

// Helper: add a section header
private _fnc_addSection = {
    params ["_title"];
    _contentY = _contentY + 0.008 * safezoneH;
    private _ctrl = _display ctrlCreate ["RscStructuredText", _lineIDC];
    _ctrl ctrlSetPosition [_contentX, _contentY, _contentW, _rowH];
    _ctrl ctrlSetStructuredText parseText format [
        "<t font='PuristaBold' size='1.05' color='#C8C0A8'>── %1 ──</t>",
        _title
    ];
    _ctrl ctrlCommit 0;
    _contentY = _contentY + _rowH + 0.005 * safezoneH;
    _lineIDC = _lineIDC + 1;
};

// ── LOCATION NAME ──
private _nameCtrl = _display ctrlCreate ["RscStructuredText", _lineIDC];
_nameCtrl ctrlSetPosition [_contentX, _contentY, _contentW, 0.04 * safezoneH];
_nameCtrl ctrlSetStructuredText parseText format [
    "<t font='PuristaBold' size='1.3'>%1</t>", _name
];
_nameCtrl ctrlCommit 0;
_contentY = _contentY + 0.04 * safezoneH;
_lineIDC = _lineIDC + 1;

// ── STATUS & OWNERSHIP ──
private _owner = _locData getOrDefault ["owner", "NAZI"];
private _contested = _locData getOrDefault ["contested", false];
private _captureProgress = _locData getOrDefault ["captureProgress", 0];

private _statusColor = switch (true) do {
    case (_status == "destroyed"): { "#888888" };
    case (_contested): { "#FFFF44" };
    case (_owner == "BRITISH"): { "#44FF44" };
    case (_owner == "NAZI"): { "#FF4444" };
    case (_owner == "NEUTRAL"): { "#AAAAAA" };
    default { "#FFFFFF" };
};

private _statusName = if (_contested) then {
    format ["CONTESTED (%1%%)", round _captureProgress]
} else {
    toUpper _owner
};

["STATUS"] call _fnc_addSection;
["Owner", _statusName, _statusColor] call _fnc_addLine;

if (_contested) then {
    private _direction = _locData getOrDefault ["captureDirection", "none"];
    private _dirStr = if (_direction == "british") then { "British advancing" } else { "Enemy counter-attacking" };
    ["Battle", _dirStr, "#FFCC44"] call _fnc_addLine;
};

// ── INTEL LEVEL ──
private _tierNames = ["UNKNOWN", "DETECTED", "IDENTIFIED", "OBSERVED", "DETAILED", "COMPROMISED"];
private _tierName = _tierNames select _tier;
private _tierColor = switch (_tier) do {
    case 0: { "#FF4444" };
    case 1: { "#FF8844" };
    case 2: { "#FFCC44" };
    case 3: { "#88CC44" };
    case 4: { "#44CC44" };
    case 5: { "#44FF88" };
    default { "#FFFFFF" };
};
["Intel Level", format ["%1 (%2%%)", _tierName, round _percent], _tierColor] call _fnc_addLine;

// Intel bar
private _barCtrl = _display ctrlCreate ["RscText", _lineIDC];
_barCtrl ctrlSetPosition [_contentX, _contentY, _contentW * (_percent / 100), 0.008 * safezoneH];
_barCtrl ctrlSetBackgroundColor (switch (_tier) do {
    case 0: { [0.8, 0.2, 0.2, 0.8] };
    case 1: { [0.8, 0.5, 0.2, 0.8] };
    case 2: { [0.8, 0.7, 0.2, 0.8] };
    case 3: { [0.5, 0.7, 0.2, 0.8] };
    case 4: { [0.2, 0.7, 0.2, 0.8] };
    case 5: { [0.2, 0.8, 0.5, 0.8] };
    default { [0.5, 0.5, 0.5, 0.8] };
});
_barCtrl ctrlCommit 0;
_lineIDC = _lineIDC + 1;

// Bar background
private _barBg = _display ctrlCreate ["RscText", _lineIDC];
_barBg ctrlSetPosition [_contentX, _contentY, _contentW, 0.008 * safezoneH];
_barBg ctrlSetBackgroundColor [0.1, 0.1, 0.1, 0.5];
_barBg ctrlCommit 0;
_lineIDC = _lineIDC + 1;

// Bring bar to front by recreating
ctrlDelete (_display displayCtrl (_lineIDC - 2));
private _barCtrl2 = _display ctrlCreate ["RscText", _lineIDC - 2];
_barCtrl2 ctrlSetPosition [_contentX, _contentY, _contentW * (_percent / 100), 0.008 * safezoneH];
_barCtrl2 ctrlSetBackgroundColor (switch (_tier) do {
    case 0: { [0.8, 0.2, 0.2, 0.8] };
    case 1: { [0.8, 0.5, 0.2, 0.8] };
    case 2: { [0.8, 0.7, 0.2, 0.8] };
    case 3: { [0.5, 0.7, 0.2, 0.8] };
    case 4: { [0.2, 0.7, 0.2, 0.8] };
    case 5: { [0.2, 0.8, 0.5, 0.8] };
    default { [0.5, 0.5, 0.5, 0.8] };
});
_barCtrl2 ctrlCommit 0;

_contentY = _contentY + 0.015 * safezoneH;

// ── GRID REFERENCE ──
["Grid Ref", mapGridPosition _pos] call _fnc_addLine;

// ── TIER-GATED INFORMATION ──

// Tier 0-1: Minimal info
if (_tier <= 1) then {
    ["INTELLIGENCE"] call _fnc_addSection;
    ["Type", "UNKNOWN - Requires further reconnaissance"] call _fnc_addLine;
    ["Assessment", "Insufficient data. Send recon units to gather intelligence."] call _fnc_addLine;
};

// Tier 2+: Type and production revealed
if (_tier >= 2) then {
    ["IDENTIFICATION"] call _fnc_addSection;
    
    if (count _typeData > 0) then {
        ["Type", _typeData get "displayName"] call _fnc_addLine;
        ["Category", _typeData get "category"] call _fnc_addLine;
        ["Description", _typeData get "description"] call _fnc_addLine;
    };
    
    private _produces = _locData get "produces";
    if (_produces != "") then {
        ["Produces", _produces, "#88CC44"] call _fnc_addLine;
    };
};

// Tier 3+: Garrison strength
if (_tier >= 3) then {
    ["ENEMY FORCES"] call _fnc_addSection;
    
    private _garrison = _locData get "garrisonStrength";
    private _garrisonColor = switch (_garrison) do {
        case "Light": { "#88CC44" };
        case "Moderate": { "#FFCC44" };
        case "Heavy": { "#FF8844" };
        case "Fortified": { "#FF4444" };
        default { "#888888" };
    };
    ["Garrison", _garrison, _garrisonColor] call _fnc_addLine;
};

// Tier 4+: Exact numbers, defences, reinforcements
if (_tier >= 4) then {
    private _garrisonCount = _locData get "garrisonCount";
    if (_garrisonCount > 0) then {
        ["Strength", format ["%1 personnel", _garrisonCount]] call _fnc_addLine;
    };
    
    private _defences = _locData get "defences";
    if (_defences != "Unknown") then {
        ["Defences", _defences] call _fnc_addLine;
    };
    
    private _reinforcements = _locData get "reinforcements";
    if (_reinforcements != "Unknown") then {
        ["Reinforcements", _reinforcements, "#FF8844"] call _fnc_addLine;
    };
};

// Tier 5: Real-time intel (SOE)
if (_tier >= 5) then {
    ["REAL-TIME INTELLIGENCE"] call _fnc_addSection;
    
    private _officerName = _locData get "officerName";
    private _officerRank = _locData get "officerRank";
    
    if (_officerName != "") then {
        ["Commanding Officer", format ["%1 %2", _officerRank, _officerName], "#FF4444"] call _fnc_addLine;
    };
    
    ["Source", "SOE Agent (embedded)", "#44FF88"] call _fnc_addLine;
};

// ── AVAILABLE OPERATIONS ──
if (_tier >= 2 && _status == "enemy") then {
    ["AVAILABLE OPERATIONS"] call _fnc_addSection;
    
    private _taskTypes = _locData get "taskTypes";
    if (!isNil "_taskTypes") then {
        private _taskStr = _taskTypes joinString ", ";
        ["Operations", _taskStr] call _fnc_addLine;
    };
};

// ── LAST UPDATED ──
_contentY = _contentY + 0.01 * safezoneH;
if (_lastUpdated > 0) then {
    private _timeSince = round (time - _lastUpdated);
    private _timeStr = if (_timeSince < 60) then {
        format ["%1 seconds ago", _timeSince]
    } else {
        if (_timeSince < 3600) then {
            format ["%1 minutes ago", round (_timeSince / 60)]
        } else {
            format ["%1 hours ago", round (_timeSince / 3600)]
        };
    };
    ["Last Updated", _timeStr, "#888888"] call _fnc_addLine;
} else {
    ["Last Updated", "Never", "#888888"] call _fnc_addLine;
};

systemChat format ["Intel: Viewing report for %1", _name];
