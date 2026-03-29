/*
    fn_aiDraw3D
    
    Draw3D loop for AI Commander visual indicators.
    
    Shows (gated by Command Intelligence level):
        - Red "RADIOMAN" label over units running to the radio (always visible — player can see this)
        - Red "TRANSMITTING..." label over units at the radio (always visible)
        - Orange group labels over active AI commander groups (requires 50%+ intel)
        - At 80%+ intel: shows manpower estimate and group destination
        - At 100% intel: shows exact manpower count
    
    Called from init.sqf:
        [] call OpsRoom_fnc_aiDraw3D;
*/

// Prevent duplicates
if (!isNil "OpsRoom_AI_Draw3DRunning" && {OpsRoom_AI_Draw3DRunning}) exitWith {};
OpsRoom_AI_Draw3DRunning = true;

addMissionEventHandler ["Draw3D", {
    
    // Camera position for distance checks (Zeus camera when open, else player)
    private _camPos = if (!isNull findDisplay 312) then { getPos curatorCamera } else { getPosATL player };
    
    // Get current Command Intelligence level
    private _intel = if (!isNil "OpsRoom_AI_IntelLevel") then { OpsRoom_AI_IntelLevel } else { 100 };
    
    // ========================================
    // RADIOMAN MARKERS (always visible — player witnesses this directly)
    // ========================================
    if (!isNil "OpsRoom_AI_ActiveRadiomen") then {
        {
            private _unit = _x select 0;
            private _locName = _x select 2;
            private _transmitting = if (count _x > 3) then { _x select 3 } else { false };
            
            if (alive _unit) then {
                private _pos = getPosATL _unit;
                
                // Only show within 5000m of camera
                if (_camPos distance _pos > 5000) then { continue };
                
                private _pos3D = _pos vectorAdd [0, 0, 2.5];
                
                if (_transmitting) then {
                    // Transmitting — pulsing red
                    private _alpha = 0.7 + (sin (time * 360) * 0.3);
                    drawIcon3D [
                        "\A3\ui_f\data\map\markers\military\warning_ca.paa",
                        [1, 0.2, 0.2, _alpha],
                        _pos3D,
                        1, 1, 0,
                        format ["TRANSMITTING... %1", _locName],
                        2, 0.04, "PuristaMedium", "center", true
                    ];
                } else {
                    // Running to radio
                    drawIcon3D [
                        "\A3\ui_f\data\map\markers\military\warning_ca.paa",
                        [1, 0.3, 0.1, 0.9],
                        _pos3D,
                        0.8, 0.8, 0,
                        format ["RADIOMAN — %1", _locName],
                        2, 0.035, "PuristaMedium", "center", true
                    ];
                };
            };
        } forEach OpsRoom_AI_ActiveRadiomen;
    };
    
    // ========================================
    // ACTIVE AI GROUP MARKERS (gated by intel level)
    // ========================================
    // Below 50%: no group markers at all
    // 50-79%: markers within 1500m, no destination shown
    // 80%+: markers within 3000m, full detail with destination
    if (!isNil "OpsRoom_AI_ActiveGroups" && _intel >= 50) then {
        
        private _markerRange = if (_intel >= 80) then { 3000 } else { 1500 };
        
        {
            private _grpData = _x;
            private _grp = _grpData get "group";
            private _leader = leader _grp;
            
            if (alive _leader) then {
                private _pos = getPosATL _leader;
                private _dist = _camPos distance _pos;
                
                if (_dist < _markerRange) then {
                    private _pos3D = _pos vectorAdd [0, 0, 3];
                    private _templateName = _grpData getOrDefault ["templateName", "Enemy Group"];
                    private _targetName = _grpData getOrDefault ["targetName", ""];
                    private _alive = {alive _x} count (units _grp);
                    
                    // Label detail depends on intel level
                    private _label = if (_intel >= 80) then {
                        format ["%1 (%2) -> %3", _templateName, _alive, _targetName]
                    } else {
                        format ["Enemy Group (%1)", _alive]
                    };
                    
                    drawIcon3D [
                        "\A3\ui_f\data\map\markers\military\arrow_ca.paa",
                        [0.9, 0.5, 0.1, 0.7],
                        _pos3D,
                        0.6, 0.6, 0,
                        _label,
                        2, 0.03, "PuristaMedium", "center", true
                    ];
                };
            };
        } forEach OpsRoom_AI_ActiveGroups;
    };
    
    // ========================================
    // ENEMY MANPOWER INDICATOR (80%+ intel, top of screen)
    // ========================================
    if (_intel >= 80 && !isNil "OpsRoom_AI_Manpower") then {
        private _mpText = if (_intel >= 100) then {
            format ["ENEMY MANPOWER: %1", OpsRoom_AI_Manpower]
        } else {
            // Estimate with +/- 20% fuzz
            private _fuzz = (OpsRoom_AI_Manpower * 0.2) max 5;
            private _low = (OpsRoom_AI_Manpower - _fuzz) max 0;
            private _high = OpsRoom_AI_Manpower + _fuzz;
            format ["EST. ENEMY MANPOWER: %1-%2", round _low, round _high]
        };
        
        // Draw as HUD text in top-right area using Draw3D at camera-relative position
        // This is handled by the intel GUI instead — just expose the value
        OpsRoom_AI_ManpowerDisplay = _mpText;
    } else {
        OpsRoom_AI_ManpowerDisplay = "";
    };
}];

diag_log "[OpsRoom] AI Draw3D initialized";
