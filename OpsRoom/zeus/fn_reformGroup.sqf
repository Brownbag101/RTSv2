/*
    OpsRoom_fnc_reformGroup
    
    Manually reattach all sub-teams back to their parent group.
    Only works when the MAIN GROUP (parent group) is selected.
    Call this from a button.
*/

// Get currently selected units
private _selected = curatorSelected select 0;

if (count _selected == 0) exitWith {
    hint "No units selected - select the main group to regroup detached units";
};

diag_log format ["[OpsRoom] Regroup button: %1 units selected", count _selected];
{diag_log format ["[OpsRoom]   Selected: %1 (group: %2)", name _x, groupId (group _x)];} forEach _selected;

// Get the group of the first selected unit
private _selectedGroup = group (_selected select 0);
private _selectedGroupName = groupId _selectedGroup;

diag_log format ["[OpsRoom] Regroup button: Selected group is %1", _selectedGroupName];

// Check if this is actually a SUB-TEAM (not a main group)
private _isSubTeam = _selectedGroup getVariable ["OpsRoom_IsSubTeam", false];
if (_isSubTeam) exitWith {
    hint "You've selected a detached sub-team. Select the MAIN group to reattach.";
    diag_log format ["[OpsRoom] ERROR: User selected sub-team %1 instead of main group", _selectedGroupName];
};

// Find all units in the world that have THIS group as their parent
private _detachedUnits = allUnits select {
    private _parentGrp = _x getVariable ["OpsRoom_ParentGroup", grpNull];
    !isNull _parentGrp && _parentGrp == _selectedGroup
};

diag_log format ["[OpsRoom] Found %1 detached units for group %2", count _detachedUnits, _selectedGroupName];
{diag_log format ["[OpsRoom]   - %1 (in group: %2)", name _x, groupId (group _x)];} forEach _detachedUnits;

if (count _detachedUnits == 0) exitWith {
    hint "No detached units found for this group";
    diag_log format ["[OpsRoom] No detached units found for %1", _selectedGroupName];
};

// CRITICAL: Lock the group to prevent ANY auto-detach after manual reformation
// This lock persists until units are manually detached again
// Set on ALL units in both the main group AND detached units  
private _cooldownTime = time + 60;  // 60 second cooldown per-unit as backup
_selectedGroup setVariable ["OpsRoom_LockedFromAutoDetach", true];  // Permanent lock
{
    _x setVariable ["OpsRoom_ReattachCooldown", _cooldownTime];
} forEach (units _selectedGroup);

diag_log format ["[OpsRoom] Pre-reattach cooldown set on %1 units in main group", count (units _selectedGroup)];

// Also set on the detached units
{
    _x setVariable ["OpsRoom_ReattachCooldown", _cooldownTime];
    diag_log format ["[OpsRoom] Cooldown set on detached unit: %1", name _x];
} forEach _detachedUnits;

// Reattach all sub-teams to this main group
[_selectedGroup] call OpsRoom_fnc_autoReattachUnits;

hint format ["Reformed %1 - reattached %2 units", groupId _selectedGroup, count _detachedUnits];

diag_log format ["[OpsRoom] Manual regroup: %1 (%2 units reattached)", groupId _selectedGroup, count _detachedUnits];
