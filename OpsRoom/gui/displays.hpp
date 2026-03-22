/*
    Operations Room - Display Definitions
    
    Defines the main HUD layout using RscTitles.
    Contains top bar (resources), bottom bar (unit info), and backgrounds.
*/

class RscTitles {
    class OpsRoom_HUD {
        idd = -1;
        duration = 99999;
        fadeIn = 0;
        fadeOut = 0;
        name = "OpsRoom_HUD";
        onLoad = "uiNamespace setVariable ['OpsRoom_HUD_Display', _this select 0];";
        
        class controls {
            // ========================================
            // TOP BAR - RESOURCES
            // ========================================
            class TopBar: RscBackground {
                idc = 9001;
                x = safezoneX;
                y = safezoneY;
                w = safezoneW;
                h = 0.06 * safezoneH;
            };
            
            class TopFrame: RscFrame {
                idc = 9005;
                x = safezoneX;
                y = safezoneY;
                w = safezoneW;
                h = 0.06 * safezoneH;
            };
            
            class ResourceDisplay: RscStructuredText {
                idc = 9010;
                x = safezoneX + (0.01 * safezoneW);
                y = safezoneY + (0.015 * safezoneH);
                w = safezoneW - (0.02 * safezoneW);
                h = 0.03 * safezoneH;
                size = 0.03;
                text = "";
                class Attributes {
                    font = FONT_MAIN;
                    color = "#D9D5C9";
                    align = "center";
                    shadow = 1;
                };
            };
            
            // ========================================
            // BOTTOM BAR - UNIT INFORMATION (TALLER)
            // ========================================
            class BottomBar: RscBackground {
                idc = 9002;
                x = safezoneX;
                y = safezoneY + safezoneH - (0.08 * safezoneH);
                w = safezoneW;
                h = 0.08 * safezoneH;
            };
            
            class BottomFrame: RscFrame {
                idc = 9006;
                x = safezoneX;
                y = safezoneY + safezoneH - (0.08 * safezoneH);
                w = safezoneW;
                h = 0.08 * safezoneH;
            };
            
            class UnitInfoBox: RscBackground {
                idc = 9003;
                x = safezoneX + (safezoneW / 2) - (0.15 * safezoneW);
                y = safezoneY + safezoneH - (0.07 * safezoneH);
                w = 0.30 * safezoneW;
                h = 0.06 * safezoneH;
                colorBackground[] = COLOR_ELEMENT_BG;
            };
            
            class UnitInfoFrame: RscFrame {
                idc = 9007;
                x = safezoneX + (safezoneW / 2) - (0.15 * safezoneW);
                y = safezoneY + safezoneH - (0.07 * safezoneH);
                w = 0.30 * safezoneW;
                h = 0.06 * safezoneH;
            };
            

            
            class UnitInfoDisplay: RscStructuredText {
                idc = 9020;
                x = safezoneX + (safezoneW / 2) - (0.145 * safezoneW);
                y = safezoneY + safezoneH - (0.065 * safezoneH);
                w = 0.29 * safezoneW;
                h = 0.055 * safezoneH;
                size = 0.03;
                text = "";
                class Attributes {
                    font = FONT_MAIN;
                    color = "#D9D5C9";
                    align = "center";
                    shadow = 1;
                };
            };
        };
    };
};

// Include regiment dialog
#include "regiments\dialog_regiments.hpp"

// Include group dialog
#include "regiments\dialog_groups.hpp"

// Include roster grid dialog
#include "regiments\dialog_roster_grid.hpp"

// Include unit detail dialog
#include "regiments\dialog_unit_detail.hpp"

// Include captain selection dialog
#include "regiments\dialog_captain_select.hpp"

// Include major selection dialog
#include "regiments\dialog_major_select.hpp"

// Include recruitment dialog
#include "regiments\dialog_recruitment.hpp"

// Include group select dialog (for recruitment)
#include "regiments\dialog_group_select.hpp"

// Include training dialog
#include "regiments\dialog_training.hpp"

// Research system dialogs
#include "research\dialog_research_categories.hpp"
#include "research\dialog_research_subcategories.hpp"
#include "research\dialog_research_tree.hpp"

// Production system dialogs
#include "production\dialog_factories.hpp"
#include "production\dialog_factory_interior.hpp"

// Supply system dialog
#include "supply\dialog_supply.hpp"

// Dispatch system dialog
#include "dispatches\dialog_dispatches.hpp"

// Intelligence system dialog
#include "intelligence\dialog_opsmap.hpp"

// Storehouse system dialogs
#include "storehouse\dialog_storehouse_grid.hpp"
#include "storehouse\dialog_storehouse_interior.hpp"

// Operations system dialogs
#include "operations\dialog_operations.hpp"
#include "operations\dialog_operation_wizard.hpp"
#include "operations\dialog_operation_detail.hpp"

// Air Operations dialogs
#include "air\dialog_air_wings.hpp"
#include "air\dialog_wing_detail.hpp"
#include "air\dialog_wing_mission.hpp"
#include "air\dialog_hangar.hpp"
