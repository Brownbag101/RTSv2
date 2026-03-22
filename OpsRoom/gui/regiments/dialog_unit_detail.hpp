/*
    Unit Detail Dialog
    
    Shows detailed information about a single unit with action buttons.
    Actions: Promote, Training
*/

class OpsRoom_UnitDetailDialog {
    idd = 8003;
    movingEnable = 0;
    
    class ControlsBackground {
        class Background: RscBackground {
            x = 0.3 * safezoneW + safezoneX;
            y = 0.2 * safezoneH + safezoneY;
            w = 0.4 * safezoneW;
            h = 0.6 * safezoneH;
            colorBackground[] = COLOR_BACKGROUND;
        };
        
        class TitleBar: RscBackground {
            x = 0.3 * safezoneW + safezoneX;
            y = 0.2 * safezoneH + safezoneY;
            w = 0.4 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = COLOR_HEADER;
        };
        
        class TitleText: RscText {
            idc = 8010;
            text = "UNIT DETAILS";
            x = 0.36 * safezoneW + safezoneX;
            y = 0.2 * safezoneH + safezoneY;
            w = 0.28 * safezoneW;
            h = 0.04 * safezoneH;
            colorText[] = COLOR_TEXT;
            sizeEx = 0.04;
            font = "PuristaLight";
            style = 2;
        };
    };
    
    class Controls {
        class BackButton: RscButton {
            idc = 8011;
            text = "< BACK";
            x = 0.31 * safezoneW + safezoneX;
            y = 0.205 * safezoneH + safezoneY;
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
            x = 0.68 * safezoneW + safezoneX;
            y = 0.205 * safezoneH + safezoneY;
            w = 0.015 * safezoneW;
            h = 0.03 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
            colorBackgroundActive[] = COLOR_BUTTON_ACTIVE;
            colorFocused[] = COLOR_BUTTON_ACTIVE;
            action = "closeDialog 0;";
        };
        
        // Unit information display area
        class InfoArea: RscStructuredText {
            idc = 8020;
            x = 0.32 * safezoneW + safezoneX;
            y = 0.27 * safezoneH + safezoneY;
            w = 0.36 * safezoneW;
            h = 0.38 * safezoneH;
            colorBackground[] = {0.1, 0.1, 0.1, 0.5};
            size = 0.032;
        };
        
        // Action buttons - centered side-by-side
        class PromoteButton: RscButton {
            idc = 8030;
            text = "PROMOTE";
            x = 0.36 * safezoneW + safezoneX;
            y = 0.67 * safezoneH + safezoneY;
            w = 0.12 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
            colorBackgroundActive[] = COLOR_BUTTON_ACTIVE;
            colorFocused[] = COLOR_BUTTON_ACTIVE;
            action = "";  // Set in code
        };
        
        class TrainingButton: RscButton {
            idc = 8032;
            text = "TRAINING";
            x = 0.50 * safezoneW + safezoneX;
            y = 0.67 * safezoneH + safezoneY;
            w = 0.12 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
            colorBackgroundActive[] = COLOR_BUTTON_ACTIVE;
            colorFocused[] = COLOR_BUTTON_ACTIVE;
            action = "";  // Set in code
        };
    };
};
