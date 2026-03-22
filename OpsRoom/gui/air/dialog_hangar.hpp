/*
    Hangar Browser Dialog
    
    Shows all aircraft in the hangar with filter tabs by type.
    Click aircraft to spawn preview. Shows status, fuel, damage.
    
    IDD: 11003
*/

class OpsRoom_HangarDialog {
    idd = 11003;
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
            idc = 11500;
            text = "HANGAR";
            x = 0.31 * safezoneW + safezoneX;
            y = 0.15 * safezoneH + safezoneY;
            w = 0.38 * safezoneW;
            h = 0.04 * safezoneH;
            colorText[] = COLOR_TEXT;
            sizeEx = 0.04;
            font = "PuristaLight";
        };
    };
    
    class Controls {
        class BackButton: RscButton {
            idc = 11501;
            text = "< BACK";
            x = 0.26 * safezoneW + safezoneX;
            y = 0.155 * safezoneH + safezoneY;
            w = 0.04 * safezoneW;
            h = 0.03 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
            colorBackgroundActive[] = COLOR_BUTTON_ACTIVE;
            colorFocused[] = COLOR_BUTTON_ACTIVE;
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
        
        // Filter tabs
        class TabAll: RscButton {
            idc = 11510;
            text = "ALL";
            x = 0.265 * safezoneW + safezoneX;
            y = 0.20 * safezoneH + safezoneY;
            w = 0.05 * safezoneW;
            h = 0.03 * safezoneH;
            colorBackground[] = {0.30, 0.35, 0.25, 1.0};
            colorBackgroundActive[] = COLOR_BUTTON_ACTIVE;
            colorFocused[] = COLOR_BUTTON_ACTIVE;
        };
        class TabFighter: RscButton {
            idc = 11511;
            text = "FIGHTER";
            x = 0.32 * safezoneW + safezoneX;
            y = 0.20 * safezoneH + safezoneY;
            w = 0.07 * safezoneW;
            h = 0.03 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
            colorBackgroundActive[] = COLOR_BUTTON_ACTIVE;
            colorFocused[] = COLOR_BUTTON_ACTIVE;
        };
        class TabGround: RscButton {
            idc = 11512;
            text = "GROUND";
            x = 0.395 * safezoneW + safezoneX;
            y = 0.20 * safezoneH + safezoneY;
            w = 0.07 * safezoneW;
            h = 0.03 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
            colorBackgroundActive[] = COLOR_BUTTON_ACTIVE;
            colorFocused[] = COLOR_BUTTON_ACTIVE;
        };
        class TabBomber: RscButton {
            idc = 11513;
            text = "BOMBER";
            x = 0.47 * safezoneW + safezoneX;
            y = 0.20 * safezoneH + safezoneY;
            w = 0.07 * safezoneW;
            h = 0.03 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
            colorBackgroundActive[] = COLOR_BUTTON_ACTIVE;
            colorFocused[] = COLOR_BUTTON_ACTIVE;
        };
        class TabRecon: RscButton {
            idc = 11514;
            text = "RECON";
            x = 0.545 * safezoneW + safezoneX;
            y = 0.20 * safezoneH + safezoneY;
            w = 0.07 * safezoneW;
            h = 0.03 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
            colorBackgroundActive[] = COLOR_BUTTON_ACTIVE;
            colorFocused[] = COLOR_BUTTON_ACTIVE;
        };
        class TabTransport: RscButton {
            idc = 11515;
            text = "TRANSPORT";
            x = 0.62 * safezoneW + safezoneX;
            y = 0.20 * safezoneH + safezoneY;
            w = 0.115 * safezoneW;
            h = 0.03 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
            colorBackgroundActive[] = COLOR_BUTTON_ACTIVE;
            colorFocused[] = COLOR_BUTTON_ACTIVE;
        };
        
        // Aircraft grid (3x4 = 12 slots)
        class HangarSlot_0: RscBackground { idc = 11550; x = 0.265 * safezoneW + safezoneX; y = 0.25 * safezoneH + safezoneY; w = 0.11 * safezoneW; h = 0.16 * safezoneH; colorBackground[] = COLOR_BUTTON; };
        class HangarSlot_1: RscBackground { idc = 11551; x = 0.385 * safezoneW + safezoneX; y = 0.25 * safezoneH + safezoneY; w = 0.11 * safezoneW; h = 0.16 * safezoneH; colorBackground[] = COLOR_BUTTON; };
        class HangarSlot_2: RscBackground { idc = 11552; x = 0.505 * safezoneW + safezoneX; y = 0.25 * safezoneH + safezoneY; w = 0.11 * safezoneW; h = 0.16 * safezoneH; colorBackground[] = COLOR_BUTTON; };
        class HangarSlot_3: RscBackground { idc = 11553; x = 0.625 * safezoneW + safezoneX; y = 0.25 * safezoneH + safezoneY; w = 0.11 * safezoneW; h = 0.16 * safezoneH; colorBackground[] = COLOR_BUTTON; };
        
        class HangarSlot_4: RscBackground { idc = 11554; x = 0.265 * safezoneW + safezoneX; y = 0.43 * safezoneH + safezoneY; w = 0.11 * safezoneW; h = 0.16 * safezoneH; colorBackground[] = COLOR_BUTTON; };
        class HangarSlot_5: RscBackground { idc = 11555; x = 0.385 * safezoneW + safezoneX; y = 0.43 * safezoneH + safezoneY; w = 0.11 * safezoneW; h = 0.16 * safezoneH; colorBackground[] = COLOR_BUTTON; };
        class HangarSlot_6: RscBackground { idc = 11556; x = 0.505 * safezoneW + safezoneX; y = 0.43 * safezoneH + safezoneY; w = 0.11 * safezoneW; h = 0.16 * safezoneH; colorBackground[] = COLOR_BUTTON; };
        class HangarSlot_7: RscBackground { idc = 11557; x = 0.625 * safezoneW + safezoneX; y = 0.43 * safezoneH + safezoneY; w = 0.11 * safezoneW; h = 0.16 * safezoneH; colorBackground[] = COLOR_BUTTON; };
        
        class HangarSlot_8: RscBackground { idc = 11558; x = 0.265 * safezoneW + safezoneX; y = 0.61 * safezoneH + safezoneY; w = 0.11 * safezoneW; h = 0.16 * safezoneH; colorBackground[] = COLOR_BUTTON; };
        class HangarSlot_9: RscBackground { idc = 11559; x = 0.385 * safezoneW + safezoneX; y = 0.61 * safezoneH + safezoneY; w = 0.11 * safezoneW; h = 0.16 * safezoneH; colorBackground[] = COLOR_BUTTON; };
        class HangarSlot_10: RscBackground { idc = 11560; x = 0.505 * safezoneW + safezoneX; y = 0.61 * safezoneH + safezoneY; w = 0.11 * safezoneW; h = 0.16 * safezoneH; colorBackground[] = COLOR_BUTTON; };
        class HangarSlot_11: RscBackground { idc = 11561; x = 0.625 * safezoneW + safezoneX; y = 0.61 * safezoneH + safezoneY; w = 0.11 * safezoneW; h = 0.16 * safezoneH; colorBackground[] = COLOR_BUTTON; };
        
        // Service buttons
        class RepairAllBtn: RscButton {
            idc = 11580;
            text = "REPAIR ALL";
            x = 0.265 * safezoneW + safezoneX;
            y = 0.79 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.035 * safezoneH;
            colorBackground[] = {0.30, 0.35, 0.25, 1.0};
            colorBackgroundActive[] = {0.35, 0.40, 0.30, 1.0};
            colorFocused[] = {0.35, 0.40, 0.30, 1.0};
        };
        class RearmAllBtn: RscButton {
            idc = 11581;
            text = "REARM ALL";
            x = 0.385 * safezoneW + safezoneX;
            y = 0.79 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.035 * safezoneH;
            colorBackground[] = {0.30, 0.35, 0.25, 1.0};
            colorBackgroundActive[] = {0.35, 0.40, 0.30, 1.0};
            colorFocused[] = {0.35, 0.40, 0.30, 1.0};
        };
        class RefuelAllBtn: RscButton {
            idc = 11582;
            text = "REFUEL ALL";
            x = 0.505 * safezoneW + safezoneX;
            y = 0.79 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.035 * safezoneH;
            colorBackground[] = {0.30, 0.35, 0.25, 1.0};
            colorBackgroundActive[] = {0.35, 0.40, 0.30, 1.0};
            colorFocused[] = {0.35, 0.40, 0.30, 1.0};
        };
        
        // Auto-service toggle buttons
        class AutoRepairBtn: RscButton {
            idc = 11583;
            text = "AUTO-REPAIR: OFF";
            x = 0.265 * safezoneW + safezoneX;
            y = 0.835 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.035 * safezoneH;
            colorBackground[] = {0.35, 0.25, 0.20, 1.0};
            colorBackgroundActive[] = {0.40, 0.30, 0.25, 1.0};
            colorFocused[] = {0.40, 0.30, 0.25, 1.0};
        };
        class AutoRearmBtn: RscButton {
            idc = 11584;
            text = "AUTO-REARM: OFF";
            x = 0.385 * safezoneW + safezoneX;
            y = 0.835 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.035 * safezoneH;
            colorBackground[] = {0.35, 0.25, 0.20, 1.0};
            colorBackgroundActive[] = {0.40, 0.30, 0.25, 1.0};
            colorFocused[] = {0.40, 0.30, 0.25, 1.0};
        };
        class AutoRefuelBtn: RscButton {
            idc = 11585;
            text = "AUTO-REFUEL: OFF";
            x = 0.505 * safezoneW + safezoneX;
            y = 0.835 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.035 * safezoneH;
            colorBackground[] = {0.35, 0.25, 0.20, 1.0};
            colorBackgroundActive[] = {0.40, 0.30, 0.25, 1.0};
            colorFocused[] = {0.40, 0.30, 0.25, 1.0};
        };
    };
};
