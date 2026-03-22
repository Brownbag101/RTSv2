/*
    OpsRoom_fnc_monitorSelection
    
    Monitors Zeus selection for auto-detach only
    Reattachment is now manual via "Reform Group" button
    Runs continuously while Zeus is active
*/

// Wait for Zeus curator to exist
waitUntil {!isNull (getAssignedCuratorLogic player)};

private _curator = getAssignedCuratorLogic player;
private _lastSelection = []; // Track previous selection to detect changes

while {true} do {
    sleep 0.5;
    
    // Get currently selected units
    private _selected = curatorSelected select 0; // First element is units array
    
    // Update context buttons if selection changed
    if (str _selected != str _lastSelection) then {
        [_selected] call OpsRoom_fnc_updateContextButtons;
        [_selected] call OpsRoom_fnc_updateStandardButtons;  // Show/hide standard buttons
        _lastSelection = _selected;
    };
    
    if (count _selected == 0) then {continue};
    
    // Group selected units by their groups
    private _groupHash = createHashMap;
    {
        private _unit = _x;
        private _grp = group _unit;
        private _grpID = str _grp;
        
        if (isNil {_groupHash get _grpID}) then {
            _groupHash set [_grpID, [_grp, []]];
        };
        
        private _data = _groupHash get _grpID;
        private _arr = _data select 1;
        _arr pushBack _unit;
        
    } forEach _selected;
    
    // Check each group for auto-detach only
    {
        private _grpID = _x;
        private _data = _y;
        private _grp = _data select 0;
        private _selectedFromGroup = _data select 1;
        private _allUnitsInGroup = units _grp;
        private _groupLeader = leader _grp;
        
        // Don't process sub-teams
        private _isSubTeam = !isNil {_grp getVariable "OpsRoom_IsSubTeam"};
        if (_isSubTeam) then {continue};
        
        // Check if group is locked from auto-detach (after manual reformation)
        // BUT: If user is selecting INDIVIDUAL units (not whole group), unlock it!
        private _isLocked = _grp getVariable ["OpsRoom_LockedFromAutoDetach", false];
        if (_isLocked) then {
            // If entire group is NOT selected, user is trying to detach individuals - unlock it
            private _isEntireGroupSelected = (count _selectedFromGroup == count _allUnitsInGroup);
            if (!_isEntireGroupSelected) then {
                _grp setVariable ["OpsRoom_LockedFromAutoDetach", false];
                diag_log format ["[OpsRoom] Unlocking %1 - user selecting individuals for detachment", groupId _grp];
            } else {
                diag_log format ["[OpsRoom] Skipping %1 - locked from auto-detach (manual control)", groupId _grp];
                continue;
            };
        };
        
        // Don't detach entire groups
        private _isEntireGroupSelected = (count _selectedFromGroup == count _allUnitsInGroup);
        if (_isEntireGroupSelected) then {continue};
        
        // Filter units that can be detached
        private _unitsToDetach = _selectedFromGroup select {
            private _unit = _x;
            
            // Check if unit has cooldown from recent reattachment
            private _cooldown = _unit getVariable ["OpsRoom_ReattachCooldown", 0];
            if (time < _cooldown) then {
                diag_log format ["[OpsRoom] Skipping %1 - reattach cooldown active (%.1f seconds remaining)", name _unit, _cooldown - time];
                false  // Skip this unit - still in cooldown
            } else {
                // Check if not already detached
                private _hasParent = !isNil {_unit getVariable "OpsRoom_ParentGroup"};
                if (_hasParent) then {
                    false  // Already detached
                } else {
                    true  // Can be detached
                };
            };
        };
        
        // DEBUG: Log how many units passed filter
        diag_log format ["[OpsRoom] After cooldown filter: %1 units can be detached (from %2 selected)", count _unitsToDetach, count _selectedFromGroup];
        
        // Don't detach if only leader selected
        private _isOnlyLeader = (count _unitsToDetach == 1) && 
                               {(_unitsToDetach select 0) == _groupLeader};
        
        if (count _unitsToDetach > 0 && !_isOnlyLeader) then {
            diag_log format ["[OpsRoom] Auto-detaching %1 units from %2", count _unitsToDetach, groupId _grp];
            {diag_log format ["[OpsRoom]   - %1 (cooldown: %2)", name _x, _x getVariable ["OpsRoom_ReattachCooldown", 0]];} forEach _unitsToDetach;
            [_unitsToDetach] call OpsRoom_fnc_autoDetachUnits;
        };
        
    } forEach _groupHash;
};
