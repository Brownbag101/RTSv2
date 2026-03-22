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
