/*
    Operations Room - Update Resources Display
    
    Updates the top bar with current resource values.
*/

private _display = uiNamespace getVariable ["OpsRoom_HUD_Display", displayNull];
if (isNull _display) exitWith {};

private _resourceCtrl = _display displayCtrl 9010;
if (isNull _resourceCtrl) exitWith {};

// Get resource values (with safety checks)
private _wood = if (isNil "OpsRoom_Resource_Wood") then {0} else {OpsRoom_Resource_Wood};
private _oil = if (isNil "OpsRoom_Resource_Oil") then {0} else {OpsRoom_Resource_Oil};
private _aluminium = if (isNil "OpsRoom_Resource_Aluminium") then {0} else {OpsRoom_Resource_Aluminium};
private _rubber = if (isNil "OpsRoom_Resource_Rubber") then {0} else {OpsRoom_Resource_Rubber};
private _tungsten = if (isNil "OpsRoom_Resource_Tungsten") then {0} else {OpsRoom_Resource_Tungsten};
private _steel = if (isNil "OpsRoom_Resource_Steel") then {0} else {OpsRoom_Resource_Steel};
private _chromium = if (isNil "OpsRoom_Resource_Chromium") then {0} else {OpsRoom_Resource_Chromium};
private _rp = if (isNil "OpsRoom_Resource_Research_Points") then {0} else {OpsRoom_Resource_Research_Points};
private _manpower = if (isNil "OpsRoom_Resource_Manpower") then {0} else {OpsRoom_Resource_Manpower};

// Format the display text (single line, full names)
private _text = format [
    "Wood:<t color='#FFFFFF'>%1</t> | Oil:<t color='#FFFFFF'>%2</t> | Aluminium:<t color='#FFFFFF'>%3</t> | Rubber:<t color='#FFFFFF'>%4</t> | Tungsten:<t color='#FFFFFF'>%5</t> | Steel:<t color='#FFFFFF'>%6</t> | Chromium:<t color='#FFFFFF'>%7</t> | RP:<t color='#FFFFFF'>%8</t> | MP:<t color='#FFFFFF'>%9</t>",
    _wood, _oil, _aluminium, _rubber, _tungsten, _steel, _chromium, _rp, _manpower
];

_resourceCtrl ctrlSetStructuredText parseText _text;
