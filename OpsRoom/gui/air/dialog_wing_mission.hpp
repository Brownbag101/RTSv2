/*
    Wing Mission Assignment Dialog
    
    Shows available missions for the wing type.
    Player selects mission, then clicks Zeus map to set target.
    
    IDD: 11002
*/

class OpsRoom_WingMissionDialog {
    idd = 11002;
    movingEnable = 0;
    
    class ControlsBackground {
        class Background: RscBackground {
            x = 0.30 * safezoneW + safezoneX;
            y = 0.20 * safezoneH + safezoneY;
            w = 0.40 * safezoneW;
            h = 0.65 * safezoneH;
            colorBackground[] = COLOR_BACKGROUND;
        };
        
        class TitleBar: RscBackground {
            x = 0.30 * safezoneW + safezoneX;
            y = 0.20 * safezoneH + safezoneY;
            w = 0.40 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = COLOR_HEADER;
        };
        
        class TitleText: RscText {
            idc = 11400;
            text = "ASSIGN MISSION";
            x = 0.31 * safezoneW + safezoneX;
            y = 0.20 * safezoneH + safezoneY;
            w = 0.38 * safezoneW;
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
            x = 0.68 * safezoneW + safezoneX;
            y = 0.205 * safezoneH + safezoneY;
            w = 0.015 * safezoneW;
            h = 0.03 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
            colorBackgroundActive[] = COLOR_BUTTON_ACTIVE;
            colorFocused[] = COLOR_BUTTON_ACTIVE;
            action = "closeDialog 0;";
        };
        
        // Mission description area
        class DescriptionBG: RscBackground {
            idc = 11410;
            x = 0.32 * safezoneW + safezoneX;
            y = 0.67 * safezoneH + safezoneY;
            w = 0.36 * safezoneW;
            h = 0.06 * safezoneH;
            colorBackground[] = {0.15, 0.18, 0.12, 0.8};
        };
        
        class DescriptionText: RscStructuredText {
            idc = 11411;
            x = 0.33 * safezoneW + safezoneX;
            y = 0.675 * safezoneH + safezoneY;
            w = 0.34 * safezoneW;
            h = 0.05 * safezoneH;
            size = 0.028;
            text = "Select a mission type above.";
            class Attributes {
                font = "PuristaLight";
                color = "#AAAAAA";
                align = "left";
                shadow = 1;
            };
        };
        
        // Confirm button
        class ConfirmButton: RscButton {
            idc = 11420;
            text = "SET TARGET ON MAP";
            x = 0.32 * safezoneW + safezoneX;
            y = 0.75 * safezoneH + safezoneY;
            w = 0.17 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = {0.25, 0.40, 0.25, 1.0};
            colorBackgroundActive[] = {0.30, 0.50, 0.30, 1.0};
            colorFocused[] = {0.30, 0.50, 0.30, 1.0};
            tooltip = "Select mission then click to place target on Zeus map";
        };
        
        // Cancel button
        class CancelButton: RscButton {
            idc = 11421;
            text = "CANCEL";
            x = 0.51 * safezoneW + safezoneX;
            y = 0.75 * safezoneH + safezoneY;
            w = 0.17 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = {0.40, 0.25, 0.20, 1.0};
            colorBackgroundActive[] = {0.50, 0.30, 0.25, 1.0};
            colorFocused[] = {0.50, 0.30, 0.25, 1.0};
        };
    };
};
