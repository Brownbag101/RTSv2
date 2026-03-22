/*
    OpsRoom_fnc_renderInventoryPanels
    
    Renders item rows for both panels with collapsible sections.
    Sections are clickable headers — only one expanded per panel at a time.
    All controls created directly on Zeus display 312.
    
    Transfer buttons:
    - With container: ">" arrows to push items to container, "<" to pull from container
    - Without container: "v" arrows to drop items to ground
*/

params [
    "_display", "_unit", "_container", "_hasContainer",
    "_panelX", "_contentStartY", "_panelW", "_pad", "_rowH", "_sectionH", "_smallText", "_maxPanelH",
    "_sectionColor", "_itemBgEven", "_itemBgOdd", "_textColor", "_sectionTextColor", "_dimTextColor",
    "_btnColor", "_btnHoverColor", "_nearContainers"
];

// Delete existing item controls (keep frames 9400-9409)
for "_i" from 9410 to 9589 do {
    private _ctrl = _display displayCtrl _i;
    if (!isNull _ctrl) then { ctrlDelete _ctrl };
};

private _contentW = _panelW - (2 * _pad);
private _transferBtnW = 0.025 * safezoneW;
private _panelY = _contentStartY - (0.035 * safezoneH);

// Section header colors
private _sectionCollapsed = [0.22, 0.25, 0.17, 0.9];
private _sectionExpanded = [0.30, 0.35, 0.22, 1.0];
private _dropBtnColor = [0.35, 0.28, 0.18, 0.9];

// ========================================
// Helper: Render one panel with collapsible sections
// ========================================
private _fnc_renderPanel = {
    params ["_sections", "_startX", "_startY", "_idcStart", "_idcMax", "_direction", "_expandedVar"];
    
    private _currentY = _startY + (0.005 * safezoneH);
    private _idcCounter = _idcStart;
    private _expandedSection = missionNamespace getVariable [_expandedVar, ""];
    
    // Account for container switcher button on right panel
    if (_direction == "left" && {count _nearContainers > 1}) then {
        _currentY = _currentY + _rowH + (0.003 * safezoneH);
    };
    
    {
        _x params ["_sectionName", "_sectionItems"];
        
        if (_idcCounter >= _idcMax) then { continue };
        
        private _isExpanded = (_sectionName == _expandedSection);
        private _itemCount = count _sectionItems;
        
        // Section header button
        private _sBtn = _display ctrlCreate ["RscButton", _idcCounter];
        _sBtn ctrlSetPosition [_startX, _currentY, _panelW, _sectionH];
        
        private _arrow = if (_isExpanded) then { "▼" } else { "►" };
        _sBtn ctrlSetText format [" %1  %2 (%3)", _arrow, _sectionName, _itemCount];
        _sBtn ctrlSetTextColor _sectionTextColor;
        _sBtn ctrlSetBackgroundColor (if (_isExpanded) then { _sectionExpanded } else { _sectionCollapsed });
        _sBtn ctrlSetFont "PuristaBold";
        _sBtn ctrlSetFontHeight _smallText;
        _sBtn ctrlCommit 0;
        
        _sBtn setVariable ["sectionName", _sectionName];
        _sBtn setVariable ["expandedVar", _expandedVar];
        
        _sBtn ctrlAddEventHandler ["ButtonClick", {
            params ["_ctrl"];
            private _secName = _ctrl getVariable "sectionName";
            private _eVar = _ctrl getVariable "expandedVar";
            private _current = missionNamespace getVariable [_eVar, ""];
            
            if (_current == _secName) then {
                missionNamespace setVariable [_eVar, ""];
            } else {
                missionNamespace setVariable [_eVar, _secName];
            };
            
            [] call OpsRoom_fnc_refreshInventory;
        }];
        
        _sBtn ctrlAddEventHandler ["MouseEnter", { (_this select 0) ctrlSetBackgroundColor [0.35, 0.40, 0.25, 1.0] }];
        _sBtn ctrlAddEventHandler ["MouseExit", {
            params ["_ctrl"];
            private _secName = _ctrl getVariable "sectionName";
            private _eVar = _ctrl getVariable "expandedVar";
            private _current = missionNamespace getVariable [_eVar, ""];
            if (_current == _secName) then {
                _ctrl ctrlSetBackgroundColor [0.30, 0.35, 0.22, 1.0];
            } else {
                _ctrl ctrlSetBackgroundColor [0.22, 0.25, 0.17, 0.9];
            };
        }];
        
        _idcCounter = _idcCounter + 1;
        _currentY = _currentY + _sectionH;
        
        // Only render items if this section is expanded
        if (_isExpanded) then {
            private _itemIdx = 0;
            {
                _x params ["_displayText", "_className", "_qty", "_itemType"];
                
                if (_idcCounter + 2 >= _idcMax) then { continue };
                
                private _isIndented = (_displayText select [0, 2]) == "  ";
                private _isTransferable = !(_itemType in ["attachment", "loaded_mag"]);
                
                // Determine if we show a transfer/drop button
                // With container: show transfer arrows
                // Without container (unit panel only): show drop-to-ground button
                private _showButton = false;
                if (_isTransferable) then {
                    if (_hasContainer) then {
                        _showButton = true;
                    } else {
                        // No container — only show drop button on unit panel (direction "right")
                        if (_direction == "right") then {
                            _showButton = true;
                        };
                    };
                };
                
                // Row background
                private _rowBg = if (_itemIdx mod 2 == 0) then { _itemBgEven } else { _itemBgOdd };
                private _bgCtrl = _display ctrlCreate ["RscText", _idcCounter];
                _bgCtrl ctrlSetPosition [_startX + _pad, _currentY, _contentW, _rowH];
                _bgCtrl ctrlSetBackgroundColor _rowBg;
                _bgCtrl ctrlCommit 0;
                _idcCounter = _idcCounter + 1;
                
                if (_showButton) then {
                    private _btnCtrl = _display ctrlCreate ["RscButton", _idcCounter];
                    
                    if (_hasContainer) then {
                        // Transfer to/from container
                        if (_direction == "right") then {
                            _btnCtrl ctrlSetPosition [_startX + _panelW - _transferBtnW - _pad, _currentY, _transferBtnW, _rowH];
                            _btnCtrl ctrlSetText ">";
                        } else {
                            _btnCtrl ctrlSetPosition [_startX + _pad, _currentY, _transferBtnW, _rowH];
                            _btnCtrl ctrlSetText "<";
                        };
                        _btnCtrl ctrlSetBackgroundColor _btnColor;
                    } else {
                        // Drop to ground (unit panel, no container)
                        _btnCtrl ctrlSetPosition [_startX + _panelW - _transferBtnW - _pad, _currentY, _transferBtnW, _rowH];
                        _btnCtrl ctrlSetText "v";
                        _btnCtrl ctrlSetBackgroundColor _dropBtnColor;
                    };
                    
                    _btnCtrl ctrlSetTextColor _textColor;
                    _btnCtrl ctrlSetFont "PuristaBold";
                    _btnCtrl ctrlSetFontHeight _smallText;
                    _btnCtrl ctrlCommit 0;
                    
                    _btnCtrl setVariable ["transferClass", _className];
                    _btnCtrl setVariable ["transferQty", _qty];
                    _btnCtrl setVariable ["transferType", _itemType];
                    _btnCtrl setVariable ["transferDirection", _direction];
                    _btnCtrl setVariable ["isGroundDrop", !_hasContainer];
                    
                    _btnCtrl ctrlAddEventHandler ["ButtonClick", {
                        params ["_ctrl"];
                        private _cls = _ctrl getVariable "transferClass";
                        private _qty = _ctrl getVariable "transferQty";
                        private _type = _ctrl getVariable "transferType";
                        private _dir = _ctrl getVariable "transferDirection";
                        private _groundDrop = _ctrl getVariable ["isGroundDrop", false];
                        
                        private _theUnit = missionNamespace getVariable ["OpsRoom_InventoryUnit", objNull];
                        private _theCont = missionNamespace getVariable ["OpsRoom_InventoryContainer", objNull];
                        
                        if (_groundDrop) then {
                            // Drop to ground — create a weapon holder at unit's feet
                            private _groundPos = getPosATL _theUnit;
                            private _holder = createVehicle ["GroundWeaponHolder", _groundPos, [], 0, "CAN_COLLIDE"];
                            _holder setPosATL _groundPos;
                            [_cls, 1, _type, _theUnit, _holder] call OpsRoom_fnc_transferItem;
                        } else {
                            if (_dir == "right") then {
                                [_cls, 1, _type, _theUnit, _theCont] call OpsRoom_fnc_transferItem;
                            } else {
                                [_cls, 1, _type, _theCont, _theUnit] call OpsRoom_fnc_transferItem;
                            };
                        };
                    }];
                    
                    if (_hasContainer) then {
                        _btnCtrl ctrlAddEventHandler ["MouseEnter", { (_this select 0) ctrlSetBackgroundColor [0.45, 0.50, 0.30, 1.0] }];
                        _btnCtrl ctrlAddEventHandler ["MouseExit", { (_this select 0) ctrlSetBackgroundColor [0.30, 0.35, 0.22, 0.9] }];
                    } else {
                        _btnCtrl ctrlAddEventHandler ["MouseEnter", { (_this select 0) ctrlSetBackgroundColor [0.50, 0.38, 0.22, 1.0] }];
                        _btnCtrl ctrlAddEventHandler ["MouseExit", { (_this select 0) ctrlSetBackgroundColor [0.35, 0.28, 0.18, 0.9] }];
                    };
                    
                    _idcCounter = _idcCounter + 1;
                };
                
                // Item text
                if (_idcCounter < _idcMax) then {
                    private _txtCtrl = _display ctrlCreate ["RscText", _idcCounter];
                    
                    private _textX = _startX + _pad;
                    private _textW = _contentW;
                    
                    if (_showButton) then {
                        if (_hasContainer && _direction == "left") then {
                            // Container panel: button on left
                            _textX = _textX + _transferBtnW + _pad;
                            _textW = _contentW - _transferBtnW - _pad;
                        } else {
                            // Unit panel (with or without container): button on right
                            _textW = _contentW - _transferBtnW - _pad;
                        };
                    };
                    
                    _txtCtrl ctrlSetPosition [_textX, _currentY, _textW, _rowH];
                    _txtCtrl ctrlSetText _displayText;
                    _txtCtrl ctrlSetTextColor (if (_isIndented) then { _dimTextColor } else { _textColor });
                    _txtCtrl ctrlSetFont "PuristaMedium";
                    _txtCtrl ctrlSetFontHeight _smallText;
                    _txtCtrl ctrlCommit 0;
                    _idcCounter = _idcCounter + 1;
                };
                
                _currentY = _currentY + _rowH;
                _itemIdx = _itemIdx + 1;
                
            } forEach _sectionItems;
        };
        
        _currentY = _currentY + (0.003 * safezoneH);
        
    } forEach _sections;
    
    _currentY
};

// ========================================
// LEFT PANEL - Unit inventory
// ========================================
private _unitSections = [_unit] call OpsRoom_fnc_getContainerItems;
private _leftEndY = [_unitSections, _panelX, _contentStartY, 9410, 9499, "right", "OpsRoom_InventoryExpandedLeft"] call _fnc_renderPanel;

// ========================================
// RIGHT PANEL - Container inventory
// ========================================
private _rightEndY = _leftEndY;

if (_hasContainer) then {
    private _rightX = _panelX + _panelW;
    private _containerSections = [_container] call OpsRoom_fnc_getContainerItems;
    _rightEndY = [_containerSections, _rightX, _contentStartY, 9500, 9589, "left", "OpsRoom_InventoryExpandedRight"] call _fnc_renderPanel;
};

// ========================================
// RESIZE BACKGROUNDS TO FIT
// ========================================
private _finalH = (((_leftEndY max _rightEndY) - _panelY) + (0.01 * safezoneH)) min _maxPanelH;

private _bgLeft = _display displayCtrl 9400;
if (!isNull _bgLeft) then {
    _bgLeft ctrlSetPosition [_panelX, _panelY, _panelW, _finalH];
    _bgLeft ctrlCommit 0;
};

if (_hasContainer) then {
    private _bgRight = _display displayCtrl 9404;
    if (!isNull _bgRight) then {
        _bgRight ctrlSetPosition [_panelX + _panelW, _panelY, _panelW, _finalH];
        _bgRight ctrlCommit 0;
    };
};
