/*
    Training Dialog
    
    Unit training selection interface.
    Accessed from unit detail dialog.
*/

class OpsRoom_TrainingDialog {
    idd = 8006;
    movingEnable = 0;
    
    class ControlsBackground {
        class Background: RscBackground {
            x = 0.25 * safezoneW + safezoneX;
            y = 0.20 * safezoneH + safezoneY;
            w = 0.50 * safezoneW;
            h = 0.60 * safezoneH;
            colorBackground[] = COLOR_BACKGROUND;
        };
        
        class TitleBar: RscBackground {
            x = 0.25 * safezoneW + safezoneX;
            y = 0.20 * safezoneH + safezoneY;
            w = 0.50 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = COLOR_HEADER;
        };
        
        class TitleText: RscText {
            idc = 8600;
            text = "TRAINING DEPOT";
            x = 0.26 * safezoneW + safezoneX;
            y = 0.205 * safezoneH + safezoneY;
            w = 0.40 * safezoneW;
            h = 0.03 * safezoneH;
            colorText[] = COLOR_TEXT;
            sizeEx = 0.040;
            font = "PuristaBold";
        };
        
        // Details panel background
        class DetailsPanel: RscBackground {
            x = 0.42 * safezoneW + safezoneX;
            y = 0.26 * safezoneH + safezoneY;
            w = 0.31 * safezoneW;
            h = 0.46 * safezoneH;
            colorBackground[] = {0.1, 0.1, 0.1, 0.3};
        };
    };
    
    class Controls {
        class BackButton: RscButton {
            idc = 8601;
            text = "< BACK";
            x = 0.26 * safezoneW + safezoneX;
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
            x = 0.73 * safezoneW + safezoneX;
            y = 0.205 * safezoneH + safezoneY;
            w = 0.015 * safezoneW;
            h = 0.03 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
            colorBackgroundActive[] = COLOR_BUTTON_ACTIVE;
            colorFocused[] = COLOR_BUTTON_ACTIVE;
            action = "closeDialog 0;";
        };
        
        // Unit name display
        class UnitNameText: RscText {
            idc = 8602;
            text = "Training for: Pvt. John Smith";
            x = 0.26 * safezoneW + safezoneX;
            y = 0.245 * safezoneH + safezoneY;
            w = 0.46 * safezoneW;
            h = 0.03 * safezoneH;
            colorText[] = COLOR_TEXT;
            sizeEx = 0.035;
            font = "PuristaLight";
        };
        
        // Training courses listbox (left side)
        class TrainingListbox: RscListbox {
            idc = 8610;
            x = 0.26 * safezoneW + safezoneX;
            y = 0.28 * safezoneH + safezoneY;
            w = 0.15 * safezoneW;
            h = 0.46 * safezoneH;
            colorBackground[] = {0.1, 0.1, 0.1, 0.7};
            colorSelectBackground[] = COLOR_BUTTON;
            colorSelectBackground2[] = COLOR_BUTTON_ACTIVE;
            sizeEx = 0.030;
            rowHeight = 0.045;
        };
        
        // Details display (right side)
        class DetailsText: RscStructuredText {
            idc = 8620;
            x = 0.43 * safezoneW + safezoneX;
            y = 0.27 * safezoneH + safezoneY;
            w = 0.29 * safezoneW;
            h = 0.36 * safezoneH;
            colorBackground[] = {0, 0, 0, 0};
            size = 0.032;
        };
        
        // Start training button
        class StartButton: RscButton {
            idc = 8630;
            text = "START TRAINING";
            x = 0.43 * safezoneW + safezoneX;
            y = 0.64 * safezoneH + safezoneY;
            w = 0.14 * safezoneW;
            h = 0.06 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
            colorBackgroundActive[] = COLOR_BUTTON_ACTIVE;
            colorFocused[] = COLOR_BUTTON_ACTIVE;
            action = "";
        };
        
        // Current training status
        class StatusText: RscStructuredText {
            idc = 8640;
            x = 0.58 * safezoneW + safezoneX;
            y = 0.64 * safezoneH + safezoneY;
            w = 0.14 * safezoneW;
            h = 0.06 * safezoneH;
            colorBackground[] = {0, 0, 0, 0};
            size = 0.028;
        };
        
        // Units in training header
        class TrainingHeaderText: RscText {
            idc = 8650;
            text = "UNITS IN TRAINING:";
            x = 0.26 * safezoneW + safezoneX;
            y = 0.745 * safezoneH + safezoneY;
            w = 0.46 * safezoneW;
            h = 0.025 * safezoneH;
            colorText[] = COLOR_TEXT;
            sizeEx = 0.030;
            font = "PuristaBold";
        };
        
        // Training queue list
        class TrainingQueueText: RscStructuredText {
            idc = 8660;
            x = 0.26 * safezoneW + safezoneX;
            y = 0.770 * safezoneH + safezoneY;
            w = 0.46 * safezoneW;
            h = 0.025 * safezoneH;
            colorBackground[] = {0, 0, 0, 0};
            size = 0.028;
        };
    };
};
