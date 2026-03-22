/*
    Unit Roster Dialog
    
    Shows detailed information about all units in a group.
    Displays name, rank, role, time alive, etc.
*/

class OpsRoom_RosterDialog {
    idd = 8002;
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
            idc = 8010;
            text = "UNIT ROSTER - [Group Name]";
            x = 0.31 * safezoneW + safezoneX;  // Moved right to avoid back button
            y = 0.15 * safezoneH + safezoneY;
            w = 0.38 * safezoneW;
            h = 0.04 * safezoneH;
            colorText[] = COLOR_TEXT;
            sizeEx = 0.04;
            font = "PuristaLight";
            style = 2;  // Center aligned
        };
    };
    
    class Controls {
        class BackButton: RscButton {
            idc = 8011;
            text = "< BACK";
            x = 0.26 * safezoneW + safezoneX;
            y = 0.155 * safezoneH + safezoneY;
            w = 0.04 * safezoneW;
            h = 0.03 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
            colorBackgroundActive[] = COLOR_BUTTON_ACTIVE;
            colorFocused[] = COLOR_BUTTON_ACTIVE;
            action = "";  // Set dynamically in code
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
        
        // Scrollable list area for units
        class RosterList: RscStructuredText {
            idc = 8020;
            x = 0.27 * safezoneW + safezoneX;
            y = 0.22 * safezoneH + safezoneY;
            w = 0.46 * safezoneW;
            h = 0.63 * safezoneH;
            colorBackground[] = {0.1, 0.1, 0.1, 0.5};
            text = "";
            size = 0.032;
        };
    };
};
