/*
    Populate Wing Members
    
    Fills the wing detail grid with aircraft in the wing.
    Each square shows: aircraft icon, name, pilot, fuel/ammo/damage bars.
    
    Parameters:
        _wingId - Wing ID to populate
*/
params ["_wingId"];

private _display = findDisplay 11001;
if (isNull _display) exitWith {};

private _wingData = OpsRoom_AirWings get _wingId;
if (isNil "_wingData") exitWith {};

// Clean up dynamic controls
for "_idc" from 12200 to 15207 do {
    private _ctrl = _display displayCtrl _idc;
    if (!isNull _ctrl) then {
        ctrlDelete _ctrl;
    };
};

private _aircraftIds = _wingData get "aircraft";
private _squareIndex = 0;
private _maxSquares = 8;

{
    if (_squareIndex >= _maxSquares) exitWith {};
    
    private _hangarId = _x;
    private _entry = OpsRoom_Hangar get _hangarId;
    
    if (!isNil "_entry") then {
        private _displayName = _entry get "displayName";
        private _damage = _entry get "damage";
        private _fuel = _entry get "fuel";
        private _ammo = _entry get "ammo";
        private _pilotName = _entry get "pilotName";
        private _status = _entry get "status";
        private _sortieCount = _entry get "sortieCount";
        
        if (_pilotName == "") then { _pilotName = "No pilot" };
        
        private _idc = 11200 + _squareIndex;
        private _ctrl = _display displayCtrl _idc;
        
        if (!isNull _ctrl) then {
            _ctrl ctrlShow true;
            
            // Aircraft icon (top)
            private _iconCtrl = _display ctrlCreate ["RscPicture", _idc + 1000];
            _iconCtrl ctrlSetPosition [
                ((ctrlPosition _ctrl) select 0) + 0.03 * safezoneW,
                ((ctrlPosition _ctrl) select 1) + 0.005 * safezoneH,
                0.05 * safezoneW,
                0.05 * safezoneH
            ];
            _iconCtrl ctrlSetText "\A3\ui_f\data\map\vehicleicons\iconplane_ca.paa";
            _iconCtrl ctrlCommit 0;
            
            // Aircraft name
            private _nameCtrl = _display ctrlCreate ["RscStructuredText", _idc + 2000];
            _nameCtrl ctrlSetPosition [
                (ctrlPosition _ctrl) select 0,
                ((ctrlPosition _ctrl) select 1) + 0.055 * safezoneH,
                (ctrlPosition _ctrl) select 2,
                0.025 * safezoneH
            ];
            _nameCtrl ctrlSetStructuredText parseText format [
                "<t align='center' size='0.75'>%1</t>", _displayName
            ];
            _nameCtrl ctrlCommit 0;
            
            // Pilot name
            private _pilotCtrl = _display ctrlCreate ["RscStructuredText", _idc + 2500];
            _pilotCtrl ctrlSetPosition [
                (ctrlPosition _ctrl) select 0,
                ((ctrlPosition _ctrl) select 1) + 0.08 * safezoneH,
                (ctrlPosition _ctrl) select 2,
                0.02 * safezoneH
            ];
            // Show pilot + crew status
            private _crewRequired = _entry getOrDefault ["crewRequired", 0];
            private _assignedCrew = _entry getOrDefault ["assignedCrew", []];
            private _crewText = if (_crewRequired > 0) then {
                private _crewColor = if (count _assignedCrew >= _crewRequired) then {"#88CC88"} else {"#CC8844"};
                format ["  <t color='%1'>Crew: %2/%3</t>", _crewColor, count _assignedCrew, _crewRequired]
            } else {
                ""
            };
            
            _pilotCtrl ctrlSetStructuredText parseText format [
                "<t align='center' size='0.65' color='#AAAAAA'>%1%2</t>", _pilotName, _crewText
            ];
            _pilotCtrl ctrlCommit 0;
            
            // Status bars (fuel/ammo/damage) as text
            private _fuelColor = if (_fuel > 0.5) then {"#88CC88"} else {if (_fuel > 0.2) then {"#CCCC44"} else {"#CC4444"}};
            private _ammoColor = if (_ammo > 0.5) then {"#88CC88"} else {if (_ammo > 0.2) then {"#CCCC44"} else {"#CC4444"}};
            private _dmgColor = if (_damage < 0.3) then {"#88CC88"} else {if (_damage < 0.7) then {"#CCCC44"} else {"#CC4444"}};
            
            private _barsCtrl = _display ctrlCreate ["RscStructuredText", _idc + 3000];
            _barsCtrl ctrlSetPosition [
                (ctrlPosition _ctrl) select 0,
                ((ctrlPosition _ctrl) select 1) + 0.105 * safezoneH,
                (ctrlPosition _ctrl) select 2,
                0.06 * safezoneH
            ];
            private _flightHrs = _entry getOrDefault ["flightHours", 0];
            private _flightHrsText = if (_flightHrs < 1) then {
                format ["%1m", round (_flightHrs * 60)]
            } else {
                format ["%1h", round _flightHrs]
            };
            
            // Build weapon loadout text from live vehicle if airborne
            private _weaponText = "";
            if (_status == "AIRBORNE") then {
                // Find the live vehicle
                private _spawnedObjs = (_wingData get "spawnedObjects");
                private _liveVeh = objNull;
                { if (_x isKindOf "Air" && {(_x getVariable ["OpsRoom_HangarId", ""]) == _hangarId}) exitWith { _liveVeh = _x } } forEach _spawnedObjs;
                
                if (!isNull _liveVeh && alive _liveVeh) then {
                    private _wepLines = [];
                    {
                        _x params ["_mag", "_turret", "_count"];
                        if (_count > 0) then {
                            private _magName = getText (configFile >> "CfgMagazines" >> _mag >> "displayName");
                            if (_magName == "") then { _magName = _mag };
                            _wepLines pushBackUnique format ["%1x %2", _count, _magName];
                        };
                    } forEach (magazinesAllTurrets _liveVeh);
                    _weaponText = _wepLines joinString ", ";
                    // Real fuel from live vehicle
                    _fuel = fuel _liveVeh;
                    _damage = damage _liveVeh;
                };
            };
            
            if (_weaponText == "") then {
                // For hangared aircraft, read default loadout from vehicle config (deep turret scan)
                private _className = _entry get "className";
                _weaponText = [_className] call OpsRoom_fnc_getAircraftLoadout;
                if (_weaponText == "") then {
                    _weaponText = "No weapons";
                };
            };
            
            private _fuelLitres = round (_fuel * 100);
            
            _barsCtrl ctrlSetStructuredText parseText format [
                "<t size='0.55'>Fuel:<t color='%1'>%2L</t>  Dmg:<t color='%3'>%4%%</t><br/>%5<br/>Sorties: %6  Hrs: %7</t>",
                _fuelColor, _fuelLitres,
                _dmgColor, round (_damage * 100),
                _weaponText,
                _sortieCount, _flightHrsText
            ];
            _barsCtrl ctrlCommit 0;
            
            // Click button
            private _btnCtrl = _display ctrlCreate ["RscButton", _idc + 4000];
            _btnCtrl ctrlSetPosition [
                (ctrlPosition _ctrl) select 0,
                (ctrlPosition _ctrl) select 1,
                (ctrlPosition _ctrl) select 2,
                (ctrlPosition _ctrl) select 3
            ];
            _btnCtrl ctrlSetText "";
            _btnCtrl ctrlSetTooltip format ["%1 - %2", _displayName, _pilotName];
            _btnCtrl ctrlCommit 0;
            
            _btnCtrl setVariable ["hangarId", _hangarId];
            _btnCtrl setVariable ["wingId", _wingId];
            
            _btnCtrl ctrlAddEventHandler ["ButtonClick", {
                params ["_ctrl"];
                private _hangarId = _ctrl getVariable ["hangarId", ""];
                private _wId = _ctrl getVariable ["wingId", ""];
                private _entry2 = OpsRoom_Hangar get _hangarId;
                if (!isNil "_entry2" && {(_entry2 get "status") == "AIRBORNE"}) then {
                    // Airborne — show info, don't spawn preview or assign
                    private _pName = _entry2 getOrDefault ["pilotName", "Unknown"];
                    private _dName = _entry2 get "displayName";
                    private _sorties = _entry2 get "sortieCount";
                    hint parseText format [
                        "<t size='1.1' font='PuristaBold'>%1</t><br/><br/>" +
                        "<t>Pilot: %2</t><br/>" +
                        "<t>Status: AIRBORNE</t><br/>" +
                        "<t>Sorties: %3</t>",
                        _dName, _pName, _sorties
                    ];
                } else {
                    // Hangared — check what needs assigning
                    private _hasPilot = !isNull (_entry2 getOrDefault ["assignedPilot", objNull]);
                    private _crewNeeded = _entry2 getOrDefault ["crewRequired", 0];
                    private _crewAssigned = count (_entry2 getOrDefault ["assignedCrew", []]);
                    
                    if (!_hasPilot) then {
                        // Need pilot first
                        closeDialog 0;
                        [_hangarId, "wing", _wId] spawn OpsRoom_fnc_showAssignPilot;
                    } else {
                        if (_crewNeeded > 0 && {_crewAssigned < _crewNeeded}) then {
                            // Pilot assigned but crew incomplete
                            closeDialog 0;
                            [_hangarId, _wId] spawn OpsRoom_fnc_showAssignCrew;
                        } else {
                            // Fully crewed — show preview
                            [_hangarId] call OpsRoom_fnc_spawnPreviewAircraft;
                        };
                    };
                };
            }];
            _btnCtrl ctrlSetTooltip format ["%1 - %2 | Click to assign pilot", _displayName, _pilotName];
            
            _btnCtrl ctrlAddEventHandler ["MouseEnter", {
                params ["_ctrl"];
                private _bgCtrl = (ctrlParent _ctrl) displayCtrl ((ctrlIDC _ctrl) - 4000);
                _bgCtrl ctrlSetBackgroundColor [0.3, 0.35, 0.25, 1];
            }];
            _btnCtrl ctrlAddEventHandler ["MouseExit", {
                params ["_ctrl"];
                private _bgCtrl = (ctrlParent _ctrl) displayCtrl ((ctrlIDC _ctrl) - 4000);
                _bgCtrl ctrlSetBackgroundColor [0.26, 0.30, 0.21, 1];
            }];
        };
    };
    
    _squareIndex = _squareIndex + 1;
} forEach _aircraftIds;

// Add [+] assign slot if wing not full
if (_squareIndex < _maxSquares) then {
    private _idc = 11200 + _squareIndex;
    private _ctrl = _display displayCtrl _idc;
    
    if (!isNull _ctrl) then {
        _ctrl ctrlShow true;
        
        private _plusCtrl = _display ctrlCreate ["RscStructuredText", _idc + 2000];
        _plusCtrl ctrlSetPosition [
            (ctrlPosition _ctrl) select 0,
            (ctrlPosition _ctrl) select 1,
            (ctrlPosition _ctrl) select 2,
            (ctrlPosition _ctrl) select 3
        ];
        _plusCtrl ctrlSetStructuredText parseText "<t align='center' size='3.0' valign='middle'>+</t><br/><t align='center' size='0.7'>Assign Aircraft</t>";
        _plusCtrl ctrlCommit 0;
        
        private _btnCtrl = _display ctrlCreate ["RscButton", _idc + 4000];
        _btnCtrl ctrlSetPosition [
            (ctrlPosition _ctrl) select 0,
            (ctrlPosition _ctrl) select 1,
            (ctrlPosition _ctrl) select 2,
            (ctrlPosition _ctrl) select 3
        ];
        _btnCtrl ctrlSetText "";
        _btnCtrl ctrlSetTooltip "Assign aircraft from hangar";
        _btnCtrl ctrlCommit 0;
        
        _btnCtrl setVariable ["wingId", _wingId];
        _btnCtrl ctrlAddEventHandler ["ButtonClick", {
            params ["_ctrl"];
            private _wId = _ctrl getVariable ["wingId", ""];
            closeDialog 0;
            [_wId] spawn OpsRoom_fnc_showAssignAircraft;
        }];
        
        _btnCtrl ctrlAddEventHandler ["MouseEnter", {
            params ["_ctrl"];
            private _bgCtrl = (ctrlParent _ctrl) displayCtrl ((ctrlIDC _ctrl) - 4000);
            _bgCtrl ctrlSetBackgroundColor [0.2, 0.4, 0.2, 1];
        }];
        _btnCtrl ctrlAddEventHandler ["MouseExit", {
            params ["_ctrl"];
            private _bgCtrl = (ctrlParent _ctrl) displayCtrl ((ctrlIDC _ctrl) - 4000);
            _bgCtrl ctrlSetBackgroundColor [0.26, 0.30, 0.21, 1];
        }];
    };
    
    _squareIndex = _squareIndex + 1;
};

// Hide remaining squares
for "_i" from _squareIndex to (_maxSquares - 1) do {
    private _idc = 11200 + _i;
    private _ctrl = _display displayCtrl _idc;
    if (!isNull _ctrl) then {
        _ctrl ctrlShow false;
    };
};

diag_log format ["[OpsRoom] Populated wing members: %1 aircraft", count _aircraftIds];
