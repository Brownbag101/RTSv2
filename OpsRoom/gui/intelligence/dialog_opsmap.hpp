/*
    Operational Map Dialog
    
    Near-full-screen interactive map with strategic location markers.
    Click markers to view intel cards.
    
    IDD: 8010
    IDC Range: 11500-11599
    
    Layout:
    ┌─── OPERATIONAL MAP ─────────────────────────── X ─┐
    │  [Interactive RscMapControl filling most of dialog] │
    │                                                      │
    │   Locations shown as clickable markers               │
    │   ? = unknown, icons = identified                    │
    │                                                      │
    │                                                      │
    ├──────────────────────────────────────────────────────┤
    │  Status bar: X locations | Y discovered | Z friendly │
    └──────────────────────────────────────────────────────┘
*/

class OpsRoom_OpsMapDialog {
    idd = 8010;
    movingEnable = 0;
    
    class ControlsBackground {
        class Background: RscBackground {
            x = 0.05 * safezoneW + safezoneX;
            y = 0.05 * safezoneH + safezoneY;
            w = 0.90 * safezoneW;
            h = 0.90 * safezoneH;
            colorBackground[] = COLOR_BACKGROUND;
        };
        
        class TitleBar: RscBackground {
            x = 0.05 * safezoneW + safezoneX;
            y = 0.05 * safezoneH + safezoneY;
            w = 0.90 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = COLOR_HEADER;
        };
        
        class TitleText: RscText {
            idc = -1;
            text = "OPERATIONAL MAP";
            x = 0.06 * safezoneW + safezoneX;
            y = 0.05 * safezoneH + safezoneY;
            w = 0.80 * safezoneW;
            h = 0.04 * safezoneH;
            colorText[] = COLOR_TEXT;
            sizeEx = 0.04;
            font = "PuristaLight";
            style = 2;
        };
        
        class StatusBar: RscBackground {
            x = 0.05 * safezoneW + safezoneX;
            y = 0.91 * safezoneH + safezoneY;
            w = 0.90 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = COLOR_HEADER;
        };
    };
    
    class Controls {
        class CloseButton: RscButton {
            idc = -1;
            text = "X";
            x = 0.93 * safezoneW + safezoneX;
            y = 0.055 * safezoneH + safezoneY;
            w = 0.015 * safezoneW;
            h = 0.03 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
            colorBackgroundActive[] = COLOR_BUTTON_ACTIVE;
            colorFocused[] = COLOR_BUTTON_ACTIVE;
            action = "closeDialog 0;";
        };
        
        // Command Intelligence button
        class IntelButton: RscButton {
            idc = 11504;
            text = "INTELLIGENCE";
            x = 0.18 * safezoneW + safezoneX;
            y = 0.055 * safezoneH + safezoneY;
            w = 0.07 * safezoneW;
            h = 0.03 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
            colorBackgroundActive[] = COLOR_BUTTON_ACTIVE;
            colorFocused[] = COLOR_BUTTON_ACTIVE;
            sizeEx = 0.025;
            action = "";  // Set in code
        };
        
        // Command Intelligence side panel (hidden by default)
        class IntelPanelBg: RscBackground {
            idc = 11510;
            x = 0.72 * safezoneW + safezoneX;
            y = 0.09 * safezoneH + safezoneY;
            w = 0.23 * safezoneW;
            h = 0.82 * safezoneH;
            colorBackground[] = {0.08, 0.09, 0.06, 0.92};
        };
        
        class IntelPanelTitle: RscText {
            idc = 11511;
            text = "COMMAND INTELLIGENCE";
            x = 0.73 * safezoneW + safezoneX;
            y = 0.10 * safezoneH + safezoneY;
            w = 0.21 * safezoneW;
            h = 0.03 * safezoneH;
            colorText[] = COLOR_TEXT;
            sizeEx = 0.035;
            font = "PuristaBold";
        };
        
        class IntelPanelBody: RscStructuredText {
            idc = 11512;
            x = 0.73 * safezoneW + safezoneX;
            y = 0.14 * safezoneH + safezoneY;
            w = 0.21 * safezoneW;
            h = 0.75 * safezoneH;
            size = 0.028;
            text = "";
            class Attributes {
                font = "PuristaLight";
                color = "#D9D5C9";
                shadow = 1;
            };
        };
        
        // Interactive map control
        class MapControl: RscMapControl {
            idc = 11500;
            x = 0.05 * safezoneW + safezoneX;
            y = 0.09 * safezoneH + safezoneY;
            w = 0.90 * safezoneW;
            h = 0.82 * safezoneH;
            
            // Map display settings
            maxSatelliteAlpha = 0.85;
            alphaFadeStartScale = 0.35;
            alphaFadeEndScale = 0.4;
            colorBackground[] = {0.15, 0.17, 0.12, 1.0};
            colorOutside[] = {0.10, 0.12, 0.08, 1.0};
            colorText[] = {0.8, 0.8, 0.7, 1.0};
            
            // Grid
            colorGrid[] = {0.3, 0.3, 0.25, 0.3};
            colorGridMap[] = {0.3, 0.3, 0.25, 0.15};
        };
        
        // Status bar text
        class StatusText: RscStructuredText {
            idc = 11501;
            x = 0.06 * safezoneW + safezoneX;
            y = 0.91 * safezoneH + safezoneY;
            w = 0.88 * safezoneW;
            h = 0.04 * safezoneH;
            size = 0.03;
            text = "";
            class Attributes {
                font = "PuristaLight";
                color = "#D9D5C9";
                align = "center";
                shadow = 1;
            };
        };
        
        // Legend button (top-left of map)
        class LegendButton: RscButton {
            idc = 11502;
            text = "LEGEND";
            x = 0.06 * safezoneW + safezoneX;
            y = 0.055 * safezoneH + safezoneY;
            w = 0.05 * safezoneW;
            h = 0.03 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
            colorBackgroundActive[] = COLOR_BUTTON_ACTIVE;
            colorFocused[] = COLOR_BUTTON_ACTIVE;
            sizeEx = 0.025;
            action = "";  // Set in code
        };
        
        // Refresh intel button
        class RefreshButton: RscButton {
            idc = 11503;
            text = "REFRESH";
            x = 0.12 * safezoneW + safezoneX;
            y = 0.055 * safezoneH + safezoneY;
            w = 0.05 * safezoneW;
            h = 0.03 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
            colorBackgroundActive[] = COLOR_BUTTON_ACTIVE;
            colorFocused[] = COLOR_BUTTON_ACTIVE;
            sizeEx = 0.025;
            action = "";  // Set in code
        };
    };
};
