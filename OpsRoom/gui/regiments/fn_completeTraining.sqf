/*
    Complete Training
    
    Finishes training for a unit - unhides, applies skill bonuses, returns to formation.
    
    Parameters:
        0: OBJECT - Unit completing training
        1: ARRAY - Skill bonuses to apply
        2: ARRAY - Qualifications to grant
    
    Usage:
        [_unit, _skills, _quals] call OpsRoom_fnc_completeTraining;
*/

params [
    ["_unit", objNull, [objNull]],
    ["_skills", [], [[]]],
    ["_quals", [], [[]]]
];

if (isNull _unit) exitWith {};

// Apply skill bonuses
{
    _x params ["_skillName", "_bonus"];
    private _currentSkill = _unit skill _skillName;
    private _newSkill = (_currentSkill + _bonus) min 1.0;  // Cap at 1.0
    _unit setSkill [_skillName, _newSkill];
    
    diag_log format ["[OpsRoom] Applied skill: %1 %2 -> %3", _skillName, _currentSkill, _newSkill];
} forEach _skills;

// Apply qualifications
{
    switch (_x) do {
        case "medic": {
            _unit setVariable ["ace_medical_medicClass", 1, true];
            diag_log format ["[OpsRoom] Qualified as medic: %1", name _unit];
        };
        case "engineer": {
            _unit setVariable ["ace_isEngineer", 1, true];
            diag_log format ["[OpsRoom] Qualified as engineer: %1", name _unit];
        };
        case "suppressiveFire": {
            _unit setVariable ["OpsRoom_Ability_SuppressiveFire", true, true];
            diag_log format ["[OpsRoom] Granted Suppress ability: %1", name _unit];
        };
        case "repair": {
            _unit setVariable ["OpsRoom_Ability_Repair", true, true];
            diag_log format ["[OpsRoom] Granted Repair ability: %1", name _unit];
        };
        case "heal": {
            _unit setVariable ["OpsRoom_Ability_Heal", true, true];
            diag_log format ["[OpsRoom] Granted Heal ability: %1", name _unit];
        };
        case "marksmanShot": {
            _unit setVariable ["OpsRoom_Ability_MarksmanShot", true, true];
            diag_log format ["[OpsRoom] Granted Aimed Shot ability: %1", name _unit];
        };
        case "timebomb": {
            _unit setVariable ["OpsRoom_Ability_Timebomb", true, true];
            diag_log format ["[OpsRoom] Granted Timebomb ability: %1", name _unit];
        };
        case "reconnoitre": {
            _unit setVariable ["OpsRoom_Ability_Reconnoitre", true, true];
            diag_log format ["[OpsRoom] Granted Reconnoitre ability: %1", name _unit];
        };
        case "infiltrate": {
            _unit setVariable ["OpsRoom_Ability_Infiltrate", true, true];
            diag_log format ["[OpsRoom] Granted Infiltrate ability: %1", name _unit];
        };
        case "assassinate": {
            _unit setVariable ["OpsRoom_Ability_Assassinate", true, true];
            diag_log format ["[OpsRoom] Granted Assassinate ability: %1", name _unit];
        };
        case "paratrooper": {
            _unit setVariable ["OpsRoom_Ability_Paratrooper", true, true];
            
            // Store qualification
            private _quals2 = _unit getVariable ["OpsRoom_Qualifications", []];
            if !("paratrooper" in _quals2) then { _quals2 pushBack "paratrooper" };
            _unit setVariable ["OpsRoom_Qualifications", _quals2, true];
            
            // Apply para uniform and kit after training completes
            [_unit] spawn {
                params ["_u"];
                sleep 1;
                
                // Store name before uniform change (FOW overwrites names)
                private _savedName = name _u;
                
                // Apply Paratrooper loadout
                removeAllWeapons _u;
                removeAllItems _u;
                removeAllAssignedItems _u;
                removeUniform _u;
                removeVest _u;
                removeBackpack _u;
                removeHeadgear _u;
                removeGoggles _u;
                
                _u addWeapon "fow_w_leeenfield_no4mk1";
                _u addPrimaryWeaponItem "fow_10Rnd_303";
                
                _u forceAddUniform "UK_Uniform_PARA_6thAB_Pte";
                _u addVest "fow_v_uk_para_base_green";
                _u addBackpack "fow_b_uk_p37_blanco";
                
                _u addItemToUniform "FirstAidKit";
                for "_i" from 1 to 4 do {_u addItemToUniform "fow_10Rnd_303";};
                for "_i" from 1 to 2 do {_u addItemToUniform "fow_e_no36mk1";};
                for "_i" from 1 to 2 do {_u addItemToUniform "SmokeShell";};
                
                _u addHeadgear "fow_h_uk_mk2_para_camo";
                
                _u linkItem "ItemMap";
                _u linkItem "ItemCompass";
                _u linkItem "ItemWatch";
                _u linkItem "ItemRadio";
                
                // Re-apply name after delay (FOW overwrites)
                sleep 0.5;
                _u setName _savedName;
                
                ["PRIORITY", format ["%1 qualified as paratrooper", _savedName],
                    format ["%1 has completed airborne training and is now jump-qualified.", _savedName]
                ] call OpsRoom_fnc_dispatch;
                
                diag_log format ["[OpsRoom] Paratrooper %1 kitted out", _savedName];
            };
            
            diag_log format ["[OpsRoom] Granted Paratrooper qualification: %1", name _unit];
        };
        case "airStrike": {
            _unit setVariable ["OpsRoom_Ability_AirStrike", true, true];
            diag_log format ["[OpsRoom] Granted Air Strike ability: %1", name _unit];
        };
        case "pilot": {
            // Store pilot qualification on unit
            private _quals2 = _unit getVariable ["OpsRoom_Qualifications", []];
            if !("pilot" in _quals2) then { _quals2 pushBack "pilot" };
            _unit setVariable ["OpsRoom_Qualifications", _quals2, true];
            
            // Mark as pilot so auto-detach/reattach ignores them
            _unit setVariable ["OpsRoom_IsPilot", true, true];
            
            // Spawn the pilot transfer so it runs AFTER this function completes
            // (avoids the "return to original group" block overwriting our changes)
            [_unit] spawn {
                params ["_u"];
                sleep 1;  // Wait for completeTraining to finish
                
                // Pilot uniform and parachute
                _u forceAddUniform "sab_fl_pilotuniform_green";
                _u addBackpack "B_Parachute";
                
                // Remove from ALL OpsRoom regiment group tracking
                {
                    private _grpData = _y;
                    private _grpUnits = _grpData get "units";
                    if (_u in _grpUnits) then {
                        _grpUnits = _grpUnits - [_u];
                        _grpData set ["units", _grpUnits];
                        diag_log format ["[OpsRoom] Removed %1 from regiment group %2 for pilot duty", name _u, _x];
                    };
                } forEach OpsRoom_Groups;
                
                // Leave current ARMA group entirely
                private _pilotGrp = createGroup [independent, true];
                [_u] joinSilent _pilotGrp;
                
                // Clear any auto-detach variables
                _u setVariable ["OpsRoom_ParentGroup", nil];
                _u setVariable ["OpsRoom_ParentGroupName", nil];
                _u setVariable ["OpsRoom_Training_OriginalGroup", nil];
                
                // Teleport to pilot ready point (or hangar fallback)
                private _destPos = if (markerType "OpsRoom_pilot_ready" != "") then {
                    getMarkerPos "OpsRoom_pilot_ready"
                } else {
                    if (markerType "OpsRoom_hangar" != "") then {
                        getMarkerPos "OpsRoom_hangar"
                    } else {
                        getPos _u
                    };
                };
                // Walk to ready point (not teleport)
                _u doMove _destPos;
                
                // Add to pilot pool for tracking
                if (isNil "OpsRoom_PilotPool") then { OpsRoom_PilotPool = [] };
                OpsRoom_PilotPool pushBack _u;
                
                // Re-add to Zeus
                private _curator = getAssignedCuratorLogic player;
                if (!isNull _curator) then {
                    _curator addCuratorEditableObjects [[_u], true];
                };
                
                ["PRIORITY", format ["%1 qualified as pilot", name _u],
                    format ["%1 has completed RAF pilot training and is posted to the airfield.", name _u]
                ] call OpsRoom_fnc_dispatch;
                
                diag_log format ["[OpsRoom] Pilot %1 transferred to airfield", name _u];
            };
            
            diag_log format ["[OpsRoom] Granted Pilot qualification: %1", name _unit];
        };
        case "airCrew": {
            // Store air crew qualification on unit
            private _quals2 = _unit getVariable ["OpsRoom_Qualifications", []];
            if !("airCrew" in _quals2) then { _quals2 pushBack "airCrew" };
            _unit setVariable ["OpsRoom_Qualifications", _quals2, true];
            
            // Mark as aircrew so auto-detach/reattach ignores them
            _unit setVariable ["OpsRoom_IsPilot", true, true];  // Same flag — they're all airfield personnel
            
            // Spawn the crew transfer so it runs AFTER this function completes
            [_unit] spawn {
                params ["_u"];
                sleep 1;
                
                // Aircrew uniform and parachute
                _u forceAddUniform "sab_fl_pilotuniform_green";
                _u addBackpack "B_Parachute";
                
                // Remove from ALL OpsRoom regiment group tracking
                {
                    private _grpData = _y;
                    private _grpUnits = _grpData get "units";
                    if (_u in _grpUnits) then {
                        _grpUnits = _grpUnits - [_u];
                        _grpData set ["units", _grpUnits];
                    };
                } forEach OpsRoom_Groups;
                
                // Leave current ARMA group
                private _crewGrp = createGroup [independent, true];
                [_u] joinSilent _crewGrp;
                
                // Clear auto-detach variables
                _u setVariable ["OpsRoom_ParentGroup", nil];
                _u setVariable ["OpsRoom_ParentGroupName", nil];
                _u setVariable ["OpsRoom_Training_OriginalGroup", nil];
                
                // WALK to crew ready point (not teleport)
                private _destPos = if (markerType "OpsRoom_pilot_ready" != "") then {
                    getMarkerPos "OpsRoom_pilot_ready"
                } else {
                    if (markerType "OpsRoom_hangar" != "") then {
                        getMarkerPos "OpsRoom_hangar"
                    } else {
                        getPos _u
                    };
                };
                _u doMove _destPos;
                
                // Add to crew pool
                if (isNil "OpsRoom_CrewPool") then { OpsRoom_CrewPool = [] };
                OpsRoom_CrewPool pushBack _u;
                
                // Re-add to Zeus
                private _curator = getAssignedCuratorLogic player;
                if (!isNull _curator) then {
                    _curator addCuratorEditableObjects [[_u], true];
                };
                
                ["PRIORITY", format ["%1 qualified as air gunner", name _u],
                    format ["%1 has completed aerial gunnery training and is posted to the airfield.", name _u]
                ] call OpsRoom_fnc_dispatch;
                
                diag_log format ["[OpsRoom] Air Gunner %1 transferred to airfield", name _u];
            };
            
            diag_log format ["[OpsRoom] Granted AirCrew qualification: %1", name _unit];
        };
    };
} forEach _quals;

// Restore visibility and invulnerability
_unit allowDamage true;
_unit hideObjectGlobal false;
_unit enableSimulationGlobal true;

// Return to original group — UNLESS pilot/aircrew (they leave to go to airfield)
private _isAirfieldPersonnel = ("pilot" in _quals) || ("airCrew" in _quals);
if (!_isAirfieldPersonnel) then {
    private _originalGroup = _unit getVariable ["OpsRoom_Training_OriginalGroup", grpNull];
    if (!isNull _originalGroup) then {
        [_unit] joinSilent _originalGroup;
    };
};

// Make visible to Zeus again
private _curator = getAssignedCuratorLogic player;
if (!isNull _curator) then {
    _curator addCuratorEditableObjects [[_unit], true];
};

// Cleanup variables
_unit setVariable ["OpsRoom_Training_OriginalPos", nil];
_unit setVariable ["OpsRoom_Training_OriginalGroup", nil];

// Feedback
["ROUTINE", "TRAINING COMPLETE", format ["%1 has completed training and returned to duty", name _unit], nil, _unit] call OpsRoom_fnc_dispatch;
diag_log format ["[OpsRoom] Training completed: %1", name _unit];
