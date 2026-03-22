/*
    Factory Interior Dialog
    
    Left panel: categorised list of researched items available to produce.
    Right panel: selected item details + START PRODUCTION button.
    Shows current production status at bottom.
    Follows Training dialog layout pattern.
    
    IDC Range: 11300-11399
*/

class OpsRoom_FactoryInteriorDialog {
    idd = 11004;
    movingEnable = 0;
    
    class ControlsBackground {
        class Background: RscBackground {
            x = 0.25 * safezoneW + safezoneX;
            y = 0.15 * safezoneH + safezoneY;
            w = 0.50 * safezoneW;
            h = 0.68 * safezoneH;
            colorBackground[] = COLOR_BACKGROUND;
        };
        
        class TitleBar: RscBackground {
            x = 0.25 * safezoneW + safezoneX;
            y = 0.15 * safezoneH + safezoneY;
            w = 0.50 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = COLOR_HEADER;
        };
        
        class TitleText: RscText {
            idc = 11300;
            text = "FACTORY 1";
            x = 0.31 * safezoneW + safezoneX;
            y = 0.15 * safezoneH + safezoneY;
            w = 0.38 * safezoneW;
            h = 0.04 * safezoneH;
            colorText[] = COLOR_TEXT;
            sizeEx = 0.04;
            font = "PuristaLight";
            style = 2;
        };
        
        // Details panel background
        class DetailsPanel: RscBackground {
            x = 0.42 * safezoneW + safezoneX;
            y = 0.22 * safezoneH + safezoneY;
            w = 0.31 * safezoneW;
            h = 0.44 * safezoneH;
            colorBackground[] = {0.1, 0.1, 0.1, 0.3};
        };
        
        // Current production status background
        class StatusBG: RscBackground {
            x = 0.26 * safezoneW + safezoneX;
            y = 0.70 * safezoneH + safezoneY;
            w = 0.47 * safezoneW;
            h = 0.08 * safezoneH;
            colorBackground[] = {0.18, 0.22, 0.14, 0.8};
        };
    };
    
    class Controls {
        class BackButton: RscButton {
            idc = 11301;
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
        
        // Item listbox (left side)
        class ProductionListbox: RscListbox {
            idc = 11310;
            x = 0.26 * safezoneW + safezoneX;
            y = 0.22 * safezoneH + safezoneY;
            w = 0.15 * safezoneW;
            h = 0.44 * safezoneH;
            colorBackground[] = {0.1, 0.1, 0.1, 0.7};
            colorSelectBackground[] = COLOR_BUTTON;
            colorSelectBackground2[] = COLOR_BUTTON_ACTIVE;
            sizeEx = 0.028;
            rowHeight = 0.040;
        };
        
        // Details display (right side)
        class DetailsText: RscStructuredText {
            idc = 11320;
            x = 0.43 * safezoneW + safezoneX;
            y = 0.23 * safezoneH + safezoneY;
            w = 0.29 * safezoneW;
            h = 0.32 * safezoneH;
            colorBackground[] = {0, 0, 0, 0};
            size = 0.032;
        };
        
        // Start production button
        class ProduceButton: RscButton {
            idc = 11330;
            text = "START PRODUCTION";
            x = 0.43 * safezoneW + safezoneX;
            y = 0.58 * safezoneH + safezoneY;
            w = 0.14 * safezoneW;
            h = 0.06 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
            colorBackgroundActive[] = COLOR_BUTTON_ACTIVE;
            colorFocused[] = COLOR_BUTTON_ACTIVE;
            action = "";
        };
        
        // Cancel production button (shown when factory is producing)
        class CancelButton: RscButton {
            idc = 11331;
            text = "CANCEL";
            x = 0.58 * safezoneW + safezoneX;
            y = 0.58 * safezoneH + safezoneY;
            w = 0.07 * safezoneW;
            h = 0.06 * safezoneH;
            colorBackground[] = {0.45, 0.20, 0.18, 0.95};
            colorBackgroundActive[] = {0.65, 0.25, 0.20, 1.0};
            colorFocused[] = {0.65, 0.25, 0.20, 1.0};
            action = "";
        };
        
        // Current production status text
        class ProductionStatusText: RscStructuredText {
            idc = 11340;
            x = 0.27 * safezoneW + safezoneX;
            y = 0.705 * safezoneH + safezoneY;
            w = 0.45 * safezoneW;
            h = 0.07 * safezoneH;
            colorBackground[] = {0, 0, 0, 0};
            size = 0.030;
        };
    };
};
