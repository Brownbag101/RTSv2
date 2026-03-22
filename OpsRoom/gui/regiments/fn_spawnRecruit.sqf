/*
    Spawn Recruit
    
    Spawns recruited unit near player with WW2 British loadout and assigns to group.
    Consumes manpower and removes recruit from pool.
    
    Parameters:
        0: STRING - Group ID to assign recruit to
    
    Usage:
        ["group_1"] call OpsRoom_fnc_spawnRecruit;
*/

params [
    ["_groupId", "", [""]]
];

if (_groupId == "") exitWith {
    diag_log "[OpsRoom] ERROR: No group ID provided";
};

private _recruit = uiNamespace getVariable ["OpsRoom_PendingRecruit", createHashMap];
private _index = uiNamespace getVariable ["OpsRoom_PendingRecruitIndex", -1];

if (_index < 0) exitWith {
    diag_log "[OpsRoom] ERROR: No pending recruit";
};

// Get group data
private _groupData = OpsRoom_Groups get _groupId;
if (isNil "_groupData") exitWith {
    hint "Group not found!";
    diag_log format ["[OpsRoom] ERROR: Group not found: %1", _groupId];
};

// Spawn unit near player (disable automatic identity)
private _pos = player getPos [5 + random 10, random 360];
private _grp = createGroup west;
private _unit = _grp createUnit [_recruit get "unitType", _pos, [], 0, "NONE"];

// Disable automatic identity to preserve custom name
_unit setVariable ["BIS_fnc_setIdentity_done", true];
_unit setVariable ["ace_medical_medicClass", 0, true];

// Apply WW2 British loadout
removeAllWeapons _unit;
removeAllItems _unit;
removeAllAssignedItems _unit;
removeUniform _unit;
removeVest _unit;
removeBackpack _unit;
removeHeadgear _unit;
removeGoggles _unit;

// Add weapons
_unit addWeapon "fow_w_leeenfield_no4mk1";
_unit addPrimaryWeaponItem "fow_10Rnd_303";

// Add containers
_unit forceAddUniform "fow_u_uk_bd40_01_private";
_unit addVest "fow_v_uk_base_green";

// Add items to containers
_unit addItemToUniform "FirstAidKit";
for "_i" from 1 to 2 do {_unit addItemToUniform "fow_e_no36mk1";};
for "_i" from 1 to 4 do {_unit addItemToUniform "fow_10Rnd_303";};
_unit addItemToVest "fow_10Rnd_303";
for "_i" from 1 to 2 do {_unit addItemToVest "fow_30Rnd_303_bren";};
_unit addHeadgear "fow_h_uk_mk2";

// Add items
_unit linkItem "ItemMap";
_unit linkItem "ItemCompass";
_unit linkItem "ItemWatch";

// Set skills
private _skills = _recruit get "skills";
{
    _unit setSkill [_x, _skills get _x];
} forEach (keys _skills);

// Track spawn time
missionNamespace setVariable [format ["OpsRoom_Unit_%1_SpawnTime", _unit], time];

// Register for service record tracking (kills, injuries, medals)
[_unit] call OpsRoom_fnc_registerUnitService;

// Add to group
private _units = _groupData get "units";
if (isNil "_units") then {_units = []};

// Join existing group if units exist
if (count _units > 0) then {
    [_unit] joinSilent (group (_units select 0));
    deleteGroup _grp;
} else {
    // First unit in group
    _units pushBack _unit;
};

// Set name AFTER joining group (joinSilent can reset names)
private _recruitName = _recruit get "name";
diag_log format ["[OpsRoom] Setting unit name to: %1", _recruitName];
_unit setName _recruitName;
diag_log format ["[OpsRoom] Unit name after setName: %1", name _unit];

// Force name to persist after FOW identity system runs
[_unit, _recruitName] spawn {
    params ["_unit", "_name"];
    sleep 0.5;
    _unit setName _name;
    diag_log format ["[OpsRoom] Re-applied name after delay: %1", name _unit];
};

// Update group data
_units pushBack _unit;
_groupData set ["units", _units];

// Make visible to Zeus
private _curator = getAssignedCuratorLogic player;
if (!isNull _curator) then {
    _curator addCuratorEditableObjects [[_unit], true];
};

// Reduce manpower
OpsRoom_Resource_Manpower = OpsRoom_Resource_Manpower - 1;
[] call OpsRoom_fnc_updateResources;

// Remove from pool
OpsRoom_RecruitPool deleteAt _index;

// Cleanup
uiNamespace setVariable ["OpsRoom_PendingRecruit", nil];
uiNamespace setVariable ["OpsRoom_PendingRecruitIndex", nil];

// Feedback
private _groupName = _groupData get "name";
["ROUTINE", "RECRUIT ENLISTED", format ["%1 enlisted and assigned to %2", _recruit get "name", _groupName], nil, _unit] call OpsRoom_fnc_dispatch;
diag_log format ["[OpsRoom] Recruit spawned: %1 -> %2", _recruit get "name", _groupName];

// Return to recruitment dialog
closeDialog 0;
[] call OpsRoom_fnc_openRecruitment;
