/*
    Show Create Wing Dialog
    
    Asks the player to name the wing and choose its type.
    Uses simple hint-based input for now, then creates the wing.
*/

// Wing type selection via sequential hints
private _wingTypes = [];
{
    _wingTypes pushBack [_x, _y get "displayName", _y get "description"];
} forEach OpsRoom_WingTypes;

// Store selection globally for the button handlers
OpsRoom_CreateWing_SelectedType = "";

// Create a simple selection dialog
createDialog "RscDisplayEmpty";
private _display = findDisplay -1;
if (isNull _display) exitWith {};

// Background
private _bg = _display ctrlCreate ["RscText", 7000];
_bg ctrlSetPosition [0.3 * safezoneW + safezoneX, 0.25 * safezoneH + safezoneY, 0.4 * safezoneW, 0.55 * safezoneH];
_bg ctrlSetBackgroundColor [0.20, 0.25, 0.18, 0.95];
_bg ctrlCommit 0;

// Title
private _title = _display ctrlCreate ["RscText", 7001];
_title ctrlSetPosition [0.3 * safezoneW + safezoneX, 0.25 * safezoneH + safezoneY, 0.4 * safezoneW, 0.04 * safezoneH];
_title ctrlSetText "CREATE AIR WING";
_title ctrlSetBackgroundColor [0.15, 0.20, 0.13, 1.0];
_title ctrlSetTextColor [0.85, 0.82, 0.74, 1.0];
_title ctrlSetFont "PuristaLight";
_title ctrlCommit 0;

// Name label
private _nameLabel = _display ctrlCreate ["RscText", 7002];
_nameLabel ctrlSetPosition [0.32 * safezoneW + safezoneX, 0.31 * safezoneH + safezoneY, 0.15 * safezoneW, 0.03 * safezoneH];
_nameLabel ctrlSetText "Squadron Name:";
_nameLabel ctrlCommit 0;

// Name input
private _nameInput = _display ctrlCreate ["RscEdit", 7003];
_nameInput ctrlSetPosition [0.47 * safezoneW + safezoneX, 0.31 * safezoneH + safezoneY, 0.2 * safezoneW, 0.035 * safezoneH];
_nameInput ctrlSetText format ["No. %1 Squadron", 100 + floor random 900];
_nameInput ctrlCommit 0;

// Type label
private _typeLabel = _display ctrlCreate ["RscText", 7004];
_typeLabel ctrlSetPosition [0.32 * safezoneW + safezoneX, 0.36 * safezoneH + safezoneY, 0.36 * safezoneW, 0.03 * safezoneH];
_typeLabel ctrlSetText "Select Wing Type:";
_typeLabel ctrlCommit 0;

// Type buttons
private _btnIndex = 0;
{
    _x params ["_typeId", "_typeName", "_typeDesc"];
    
    private _btn = _display ctrlCreate ["RscButton", 7100 + _btnIndex];
    _btn ctrlSetPosition [
        0.32 * safezoneW + safezoneX,
        (0.40 + (_btnIndex * 0.05)) * safezoneH + safezoneY,
        0.36 * safezoneW,
        0.04 * safezoneH
    ];
    _btn ctrlSetText _typeName;
    _btn ctrlSetTooltip _typeDesc;
    _btn ctrlSetBackgroundColor [0.26, 0.30, 0.21, 1.0];
    _btn setVariable ["wingType", _typeId];
    _btn ctrlCommit 0;
    
    _btn ctrlAddEventHandler ["ButtonClick", {
        params ["_ctrl"];
        OpsRoom_CreateWing_SelectedType = _ctrl getVariable ["wingType", ""];
        
        // Highlight selected, unhighlight others
        private _display = ctrlParent _ctrl;
        for "_i" from 0 to 9 do {
            private _otherBtn = _display displayCtrl (7100 + _i);
            if (!isNull _otherBtn) then {
                _otherBtn ctrlSetBackgroundColor [0.26, 0.30, 0.21, 1.0];
            };
        };
        _ctrl ctrlSetBackgroundColor [0.3, 0.45, 0.25, 1.0];
    }];
    
    _btnIndex = _btnIndex + 1;
} forEach _wingTypes;

// Confirm button
private _confirmBtn = _display ctrlCreate ["RscButton", 7200];
_confirmBtn ctrlSetPosition [0.42 * safezoneW + safezoneX, 0.70 * safezoneH + safezoneY, 0.12 * safezoneW, 0.04 * safezoneH];
_confirmBtn ctrlSetText "CREATE";
_confirmBtn ctrlSetBackgroundColor [0.25, 0.40, 0.25, 1.0];
_confirmBtn ctrlCommit 0;

_confirmBtn ctrlAddEventHandler ["ButtonClick", {
    params ["_ctrl"];
    private _display = ctrlParent _ctrl;
    
    if (OpsRoom_CreateWing_SelectedType == "") exitWith {
        systemChat "Select a wing type first";
    };
    
    private _nameCtrl = _display displayCtrl 7003;
    private _name = ctrlText _nameCtrl;
    
    if (_name == "") exitWith {
        systemChat "Enter a squadron name";
    };
    
    // Create the wing
    private _wingId = [_name, OpsRoom_CreateWing_SelectedType] call OpsRoom_fnc_createWing;
    
    if (_wingId != "") then {
        closeDialog 0;
        [] spawn {
            sleep 0.1;
            [] call OpsRoom_fnc_openAirOps;
        };
    };
}];

// Cancel button
private _cancelBtn = _display ctrlCreate ["RscButton", 7201];
_cancelBtn ctrlSetPosition [0.55 * safezoneW + safezoneX, 0.70 * safezoneH + safezoneY, 0.12 * safezoneW, 0.04 * safezoneH];
_cancelBtn ctrlSetText "CANCEL";
_cancelBtn ctrlSetBackgroundColor [0.40, 0.25, 0.20, 1.0];
_cancelBtn ctrlCommit 0;

_cancelBtn ctrlAddEventHandler ["ButtonClick", {
    closeDialog 0;
    [] spawn {
        sleep 0.1;
        [] call OpsRoom_fnc_openAirOps;
    };
}];
