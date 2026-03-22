/*
    Operations Room - Create Speed Controls
    
    Creates game speed control buttons below date/time display.
    Allows player to pause, slow down, or speed up time.
*/

private _zeusDisplay = findDisplay 312;
if (isNull _zeusDisplay) exitWith {};

// Background for speed controls
private _bg = _zeusDisplay ctrlCreate ["RscText", 9330];
_bg ctrlSetPosition [
    safezoneX + 0.01,
    safezoneY + 0.055,
    0.25,
    0.04
];
_bg ctrlSetBackgroundColor [0.40, 0.35, 0.25, 0.85];
_bg ctrlCommit 0;

// Button positions
private _buttonWidth = 0.045;
private _buttonHeight = 0.03;
private _buttonSpacing = 0.005;
private _startX = safezoneX + 0.015;
private _startY = safezoneY + 0.06;

// Speed settings: [IDC, Label, Multiplier]
private _speeds = [
    [9331, "⏸", 0.1],   // "Pause" - actually very slow (0 breaks Zeus)
    [9332, "◄", 0.5],
    [9333, "►", 1],
    [9334, "►►", 2],
    [9335, "►►►", 4]
];

// Initialize current speed tracking
if (isNil "OpsRoom_CurrentSpeed") then {
    OpsRoom_CurrentSpeed = 1;
};

// Create buttons
{
    _x params ["_idc", "_label", "_multiplier"];
    
    private _btn = _zeusDisplay ctrlCreate ["RscButton", _idc];
    private _xPos = _startX + (_forEachIndex * (_buttonWidth + _buttonSpacing));
    
    _btn ctrlSetPosition [_xPos, _startY, _buttonWidth, _buttonHeight];
    _btn ctrlSetText _label;
    _btn ctrlSetTooltip format ["Set speed to %1x", _multiplier];
    
    // Set initial appearance
    if (_multiplier == OpsRoom_CurrentSpeed) then {
        _btn ctrlSetBackgroundColor [0.75, 0.65, 0.45, 1]; // Highlighted
    } else {
        _btn ctrlSetBackgroundColor [0.25, 0.22, 0.18, 0.8]; // Normal
    };
    
    _btn ctrlSetTextColor [0.85, 0.80, 0.70, 1];
    _btn ctrlCommit 0;
    
    // Add click handler
    _btn ctrlAddEventHandler ["MouseButtonClick", {
        params ["_ctrl", "_button"];
        if (_button != 0) exitWith {}; // Only left click
        
        private _idc = ctrlIDC _ctrl;
        
        // Determine multiplier from IDC
        private _multiplier = switch (_idc) do {
            case 9331: {0.1};   // "Pause" - very slow (0 breaks Zeus camera)
            case 9332: {0.5};   // Slow
            case 9333: {1};     // Normal
            case 9334: {2};     // Fast
            case 9335: {4};     // Very Fast
            default {1};
        };
        
        // Set time multiplier
        setTimeMultiplier _multiplier;
        setAccTime _multiplier;  // Also set acceleration time
        OpsRoom_CurrentSpeed = _multiplier;
        
        // Feedback message
        private _speedText = switch (_multiplier) do {
            case 0.1: {"0.1x (Near Pause)"};
            case 0.5: {"0.5x (Slow)"};
            case 1: {"1x (Normal)"};
            case 2: {"2x (Fast)"};
            case 4: {"4x (Very Fast)"};
            default {format ["%1x", _multiplier]};
        };
        systemChat format ["Game speed: %1", _speedText];
        
        // Update button appearances
        private _display = findDisplay 312;
        {
            private _btn = _display displayCtrl _x;
            if (!isNull _btn) then {
                if (_x == _idc) then {
                    _btn ctrlSetBackgroundColor [0.75, 0.65, 0.45, 1]; // Highlighted
                } else {
                    _btn ctrlSetBackgroundColor [0.25, 0.22, 0.18, 0.8]; // Normal
                };
                _btn ctrlCommit 0;
            };
        } forEach [9331, 9332, 9333, 9334, 9335];
    }];
    
} forEach _speeds;
