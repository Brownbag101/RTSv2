/*
    Operation Detail Dialog
    
    Shows detailed view of a single operation.
    Status, target info, assigned regiments, progress.
    
    IDD: 8013
    IDC Range: 11800-11899
*/

class OpsRoom_OperationDetailDialog {
    idd = 8013;
    movingEnable = 0;
    
    class ControlsBackground {
        class Background: RscBackground {
            x = 0.20 * safezoneW + safezoneX;
            y = 0.10 * safezoneH + safezoneY;
            w = 0.60 * safezoneW;
            h = 0.80 * safezoneH;
            colorBackground[] = COLOR_BACKGROUND;
        };
        
        class TitleBar: RscBackground {
            x = 0.20 * safezoneW + safezoneX;
            y = 0.10 * safezoneH + safezoneY;
            w = 0.60 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = COLOR_HEADER;
        };
        
        class TitleText: RscText {
            idc = 11800;
            text = "OPERATION DETAILS";
            x = 0.26 * safezoneW + safezoneX;
            y = 0.10 * safezoneH + safezoneY;
            w = 0.48 * safezoneW;
            h = 0.04 * safezoneH;
            colorText[] = COLOR_TEXT;
            sizeEx = 0.04;
            font = "PuristaLight";
            style = 2;
        };
    };
    
    class Controls {
        class BackButton: RscButton {
            idc = 11801;
            text = "< BACK";
            x = 0.21 * safezoneW + safezoneX;
            y = 0.105 * safezoneH + safezoneY;
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
            x = 0.78 * safezoneW + safezoneX;
            y = 0.105 * safezoneH + safezoneY;
            w = 0.015 * safezoneW;
            h = 0.03 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
            colorBackgroundActive[] = COLOR_BUTTON_ACTIVE;
            colorFocused[] = COLOR_BUTTON_ACTIVE;
            action = "closeDialog 0;";
        };
    };
};
