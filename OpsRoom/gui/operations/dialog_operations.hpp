/*
    Operations Dashboard Dialog
    
    Main operations screen showing all active/completed operations.
    Big "CREATE OPERATION" button at top.
    List of operations below with status indicators.
    
    IDD: 8011
    IDC Range: 11600-11699
    
    Layout:
    ┌─── OPERATIONS ROOM ──────────────────────── X ─┐
    │                                                  │
    │  [ + CREATE NEW OPERATION ]                      │
    │                                                  │
    │  ── ACTIVE OPERATIONS ──                         │
    │  Operation Mincemeat    | Capture Factory | 40%  │
    │  Operation Overlord     | Recon Port      | 10%  │
    │                                                  │
    │  ── COMPLETED OPERATIONS ──                      │
    │  Operation Torch        | Destroy Camp    | DONE │
    │                                                  │
    │  Status: 2 Active | 1 Complete | 0 Failed        │
    └──────────────────────────────────────────────────┘
*/

class OpsRoom_OperationsDialog {
    idd = 8011;
    movingEnable = 0;
    
    class ControlsBackground {
        class Background: RscBackground {
            x = 0.15 * safezoneW + safezoneX;
            y = 0.10 * safezoneH + safezoneY;
            w = 0.70 * safezoneW;
            h = 0.80 * safezoneH;
            colorBackground[] = COLOR_BACKGROUND;
        };
        
        class TitleBar: RscBackground {
            x = 0.15 * safezoneW + safezoneX;
            y = 0.10 * safezoneH + safezoneY;
            w = 0.70 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = COLOR_HEADER;
        };
        
        class TitleText: RscText {
            idc = -1;
            text = "OPERATIONS ROOM";
            x = 0.16 * safezoneW + safezoneX;
            y = 0.10 * safezoneH + safezoneY;
            w = 0.60 * safezoneW;
            h = 0.04 * safezoneH;
            colorText[] = COLOR_TEXT;
            sizeEx = 0.04;
            font = "PuristaLight";
            style = 2;
        };
        
        class StatusBar: RscBackground {
            x = 0.15 * safezoneW + safezoneX;
            y = 0.86 * safezoneH + safezoneY;
            w = 0.70 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = COLOR_HEADER;
        };
    };
    
    class Controls {
        class CloseButton: RscButton {
            idc = -1;
            text = "X";
            x = 0.83 * safezoneW + safezoneX;
            y = 0.105 * safezoneH + safezoneY;
            w = 0.015 * safezoneW;
            h = 0.03 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
            colorBackgroundActive[] = COLOR_BUTTON_ACTIVE;
            colorFocused[] = COLOR_BUTTON_ACTIVE;
            action = "closeDialog 0;";
        };
        
        // Create Operation button
        class CreateButton: RscButton {
            idc = 11600;
            text = "+ CREATE NEW OPERATION";
            x = 0.25 * safezoneW + safezoneX;
            y = 0.155 * safezoneH + safezoneY;
            w = 0.30 * safezoneW;
            h = 0.05 * safezoneH;
            colorBackground[] = {0.25, 0.35, 0.20, 1.0};
            colorBackgroundActive[] = {0.30, 0.42, 0.25, 1.0};
            colorFocused[] = {0.30, 0.42, 0.25, 1.0};
            colorText[] = {0.9, 0.95, 0.85, 1.0};
            font = "PuristaBold";
            sizeEx = 0.035;
            action = "";
        };
        
        // Overall objective display
        class ObjectiveBar: RscBackground {
            idc = 11601;
            x = 0.16 * safezoneW + safezoneX;
            y = 0.22 * safezoneH + safezoneY;
            w = 0.68 * safezoneW;
            h = 0.035 * safezoneH;
            colorBackground[] = {0.30, 0.20, 0.15, 0.8};
        };
        
        class ObjectiveText: RscStructuredText {
            idc = 11602;
            x = 0.17 * safezoneW + safezoneX;
            y = 0.22 * safezoneH + safezoneY;
            w = 0.66 * safezoneW;
            h = 0.035 * safezoneH;
            size = 0.03;
            text = "";
            class Attributes {
                font = "PuristaBold";
                color = "#FFD700";
                align = "center";
                shadow = 1;
            };
        };
        
        // Status bar text
        class StatusText: RscStructuredText {
            idc = 11603;
            x = 0.16 * safezoneW + safezoneX;
            y = 0.86 * safezoneH + safezoneY;
            w = 0.68 * safezoneW;
            h = 0.04 * safezoneH;
            size = 0.028;
            text = "";
            class Attributes {
                font = "PuristaLight";
                color = "#D9D5C9";
                align = "center";
                shadow = 1;
            };
        };
    };
};
