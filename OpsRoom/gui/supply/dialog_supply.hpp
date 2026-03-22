/*
    Supply Dialog (Reworked for Convoy System)
    
    Left panel: warehouse contents (categorised, showing counts).
    Centre panel: selected item details + quantity selector.
    Right panel: convoy builder — per-ship manifests, sea lane picker.
    Bottom: active convoys status.
    
    IDC Range: 11400-11499
*/

class OpsRoom_SupplyDialog {
    idd = 11005;
    movingEnable = 0;
    
    class ControlsBackground {
        class Background: RscBackground {
            x = 0.10 * safezoneW + safezoneX;
            y = 0.08 * safezoneH + safezoneY;
            w = 0.80 * safezoneW;
            h = 0.86 * safezoneH;
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
            idc = -1;
            text = "SUPPLY & LOGISTICS — CONVOY OPERATIONS";
            x = 0.11 * safezoneW + safezoneX;
            y = 0.08 * safezoneH + safezoneY;
            w = 0.6 * safezoneW;
            h = 0.04 * safezoneH;
            colorText[] = COLOR_TEXT;
            sizeEx = 0.04;
            font = "PuristaLight";
        };
        
        // Details panel background
        class DetailsPanel: RscBackground {
            x = 0.30 * safezoneW + safezoneX;
            y = 0.15 * safezoneH + safezoneY;
            w = 0.20 * safezoneW;
            h = 0.42 * safezoneH;
            colorBackground[] = {0.1, 0.1, 0.1, 0.3};
        };
        
        // Convoy builder panel background
        class ConvoyPanel: RscBackground {
            x = 0.51 * safezoneW + safezoneX;
            y = 0.15 * safezoneH + safezoneY;
            w = 0.37 * safezoneW;
            h = 0.42 * safezoneH;
            colorBackground[] = {0.14, 0.16, 0.10, 0.6};
        };
        
        // Active convoys background
        class ConvoysBG: RscBackground {
            x = 0.11 * safezoneW + safezoneX;
            y = 0.62 * safezoneH + safezoneY;
            w = 0.77 * safezoneW;
            h = 0.28 * safezoneH;
            colorBackground[] = {0.18, 0.22, 0.14, 0.8};
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
        
        // Ship pool display (top-right of title)
        class ShipPoolText: RscText {
            idc = 11470;
            text = "Ships Available: 0";
            x = 0.68 * safezoneW + safezoneX;
            y = 0.085 * safezoneH + safezoneY;
            w = 0.18 * safezoneW;
            h = 0.03 * safezoneH;
            colorText[] = {0.95, 0.85, 0.40, 1.0};
            sizeEx = 0.030;
            font = "PuristaBold";
            style = 1;  // right align
        };
        
        // ========== LEFT: Warehouse listbox ==========
        class WarehouseListbox: RscListbox {
            idc = 11410;
            x = 0.11 * safezoneW + safezoneX;
            y = 0.15 * safezoneH + safezoneY;
            w = 0.18 * safezoneW;
            h = 0.42 * safezoneH;
            colorBackground[] = {0.1, 0.1, 0.1, 0.7};
            colorSelectBackground[] = COLOR_BUTTON;
            colorSelectBackground2[] = COLOR_BUTTON_ACTIVE;
            sizeEx = 0.028;
            rowHeight = 0.040;
        };
        
        // ========== CENTRE: Item details ==========
        class DetailsText: RscStructuredText {
            idc = 11420;
            x = 0.31 * safezoneW + safezoneX;
            y = 0.16 * safezoneH + safezoneY;
            w = 0.18 * safezoneW;
            h = 0.28 * safezoneH;
            colorBackground[] = {0, 0, 0, 0};
            size = 0.030;
        };
        
        // Quantity controls
        class QtyLabel: RscText {
            idc = -1;
            text = "Quantity:";
            x = 0.31 * safezoneW + safezoneX;
            y = 0.46 * safezoneH + safezoneY;
            w = 0.06 * safezoneW;
            h = 0.03 * safezoneH;
            colorText[] = COLOR_TEXT;
            sizeEx = 0.030;
            font = "PuristaBold";
        };
        
        class QtyMinus: RscButton {
            idc = 11430;
            text = "-";
            x = 0.37 * safezoneW + safezoneX;
            y = 0.46 * safezoneH + safezoneY;
            w = 0.025 * safezoneW;
            h = 0.03 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
            colorBackgroundActive[] = COLOR_BUTTON_ACTIVE;
            colorFocused[] = COLOR_BUTTON_ACTIVE;
            font = "PuristaBold";
            sizeEx = 0.04;
            action = "";
        };
        
        class QtyDisplay: RscText {
            idc = 11431;
            text = "1";
            x = 0.40 * safezoneW + safezoneX;
            y = 0.46 * safezoneH + safezoneY;
            w = 0.03 * safezoneW;
            h = 0.03 * safezoneH;
            colorText[] = {0.95, 0.85, 0.40, 1.0};
            sizeEx = 0.035;
            font = "PuristaBold";
            style = 2;
        };
        
        class QtyPlus: RscButton {
            idc = 11432;
            text = "+";
            x = 0.43 * safezoneW + safezoneX;
            y = 0.46 * safezoneH + safezoneY;
            w = 0.025 * safezoneW;
            h = 0.03 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
            colorBackgroundActive[] = COLOR_BUTTON_ACTIVE;
            colorFocused[] = COLOR_BUTTON_ACTIVE;
            font = "PuristaBold";
            sizeEx = 0.04;
            action = "";
        };
        
        // Add to manifest button
        class AddToShipmentButton: RscButton {
            idc = 11440;
            text = "ADD TO MANIFEST";
            x = 0.31 * safezoneW + safezoneX;
            y = 0.50 * safezoneH + safezoneY;
            w = 0.14 * safezoneW;
            h = 0.04 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
            colorBackgroundActive[] = COLOR_BUTTON_ACTIVE;
            colorFocused[] = COLOR_BUTTON_ACTIVE;
            action = "";
        };
        
        // ========== RIGHT: Convoy Builder ==========
        class ConvoyHeader: RscText {
            idc = -1;
            text = "CONVOY BUILDER";
            x = 0.52 * safezoneW + safezoneX;
            y = 0.15 * safezoneH + safezoneY;
            w = 0.35 * safezoneW;
            h = 0.03 * safezoneH;
            colorText[] = {0.95, 0.85, 0.40, 1.0};
            sizeEx = 0.032;
            font = "PuristaBold";
            style = 2;
        };
        
        // Sea lane selector
        class SeaLaneLabel: RscText {
            idc = -1;
            text = "Route:";
            x = 0.52 * safezoneW + safezoneX;
            y = 0.185 * safezoneH + safezoneY;
            w = 0.06 * safezoneW;
            h = 0.025 * safezoneH;
            colorText[] = COLOR_TEXT;
            sizeEx = 0.028;
            font = "PuristaBold";
        };
        
        class SeaLaneCombo: RscCombo {
            idc = 11471;
            x = 0.59 * safezoneW + safezoneX;
            y = 0.185 * safezoneH + safezoneY;
            w = 0.25 * safezoneW;
            h = 0.025 * safezoneH;
            colorBackground[] = {0.2, 0.2, 0.15, 0.9};
            colorSelectBackground[] = COLOR_BUTTON;
            sizeEx = 0.028;
        };
        
        // Destination port selector (hidden — route dropdown combines both)
        class PortLabel: RscText {
            idc = -1;
            text = "";
            x = 0.52 * safezoneW + safezoneX;
            y = 0.215 * safezoneH + safezoneY;
            w = 0.06 * safezoneW;
            h = 0.025 * safezoneH;
            colorText[] = COLOR_TEXT;
            sizeEx = 0.028;
            font = "PuristaBold";
        };
        
        class PortCombo: RscCombo {
            idc = 11475;
            x = 0.59 * safezoneW + safezoneX;
            y = 0.215 * safezoneH + safezoneY;
            w = 0.25 * safezoneW;
            h = 0.025 * safezoneH;
            colorBackground[] = {0.2, 0.2, 0.15, 0.9};
            colorSelectBackground[] = COLOR_BUTTON;
            sizeEx = 0.028;
        };
        
        // Current ship manifest
        class ManifestHeader: RscText {
            idc = 11472;
            text = "Ship 1 Manifest (0/5 slots)";
            x = 0.52 * safezoneW + safezoneX;
            y = 0.25 * safezoneH + safezoneY;
            w = 0.35 * safezoneW;
            h = 0.025 * safezoneH;
            colorText[] = {0.85, 0.83, 0.70, 1.0};
            sizeEx = 0.026;
            font = "PuristaBold";
        };
        
        // Manifest items (structured text)
        class ManifestList: RscStructuredText {
            idc = 11450;
            x = 0.52 * safezoneW + safezoneX;
            y = 0.28 * safezoneH + safezoneY;
            w = 0.35 * safezoneW;
            h = 0.18 * safezoneH;
            colorBackground[] = {0, 0, 0, 0};
            size = 0.028;
        };
        
        // Convoy summary (ships already confirmed)
        class ConvoySummary: RscStructuredText {
            idc = 11473;
            x = 0.52 * safezoneW + safezoneX;
            y = 0.44 * safezoneH + safezoneY;
            w = 0.35 * safezoneW;
            h = 0.08 * safezoneH;
            colorBackground[] = {0, 0, 0, 0};
            size = 0.026;
        };
        
        // Buttons row
        class ClearManifestBtn: RscButton {
            idc = 11452;
            text = "CLEAR";
            x = 0.52 * safezoneW + safezoneX;
            y = 0.53 * safezoneH + safezoneY;
            w = 0.07 * safezoneW;
            h = 0.035 * safezoneH;
            colorBackground[] = {0.45, 0.20, 0.18, 0.95};
            colorBackgroundActive[] = {0.65, 0.25, 0.20, 1.0};
            colorFocused[] = {0.65, 0.25, 0.20, 1.0};
            sizeEx = 0.028;
            action = "";
        };
        
        class AddShipBtn: RscButton {
            idc = 11474;
            text = "CONFIRM SHIP + ADD ANOTHER";
            x = 0.60 * safezoneW + safezoneX;
            y = 0.53 * safezoneH + safezoneY;
            w = 0.14 * safezoneW;
            h = 0.035 * safezoneH;
            colorBackground[] = COLOR_BUTTON;
            colorBackgroundActive[] = COLOR_BUTTON_ACTIVE;
            colorFocused[] = COLOR_BUTTON_ACTIVE;
            sizeEx = 0.026;
            action = "";
        };
        
        class DispatchConvoyBtn: RscButton {
            idc = 11453;
            text = "DISPATCH CONVOY";
            x = 0.75 * safezoneW + safezoneX;
            y = 0.53 * safezoneH + safezoneY;
            w = 0.12 * safezoneW;
            h = 0.035 * safezoneH;
            colorBackground[] = {0.20, 0.35, 0.18, 0.95};
            colorBackgroundActive[] = {0.28, 0.45, 0.22, 1.0};
            colorFocused[] = {0.28, 0.45, 0.22, 1.0};
            sizeEx = 0.028;
            font = "PuristaBold";
            action = "";
        };
        
        // ========== BOTTOM: Active Convoys ==========
        class ConvoysHeader: RscText {
            idc = -1;
            text = "ACTIVE CONVOYS";
            x = 0.12 * safezoneW + safezoneX;
            y = 0.625 * safezoneH + safezoneY;
            w = 0.20 * safezoneW;
            h = 0.03 * safezoneH;
            colorText[] = {0.95, 0.85, 0.40, 1.0};
            sizeEx = 0.030;
            font = "PuristaBold";
        };
        
        class ConvoysText: RscStructuredText {
            idc = 11460;
            x = 0.12 * safezoneW + safezoneX;
            y = 0.66 * safezoneH + safezoneY;
            w = 0.75 * safezoneW;
            h = 0.22 * safezoneH;
            colorBackground[] = {0, 0, 0, 0};
            size = 0.028;
        };
    };
};
