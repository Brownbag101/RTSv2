/*
    Populate Training List
    
    Fills the training courses listbox with available courses.
    Checks prerequisites, courage gates, and research requirements.
    Locked courses are shown greyed out with lock reason.
    
    Usage:
        [] call OpsRoom_fnc_populateTrainingList;
*/

private _display = findDisplay 8006;
if (isNull _display) exitWith {};

private _listbox = _display displayCtrl 8610;
lbClear _listbox;

private _unit = uiNamespace getVariable ["OpsRoom_TrainingUnit", objNull];
if (isNull _unit) exitWith {};

private _unitQuals = _unit getVariable ["OpsRoom_Qualifications", []];
private _unitCourage = _unit skill "courage";

private _availableCount = 0;
private _totalCount = 0;

// Add all training courses
{
    // Support both old format (6 fields) and new format (9 fields)
    private _id = _x select 0;
    private _name = _x select 1;
    private _desc = _x select 2;
    private _duration = _x select 3;
    private _skills = _x select 4;
    private _quals = _x select 5;
    
    // New fields with defaults for backward compatibility
    private _prereqQuals = if (count _x > 6) then { _x select 6 } else { [] };
    private _minCourage = if (count _x > 7) then { _x select 7 } else { 0 };
    private _reqResearch = if (count _x > 8) then { _x select 8 } else { "" };
    
    _totalCount = _totalCount + 1;
    
    // Check if unit already has all qualifications this course grants
    private _alreadyQualified = false;
    if (count _quals > 0) then {
        _alreadyQualified = true;
        {
            // Check both qualification list and ability variables
            private _hasQual = false;
            if (_x in _unitQuals) then { _hasQual = true };
            
            // Also check ability variables
            private _abilityVar = switch (_x) do {
                case "suppressiveFire": { "OpsRoom_Ability_SuppressiveFire" };
                case "repair": { "OpsRoom_Ability_Repair" };
                case "heal": { "OpsRoom_Ability_Heal" };
                case "marksmanShot": { "OpsRoom_Ability_MarksmanShot" };
                case "timebomb": { "OpsRoom_Ability_Timebomb" };
                case "reconnoitre": { "OpsRoom_Ability_Reconnoitre" };
                case "infiltrate": { "OpsRoom_Ability_Infiltrate" };
                case "assassinate": { "OpsRoom_Ability_Assassinate" };
                case "airStrike": { "OpsRoom_Ability_AirStrike" };
                case "build": { "OpsRoom_Ability_Build" };
                default { "" };
            };
            if (_abilityVar != "") then {
                if (_unit getVariable [_abilityVar, false]) then { _hasQual = true };
            };
            
            if (!_hasQual) then { _alreadyQualified = false };
        } forEach _quals;
    };
    
    // Skip courses where unit already has everything
    if (_alreadyQualified) then { continue };
    
    // Check research requirement
    private _researchMet = true;
    if (_reqResearch != "") then {
        _researchMet = [_reqResearch] call OpsRoom_fnc_isResearched;
    };
    
    // Check prerequisite qualifications (OR logic - need ANY one)
    private _prereqMet = true;
    private _missingPrereq = "";
    if (count _prereqQuals > 0) then {
        _prereqMet = false;
        {
            if (_x in _unitQuals) exitWith { _prereqMet = true };
        } forEach _prereqQuals;
        if (!_prereqMet) then {
            _missingPrereq = _prereqQuals joinString " or ";
        };
    };
    
    // Check courage gate
    private _courageMet = true;
    if (_minCourage > 0) then {
        _courageMet = _unitCourage >= _minCourage;
    };
    
    private _isAvailable = _researchMet && _prereqMet && _courageMet;
    
    // Add to listbox
    private _displayName = if (_isAvailable) then {
        _name
    } else {
        // Build lock reason
        private _lockReason = if (!_researchMet) then {
            "[LOCKED - Research Required]"
        } else {
            if (!_prereqMet) then {
                format ["[LOCKED - Requires: %1]", _missingPrereq]
            } else {
                format ["[LOCKED - Courage %.1f required]", _minCourage]
            };
        };
        format ["%1  %2", _name, _lockReason];
    };
    
    private _index = _listbox lbAdd _displayName;
    _listbox lbSetData [_index, _id];
    
    if (_isAvailable) then {
        _listbox lbSetColor [_index, [0.85, 0.82, 0.74, 1.0]];
        _availableCount = _availableCount + 1;
    } else {
        _listbox lbSetColor [_index, [0.45, 0.45, 0.45, 1.0]];
    };
    
} forEach OpsRoom_TrainingCourses;

diag_log format ["[OpsRoom] Training list populated: %1/%2 courses available for %3", _availableCount, _totalCount, name _unit];
