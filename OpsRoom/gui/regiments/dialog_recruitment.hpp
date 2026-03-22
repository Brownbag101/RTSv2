/*
    Recruitment Dialog
    
    Shows available recruits with skills and allows enlistment.
    Consistent with regiment system styling.
*/

class OpsRoom_RecruitmentDialog {
    idd = 8004;
    movingEnable = 0;
    
    class ControlsBackground {
        class Background: RscBackground {
            x = 0.20 * safezoneW + safezoneX;
            y = 0.15 * safezoneH + safezoneY;
            w = 0.60 * safezoneW;
            h = 0.70 * safezoneH;
            colorBackground[] = COLOR_BACKGROUND;
        };
        
        class TitleBar: RscBackground {
            x = 0.20 * safezoneW + safezoneX;
            y = 0.15 * safezoneH + safezoneY;
            w = 0.60 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = COLOR_HEADER;
        };
        
        class TitleText: RscText {
            idc = 8410;
            text = "RECRUITMENT DEPOT";
            x = 0.26 * safezoneW + safezoneX;
            y = 0.15 * safezoneH + safezoneY;
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
            idc = 8411;
            text = "< BACK";
            x = 0.21 * safezoneW + safezoneX;
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
            x = 0.78 * safezoneW + safezoneX;
            y = 0.155 * safezoneH + safezoneY;
            w = 0.015 * safezoneW;
            h = 0.03 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
            colorBackgroundActive[] = COLOR_BUTTON_ACTIVE;
            colorFocused[] = COLOR_BUTTON_ACTIVE;
            action = "closeDialog 0;";
        };
        
        // Manpower display
        class ManpowerText: RscText {
            idc = 8420;
            text = "Available Manpower: 5 | Recruits in Pool: 5";
            x = 0.22 * safezoneW + safezoneX;
            y = 0.21 * safezoneH + safezoneY;
            w = 0.56 * safezoneW;
            h = 0.03 * safezoneH;
            colorText[] = COLOR_TEXT;
            sizeEx = 0.035;
            font = "PuristaLight";
        };
        
        // Recruit listbox (left side)
        class RecruitListbox: RscListbox {
            idc = 8421;
            x = 0.22 * safezoneW + safezoneX;
            y = 0.25 * safezoneH + safezoneY;
            w = 0.26 * safezoneW;
            h = 0.50 * safezoneH;
            colorBackground[] = {0.1, 0.1, 0.1, 0.7};
            colorSelectBackground[] = COLOR_BUTTON;
            colorSelectBackground2[] = COLOR_BUTTON_ACTIVE;
            sizeEx = 0.035;
            rowHeight = 0.04;
        };
        
        // Detail panel (right side)
        class DetailPanel: RscStructuredText {
            idc = 8422;
            x = 0.50 * safezoneW + safezoneX;
            y = 0.25 * safezoneH + safezoneY;
            w = 0.28 * safezoneW;
            h = 0.50 * safezoneH;
            colorBackground[] = {0.1, 0.1, 0.1, 0.5};
            size = 0.032;
        };
        
        // Enlist button
        class EnlistButton: RscButton {
            idc = 8430;
            text = "ENLIST RECRUIT";
            x = 0.60 * safezoneW + safezoneX;
            y = 0.77 * safezoneH + safezoneY;
            w = 0.18 * safezoneW;
            h = 0.05 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
            colorBackgroundActive[] = COLOR_BUTTON_ACTIVE;
            colorFocused[] = COLOR_BUTTON_ACTIVE;
            action = "";
        };
        
        // Refresh button
        class RefreshButton: RscButton {
            idc = 8431;
            text = "REFRESH POOL";
            x = 0.22 * safezoneW + safezoneX;
            y = 0.77 * safezoneH + safezoneY;
            w = 0.15 * safezoneW;
            h = 0.05 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
            colorBackgroundActive[] = COLOR_BUTTON_ACTIVE;
            colorFocused[] = COLOR_BUTTON_ACTIVE;
            action = "";
        };
    };
};
