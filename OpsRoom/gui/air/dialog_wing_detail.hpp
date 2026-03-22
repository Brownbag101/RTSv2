/*
    Wing Detail Dialog
    
    Shows aircraft within a selected wing (max 8).
    Click aircraft to view detail / spawn preview at hangar.
    Bottom buttons: Set Mission, Launch, Land.
    
    IDD: 11001
*/

class OpsRoom_WingDetailDialog {
    idd = 11001;
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
            idc = 11110;
            text = "WING DETAIL";
            x = 0.31 * safezoneW + safezoneX;
            y = 0.15 * safezoneH + safezoneY;
            w = 0.38 * safezoneW;
            h = 0.04 * safezoneH;
            colorText[] = COLOR_TEXT;
            sizeEx = 0.04;
            font = "PuristaLight";
            style = 2;
        };
    };
    
    class Controls {
        class BackButton: RscButton {
            idc = 11111;
            text = "< BACK";
            x = 0.26 * safezoneW + safezoneX;
            y = 0.155 * safezoneH + safezoneY;
            w = 0.04 * safezoneW;
            h = 0.03 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
            colorBackgroundActive[] = COLOR_BUTTON_ACTIVE;
            colorFocused[] = COLOR_BUTTON_ACTIVE;
        };
        
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
        
        // Wing status bar
        class StatusBar: RscBackground {
            idc = 11120;
            x = 0.25 * safezoneW + safezoneX;
            y = 0.19 * safezoneH + safezoneY;
            w = 0.5 * safezoneW;
            h = 0.025 * safezoneH;
            colorBackground[] = {0.15, 0.18, 0.12, 1.0};
        };
        
        class StatusText: RscStructuredText {
            idc = 11121;
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
        
        // Aircraft Grid (2x4 = 8 squares)
        class AircraftSquare_0: RscBackground {
            idc = 11200;
            x = 0.265 * safezoneW + safezoneX;
            y = 0.23 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.18 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
        };
        class AircraftSquare_1: RscBackground {
            idc = 11201;
            x = 0.385 * safezoneW + safezoneX;
            y = 0.23 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.18 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
        };
        class AircraftSquare_2: RscBackground {
            idc = 11202;
            x = 0.505 * safezoneW + safezoneX;
            y = 0.23 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.18 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
        };
        class AircraftSquare_3: RscBackground {
            idc = 11203;
            x = 0.625 * safezoneW + safezoneX;
            y = 0.23 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.18 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
        };
        class AircraftSquare_4: RscBackground {
            idc = 11204;
            x = 0.265 * safezoneW + safezoneX;
            y = 0.43 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.18 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
        };
        class AircraftSquare_5: RscBackground {
            idc = 11205;
            x = 0.385 * safezoneW + safezoneX;
            y = 0.43 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.18 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
        };
        class AircraftSquare_6: RscBackground {
            idc = 11206;
            x = 0.505 * safezoneW + safezoneX;
            y = 0.43 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.18 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
        };
        class AircraftSquare_7: RscBackground {
            idc = 11207;
            x = 0.625 * safezoneW + safezoneX;
            y = 0.43 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.18 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
        };
        
        // Bottom action buttons
        class ScheduleButton: RscButton {
            idc = 11130;
            text = "SCHEDULE";
            x = 0.265 * safezoneW + safezoneX;
            y = 0.64 * safezoneH + safezoneY;
            w = 0.08 * safezoneW;
            h = 0.035 * safezoneH;
            colorBackground[] = {0.30, 0.35, 0.25, 1.0};
            colorBackgroundActive[] = {0.35, 0.40, 0.30, 1.0};
            colorFocused[] = {0.35, 0.40, 0.30, 1.0};
            tooltip = "Set up automated mission launches";
        };
        
        // Mission info panel below buttons
        class InfoPanelBg: RscBackground {
            idc = 11135;
            x = 0.265 * safezoneW + safezoneX;
            y = 0.685 * safezoneH + safezoneY;
            w = 0.47 * safezoneW;
            h = 0.17 * safezoneH;
            colorBackground[] = {0.15, 0.18, 0.12, 0.9};
        };
        
        class InfoPanelText: RscStructuredText {
            idc = 11136;
            x = 0.27 * safezoneW + safezoneX;
            y = 0.69 * safezoneH + safezoneY;
            w = 0.46 * safezoneW;
            h = 0.16 * safezoneH;
            size = 0.025;
            text = "";
            class Attributes {
                font = "PuristaLight";
                color = "#AAAAAA";
                shadow = 1;
            };
        };
        
        class MissionButton: RscButton {
            idc = 11131;
            text = "SET MISSION";
            x = 0.355 * safezoneW + safezoneX;
            y = 0.64 * safezoneH + safezoneY;
            w = 0.10 * safezoneW;
            h = 0.035 * safezoneH;
            colorBackground[] = {0.30, 0.30, 0.40, 1.0};
            colorBackgroundActive[] = {0.35, 0.35, 0.45, 1.0};
            colorFocused[] = {0.35, 0.35, 0.45, 1.0};
            tooltip = "Assign mission to this wing";
        };
        
        class LaunchButton: RscButton {
            idc = 11132;
            text = "LAUNCH";
            x = 0.465 * safezoneW + safezoneX;
            y = 0.64 * safezoneH + safezoneY;
            w = 0.08 * safezoneW;
            h = 0.035 * safezoneH;
            colorBackground[] = {0.25, 0.40, 0.25, 1.0};
            colorBackgroundActive[] = {0.30, 0.50, 0.30, 1.0};
            colorFocused[] = {0.30, 0.50, 0.30, 1.0};
            tooltip = "Launch wing - spawn all aircraft at runway";
        };
        
        class LandButton: RscButton {
            idc = 11133;
            text = "LAND";
            x = 0.555 * safezoneW + safezoneX;
            y = 0.64 * safezoneH + safezoneY;
            w = 0.08 * safezoneW;
            h = 0.035 * safezoneH;
            colorBackground[] = {0.40, 0.30, 0.20, 1.0};
            colorBackgroundActive[] = {0.50, 0.35, 0.25, 1.0};
            colorFocused[] = {0.50, 0.35, 0.25, 1.0};
            tooltip = "Order wing to return and land";
        };
    };
};
