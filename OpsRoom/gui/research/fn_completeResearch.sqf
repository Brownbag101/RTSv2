/*
    Complete Research
    
    Called when a research timer finishes.
    Marks item as researched, clears active research slot.
    
    Parameters:
        0: STRING - Item ID that was researched
    
    Usage:
        ["lee_enfield"] call OpsRoom_fnc_completeResearch;
*/

params [["_itemId", "", [""]]];

if (_itemId == "") exitWith {};

private _itemData = OpsRoom_EquipmentDB get _itemId;
if (isNil "_itemData") exitWith {};

private _name = _itemData get "displayName";

// Mark as researched
if (isNil "OpsRoom_ResearchCompleted") then {
    OpsRoom_ResearchCompleted = [];
};
OpsRoom_ResearchCompleted pushBackUnique _itemId;

// Clear active research
missionNamespace setVariable ["OpsRoom_ResearchInProgress", []];

// Notify player
["PRIORITY", "RESEARCH COMPLETE", format ["%1 is now available for production!", _name]] call OpsRoom_fnc_dispatch;

diag_log format ["[OpsRoom] Research completed: %1", _itemId];
