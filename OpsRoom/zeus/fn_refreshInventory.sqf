/*
    OpsRoom_fnc_refreshInventory
    
    Re-reads inventories and re-renders item panels.
    Preserves frame/title controls, only rebuilds item rows.
*/

private _display = findDisplay 312;
if (isNull _display) exitWith {};

private _unit = missionNamespace getVariable ["OpsRoom_InventoryUnit", objNull];
private _container = missionNamespace getVariable ["OpsRoom_InventoryContainer", objNull];
private _nearContainers = missionNamespace getVariable ["OpsRoom_InventoryNearContainers", []];
private _hasContainer = !isNull _container;

if (isNull _unit) exitWith { [] call OpsRoom_fnc_closeInventory };

// Layout params — must match openInventory
private _totalW = if (_hasContainer) then { 0.44 * safezoneW } else { 0.22 * safezoneW };
private _panelW = 0.22 * safezoneW;
private _panelX = safezoneX + safezoneW - _totalW - (0.01 * safezoneW);
private _panelY = safezoneY + (0.08 * safezoneH);
private _titleH = 0.035 * safezoneH;
private _rowH = 0.028 * safezoneH;
private _sectionH = 0.030 * safezoneH;
private _pad = 0.004 * safezoneW;
private _smallText = 0.028;
private _maxPanelH = 0.78 * safezoneH;

// Colors
private _sectionColor = [0.25, 0.28, 0.19, 0.9];
private _itemBgEven = [0.22, 0.24, 0.16, 0.5];
private _itemBgOdd = [0.20, 0.22, 0.15, 0.3];
private _textColor = [0.85, 0.82, 0.74, 1.0];
private _sectionTextColor = [0.95, 0.92, 0.80, 1.0];
private _dimTextColor = [0.65, 0.62, 0.54, 1.0];
private _btnColor = [0.30, 0.35, 0.22, 0.9];
private _btnHoverColor = [0.45, 0.50, 0.30, 1.0];

// Update unit title
private _titleL = _display displayCtrl 9402;
if (!isNull _titleL) then {
    private _unitLabel = if (alive _unit) then { format ["%1 | %2", name _unit, rank _unit] } else { format ["%1 | DEAD", name _unit] };
    _titleL ctrlSetText _unitLabel;
};

// Update container title
if (_hasContainer) then {
    private _idx = missionNamespace getVariable ["OpsRoom_InventoryContainerIndex", 0];
    if (_idx < count _nearContainers) then {
        private _cData = _nearContainers select _idx;
        private _cName = _cData select 2;
        private _cDist = (_cData select 1) toFixed 1;
        private _titleR = _display displayCtrl 9406;
        if (!isNull _titleR) then {
            _titleR ctrlSetText format ["%1 [%2m]", _cName, _cDist];
        };
    };
};

// Re-render item rows
[_display, _unit, _container, _hasContainer,
 _panelX, _panelY + _titleH, _panelW, _pad, _rowH, _sectionH, _smallText, _maxPanelH,
 _sectionColor, _itemBgEven, _itemBgOdd, _textColor, _sectionTextColor, _dimTextColor,
 _btnColor, _btnHoverColor, _nearContainers] call OpsRoom_fnc_renderInventoryPanels;
