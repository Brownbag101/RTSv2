/*
    fn_populateDispatchLog
    
    Populates the dispatch log dialog with all stored messages.
    Creates dynamic rows in the list area (IDC 12200+).
    Newest first, colour-coded by type, unread indicator.
    
    Dynamic IDC range: 12200-12499
*/

private _display = findDisplay 8020;
if (isNull _display) exitWith {};

// Delete old dynamic controls
for "_idc" from 12200 to 12499 do {
    private _ctrl = _display displayCtrl _idc;
    if (!isNull _ctrl) then { ctrlDelete _ctrl };
};

// Update summary
private _totalCount = count OpsRoom_Dispatches;
private _unreadCount = OpsRoom_DispatchUnread;
private _summaryCtrl = _display displayCtrl 12100;
_summaryCtrl ctrlSetStructuredText parseText format [
    "<t color='#D9D5C9'>Dispatches: </t><t color='#FFFFFF'>%1</t><t color='#D9D5C9'>  |  Unread: </t><t color='%3'>%2</t>",
    _totalCount,
    _unreadCount,
    if (_unreadCount > 0) then {"#FFD700"} else {"#888888"}
];

// List area dimensions
private _listX = 0.16 * safezoneW + safezoneX;
private _listY = 0.18 * safezoneH + safezoneY;
private _listW = 0.68 * safezoneW;
private _rowH = 0.035 * safezoneH;
private _rowSpacing = 0.002 * safezoneH;

// Maximum visible rows (before detail divider at 0.65)
private _maxRows = floor ((0.65 * safezoneH + safezoneY - _listY) / (_rowH + _rowSpacing));

private _idcCounter = 12200;
private _rowIndex = 0;

{
    if (_rowIndex >= _maxRows) exitWith {};
    if (_idcCounter >= 12490) exitWith {};  // Safety limit
    
    private _dispatch = _x;
    private _type = _dispatch get "type";
    private _title = _dispatch get "title";
    private _dateTime = _dispatch get "dateTime";
    private _isRead = _dispatch get "read";
    private _dispId = _dispatch get "id";
    
    // Get type config
    private _typeConfig = OpsRoom_DispatchTypes getOrDefault [_type, OpsRoom_DispatchTypes get "ROUTINE"];
    private _typeColor = _typeConfig get "color";
    private _displayName = _typeConfig get "displayName";
    
    private _yPos = _listY + (_rowIndex * (_rowH + _rowSpacing));
    
    // Row background
    private _rowBg = _display ctrlCreate ["RscText", _idcCounter];
    _rowBg ctrlSetPosition [_listX, _yPos, _listW, _rowH];
    private _bgAlpha = if (_isRead) then {0.3} else {0.5};
    _rowBg ctrlSetBackgroundColor [0.20, 0.18, 0.14, _bgAlpha];
    _rowBg ctrlCommit 0;
    _idcCounter = _idcCounter + 1;
    
    // Type colour bar (left edge)
    private _typeBar = _display ctrlCreate ["RscText", _idcCounter];
    _typeBar ctrlSetPosition [_listX, _yPos, 0.004 * safezoneW, _rowH];
    _typeBar ctrlSetBackgroundColor _typeColor;
    _typeBar ctrlCommit 0;
    _idcCounter = _idcCounter + 1;
    
    // Unread indicator (dot)
    if (!_isRead) then {
        private _dot = _display ctrlCreate ["RscText", _idcCounter];
        _dot ctrlSetPosition [_listX + 0.008 * safezoneW, _yPos + 0.008 * safezoneH, 0.012 * safezoneW, 0.018 * safezoneH];
        _dot ctrlSetText "●";
        _dot ctrlSetTextColor [1, 0.85, 0.3, 1];
        _dot ctrlSetBackgroundColor [0, 0, 0, 0];
        _dot ctrlSetFont "PuristaBold";
        _dot ctrlCommit 0;
    };
    _idcCounter = _idcCounter + 1;
    
    // Type label
    private _typeLbl = _display ctrlCreate ["RscText", _idcCounter];
    _typeLbl ctrlSetPosition [_listX + 0.022 * safezoneW, _yPos + 0.003 * safezoneH, 0.10 * safezoneW, 0.03 * safezoneH];
    _typeLbl ctrlSetText _displayName;
    _typeLbl ctrlSetFont "PuristaBold";
    _typeLbl ctrlSetTextColor (_typeColor apply {_x min 1});
    _typeLbl ctrlSetBackgroundColor [0, 0, 0, 0];
    _typeLbl ctrlCommit 0;
    private _typeSizeEx = 0.024;
    _typeLbl ctrlSetFontHeight _typeSizeEx;
    _idcCounter = _idcCounter + 1;
    
    // Title
    private _titleLbl = _display ctrlCreate ["RscText", _idcCounter];
    _titleLbl ctrlSetPosition [_listX + 0.13 * safezoneW, _yPos + 0.003 * safezoneH, 0.40 * safezoneW, 0.03 * safezoneH];
    _titleLbl ctrlSetText (toUpper _title);
    _titleLbl ctrlSetFont "PuristaBold";
    private _titleAlpha = if (_isRead) then {0.7} else {1.0};
    _titleLbl ctrlSetTextColor [0.90, 0.87, 0.78, _titleAlpha];
    _titleLbl ctrlSetBackgroundColor [0, 0, 0, 0];
    _titleLbl ctrlCommit 0;
    _idcCounter = _idcCounter + 1;
    
    // Timestamp (right aligned)
    private _timeLbl = _display ctrlCreate ["RscText", _idcCounter];
    _timeLbl ctrlSetPosition [_listX + _listW - 0.10 * safezoneW, _yPos + 0.003 * safezoneH, 0.09 * safezoneW, 0.03 * safezoneH];
    _timeLbl ctrlSetText _dateTime;
    _timeLbl ctrlSetFont "PuristaLight";
    _timeLbl ctrlSetTextColor [0.6, 0.58, 0.52, 0.8];
    _timeLbl ctrlSetBackgroundColor [0, 0, 0, 0];
    _timeLbl ctrlCommit 0;
    private _timeSizeEx = 0.022;
    _timeLbl ctrlSetFontHeight _timeSizeEx;
    _idcCounter = _idcCounter + 1;
    
    // Clickable overlay button (transparent, covers full row)
    private _clickBtn = _display ctrlCreate ["RscButton", _idcCounter];
    _clickBtn ctrlSetPosition [_listX, _yPos, _listW, _rowH];
    _clickBtn ctrlSetText "";
    _clickBtn ctrlSetBackgroundColor [0, 0, 0, 0];
    _clickBtn ctrlSetTextColor [0, 0, 0, 0];
    _clickBtn ctrlCommit 0;
    
    _clickBtn setVariable ["dispatchId", _dispId];
    _clickBtn setVariable ["dispatchIndex", _rowIndex];
    
    _clickBtn ctrlAddEventHandler ["ButtonClick", {
        params ["_ctrl"];
        private _dId = _ctrl getVariable ["dispatchId", ""];
        
        // Find the dispatch
        {
            if ((_x get "id") == _dId) exitWith {
                // Mark as read
                _x set ["read", true];
                OpsRoom_DispatchUnread = (OpsRoom_DispatchUnread - 1) max 0;
                [] call OpsRoom_fnc_updateDispatchBadge;
                
                // Show detail in bottom panel
                private _disp = findDisplay 8020;
                if (!isNull _disp) then {
                    // Update detail label
                    private _typeConf = OpsRoom_DispatchTypes getOrDefault [_x get "type", OpsRoom_DispatchTypes get "ROUTINE"];
                    private _detailLabel = _disp displayCtrl 12103;
                    _detailLabel ctrlSetText format ["%1  —  %2  —  %3", _typeConf get "displayName", toUpper (_x get "title"), _x get "dateTime"];
                    _detailLabel ctrlSetTextColor (_typeConf get "color");
                    
                    // Update detail body
                    private _detailBody = _disp displayCtrl 12104;
                    _detailBody ctrlSetStructuredText parseText format ["<t color='#C8C4B8' size='1.0'>%1</t>", _x get "body"];
                    
                    // Show/hide focus button
                    private _focusBtn = _disp displayCtrl 12105;
                    private _hasFocus = false;
                    if (!isNil {_x get "focusPos"}) then { _hasFocus = true };
                    if (!isNull (_x getOrDefault ["focusObj", objNull])) then { _hasFocus = true };
                    
                    _focusBtn ctrlShow _hasFocus;
                    if (_hasFocus) then {
                        _focusBtn setVariable ["dispatchId", _dId];
                        // Remove old EH and add new one
                        _focusBtn ctrlRemoveAllEventHandlers "ButtonClick";
                        _focusBtn ctrlAddEventHandler ["ButtonClick", {
                            params ["_ctrl"];
                            private _focusId = _ctrl getVariable ["dispatchId", ""];
                            [_focusId] spawn {
                                params ["_fId"];
                                closeDialog 0;
                                sleep 0.1;
                                [_fId] call OpsRoom_fnc_focusDispatch;
                            };
                        }];
                    };
                };
                
                // Refresh list to update read state
                [] call OpsRoom_fnc_populateDispatchLog;
            };
        } forEach OpsRoom_Dispatches;
    }];
    
    _idcCounter = _idcCounter + 1;
    _rowIndex = _rowIndex + 1;
    
} forEach OpsRoom_Dispatches;

// Update status bar
private _statusCtrl = _display displayCtrl 12102;
_statusCtrl ctrlSetStructuredText parseText format [
    "<t color='#D9D5C9' align='center'>%1 dispatches received  |  %2 unread</t>",
    _totalCount,
    _unreadCount
];
