/*
    Research Tree Dialog
    
    Left panel: tiered list of items in a subcategory
    Right panel: selected item details + RESEARCH button
    Follows Training dialog layout pattern.
*/

class OpsRoom_ResearchTreeDialog {
    idd = 11002;
    movingEnable = 0;
    
    class ControlsBackground {
        class Background: RscBackground {
            x = 0.25 * safezoneW + safezoneX;
            y = 0.15 * safezoneH + safezoneY;
            w = 0.5 * safezoneW;
            h = 0.68 * safezoneH;
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
            idc = 11030;
            text = "RESEARCH > CATEGORY > SUBCATEGORY";
            x = 0.31 * safezoneW + safezoneX;
            y = 0.15 * safezoneH + safezoneY;
            w = 0.38 * safezoneW;
            h = 0.04 * safezoneH;
            colorText[] = COLOR_TEXT;
            sizeEx = 0.035;
            font = "PuristaLight";
            style = 2;
        };
        
        class ResearchPointsText: RscText {
            idc = 11031;
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
        
        // Details panel background
        class DetailsPanel: RscBackground {
            x = 0.42 * safezoneW + safezoneX;
            y = 0.22 * safezoneH + safezoneY;
            w = 0.31 * safezoneW;
            h = 0.53 * safezoneH;
            colorBackground[] = {0.1, 0.1, 0.1, 0.3};
        };
    };
    
    class Controls {
        class BackButton: RscButton {
            idc = 11032;
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
        
        // Item listbox (left side) - same as training
        class ItemListbox: RscListbox {
            idc = 11040;
            x = 0.26 * safezoneW + safezoneX;
            y = 0.22 * safezoneH + safezoneY;
            w = 0.15 * safezoneW;
            h = 0.53 * safezoneH;
            colorBackground[] = {0.1, 0.1, 0.1, 0.7};
            colorSelectBackground[] = COLOR_BUTTON;
            colorSelectBackground2[] = COLOR_BUTTON_ACTIVE;
            sizeEx = 0.030;
            rowHeight = 0.045;
        };
        
        // Details display (right side)
        class DetailsText: RscStructuredText {
            idc = 11050;
            x = 0.43 * safezoneW + safezoneX;
            y = 0.23 * safezoneH + safezoneY;
            w = 0.29 * safezoneW;
            h = 0.40 * safezoneH;
            colorBackground[] = {0, 0, 0, 0};
            size = 0.032;
        };
        
        // Research button
        class ResearchButton: RscButton {
            idc = 11060;
            text = "BEGIN RESEARCH";
            x = 0.43 * safezoneW + safezoneX;
            y = 0.68 * safezoneH + safezoneY;
            w = 0.14 * safezoneW;
            h = 0.06 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
            colorBackgroundActive[] = COLOR_BUTTON_ACTIVE;
            colorFocused[] = COLOR_BUTTON_ACTIVE;
            action = "";
        };
        
        // Status text (next to research button)
        class StatusText: RscStructuredText {
            idc = 11061;
            x = 0.58 * safezoneW + safezoneX;
            y = 0.68 * safezoneH + safezoneY;
            w = 0.14 * safezoneW;
            h = 0.06 * safezoneH;
            colorBackground[] = {0, 0, 0, 0};
            size = 0.028;
        };
    };
};
