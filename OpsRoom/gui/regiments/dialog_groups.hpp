/*
    Group Management Dialog
    
    Shows groups within a selected regiment (max 12).
    Click group to view unit roster (Phase 3).
    Click [+] to add new group (requires available Captain).
*/

class OpsRoom_GroupDialog {
    idd = 8001;
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
            text = "GROUPS - [Regiment Name]";
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
        
        // Group Grid Container (3x4 = 12 squares)
        // Same layout as regiment grid
        
        // Row 1
        class GroupSquare_0: RscBackground {
            idc = 8100;
            x = 0.265 * safezoneW + safezoneX;
            y = 0.22 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.16 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
        };
        
        class GroupSquare_1: RscBackground {
            idc = 8101;
            x = 0.385 * safezoneW + safezoneX;
            y = 0.22 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.16 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
        };
        
        class GroupSquare_2: RscBackground {
            idc = 8102;
            x = 0.505 * safezoneW + safezoneX;
            y = 0.22 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.16 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
        };
        
        class GroupSquare_3: RscBackground {
            idc = 8103;
            x = 0.625 * safezoneW + safezoneX;
            y = 0.22 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.16 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
        };
        
        // Row 2
        class GroupSquare_4: RscBackground {
            idc = 8104;
            x = 0.265 * safezoneW + safezoneX;
            y = 0.40 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.16 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
        };
        
        class GroupSquare_5: RscBackground {
            idc = 8105;
            x = 0.385 * safezoneW + safezoneX;
            y = 0.40 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.16 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
        };
        
        class GroupSquare_6: RscBackground {
            idc = 8106;
            x = 0.505 * safezoneW + safezoneX;
            y = 0.40 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.16 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
        };
        
        class GroupSquare_7: RscBackground {
            idc = 8107;
            x = 0.625 * safezoneW + safezoneX;
            y = 0.40 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.16 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
        };
        
        // Row 3
        class GroupSquare_8: RscBackground {
            idc = 8108;
            x = 0.265 * safezoneW + safezoneX;
            y = 0.58 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.16 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
        };
        
        class GroupSquare_9: RscBackground {
            idc = 8109;
            x = 0.385 * safezoneW + safezoneX;
            y = 0.58 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.16 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
        };
        
        class GroupSquare_10: RscBackground {
            idc = 8110;
            x = 0.505 * safezoneW + safezoneX;
            y = 0.58 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.16 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
        };
        
        class GroupSquare_11: RscBackground {
            idc = 8111;
            x = 0.625 * safezoneW + safezoneX;
            y = 0.58 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.16 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
        };
    };
};
