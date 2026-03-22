/*
    Operation Creation Wizard Dialog
    
    Multi-step wizard for creating a new operation.
    Steps: Name → Select Target → Choose Task → Assign Regiments → Confirm
    
    IDD: 8012
    IDC Range: 11700-11799
    
    Left side: Steps indicator (which step you're on)
    Right side: Current step content
*/

class OpsRoom_OperationWizardDialog {
    idd = 8012;
    movingEnable = 0;
    
    class ControlsBackground {
        class Background: RscBackground {
            x = 0.10 * safezoneW + safezoneX;
            y = 0.08 * safezoneH + safezoneY;
            w = 0.80 * safezoneW;
            h = 0.84 * safezoneH;
            colorBackground[] = COLOR_BACKGROUND;
        };
        
        class TitleBar: RscBackground {
            x = 0.10 * safezoneW + safezoneX;
            y = 0.08 * safezoneH + safezoneY;
            w = 0.80 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = COLOR_HEADER;
        };
        
        class TitleText: RscText {
            idc = 11700;
            text = "CREATE OPERATION";
            x = 0.11 * safezoneW + safezoneX;
            y = 0.08 * safezoneH + safezoneY;
            w = 0.70 * safezoneW;
            h = 0.04 * safezoneH;
            colorText[] = COLOR_TEXT;
            sizeEx = 0.04;
            font = "PuristaLight";
            style = 2;
        };
        
        // Steps sidebar background
        class StepsSidebar: RscBackground {
            x = 0.10 * safezoneW + safezoneX;
            y = 0.12 * safezoneH + safezoneY;
            w = 0.15 * safezoneW;
            h = 0.80 * safezoneH;
            colorBackground[] = {0.18, 0.22, 0.15, 1.0};
        };
    };
    
    class Controls {
        class CloseButton: RscButton {
            idc = -1;
            text = "X";
            x = 0.88 * safezoneW + safezoneX;
            y = 0.085 * safezoneH + safezoneY;
            w = 0.015 * safezoneW;
            h = 0.03 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
            colorBackgroundActive[] = COLOR_BUTTON_ACTIVE;
            colorFocused[] = COLOR_BUTTON_ACTIVE;
            action = "closeDialog 0;";
        };
        
        // Cancel button
        class CancelButton: RscButton {
            idc = 11701;
            text = "CANCEL";
            x = 0.11 * safezoneW + safezoneX;
            y = 0.87 * safezoneH + safezoneY;
            w = 0.08 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = {0.4, 0.2, 0.2, 0.8};
            colorBackgroundActive[] = {0.5, 0.25, 0.25, 1.0};
            colorFocused[] = {0.5, 0.25, 0.25, 1.0};
            action = "closeDialog 0;";
        };
        
        // Step indicator labels (static positions, highlighted dynamically)
        class Step1Label: RscStructuredText {
            idc = 11710;
            x = 0.105 * safezoneW + safezoneX;
            y = 0.14 * safezoneH + safezoneY;
            w = 0.14 * safezoneW;
            h = 0.04 * safezoneH;
            size = 0.028;
            text = "";
        };
        
        class Step2Label: RscStructuredText {
            idc = 11711;
            x = 0.105 * safezoneW + safezoneX;
            y = 0.19 * safezoneH + safezoneY;
            w = 0.14 * safezoneW;
            h = 0.04 * safezoneH;
            size = 0.028;
            text = "";
        };
        
        class Step3Label: RscStructuredText {
            idc = 11712;
            x = 0.105 * safezoneW + safezoneX;
            y = 0.24 * safezoneH + safezoneY;
            w = 0.14 * safezoneW;
            h = 0.04 * safezoneH;
            size = 0.028;
            text = "";
        };
        
        class Step4Label: RscStructuredText {
            idc = 11713;
            x = 0.105 * safezoneW + safezoneX;
            y = 0.29 * safezoneH + safezoneY;
            w = 0.14 * safezoneW;
            h = 0.04 * safezoneH;
            size = 0.028;
            text = "";
        };
        
        class Step5Label: RscStructuredText {
            idc = 11714;
            x = 0.105 * safezoneW + safezoneX;
            y = 0.34 * safezoneH + safezoneY;
            w = 0.14 * safezoneW;
            h = 0.04 * safezoneH;
            size = 0.028;
            text = "";
        };
    };
};
