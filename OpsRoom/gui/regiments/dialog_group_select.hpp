/*
    Group Select Dialog (for Recruitment)
    
    Simple group selection dialog for assigning recruits to groups.
*/

class OpsRoom_GroupSelectDialog {
    idd = 8005;
    movingEnable = 0;
    
    class ControlsBackground {
        class Background: RscBackground {
            x = 0.35 * safezoneW + safezoneX;
            y = 0.25 * safezoneH + safezoneY;
            w = 0.30 * safezoneW;
            h = 0.50 * safezoneH;
            colorBackground[] = COLOR_BACKGROUND;
        };
        
        class TitleBar: RscBackground {
            x = 0.35 * safezoneW + safezoneX;
            y = 0.25 * safezoneH + safezoneY;
            w = 0.30 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = COLOR_HEADER;
        };
        
        class TitleText: RscText {
            idc = 8510;
            text = "SELECT GROUP";
            x = 0.37 * safezoneW + safezoneX;
            y = 0.25 * safezoneH + safezoneY;
            w = 0.26 * safezoneW;
            h = 0.04 * safezoneH;
            colorText[] = COLOR_TEXT;
            sizeEx = 0.04;
            font = "PuristaLight";
            style = 2;
        };
    };
    
    class Controls {
        class CloseButton: RscButton {
            idc = -1;
            text = "X";
            x = 0.635 * safezoneW + safezoneX;
            y = 0.255 * safezoneH + safezoneY;
            w = 0.015 * safezoneW;
            h = 0.03 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
            colorBackgroundActive[] = COLOR_BUTTON_ACTIVE;
            colorFocused[] = COLOR_BUTTON_ACTIVE;
            action = "closeDialog 0;";
        };
        
        class InfoText: RscText {
            idc = 8511;
            text = "Select a group to assign the recruit:";
            x = 0.37 * safezoneW + safezoneX;
            y = 0.31 * safezoneH + safezoneY;
            w = 0.26 * safezoneW;
            h = 0.03 * safezoneH;
            colorText[] = COLOR_TEXT;
            sizeEx = 0.032;
        };
        
        // Group listbox
        class GroupListbox: RscListbox {
            idc = 8520;
            x = 0.37 * safezoneW + safezoneX;
            y = 0.35 * safezoneH + safezoneY;
            w = 0.26 * safezoneW;
            h = 0.30 * safezoneH;
            colorBackground[] = {0.1, 0.1, 0.1, 0.7};
            colorSelectBackground[] = COLOR_BUTTON;
            colorSelectBackground2[] = COLOR_BUTTON_ACTIVE;
            sizeEx = 0.035;
            rowHeight = 0.04;
        };
        
        // Confirm button
        class ConfirmButton: RscButton {
            idc = 8530;
            text = "ASSIGN TO GROUP";
            x = 0.47 * safezoneW + safezoneX;
            y = 0.67 * safezoneH + safezoneY;
            w = 0.15 * safezoneW;
            h = 0.05 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
            colorBackgroundActive[] = COLOR_BUTTON_ACTIVE;
            colorFocused[] = COLOR_BUTTON_ACTIVE;
            action = "";
        };
        
        // Cancel button
        class CancelButton: RscButton {
            idc = 8531;
            text = "CANCEL";
            x = 0.37 * safezoneW + safezoneX;
            y = 0.67 * safezoneH + safezoneY;
            w = 0.08 * safezoneW;
            h = 0.05 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
            colorBackgroundActive[] = COLOR_BUTTON_ACTIVE;
            colorFocused[] = COLOR_BUTTON_ACTIVE;
            action = "";
        };
    };
};
