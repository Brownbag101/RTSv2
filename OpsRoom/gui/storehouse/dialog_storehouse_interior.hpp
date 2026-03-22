/*
    Storehouse Interior Dialog
    
    Left panel: Units near the storehouse (selectable list)
    Centre panel: Selected unit's inventory (collapsible sections)
    Right panel: Storehouse virtual inventory (categorised)
    Bottom: Absorb Crates button + status
    
    IDC Range: 11700-11899
    - 11700-11709: Frame controls (backgrounds, titles, close)
    - 11710: Unit listbox
    - 11720: Unit inventory structured text area
    - 11730: Storehouse inventory listbox
    - 11740: Details/status text
    - 11750: Absorb Crates button
    - 11760-11769: Transfer controls
    - 11770-11899: Dynamic item rows
*/

class OpsRoom_StorehouseInteriorDialog {
    idd = 11007;
    movingEnable = 0;
    
    class ControlsBackground {
        class Background: RscBackground {
            x = 0.10 * safezoneW + safezoneX;
            y = 0.10 * safezoneH + safezoneY;
            w = 0.80 * safezoneW;
            h = 0.82 * safezoneH;
            colorBackground[] = COLOR_BACKGROUND;
        };
        
        class TitleBar: RscBackground {
            x = 0.10 * safezoneW + safezoneX;
            y = 0.10 * safezoneH + safezoneY;
            w = 0.80 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = COLOR_HEADER;
        };
        
        class TitleText: RscText {
            idc = 11700;
            text = "SUPPLY STORES";
            x = 0.16 * safezoneW + safezoneX;
            y = 0.10 * safezoneH + safezoneY;
            w = 0.68 * safezoneW;
            h = 0.04 * safezoneH;
            colorText[] = COLOR_TEXT;
            sizeEx = 0.04;
            font = "PuristaLight";
            style = 2;
        };
        
        // Units panel background
        class UnitsPanelBG: RscBackground {
            x = 0.11 * safezoneW + safezoneX;
            y = 0.17 * safezoneH + safezoneY;
            w = 0.18 * safezoneW;
            h = 0.52 * safezoneH;
            colorBackground[] = {0.14, 0.16, 0.10, 0.6};
        };
        
        // Unit inventory panel background
        class UnitInvPanelBG: RscBackground {
            x = 0.30 * safezoneW + safezoneX;
            y = 0.17 * safezoneH + safezoneY;
            w = 0.28 * safezoneW;
            h = 0.52 * safezoneH;
            colorBackground[] = {0.12, 0.14, 0.09, 0.5};
        };
        
        // Storehouse inventory panel background
        class StorePanelBG: RscBackground {
            x = 0.59 * safezoneW + safezoneX;
            y = 0.17 * safezoneH + safezoneY;
            w = 0.30 * safezoneW;
            h = 0.52 * safezoneH;
            colorBackground[] = {0.14, 0.16, 0.10, 0.6};
        };
        
        // Bottom status area
        class BottomPanelBG: RscBackground {
            x = 0.11 * safezoneW + safezoneX;
            y = 0.72 * safezoneH + safezoneY;
            w = 0.78 * safezoneW;
            h = 0.17 * safezoneH;
            colorBackground[] = {0.18, 0.22, 0.14, 0.8};
        };
    };
    
    class Controls {
        // Back button
        class BackButton: RscButton {
            idc = 11701;
            text = "< BACK";
            x = 0.11 * safezoneW + safezoneX;
            y = 0.105 * safezoneH + safezoneY;
            w = 0.04 * safezoneW;
            h = 0.03 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
            colorBackgroundActive[] = COLOR_BUTTON_ACTIVE;
            colorFocused[] = COLOR_BUTTON_ACTIVE;
            sizeEx = 0.025;
            action = "";
        };
        
        // Close button
        class CloseButton: RscButton {
            idc = -1;
            text = "X";
            x = 0.88 * safezoneW + safezoneX;
            y = 0.105 * safezoneH + safezoneY;
            w = 0.015 * safezoneW;
            h = 0.03 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
            colorBackgroundActive[] = COLOR_BUTTON_ACTIVE;
            colorFocused[] = COLOR_BUTTON_ACTIVE;
            action = "closeDialog 0;";
        };
        
        // === LEFT PANEL: Units ===
        class UnitsHeader: RscText {
            idc = -1;
            text = "UNITS IN AREA";
            x = 0.11 * safezoneW + safezoneX;
            y = 0.145 * safezoneH + safezoneY;
            w = 0.18 * safezoneW;
            h = 0.025 * safezoneH;
            colorText[] = {0.95, 0.85, 0.40, 1.0};
            sizeEx = 0.028;
            font = "PuristaBold";
            style = 2;
        };
        
        class UnitListbox: RscListbox {
            idc = 11710;
            x = 0.115 * safezoneW + safezoneX;
            y = 0.17 * safezoneH + safezoneY;
            w = 0.17 * safezoneW;
            h = 0.52 * safezoneH;
            colorBackground[] = {0, 0, 0, 0};
            colorSelectBackground[] = COLOR_BUTTON;
            colorSelectBackground2[] = COLOR_BUTTON_ACTIVE;
            sizeEx = 0.028;
            rowHeight = 0.035;
        };
        
        // === CENTRE PANEL: Unit Inventory ===
        class UnitInvHeader: RscText {
            idc = 11721;
            text = "SELECT A UNIT";
            x = 0.30 * safezoneW + safezoneX;
            y = 0.145 * safezoneH + safezoneY;
            w = 0.28 * safezoneW;
            h = 0.025 * safezoneH;
            colorText[] = {0.95, 0.85, 0.40, 1.0};
            sizeEx = 0.028;
            font = "PuristaBold";
            style = 2;
        };
        
        class UnitInvText: RscStructuredText {
            idc = 11720;
            x = 0.305 * safezoneW + safezoneX;
            y = 0.17 * safezoneH + safezoneY;
            w = 0.27 * safezoneW;
            h = 0.52 * safezoneH;
            colorBackground[] = {0, 0, 0, 0};
            size = 0.026;
        };
        
        // === RIGHT PANEL: Storehouse Inventory ===
        class StoreHeader: RscText {
            idc = -1;
            text = "STOREHOUSE INVENTORY";
            x = 0.59 * safezoneW + safezoneX;
            y = 0.145 * safezoneH + safezoneY;
            w = 0.30 * safezoneW;
            h = 0.025 * safezoneH;
            colorText[] = {0.95, 0.85, 0.40, 1.0};
            sizeEx = 0.028;
            font = "PuristaBold";
            style = 2;
        };
        
        class StoreListbox: RscListbox {
            idc = 11730;
            x = 0.595 * safezoneW + safezoneX;
            y = 0.17 * safezoneH + safezoneY;
            w = 0.29 * safezoneW;
            h = 0.52 * safezoneH;
            colorBackground[] = {0, 0, 0, 0};
            colorSelectBackground[] = COLOR_BUTTON;
            colorSelectBackground2[] = COLOR_BUTTON_ACTIVE;
            sizeEx = 0.028;
            rowHeight = 0.035;
        };
        
        // === BOTTOM PANEL ===
        class CratesHeader: RscText {
            idc = -1;
            text = "CRATE OPERATIONS";
            x = 0.12 * safezoneW + safezoneX;
            y = 0.725 * safezoneH + safezoneY;
            w = 0.20 * safezoneW;
            h = 0.025 * safezoneH;
            colorText[] = {0.95, 0.85, 0.40, 1.0};
            sizeEx = 0.028;
            font = "PuristaBold";
        };
        
        // Status text (shows crates found, absorption results)
        class StatusText: RscStructuredText {
            idc = 11740;
            x = 0.12 * safezoneW + safezoneX;
            y = 0.76 * safezoneH + safezoneY;
            w = 0.55 * safezoneW;
            h = 0.12 * safezoneH;
            colorBackground[] = {0, 0, 0, 0};
            size = 0.026;
        };
        
        // Absorb Crates button
        class AbsorbButton: RscButton {
            idc = 11750;
            text = "ABSORB CRATES INTO STORES";
            x = 0.69 * safezoneW + safezoneX;
            y = 0.76 * safezoneH + safezoneY;
            w = 0.18 * safezoneW;
            h = 0.05 * safezoneH;
            colorBackground[] = {0.20, 0.35, 0.18, 0.95};
            colorBackgroundActive[] = {0.28, 0.45, 0.22, 1.0};
            colorFocused[] = {0.28, 0.45, 0.22, 1.0};
            font = "PuristaBold";
            sizeEx = 0.030;
            action = "";
        };
        
        // Transfer to unit button (storehouse → unit)
        class TransferToUnitBtn: RscButton {
            idc = 11760;
            text = "< ISSUE TO UNIT";
            x = 0.59 * safezoneW + safezoneX;
            y = 0.695 * safezoneH + safezoneY;
            w = 0.14 * safezoneW;
            h = 0.03 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
            colorBackgroundActive[] = COLOR_BUTTON_ACTIVE;
            colorFocused[] = COLOR_BUTTON_ACTIVE;
            font = "PuristaBold";
            sizeEx = 0.026;
            action = "";
        };
        
        // Transfer to store button (unit → storehouse)
        class TransferToStoreBtn: RscButton {
            idc = 11761;
            text = "DEPOSIT TO STORE >";
            x = 0.74 * safezoneW + safezoneX;
            y = 0.695 * safezoneH + safezoneY;
            w = 0.14 * safezoneW;
            h = 0.03 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
            colorBackgroundActive[] = COLOR_BUTTON_ACTIVE;
            colorFocused[] = COLOR_BUTTON_ACTIVE;
            font = "PuristaBold";
            sizeEx = 0.026;
            action = "";
        };
    };
};
