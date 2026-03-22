/*
    Dispatch Log Dialog
    
    Full-screen log of all received dispatches.
    Newest first, with unread indicators and colour-coded type bars.
    Click any dispatch to re-read it and optionally FOCUS.
    
    IDD: 8020
    IDC Range: 12100-12199
    
    Layout:
    ┌─── DISPATCHES ──────────────────────────── X ─┐
    │                                                │
    │  Unread: 3  |  Total: 15  |  [CLEAR ALL]       │
    │                                                │
    │  ■ FLASH   | UNIT KILLED           | 14:32 hrs │
    │    PRIORITY | MEDAL EARNED          | 14:20 hrs │
    │    ROUTINE  | TRAINING COMPLETE     | 13:55 hrs │
    │    ...                                         │
    │                                                │
    │  ── SELECTED DISPATCH ──                       │
    │  [Full body text]                              │
    │  [FOCUS]                                       │
    └────────────────────────────────────────────────┘
*/

class OpsRoom_DispatchLogDialog {
    idd = 8020;
    movingEnable = 0;
    
    class ControlsBackground {
        class Background: RscBackground {
            x = 0.15 * safezoneW + safezoneX;
            y = 0.10 * safezoneH + safezoneY;
            w = 0.70 * safezoneW;
            h = 0.80 * safezoneH;
            colorBackground[] = COLOR_BACKGROUND;
        };
        
        class TitleBar: RscBackground {
            x = 0.15 * safezoneW + safezoneX;
            y = 0.10 * safezoneH + safezoneY;
            w = 0.70 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = COLOR_HEADER;
        };
        
        class TitleText: RscText {
            idc = -1;
            text = "DISPATCHES";
            x = 0.16 * safezoneW + safezoneX;
            y = 0.10 * safezoneH + safezoneY;
            w = 0.60 * safezoneW;
            h = 0.04 * safezoneH;
            colorText[] = COLOR_TEXT;
            sizeEx = 0.04;
            font = "PuristaLight";
            style = 2;
        };
        
        // Status bar at bottom
        class StatusBar: RscBackground {
            x = 0.15 * safezoneW + safezoneX;
            y = 0.86 * safezoneH + safezoneY;
            w = 0.70 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = COLOR_HEADER;
        };
        
        // Divider between list and detail
        class DetailDivider: RscBackground {
            x = 0.15 * safezoneW + safezoneX;
            y = 0.65 * safezoneH + safezoneY;
            w = 0.70 * safezoneW;
            h = 0.002 * safezoneH;
            colorBackground[] = {0.50, 0.45, 0.35, 0.6};
        };
    };
    
    class Controls {
        class CloseButton: RscButton {
            idc = -1;
            text = "X";
            x = 0.83 * safezoneW + safezoneX;
            y = 0.105 * safezoneH + safezoneY;
            w = 0.015 * safezoneW;
            h = 0.03 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
            colorBackgroundActive[] = COLOR_BUTTON_ACTIVE;
            colorFocused[] = COLOR_BUTTON_ACTIVE;
            action = "closeDialog 0;";
        };
        
        // Summary line
        class SummaryText: RscStructuredText {
            idc = 12100;
            x = 0.16 * safezoneW + safezoneX;
            y = 0.145 * safezoneH + safezoneY;
            w = 0.50 * safezoneW;
            h = 0.03 * safezoneH;
            size = 0.028;
            text = "";
        };
        
        // Mark All Read button
        class MarkReadButton: RscButton {
            idc = 12101;
            text = "MARK ALL READ";
            x = 0.70 * safezoneW + safezoneX;
            y = 0.148 * safezoneH + safezoneY;
            w = 0.12 * safezoneW;
            h = 0.025 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
            colorBackgroundActive[] = COLOR_BUTTON_ACTIVE;
            colorFocused[] = COLOR_BUTTON_ACTIVE;
            font = "PuristaBold";
            sizeEx = 0.024;
            action = "";
        };
        
        // Status bar text
        class StatusText: RscStructuredText {
            idc = 12102;
            x = 0.16 * safezoneW + safezoneX;
            y = 0.86 * safezoneH + safezoneY;
            w = 0.68 * safezoneW;
            h = 0.04 * safezoneH;
            size = 0.028;
            text = "";
            class Attributes {
                font = "PuristaLight";
                color = "#D9D5C9";
                align = "center";
                shadow = 1;
            };
        };
        
        // Detail panel - selected dispatch body
        class DetailLabel: RscText {
            idc = 12103;
            text = "SELECT A DISPATCH ABOVE";
            x = 0.16 * safezoneW + safezoneX;
            y = 0.66 * safezoneH + safezoneY;
            w = 0.68 * safezoneW;
            h = 0.025 * safezoneH;
            colorText[] = {0.7, 0.65, 0.55, 0.8};
            sizeEx = 0.026;
            font = "PuristaBold";
        };
        
        class DetailBody: RscStructuredText {
            idc = 12104;
            x = 0.16 * safezoneW + safezoneX;
            y = 0.69 * safezoneH + safezoneY;
            w = 0.55 * safezoneW;
            h = 0.15 * safezoneH;
            size = 0.028;
            text = "";
        };
        
        // Focus button (for selected dispatch)
        class DetailFocusButton: RscButton {
            idc = 12105;
            text = "FOCUS";
            x = 0.73 * safezoneW + safezoneX;
            y = 0.69 * safezoneH + safezoneY;
            w = 0.09 * safezoneW;
            h = 0.035 * safezoneH;
            colorBackground[] = {0.30, 0.35, 0.25, 0.9};
            colorBackgroundActive[] = {0.35, 0.42, 0.30, 1.0};
            colorFocused[] = {0.35, 0.42, 0.30, 1.0};
            font = "PuristaBold";
            sizeEx = 0.03;
            action = "";
        };
    };
};
