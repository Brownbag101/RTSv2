/*
    Research Categories Dialog
    
    Grid display showing equipment categories (Weapons, Ammunition, etc.)
    Reuses Regiment grid pattern: 4x3 squares.
    Click a category to see subcategories.
*/

class OpsRoom_ResearchCategoriesDialog {
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
            idc = -1;
            text = "RESEARCH";
            x = 0.26 * safezoneW + safezoneX;
            y = 0.15 * safezoneH + safezoneY;
            w = 0.4 * safezoneW;
            h = 0.04 * safezoneH;
            colorText[] = COLOR_TEXT;
            sizeEx = 0.04;
            font = "PuristaLight";
        };
        
        // Research points display
        class ResearchPointsText: RscText {
            idc = 11010;
            text = "Research Points: 0";
            x = 0.50 * safezoneW + safezoneX;
            y = 0.155 * safezoneH + safezoneY;
            w = 0.22 * safezoneW;
            h = 0.03 * safezoneH;
            colorText[] = {0.95, 0.85, 0.40, 1.0};
            sizeEx = 0.032;
            font = "PuristaBold";
            style = 1;
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
        
        // Active research status bar
        class ActiveResearchBG: RscBackground {
            idc = 11011;
            x = 0.265 * safezoneW + safezoneX;
            y = 0.76 * safezoneH + safezoneY;
            w = 0.47 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = {0.18, 0.22, 0.14, 0.8};
        };
        
        class ActiveResearchText: RscStructuredText {
            idc = 11012;
            x = 0.27 * safezoneW + safezoneX;
            y = 0.765 * safezoneH + safezoneY;
            w = 0.45 * safezoneW;
            h = 0.03 * safezoneH;
            size = 0.028;
        };
        
        // Category Grid - 4x3 = 12 squares (same layout as regiments)
        // Row 1
        class CatSquare_0: RscBackground {
            idc = 11100;
            x = 0.265 * safezoneW + safezoneX;
            y = 0.22 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.16 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
        };
        class CatSquare_1: RscBackground {
            idc = 11101;
            x = 0.385 * safezoneW + safezoneX;
            y = 0.22 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.16 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
        };
        class CatSquare_2: RscBackground {
            idc = 11102;
            x = 0.505 * safezoneW + safezoneX;
            y = 0.22 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.16 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
        };
        class CatSquare_3: RscBackground {
            idc = 11103;
            x = 0.625 * safezoneW + safezoneX;
            y = 0.22 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.16 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
        };
        
        // Row 2
        class CatSquare_4: RscBackground {
            idc = 11104;
            x = 0.265 * safezoneW + safezoneX;
            y = 0.40 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.16 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
        };
        class CatSquare_5: RscBackground {
            idc = 11105;
            x = 0.385 * safezoneW + safezoneX;
            y = 0.40 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.16 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
        };
        class CatSquare_6: RscBackground {
            idc = 11106;
            x = 0.505 * safezoneW + safezoneX;
            y = 0.40 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.16 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
        };
        class CatSquare_7: RscBackground {
            idc = 11107;
            x = 0.625 * safezoneW + safezoneX;
            y = 0.40 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.16 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
        };
        
        // Row 3
        class CatSquare_8: RscBackground {
            idc = 11108;
            x = 0.265 * safezoneW + safezoneX;
            y = 0.58 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.16 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
        };
        class CatSquare_9: RscBackground {
            idc = 11109;
            x = 0.385 * safezoneW + safezoneX;
            y = 0.58 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.16 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
        };
        class CatSquare_10: RscBackground {
            idc = 11110;
            x = 0.505 * safezoneW + safezoneX;
            y = 0.58 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.16 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
        };
        class CatSquare_11: RscBackground {
            idc = 11111;
            x = 0.625 * safezoneW + safezoneX;
            y = 0.58 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.16 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
        };
    };
};
