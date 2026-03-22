/*
    OpsRoom_fnc_openInventory
    
    Two-panel inventory viewer on Zeus display (312).
    Left panel: selected unit's inventory
    Right panel: nearest container/body if within 5m
    If no container nearby, unit can still drop items to ground.
    Collapsible sections — click section headers to expand/collapse.
    
    IDC Range: 9400-9599
    - 9400-9409: Panel frames, titles, close button
    - 9410-9499: Left panel items (unit)
    - 9500-9589: Right panel items (container)
    - 9590-9599: Container switcher controls
*/

// Get Zeus curator
private _curator = getAssignedCuratorLogic player;
if (isNull _curator) exitWith { systemChat "No curator assigned" };

private _selected = curatorSelected select 0;
if (count _selected == 0) exitWith { systemChat "No unit selected" };

private _unit = _selected select 0;
private _display = findDisplay 312;
if (isNull _display) exitWith {};

// Close existing panels
[] call OpsRoom_fnc_closeInventory;
if (missionNamespace getVariable ["OpsRoom_DossierOpen", false]) then {
    [] call OpsRoom_fnc_closeDossier;
};

// ========================================
// FIND NEARBY CONTAINER
// ========================================
private _nearContainers = [_unit, 5] call OpsRoom_fnc_findNearContainers;
private _container = objNull;
private _containerName = "";
private _containerDist = 0;
private _hasContainer = false;

if (count _nearContainers > 0) then {
    _container = (_nearContainers select 0) select 0;
    _containerDist = (_nearContainers select 0) select 1;
    _containerName = (_nearContainers select 0) select 2;
    _hasContainer = true;
};

// Store state
missionNamespace setVariable ["OpsRoom_InventoryOpen", true];
missionNamespace setVariable ["OpsRoom_InventoryUnit", _unit];
missionNamespace setVariable ["OpsRoom_InventoryContainer", _container];
missionNamespace setVariable ["OpsRoom_InventoryNearContainers", _nearContainers];
missionNamespace setVariable ["OpsRoom_InventoryContainerIndex", 0];
// Track which section is expanded per panel
missionNamespace setVariable ["OpsRoom_InventoryExpandedLeft", ""];
missionNamespace setVariable ["OpsRoom_InventoryExpandedRight", ""];

// ========================================
// LAYOUT
// ========================================
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
private _bgColor = [0.18, 0.20, 0.14, 0.95];
private _titleColor = [0.20, 0.25, 0.18, 1.0];
private _sectionColor = [0.25, 0.28, 0.19, 0.9];
private _itemBgEven = [0.22, 0.24, 0.16, 0.5];
private _itemBgOdd = [0.20, 0.22, 0.15, 0.3];
private _textColor = [0.85, 0.82, 0.74, 1.0];
private _sectionTextColor = [0.95, 0.92, 0.80, 1.0];
private _dimTextColor = [0.65, 0.62, 0.54, 1.0];
private _btnColor = [0.30, 0.35, 0.22, 0.9];
private _btnHoverColor = [0.45, 0.50, 0.30, 1.0];
private _closeBtnColor = [0.45, 0.20, 0.18, 0.95];

// ========================================
// LEFT PANEL FRAME (unit)
// ========================================
private _bgLeft = _display ctrlCreate ["RscText", 9400];
_bgLeft ctrlSetPosition [_panelX, _panelY, _panelW, _maxPanelH];
_bgLeft ctrlSetBackgroundColor _bgColor;
_bgLeft ctrlCommit 0;

private _titleLeft = _display ctrlCreate ["RscText", 9401];
_titleLeft ctrlSetPosition [_panelX, _panelY, _panelW, _titleH];
_titleLeft ctrlSetBackgroundColor _titleColor;
_titleLeft ctrlCommit 0;

private _titleTextL = _display ctrlCreate ["RscText", 9402];
private _unitLabel = if (alive _unit) then { format ["%1 | %2", name _unit, rank _unit] } else { format ["%1 | DEAD", name _unit] };
_titleTextL ctrlSetPosition [_panelX + _pad, _panelY, _panelW - (0.04 * safezoneW), _titleH];
_titleTextL ctrlSetText _unitLabel;
_titleTextL ctrlSetTextColor _sectionTextColor;
_titleTextL ctrlSetFont "PuristaBold";
_titleTextL ctrlSetFontHeight _smallText;
_titleTextL ctrlCommit 0;

// ========================================
// RIGHT PANEL FRAME (container) - only if container exists
// ========================================
if (_hasContainer) then {
    private _rightX = _panelX + _panelW;
    
    private _bgRight = _display ctrlCreate ["RscText", 9404];
    _bgRight ctrlSetPosition [_rightX, _panelY, _panelW, _maxPanelH];
    _bgRight ctrlSetBackgroundColor [0.16, 0.18, 0.12, 0.95];
    _bgRight ctrlCommit 0;
    
    private _titleRight = _display ctrlCreate ["RscText", 9405];
    _titleRight ctrlSetPosition [_rightX, _panelY, _panelW, _titleH];
    _titleRight ctrlSetBackgroundColor [0.18, 0.22, 0.15, 1.0];
    _titleRight ctrlCommit 0;
    
    private _titleTextR = _display ctrlCreate ["RscText", 9406];
    private _distStr = _containerDist toFixed 1;
    _titleTextR ctrlSetPosition [_rightX + _pad, _panelY, _panelW - (0.04 * safezoneW), _titleH];
    _titleTextR ctrlSetText format ["%1 [%2m]", _containerName, _distStr];
    _titleTextR ctrlSetTextColor _sectionTextColor;
    _titleTextR ctrlSetFont "PuristaBold";
    _titleTextR ctrlSetFontHeight _smallText;
    _titleTextR ctrlCommit 0;
    
    // Container switcher
    if (count _nearContainers > 1) then {
        private _switchBtn = _display ctrlCreate ["RscButton", 9590];
        _switchBtn ctrlSetPosition [_rightX + _pad, _panelY + _titleH, _panelW - (2 * _pad), _rowH];
        _switchBtn ctrlSetText format ["Switch Container (%1 nearby)", count _nearContainers];
        _switchBtn ctrlSetTextColor _textColor;
        _switchBtn ctrlSetBackgroundColor _btnColor;
        _switchBtn ctrlSetFont "PuristaMedium";
        _switchBtn ctrlSetFontHeight _smallText;
        _switchBtn ctrlCommit 0;
        _switchBtn ctrlAddEventHandler ["ButtonClick", {
            private _containers = missionNamespace getVariable ["OpsRoom_InventoryNearContainers", []];
            private _idx = missionNamespace getVariable ["OpsRoom_InventoryContainerIndex", 0];
            _idx = (_idx + 1) mod (count _containers);
            missionNamespace setVariable ["OpsRoom_InventoryContainerIndex", _idx];
            missionNamespace setVariable ["OpsRoom_InventoryContainer", (_containers select _idx) select 0];
            [] call OpsRoom_fnc_refreshInventory;
        }];
        _switchBtn ctrlAddEventHandler ["MouseEnter", { (_this select 0) ctrlSetBackgroundColor [0.45, 0.50, 0.30, 1.0] }];
        _switchBtn ctrlAddEventHandler ["MouseExit", { (_this select 0) ctrlSetBackgroundColor [0.30, 0.35, 0.22, 0.9] }];
    };
};

// ========================================
// CLOSE BUTTON - Created LAST so it's on top
// ========================================
private _closeBtn = _display ctrlCreate ["RscButton", 9403];
private _closeBtnW = 0.022 * safezoneW;
private _closeBtnH = _titleH - (0.004 * safezoneH);
private _closeBtnX = _panelX + _totalW - _closeBtnW - _pad;
private _closeBtnY = _panelY + ((_titleH - _closeBtnH) / 2);
_closeBtn ctrlSetPosition [_closeBtnX, _closeBtnY, _closeBtnW, _closeBtnH];
_closeBtn ctrlSetText "X";
_closeBtn ctrlSetTextColor [1, 1, 1, 1];
_closeBtn ctrlSetBackgroundColor _closeBtnColor;
_closeBtn ctrlSetFont "PuristaBold";
_closeBtn ctrlSetFontHeight 0.032;
_closeBtn ctrlCommit 0;
_closeBtn ctrlAddEventHandler ["ButtonClick", { [] call OpsRoom_fnc_closeInventory }];
_closeBtn ctrlAddEventHandler ["MouseEnter", { (_this select 0) ctrlSetBackgroundColor [0.65, 0.25, 0.20, 1.0] }];
_closeBtn ctrlAddEventHandler ["MouseExit", { (_this select 0) ctrlSetBackgroundColor [0.45, 0.20, 0.18, 0.95] }];

// ========================================
// RENDER ITEM ROWS
// ========================================
[_display, _unit, _container, _hasContainer,
 _panelX, _panelY + _titleH, _panelW, _pad, _rowH, _sectionH, _smallText, _maxPanelH,
 _sectionColor, _itemBgEven, _itemBgOdd, _textColor, _sectionTextColor, _dimTextColor,
 _btnColor, _btnHoverColor, _nearContainers] call OpsRoom_fnc_renderInventoryPanels;

// ========================================
// CAMERA: Move to inspect the unit
// ========================================
[] spawn {
    private _unit = missionNamespace getVariable ["OpsRoom_InventoryUnit", objNull];
    if (isNull _unit) exitWith {};
    
    private _unitPos = getPosATL _unit;
    private _unitDir = getDir _unit;
    
    private _dirRad = _unitDir * (pi / 180);
    private _camX = (_unitPos select 0) + (3 * sin _dirRad) + (0.8 * cos _dirRad);
    private _camY = (_unitPos select 1) + (3 * cos _dirRad) - (0.8 * sin _dirRad);
    private _camZ = 1.5;
    
    private _camPos = [_camX, _camY, _camZ];
    [_camPos, _unit, 1.5] call BIS_fnc_setCuratorCamera;
};

// ========================================
// AUTO-REFRESH: Periodically rescan for nearby containers
// Catches dropped items creating new GroundWeaponHolders
// ========================================
[] spawn {
    sleep 1;
    while {missionNamespace getVariable ["OpsRoom_InventoryOpen", false]} do {
        private _unit = missionNamespace getVariable ["OpsRoom_InventoryUnit", objNull];
        if (isNull _unit || !alive _unit) exitWith {};
        
        // Rescan for nearby containers
        private _newNear = [_unit, 5] call OpsRoom_fnc_findNearContainers;
        private _oldNear = missionNamespace getVariable ["OpsRoom_InventoryNearContainers", []];
        
        // Check if container count changed (item dropped/picked up)
        if (count _newNear != count _oldNear) then {
            missionNamespace setVariable ["OpsRoom_InventoryNearContainers", _newNear];
            
            // Update active container
            private _idx = missionNamespace getVariable ["OpsRoom_InventoryContainerIndex", 0];
            if (count _newNear > 0) then {
                if (_idx >= count _newNear) then { _idx = 0 };
                private _cData = _newNear select _idx;
                missionNamespace setVariable ["OpsRoom_InventoryContainer", _cData select 0];
            } else {
                missionNamespace setVariable ["OpsRoom_InventoryContainer", objNull];
            };
            
            [] call OpsRoom_fnc_refreshInventory;
        };
        
        sleep 2;
    };
};
