/*
    OpsRoom_fnc_autoReattachUnits
    
    Reattaches sub-teams back to parent group
    
    Parameters:
        _parentGroup - The parent group to rejoin units to
*/

params ["_parentGroup"];

// Find all units that have this group as their parent
private _allUnits = allUnits select {
    !isNil {_x getVariable "OpsRoom_ParentGroup"} &&
    {(_x getVariable "OpsRoom_ParentGroup") == _parentGroup}
};

if (count _allUnits == 0) exitWith {
    hint "No sub-teams found to reattach";
};

// Store sub-groups to delete after rejoining
private _subGroupsToDelete = [];

// Rejoin each unit to parent group
{
    private _unit = _x;
    private _subGroup = group _unit;
    private _subTeamName = groupId _subGroup;
    
    // Store sub-group for deletion (only once per group)
    if !(_subGroup in _subGroupsToDelete) then {
        _subGroupsToDelete pushBack _subGroup;
    };
    
    // Rejoin parent
    [_unit] joinSilent _parentGroup;
    
    // IMPORTANT: Inherit cooldown from parent group to prevent immediate re-detach
    // Get cooldown from any unit in parent group (they should all have same value)
    private _parentUnits = units _parentGroup;
    if (count _parentUnits > 0) then {
        private _parentCooldown = (_parentUnits select 0) getVariable ["OpsRoom_ReattachCooldown", 0];
        if (_parentCooldown > time) then {
            _unit setVariable ["OpsRoom_ReattachCooldown", _parentCooldown];
            diag_log format ["[OpsRoom] Inherited cooldown for rejoined unit: %1 (%2 seconds)", name _unit, _parentCooldown - time];
        };
    };
    
    // Clear stored variables from unit
    _unit setVariable ["OpsRoom_ParentGroup", nil];
    _unit setVariable ["OpsRoom_ParentGroupName", nil];
    
} forEach _allUnits;

// Delete all empty sub-groups and clean their variables
{
    private _grp = _x;
    // Clear sub-team markers before deleting
    _grp setVariable ["OpsRoom_IsSubTeam", nil];
    _grp setVariable ["OpsRoom_ParentGroup", nil];
    deleteGroup _grp;
} forEach _subGroupsToDelete;

// Reset sub-team counter AND clear parent flag since everyone is back
_parentGroup setVariable ["OpsRoom_SubTeamCounter", 0];
_parentGroup setVariable ["OpsRoom_IsParentGroup", nil];

systemChat format ["Reformed: %1 units rejoined %2", count _allUnits, groupId _parentGroup];
