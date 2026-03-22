/*
    Air Wings Dialog
    
    Grid display showing all air wings (max 8).
    Click wing to view aircraft.
    Click [+] to create new wing.
    
    IDD: 11000
    IDCs: 11100-11107 (wing squares), 11010 (title text)
    Dynamic IDCs: 12100-12107 (badges), 13100-13107 (names), 
                  14100-14107 (counts), 15100-15107 (buttons)
*/

class OpsRoom_AirWingsDialog {
    idd = 11000;
    movingEnable = 0;
    
    class ControlsBackground {
        class Background: RscBackground {
            x = 0.25 * safezoneW + safezoneX;
            y = 0.15 * safezoneH + safezoneY;
            w = 0.5 * safezoneW;
            h = 0.73 * safezoneH;
            colorBackground[] = COLOR_BACKGROUND;
        };
        
        class TitleBar: RscBackground {
            x = 0.25 * safezoneW + safezoneX;
            y = 0.15 * safezoneH + safezoneY;
            w = 0.5 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = COLOR_HEADER;
        };
        
        class TitleText: RscText {
            idc = 11010;
            text = "AIR OPERATIONS";
            x = 0.26 * safezoneW + safezoneX;
            y = 0.15 * safezoneH + safezoneY;
            w = 0.4 * safezoneW;
            h = 0.04 * safezoneH;
            colorText[] = COLOR_TEXT;
            sizeEx = 0.04;
            font = "PuristaLight";
        };
    };
    
    class Controls {
        class CloseButton: RscButton {
            idc = -1;
            text = "X";
            x = 0.73 * safezoneW + safezoneX;
            y = 0.155 * safezoneH + safezoneY;
            w = 0.015 * safezoneW;
            h = 0.03 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
            colorBackgroundActive[] = COLOR_BUTTON_ACTIVE;
            colorFocused[] = COLOR_BUTTON_ACTIVE;
            action = "closeDialog 0;";
        };
        
        // Summary bar below title
        class SummaryBar: RscBackground {
            idc = 11020;
            x = 0.25 * safezoneW + safezoneX;
            y = 0.19 * safezoneH + safezoneY;
            w = 0.5 * safezoneW;
            h = 0.025 * safezoneH;
            colorBackground[] = {0.15, 0.18, 0.12, 1.0};
        };
        
        class SummaryText: RscStructuredText {
            idc = 11021;
            x = 0.26 * safezoneW + safezoneX;
            y = 0.19 * safezoneH + safezoneY;
            w = 0.48 * safezoneW;
            h = 0.025 * safezoneH;
            size = 0.025;
            text = "";
            class Attributes {
                font = "PuristaLight";
                color = "#AAAAAA";
                align = "center";
                shadow = 1;
            };
        };
        
        // Wing Grid (2x4 = 8 squares)
        // Each square: 0.11w x 0.2h with 0.01w spacing
        
        // Row 1
        class WingSquare_0: RscBackground {
            idc = 11100;
            x = 0.265 * safezoneW + safezoneX;
            y = 0.23 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.20 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
        };
        
        class WingSquare_1: RscBackground {
            idc = 11101;
            x = 0.385 * safezoneW + safezoneX;
            y = 0.23 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.20 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
        };
        
        class WingSquare_2: RscBackground {
            idc = 11102;
            x = 0.505 * safezoneW + safezoneX;
            y = 0.23 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.20 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
        };
        
        class WingSquare_3: RscBackground {
            idc = 11103;
            x = 0.625 * safezoneW + safezoneX;
            y = 0.23 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.20 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
        };
        
        // Row 2
        class WingSquare_4: RscBackground {
            idc = 11104;
            x = 0.265 * safezoneW + safezoneX;
            y = 0.45 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.20 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
        };
        
        class WingSquare_5: RscBackground {
            idc = 11105;
            x = 0.385 * safezoneW + safezoneX;
            y = 0.45 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.20 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
        };
        
        class WingSquare_6: RscBackground {
            idc = 11106;
            x = 0.505 * safezoneW + safezoneX;
            y = 0.45 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.20 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
        };
        
        class WingSquare_7: RscBackground {
            idc = 11107;
            x = 0.625 * safezoneW + safezoneX;
            y = 0.45 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.20 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
        };
        
        // Hangar button (bottom left)
        class HangarButton: RscButton {
            idc = 11030;
            text = "HANGAR";
            x = 0.265 * safezoneW + safezoneX;
            y = 0.68 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = {0.30, 0.35, 0.25, 1.0};
            colorBackgroundActive[] = {0.35, 0.40, 0.30, 1.0};
            colorFocused[] = {0.35, 0.40, 0.30, 1.0};
            tooltip = "View all aircraft in hangar";
        };
        
        // Pilot Roster button
        class PilotRosterButton: RscButton {
            idc = 11032;
            text = "PILOT ROSTER";
            x = 0.385 * safezoneW + safezoneX;
            y = 0.68 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = {0.25, 0.30, 0.35, 1.0};
            colorBackgroundActive[] = {0.30, 0.35, 0.40, 1.0};
            colorFocused[] = {0.30, 0.35, 0.40, 1.0};
            tooltip = "View all qualified pilots";
        };
        
        // Aircrew Roster button
        class CrewRosterButton: RscButton {
            idc = 11033;
            text = "AIRCREW ROSTER";
            x = 0.505 * safezoneW + safezoneX;
            y = 0.68 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = {0.25, 0.28, 0.35, 1.0};
            colorBackgroundActive[] = {0.30, 0.33, 0.40, 1.0};
            colorFocused[] = {0.30, 0.33, 0.40, 1.0};
            tooltip = "View all qualified air gunners";
        };
        
        // Fuel display (bottom right)
        class FuelLabel: RscStructuredText {
            idc = 11031;
            x = 0.56 * safezoneW + safezoneX;
            y = 0.685 * safezoneH + safezoneY;
            w = 0.18 * safezoneW;
            h = 0.03 * safezoneH;
            size = 0.028;
            text = "";
            class Attributes {
                font = "PuristaLight";
                color = "#D9D5C9";
                align = "right";
                shadow = 1;
            };
        };
    };
};
