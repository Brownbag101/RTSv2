/*
    OpsRoom_fnc_autoDetachUnits
    
    Detaches selected units into independent sub-teams
    If multiple units from same group selected, they form ONE sub-team together
    
    Parameters:
        _units - Array of units to detach
*/

params ["_units"];

// Group units by their original parent group
private _unitsByParentGroup = createHashMap;

{
    private _unit = _x;
    private _originalGroup = group _unit;
    private _groupLeader = leader _originalGroup;
    
    // Don't detach if:
    // - Unit is not on player's side (never detach enemies)
    // - Unit is alone in group
    // - Unit already detached
    // - The group itself is marked as a sub-team
    // - Unit is a pilot (they live at the airfield independently)
    if (side group _unit != side player) then {continue};
    if (count units _originalGroup <= 1) then {continue};
    if (!isNil {_unit getVariable "OpsRoom_ParentGroup"}) then {continue};
    if (!isNil {_originalGroup getVariable "OpsRoom_IsSubTeam"}) then {continue};
    if (_unit getVariable ["OpsRoom_IsPilot", false]) then {continue};
    if (_unit getVariable ["OpsRoom_IsCargoLoaded", false]) then {continue};
    
    // Group by parent group
    private _grpID = str _originalGroup;
    if (isNil {_unitsByParentGroup get _grpID}) then {
        _unitsByParentGroup set [_grpID, [_originalGroup, []]];
    };
    
    private _data = _unitsByParentGroup get _grpID;
    private _arr = _data select 1;
    _arr pushBack _unit;
    
} forEach _units;

// Now create ONE sub-team per parent group
{
    private _grpID = _x;
    private _data = _y;
    private _originalGroup = _data select 0;
    private _unitsToDetach = _data select 1;
    
    if (count _unitsToDetach == 0) then {continue};
    
    // Mark this group as a parent group (first time detachment happens)
    if (isNil {_originalGroup getVariable "OpsRoom_IsParentGroup"}) then {
        _originalGroup setVariable ["OpsRoom_IsParentGroup", true];
        _originalGroup setVariable ["OpsRoom_SubTeamCounter", 0];
    };
    
    // Unlock the group for auto-detach (user is manually detaching, so auto-detach is OK again)
    _originalGroup setVariable ["OpsRoom_LockedFromAutoDetach", false];
    
    // Get phonetic name for new sub-team
    private _phoneticName = [_originalGroup] call OpsRoom_fnc_getPhoneticName;
    private _parentGroupName = groupId _originalGroup;
    private _subTeamName = format ["%1 %2 Team", _parentGroupName, _phoneticName];
    
    // Create new group
    private _newGroup = createGroup [side (_unitsToDetach select 0), true];
    _newGroup setGroupIdGlobal [_subTeamName];
    
    // Mark new group as a sub-team
    _newGroup setVariable ["OpsRoom_IsSubTeam", true];
    _newGroup setVariable ["OpsRoom_ParentGroup", _originalGroup];
    
    // Move all units to the new sub-team
    {
        private _unit = _x;
        
        // Store original parent group info on the unit
        _unit setVariable ["OpsRoom_ParentGroup", _originalGroup];
        _unit setVariable ["OpsRoom_ParentGroupName", _parentGroupName];
        
        // Join new group
        [_unit] joinSilent _newGroup;
        
    } forEach _unitsToDetach;
    
    systemChat format ["Detached: %1 units → %2", count _unitsToDetach, _subTeamName];
    
} forEach _unitsByParentGroup;
