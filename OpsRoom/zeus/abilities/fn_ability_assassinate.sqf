/*
    OpsRoom_fnc_ability_assassinate
    
    SOE Assassination. Shows known enemies within 150m of selected agent.
    Player picks a target from menu. Agent moves to target and performs silent kill.
    Uses Aimed Shot-style dynamic menu pattern.
*/

private _selected = curatorSelected select 0;

if (typeName _selected != "ARRAY") exitWith {};
if (count _selected == 0) exitWith { hint "No units selected"; };

private _capable = _selected select {
    _x getVariable ["OpsRoom_Ability_Assassinate", false]
};

if (count _capable == 0) exitWith { hint "No SOE agents selected"; };

private _agent = _capable select 0;
OpsRoom_Assassinate_Agent = _agent;

// Check known enemies within 150m
if (isNil "OpsRoom_KnownEnemies") then {
    OpsRoom_KnownEnemies = [];
};

private _agentPos = getPos _agent;
private _nearbyTargets = [];

{
    private _enemy = _x select 0;
    if (!isNull _enemy && {alive _enemy}) then {
        private _dist = _agentPos distance _enemy;
        if (_dist <= 150) then {
            _nearbyTargets pushBack [_enemy, round _dist];
        };
    };
} forEach OpsRoom_KnownEnemies;

if (count _nearbyTargets == 0) exitWith {
    hint format ["%1 has no known enemies within 150m\nUse Reconnoitre first to identify targets", name _agent];
};

// Sort by distance (closest first)
_nearbyTargets sort true;

// Store targets globally
OpsRoom_Assassinate_Targets = _nearbyTargets;

// Draw3D markers on potential targets
missionNamespace setVariable ["OpsRoom_Assassinate_Markers_Active", true];
missionNamespace setVariable ["OpsRoom_Assassinate_Markers_Data", _nearbyTargets];

OpsRoom_Assassinate_DrawHandler = addMissionEventHandler ["Draw3D", {
    if !(missionNamespace getVariable ["OpsRoom_Assassinate_Markers_Active", false]) exitWith {};
    
    private _data = missionNamespace getVariable ["OpsRoom_Assassinate_Markers_Data", []];
    
    {
        _x params ["_enemy", "_dist"];
        
        if (!isNull _enemy && {alive _enemy}) then {
            private _pos = getPos _enemy;
            
            // Red skull marker
            drawIcon3D [
                "\A3\ui_f\data\IGUI\Cfg\SimpleTasks\types\kill_ca.paa",
                [1, 0, 0, 0.8],
                [_pos select 0, _pos select 1, (_pos select 2) + 2.5],
                1.5, 1.5, 0, "", 2, 0.05, "PuristaBold", "center"
            ];
            
            // Target label with distance
            drawIcon3D ["", [1, 0, 0, 1],
                [_pos select 0, _pos select 1, (_pos select 2) + 4],
                0, 0, 0,
                format ["TARGET %1 - %2m", _forEachIndex + 1, round ((getPos OpsRoom_Assassinate_Agent) distance _enemy)],
                2, 0.04, "PuristaBold", "center"
            ];
        };
    } forEach _data;
}];

// Find button for menu placement
private _display = findDisplay 312;
if (isNull _display) exitWith {
    [] call OpsRoom_fnc_cancelAssassinateTargeting;
};

private _myButton = controlNull;
for "_i" from 9350 to 9389 step 2 do {
    private _btn = _display displayCtrl (_i + 1);
    if (!isNull _btn) then {
        if ((_btn getVariable ["abilityID", ""]) == "assassinate") exitWith {
            _myButton = _btn;
        };
    };
};

if (isNull _myButton) exitWith {
    [] call OpsRoom_fnc_cancelAssassinateTargeting;
    hint "Button not found";
};

private _btnPos = ctrlPosition _myButton;
_btnPos params ["_baseX", "_baseY", "_btnW", "_btnH"];

// Build dynamic menu — one item per target
private _menuItems = [];
{
    _x params ["_enemy", "_dist"];
    private _idx = _forEachIndex;
    
    private _label = format ["TARGET %1 (%2m)", _idx + 1, _dist];
    
    private _actionCode = compile format [
        "OpsRoom_Assassinate_SelectedIndex = %1; call OpsRoom_fnc_executeAssassinate;",
        _idx
    ];
    
    _menuItems pushBack [_label, "\A3\ui_f\data\IGUI\Cfg\SimpleTasks\types\kill_ca.paa", _actionCode];
} forEach _nearbyTargets;

[_display, _myButton, _menuItems, _baseX, _baseY, _btnW] call OpsRoom_fnc_createButtonMenu;

// ESC handler to cancel
OpsRoom_Assassinate_ESCHandler = _display displayAddEventHandler ["KeyDown", {
    params ["_display", "_key"];
    if (_key == 1) then {
        [] call OpsRoom_fnc_cancelAssassinateTargeting;
        true
    } else { false };
}];

// Mouse handler — cancel if clicking outside menu
OpsRoom_Assassinate_MouseHandler = _display displayAddEventHandler ["MouseButtonDown", {
    params ["_display", "_button", "_xPos", "_yPos"];
    if (_button == 0) then {
        private _clickedMenu = false;
        for "_i" from 9400 to 9420 do {
            private _ctrl = _display displayCtrl _i;
            if (!isNull _ctrl && {ctrlShown _ctrl}) then {
                private _ctrlPos = ctrlPosition _ctrl;
                _ctrlPos params ["_x", "_y", "_w", "_h"];
                if (_xPos >= _x && {_xPos <= (_x + _w)} && {_yPos >= _y} && {_yPos <= (_y + _h)}) then {
                    _clickedMenu = true;
                };
            };
        };
        
        if (!_clickedMenu) then {
            [] call OpsRoom_fnc_cancelAssassinateTargeting;
        };
    };
    false
}];

hint format ["%1 targets within range. Select target to assassinate.", count _nearbyTargets];
