/*
    Populate Storehouse Unit Inventory
    
    Shows the selected unit's inventory in the centre panel as a listbox
    so items can be selected for transfer to the storehouse.
    
    Items inside containers (vest, uniform, backpack) are shown and
    can be transferred — the transfer function handles removing from
    the correct container.
    
    Usage:
        [] call OpsRoom_fnc_populateStorehouseUnitInv;
*/

private _display = findDisplay 11007;
if (isNull _display) exitWith {};

private _unit = uiNamespace getVariable ["OpsRoom_StorehouseSelectedUnit", objNull];
if (isNull _unit) exitWith {};

// Update header
private _headerCtrl = _display displayCtrl 11721;
_headerCtrl ctrlSetText format ["%1 — %2", name _unit, rank _unit];

// Get unit's inventory using existing function
private _sections = [_unit] call OpsRoom_fnc_getContainerItems;

// Delete existing dynamic listbox if present
private _dynList = _display displayCtrl 11722;
if (!isNull _dynList) then { ctrlDelete _dynList };

// Hide the structured text
private _invCtrl = _display displayCtrl 11720;
_invCtrl ctrlSetStructuredText parseText "";

// Create dynamic listbox
_dynList = _display ctrlCreate ["RscListbox", 11722];
_dynList ctrlSetPosition [
    0.305 * safezoneW + safezoneX,
    0.17 * safezoneH + safezoneY,
    0.27 * safezoneW,
    0.52 * safezoneH
];
_dynList ctrlSetBackgroundColor [0, 0, 0, 0];
_dynList ctrlSetFont "PuristaMedium";
_dynList ctrlSetFontHeight 0.028;
_dynList ctrlCommit 0;

// Build the listbox and track transferable items
// Each entry in _listItemMap: [] = not transferable, or [className, qty, itemType, parentContainer]
// parentContainer: "" = on unit directly, "uniform" / "vest" / "backpack" = inside that container
private _listItemMap = [];

// Track which section we're currently in to determine parent container
private _currentContainer = "";

{
    _x params ["_sectionName", "_sectionItems"];
    
    // Determine parent container from section name
    _currentContainer = switch (toUpper _sectionName) do {
        case "UNIFORM": { "uniform" };
        case "VEST": { "vest" };
        case "BACKPACK": { "backpack" };
        default { "" };
    };
    
    // Section header
    private _idx = _dynList lbAdd format ["── %1 ──", _sectionName];
    _dynList lbSetColor [_idx, [0.95, 0.85, 0.40, 1.0]];
    _listItemMap pushBack [];
    
    {
        _x params ["_displayText", "_className", "_qty", "_itemType"];
        
        private _isIndented = (_displayText select [0, 2]) == "  ";
        
        // Non-transferable: attachments and loaded magazines
        private _isTransferable = !(_itemType in ["attachment", "loaded_mag"]);
        
        private _idx = _dynList lbAdd format ["  %1", _displayText];
        
        if (_isTransferable) then {
            _dynList lbSetColor [_idx, [0.85, 0.82, 0.74, 1.0]];
            
            // For items inside containers, mark the parent
            // The first item in UNIFORM/VEST/BACKPACK section is the container itself
            // Sub-items (indented) are contents
            private _parent = "";
            if (_isIndented) then {
                _parent = _currentContainer;
            } else {
                // This IS the container or a top-level item
                if (_itemType in ["uniform", "vest", "backpack"]) then {
                    _parent = "";  // Removing the container itself from the unit
                } else {
                    _parent = _currentContainer;  // Item in a container section
                };
            };
            
            _listItemMap pushBack [_className, _qty, _itemType, _parent];
        } else {
            _dynList lbSetColor [_idx, [0.45, 0.43, 0.38, 0.7]];
            _listItemMap pushBack [];
        };
    } forEach _sectionItems;
} forEach _sections;

if (count _sections == 0) then {
    private _idx = _dynList lbAdd "No equipment";
    _dynList lbSetColor [_idx, [0.5, 0.5, 0.5, 0.7]];
    _listItemMap pushBack [];
};

uiNamespace setVariable ["OpsRoom_StorehouseUnitListMap", _listItemMap];
