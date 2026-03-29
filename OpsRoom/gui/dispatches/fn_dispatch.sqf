/*
    fn_dispatch
    
    CORE API - Send a dispatch message.
    Call this from ANY system to send a notification.
    
    Stores the message, shows popup on Zeus display, plays sound.
    If a popup is already showing, queues the new message.
    
    Parameters:
        0: STRING  - Type: "ROUTINE" | "PRIORITY" | "FLASH" | "ULTRA" | "SOE"
        1: STRING  - Title (short, e.g. "UNIT KILLED", "TRAINING COMPLETE")
        2: STRING  - Body text (detail message)
        3: ARRAY   - Focus position [x,y,z] (optional, nil for none)
        4: OBJECT  - Focus object/unit (optional, objNull for none)
    
    Returns: STRING - dispatch ID
    
    Usage:
        ["FLASH", "UNIT KILLED", "Pvt. Smith KIA near Port Malden"] call OpsRoom_fnc_dispatch;
        ["ROUTINE", "TRAINING COMPLETE", "Cpl. Jones completed Forward Observer", nil, _unit] call OpsRoom_fnc_dispatch;
        ["ULTRA", "DECRYPT", "Enemy convoy departing grid 045-089 at 0600hrs", [5000,3000,0]] call OpsRoom_fnc_dispatch;
*/

params [
    ["_type", "ROUTINE", [""]],
    ["_title", "", [""]],
    ["_body", "", [""]],
    ["_focusPos", nil, [[]]],
    ["_focusObj", objNull, [objNull]]
];

// Validate type
if !(_type in OpsRoom_DispatchTypes) then {
    diag_log format ["[OpsRoom] WARNING: Unknown dispatch type '%1', defaulting to ROUTINE", _type];
    _type = "ROUTINE";
};

// ========================================
// COMMAND INTELLIGENCE GATE
// ========================================
// Enemy AI commander dispatches are filtered by intel level.
// Titles starting with "ENEMY" are AI commander messages.
// Other dispatches (player actions, training, etc.) always pass through.
private _isEnemyIntel = (_title select [0, 5]) == "ENEMY" || _title == "RADIOMAN DOWN" || _title == "RADIO DESTROYED" || _title == "TRANSMISSION STOPPED" || _title == "ENEMY RADIO ACTIVE" || _title == "ENEMY REINFORCEMENTS INCOMING" || _title == "ENEMY REINFORCEMENTS DISPATCHED" || _title == "ENEMY RESUPPLY" || _title == "ENEMY RESPONSE DELAYED";

if (_isEnemyIntel && !isNil "OpsRoom_AI_IntelLevel") then {
    private _intel = OpsRoom_AI_IntelLevel;
    
    // Below 30%: suppress all enemy intel dispatches (log only)
    if (_intel < 30) exitWith {
        diag_log format ["[OpsRoom] Dispatch SUPPRESSED (intel %1%%): [%2] %3 - %4", round _intel, _type, _title, _body];
        ""
    };
    
    // 30-59%: downgrade to vague messages, suppress detail
    if (_intel < 60) then {
        // Replace specific info with vague intelligence
        _body = switch (true) do {
            case (_title find "COUNTER" >= 0): { "Reports suggest enemy forces are massing for a counter-attack. Target unknown." };
            case (_title find "REINFORCE" >= 0): { "Signals indicate enemy reinforcements are on the move. Strength and destination unclear." };
            case (_title find "GARRISON" >= 0): { "Enemy troop movements detected. Possibly repositioning forces." };
            case (_title find "RADIO" >= 0): { _body };  // Radio events pass through (player can see them)
            case (_title find "RESUPPLY" >= 0): { "Increased enemy shipping activity detected." };
            default { "Unconfirmed reports of enemy activity." };
        };
        _type = "ROUTINE";  // Downgrade urgency
    };
    // 60%+: full detail passes through as-is
};

// Generate ID
private _id = format ["dispatch_%1", OpsRoom_DispatchNextID];
OpsRoom_DispatchNextID = OpsRoom_DispatchNextID + 1;

// Build timestamp string
private _dateArr = date;
private _timeStr = format ["%1:%2 hrs", 
    [_dateArr select 3, 2] call BIS_fnc_numberText,
    [_dateArr select 4, 2] call BIS_fnc_numberText
];

// Build dispatch data
private _dispatch = createHashMapFromArray [
    ["id", _id],
    ["type", _type],
    ["title", _title],
    ["body", _body],
    ["timestamp", time],
    ["dateTime", _timeStr],
    ["read", false],
    ["focusPos", if (isNil "_focusPos") then { [] } else { _focusPos }],
    ["focusObj", if (isNil "_focusObj") then { objNull } else { _focusObj }],
    ["dismissed", false]
];

// Store (newest first)
OpsRoom_Dispatches = [_dispatch] + OpsRoom_Dispatches;

// Trim oldest if over max
private _maxDisp = missionNamespace getVariable ["OpsRoom_Settings_MaxDispatches", 100];
if (count OpsRoom_Dispatches > _maxDisp) then {
    OpsRoom_Dispatches resize _maxDisp;
};

// Increment unread
OpsRoom_DispatchUnread = OpsRoom_DispatchUnread + 1;

// Update button badge
[] call OpsRoom_fnc_updateDispatchBadge;

diag_log format ["[OpsRoom] Dispatch [%1] %2: %3 - %4", _id, _type, _title, _body];

// Show popup or queue
if (OpsRoom_DispatchPopupActive) then {
    // Queue it - will show when current popup dismisses
    OpsRoom_DispatchQueue pushBack _dispatch;
    diag_log format ["[OpsRoom] Dispatch queued (popup active): %1", _id];
} else {
    // Show immediately
    [_dispatch] spawn OpsRoom_fnc_showDispatchPopup;
};

// Return the ID
_id
