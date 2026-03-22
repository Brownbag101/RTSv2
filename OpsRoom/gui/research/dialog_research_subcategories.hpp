/*
    Research Subcategories Dialog
    
    Grid display showing subcategories within a category.
    E.g. Weapons → Rifles, Pistols, SMGs, Machine Guns
    Reuses same grid layout as categories.
*/

class OpsRoom_ResearchSubcategoriesDialog {
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
            idc = 11020;
            text = "RESEARCH > CATEGORY";
            x = 0.31 * safezoneW + safezoneX;
            y = 0.15 * safezoneH + safezoneY;
            w = 0.38 * safezoneW;
            h = 0.04 * safezoneH;
            colorText[] = COLOR_TEXT;
            sizeEx = 0.04;
            font = "PuristaLight";
            style = 2;
        };
        
        class ResearchPointsText: RscText {
            idc = 11021;
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
        class BackButton: RscButton {
            idc = 11022;
            text = "< BACK";
            x = 0.26 * safezoneW + safezoneX;
            y = 0.155 * safezoneH + safezoneY;
            w = 0.04 * safezoneW;
            h = 0.03 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
            colorBackgroundActive[] = COLOR_BUTTON_ACTIVE;
            colorFocused[] = COLOR_BUTTON_ACTIVE;
            action = "";
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
        
        // Subcategory Grid - same 4x3 layout
        // Row 1
        class SubSquare_0: RscBackground {
            idc = 11130;
            x = 0.265 * safezoneW + safezoneX;
            y = 0.22 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.16 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
        };
        class SubSquare_1: RscBackground {
            idc = 11131;
            x = 0.385 * safezoneW + safezoneX;
            y = 0.22 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.16 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
        };
        class SubSquare_2: RscBackground {
            idc = 11132;
            x = 0.505 * safezoneW + safezoneX;
            y = 0.22 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.16 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
        };
        class SubSquare_3: RscBackground {
            idc = 11133;
            x = 0.625 * safezoneW + safezoneX;
            y = 0.22 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.16 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
        };
        // Row 2
        class SubSquare_4: RscBackground {
            idc = 11134;
            x = 0.265 * safezoneW + safezoneX;
            y = 0.40 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.16 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
        };
        class SubSquare_5: RscBackground {
            idc = 11135;
            x = 0.385 * safezoneW + safezoneX;
            y = 0.40 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.16 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
        };
        class SubSquare_6: RscBackground {
            idc = 11136;
            x = 0.505 * safezoneW + safezoneX;
            y = 0.40 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.16 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
        };
        class SubSquare_7: RscBackground {
            idc = 11137;
            x = 0.625 * safezoneW + safezoneX;
            y = 0.40 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.16 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
        };
        // Row 3
        class SubSquare_8: RscBackground {
            idc = 11138;
            x = 0.265 * safezoneW + safezoneX;
            y = 0.58 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.16 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
        };
        class SubSquare_9: RscBackground {
            idc = 11139;
            x = 0.385 * safezoneW + safezoneX;
            y = 0.58 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.16 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
        };
        class SubSquare_10: RscBackground {
            idc = 11140;
            x = 0.505 * safezoneW + safezoneX;
            y = 0.58 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.16 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
        };
        class SubSquare_11: RscBackground {
            idc = 11141;
            x = 0.625 * safezoneW + safezoneX;
            y = 0.58 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.16 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
        };
    };
};
