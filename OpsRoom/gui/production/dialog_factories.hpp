/*
    Factory Grid Dialog
    
    Grid display showing factories (up to 6).
    Click a factory to open its production interface.
    Click [+] to build a new factory (costs resources + time).
    Reuses Regiment grid pattern.
    
    IDC Range: 11200-11299
*/

class OpsRoom_FactoriesDialog {
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
            idc = -1;
            text = "PRODUCTION";
            x = 0.26 * safezoneW + safezoneX;
            y = 0.15 * safezoneH + safezoneY;
            w = 0.4 * safezoneW;
            h = 0.04 * safezoneH;
            colorText[] = COLOR_TEXT;
            sizeEx = 0.04;
            font = "PuristaLight";
        };
        
        // Warehouse summary
        class WarehouseBG: RscBackground {
            idc = 11210;
            x = 0.265 * safezoneW + safezoneX;
            y = 0.76 * safezoneH + safezoneY;
            w = 0.47 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = {0.18, 0.22, 0.14, 0.8};
        };
        
        class WarehouseText: RscStructuredText {
            idc = 11211;
            x = 0.27 * safezoneW + safezoneX;
            y = 0.765 * safezoneH + safezoneY;
            w = 0.45 * safezoneW;
            h = 0.03 * safezoneH;
            size = 0.028;
        };
    };
    
    class Controls {
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
        
        // Factory Grid - 4x3 = 12 squares (same layout)
        // Row 1
        class FactorySquare_0: RscBackground {
            idc = 11220;
            x = 0.265 * safezoneW + safezoneX;
            y = 0.22 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.16 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
        };
        class FactorySquare_1: RscBackground {
            idc = 11221;
            x = 0.385 * safezoneW + safezoneX;
            y = 0.22 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.16 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
        };
        class FactorySquare_2: RscBackground {
            idc = 11222;
            x = 0.505 * safezoneW + safezoneX;
            y = 0.22 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.16 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
        };
        class FactorySquare_3: RscBackground {
            idc = 11223;
            x = 0.625 * safezoneW + safezoneX;
            y = 0.22 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.16 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
        };
        // Row 2
        class FactorySquare_4: RscBackground {
            idc = 11224;
            x = 0.265 * safezoneW + safezoneX;
            y = 0.40 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.16 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
        };
        class FactorySquare_5: RscBackground {
            idc = 11225;
            x = 0.385 * safezoneW + safezoneX;
            y = 0.40 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.16 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
        };
        class FactorySquare_6: RscBackground {
            idc = 11226;
            x = 0.505 * safezoneW + safezoneX;
            y = 0.40 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.16 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
        };
        class FactorySquare_7: RscBackground {
            idc = 11227;
            x = 0.625 * safezoneW + safezoneX;
            y = 0.40 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.16 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
        };
        // Row 3
        class FactorySquare_8: RscBackground {
            idc = 11228;
            x = 0.265 * safezoneW + safezoneX;
            y = 0.58 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.16 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
        };
        class FactorySquare_9: RscBackground {
            idc = 11229;
            x = 0.385 * safezoneW + safezoneX;
            y = 0.58 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.16 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
        };
        class FactorySquare_10: RscBackground {
            idc = 11230;
            x = 0.505 * safezoneW + safezoneX;
            y = 0.58 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.16 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
        };
        class FactorySquare_11: RscBackground {
            idc = 11231;
            x = 0.625 * safezoneW + safezoneX;
            y = 0.58 * safezoneH + safezoneY;
            w = 0.11 * safezoneW;
            h = 0.16 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
        };
    };
};
