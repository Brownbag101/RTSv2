/*
    OpsRoom_fnc_updateStandardButtons
    
    Shows or hides standard buttons based on selection
    
    Parameters:
        _units - Array of selected units
*/

params ["_units"];

private _display = findDisplay 312;
if (isNull _display) exitWith {};

private _hasSelection = count _units > 0;

// Check if selection contains enemy units
private _hasEnemy = false;
if (_hasSelection) then {
    {
        if ((side _x) != (side player)) then {
            _hasEnemy = true;
        };
    } forEach _units;
};

// Don't show standard buttons for enemy units
if (_hasEnemy) then {
    _hasSelection = false;
};

// Standard button IDCs: 9300-9309 (5 buttons, 2 controls each)
// Always show/hide these based on selection
for "_i" from 9300 to 9309 do {
    private _ctrl = _display displayCtrl _i;
    if (!isNull _ctrl) then {
        _ctrl ctrlShow _hasSelection;
    };
};

// Regroup button IDCs: 9310-9311 (special - only show for leader)
// Check regroup condition from ability config
private _showRegroup = false;
if (_hasSelection && count _units == 1) then {
    private _unit = _units select 0;
    private _group = group _unit;
    
    diag_log format ["[OpsRoom] Checking regroup: unit=%1, isLeader=%2", name _unit, (leader _group == _unit)];
    
    // Check if this is a leader with regroup ability
    if (leader _group == _unit) then {
        private _customRank = _unit getVariable ["OpsRoom_Rank", ""];
        private _rankValue = rankId _unit;
        private _isOfficer = (_customRank in ["CAPTAIN", "MAJOR", "COLONEL"]) || (_rankValue >= 3);
        
        diag_log format ["[OpsRoom] Leader check: customRank=%1, rankValue=%2, isOfficer=%3", _customRank, _rankValue, _isOfficer];
        
        if (_isOfficer) then {
            // Check for detached units
            private _hasDetached = count (allUnits select {
                (_x getVariable ["OpsRoom_ParentGroup", grpNull]) == _group
            }) > 0;
            
            diag_log format ["[OpsRoom] Detached check: hasDetached=%1", _hasDetached];
            
            _showRegroup = _hasDetached;
        };
    };
};

diag_log format ["[OpsRoom] Regroup visibility: %1", _showRegroup];

// Show/hide regroup button
for "_i" from 9310 to 9311 do {
    private _ctrl = _display displayCtrl _i;
    diag_log format ["[OpsRoom] Regroup control %1: isNull=%2", _i, isNull _ctrl];
    if (!isNull _ctrl) then {
        _ctrl ctrlShow _showRegroup;
        diag_log format ["[OpsRoom] Set regroup control %1 visibility to %2", _i, _showRegroup];
        
        // Verify it was set
        private _actuallyShown = ctrlShown _ctrl;
        diag_log format ["[OpsRoom] Regroup control %1 ctrlShown result: %2", _i, _actuallyShown];
        
        // Try committing the change
        _ctrl ctrlCommit 0;
    };
};

// Close any open menus when selection is cleared
if (!_hasSelection) then {
    [] call OpsRoom_fnc_closeButtonMenu;
};
