/*
    Operations Room - Configuration File
    
    Include this in your mission's description.ext:
    #include "OpsRoom\config.hpp"
*/

// Function registration
class CfgFunctions {
    class OpsRoom {
        class GUI {
            file = "OpsRoom\gui";
            class initMainGUI {};
            class updateUnitInfo {};
            class updateResources {};
            class createButtons {};
            class createButtonsOnZeus {};
            class createDateTimeDisplay {};
            class updateDateTime {};
            class updateInventoryButton {};
        };
        class Regiments {
            file = "OpsRoom\gui\regiments";
            class openRegiments {};
            class populateRegimentGrid {};
            class getAvailableMajors {};
            class showAddRegiment {};
            class createRegiment {};
            class openGroups {};
            class populateGroupGrid {};
            class getAvailableCaptains {};
            class showAddGroup {};
            class createGroup {};
            class openRoster {};  // Old roster (will be deprecated)
            class populateRoster {};  // Old roster (will be deprecated)
            class openRosterGrid {};  // New roster grid
            class populateRosterGrid {};  // New roster grid
            class openUnitDetail {};  // Unit detail dialog
            class populateUnitDetail {};  // Unit detail display
            class promoteUnit {};  // Promote unit
            class demoteUnit {};  // Demote unit
            class openCaptainSelect {};  // Captain selection
            class populateCaptainGrid {};  // Captain grid
            class openMajorSelect {};  // Major selection
            class populateMajorGrid {};  // Major grid
            class generateRecruit {};  // Generate recruit with skills
            class initRecruitmentPool {};  // Initialize recruitment pool
            class recruitmentRefreshLoop {};  // Refresh loop for recruitment
            class openRecruitment {};  // Open recruitment dialog
            class populateRecruitmentList {};  // Populate recruit list
            class showRecruitDetails {};  // Show recruit details
            class processRecruitment {};  // Process enlistment
            class openGroupSelectForRecruit {};  // Group selection for recruit
            class applyRegimentLoadout {};  // Apply type-specific loadout
            class spawnRecruit {};  // Spawn and assign recruit
            class openTraining {};  // Open training dialog
            class populateTrainingList {};  // Populate training courses
            class showTrainingDetails {};  // Show course details
            class startTraining {};  // Begin training
            class completeTraining {};  // Finish training
            class updateTrainingStatusDisplay {};  // Update training status
            class trainingMonitor {};  // Background training loop
            class initServiceRecords {};  // Medal/service system init
            class registerUnitService {};  // Register unit for tracking
            class getServiceRecord {};  // Get unit service record
            class checkMedals {};  // Check & award medals
            class writeOperationService {};  // Write op results to records
        };
        class Data {
            file = "OpsRoom\data";
            class initRegiments {};
        };
        class Zeus {
            file = "OpsRoom\zeus";
            class hideZeusUI {};
            class getPhoneticName {};
            class autoDetachUnits {};
            class autoReattachUnits {};
            class monitorSelection {};
            class unifiedZeusMonitor {};
            class reformGroup {};
            class createRegroupButton {};
            class createSpeedControls {};
            class getUnitAbilities {};
            class createAbilityButton {};
            class updateContextButtons {};
            class createStandardButtons {};
            class updateStandardButtons {};
            class executeStandardCommand {};
            class createButtonMenu {};
            class closeButtonMenu {};
            class getStanceMenu {};
            class getCombatModeMenu {};
            class getSpeedModeMenu {};
            class getFormationMenu {};
            class getBehaviourMenu {};
            class revealEnemy {};
            class hideEnemy {};
            class toggleFollowCamera {};
            class followCameraLoop {};
            class airFollowCameraLoop {};
            class openInventory {};
            class closeInventory {};
            class findNearContainers {};
            class getContainerItems {};
            class transferItem {};
            class renderInventoryPanels {};
            class refreshInventory {};
            class openUnitDossier {};  // New dossier panel on Zeus display
            class closeDossier {};  // Close dossier panel
            class renderDossierTab {};  // Render active dossier tab
            class debugServiceRecord {};  // Debug/cheat panel for testing
            class updateOperationMarkers {};  // Show Draw3D markers at operation targets
        };
        class Abilities {
            file = "OpsRoom\abilities";
            class checkSuppressCapable {};
            class startSuppressTargeting {};
            class cancelSuppressTargeting {};
            class executeSuppression {};
            class checkAimedShotCapable {};
            class executeAimedShot {};
            class cancelAimedShotTargeting {};
            // Timebomb
            class startTimebombTargeting {};
            class cancelTimebombTargeting {};
            class executeTimebomb {};
            // Reconnoitre
            class startReconTargeting {};
            class cancelReconTargeting {};
            class executeReconnoitre {};
            // Infiltrate
            class startInfiltrateTargeting {};
            class cancelInfiltrateTargeting {};
            class executeInfiltrate {};
            // Assassinate
            class cancelAssassinateTargeting {};
            class executeAssassinate {};
            // Build system
            class startBuildPlacement {};
            class startLinePlacement {};
            class cancelBuildPlacement {};
            class executeBuild {};
            class executeLineBuild {};
            class executeDemolish {};
            // Air Strike
            class airStrike_getAvailable {};
            class airStrike_hasWeaponType {};
            class airStrike_scatterPos {};
            class airStrike_guideProjectile {};
            class startAirStrikeTargeting {};
            class cancelAirStrikeTargeting {};
            class executeAirStrike {};
            class airStrike_gunRun {};
            class airStrike_bombRun {};
            class airStrike_rocketRun {};
            class airStrike_strafeRun {};
            class airStrike_torpedoRun {};
            class airStrike_cleanup {};
            class airStrike_returnToLoiter {};
            // Artillery
            class artillery_getAvailable {};
            class startArtilleryTargeting {};
            class cancelArtilleryTargeting {};
            class executeArtillery {};
        };
        class ZeusAbilities {
            file = "OpsRoom\zeus\abilities";
            class ability_regroup {};
            class ability_suppressiveFire {};
            class ability_aimedShot {};
            class ability_repair {};
            class ability_heal {};
            class ability_grenade {};
            class getGrenadeMenu {};
            class enterGrenadeTargeting {};
            class calculateGrenadeArc {};
            class throwGrenade {};
            class cancelGrenadeTargeting {};
            // New abilities
            class ability_timebomb {};
            class ability_reconnoitre {};
            class ability_infiltrate {};
            class ability_assassinate {};
            class ability_airStrike {};
            class ability_artillery {};
            class ability_artillery_roundMenu {};
            class ability_build {};
        };
        class Supply {
            file = "OpsRoom\gui\supply";
            class openSupply {};
            class populateWarehouse {};
            class showSupplyDetails {};
            class updateShipmentQueue {};
            class updateActiveShipments {};
            class shipItems {};
            class deliverItems {};
            class supplyMonitor {};
            // Convoy & Sea Lane system
            class initSeaLanes {};
            class convoyMonitor {};
            class spawnConvoyShips {};
            class onShipArrival {};
            class onShipDestroyed {};
            class enemyShippingMonitor {};
            class drawSeaLanes {};
            class convoyDraw3D {};
        };
        class Production {
            file = "OpsRoom\gui\production";
            class openFactories {};
            class populateFactoryGrid {};
            class buildFactory {};
            class openFactoryInterior {};
            class populateProductionList {};
            class showProductionDetails {};
            class startProduction {};
            class cancelProduction {};
            class productionMonitor {};
        };
        class Operations {
            file = "OpsRoom\gui\operations";
            class openOperations {};
            class populateOperations {};
            class openOperationWizard {};
            class wizardShowStep {};
            class createOperation {};
            class openOperationDetail {};
        };
        class Dispatches {
            file = "OpsRoom\gui\dispatches";
            class initDispatches {};
            class dispatch {};
            class showDispatchPopup {};
            class dismissDispatch {};
            class focusDispatch {};
            class updateDispatchBadge {};
            class openDispatchLog {};
            class populateDispatchLog {};
        };
        class Intelligence {
            file = "OpsRoom\gui\intelligence";
            class initStrategicLocations {};
            class getIntelLevel {};
            class captureMonitor {};
            class gatherIntel {};
            class intelMonitor {};
            class updateMapMarkers {};
            class openOpsMap {};
            class openOpsMapPicker {};
            class showIntelCard {};
            class setLocationData {};
            class initCommandIntel {};          // Command Intelligence system init
            class getCommandIntelLevel {};      // Get effective intel level
            class commandIntelMonitor {};       // Background intel decay/update loop
            class locationDraw3D {};            // Location name/progress/radius Draw3D
            class initLocationBuildings {};     // Bind buildings to locations
            class toggleLocationBuildings {};   // Add/remove buildings from Zeus on capture
        };
        class Storehouse {
            file = "OpsRoom\gui\storehouse";
            class initStorehouses {};
            class openStorehouseGrid {};
            class populateStorehouseGrid {};
            class openStorehouseInterior {};
            class populateStorehouseUnits {};
            class populateStorehouseUnitInv {};
            class populateStorehouseInventory {};
            class absorbCrates {};
            class scanStorehouseCrates {};
            class storehouseTransfer {};
        };
        class Research {
            file = "OpsRoom\gui\research";
            class openResearchCategories {};
            class openResearchSubcategories {};
            class openResearchTree {};
            class populateResearchTree {};
            class showResearchDetails {};
            class startResearch {};
            class completeResearch {};
            class researchMonitor {};
        };
        class AirGUI {
            file = "OpsRoom\gui\air";
            class openAirOps {};
            class populateWingGrid {};
            class showCreateWing {};
            class openWingDetail {};
            class populateWingMembers {};
            class spawnPreviewAircraft {};
            class deletePreviewAircraft {};
            class openWingMission {};
            class showAssignAircraft {};
            class openHangar {};
            class populateHangarGrid {};
            class openAirStrikeMapPicker {};
            class showAssignPilot {};
            class openPilotRoster {};
            class showAssignCrew {};
            class openCrewRoster {};
            class openWingSchedule {};
        };
        class Air {
            file = "OpsRoom\air";
            class initHangar {};
            class addToHangar {};
            class removeFromHangar {};
            class getHangarAircraft {};
            class repairAircraft {};
            class createWing {};
            class assignToWing {};
            class removeFromWing {};
            class launchWing {};
            class landWing {};
            class scramble {};
            class scrambleCombatMonitor {};
            class airDraw3D {};
            class reassignAirborneMission {};
            class airReconMonitor {};
            class photoReconMonitor {};
            class processReconPhotos {};
            class assignPilot {};
            class getAircraftLoadout {};
            class assignCrew {};
            class missionScheduler {};
            class autoServiceMonitor {};
            class aircraftStatusMonitor {};
        };
        class Cargo {
            file = "OpsRoom\gui\cargo";
            class initCargo {};
            class openCargoMenu {};
            class loadCargo {};
            class unloadCargo {};
            class getCargoCapacity {};
            class updateCargoDisplay {};
            class cargoDraw3D {};
            class loadAllCargo {};
            class unloadAllCargo {};
        };
        class Debug {
            file = "OpsRoom\debug";
            class spawnTestAirCrew {};
        };
        class Missions {
            file = "OpsRoom\missions";
            class spawnStartingRegiment {};
            class createClearAreaTask {};
            class checkAreaClear {};
            class createEngineersTask {};
            class showMissionNotification {};
            class create3DMarker {};
            class remove3DMarker {};
            class createMissionIntro {};
        };
        class AI {
            file = "OpsRoom\ai";
            class aiCommanderMonitor {};
            class aiFindSpawnLocation {};
            class aiSpawnGroup {};
            class aiMoveGroup {};
            class initLocationRadios {};
            class radioAlarmMonitor {};
            class radioCallback {};
            class aiDraw3D {};
            class aiManpowerMonitor {};
            class aiSpawnAirGroup {};       // Enemy aircraft spawner
            class aiSpawnNavalGroup {};     // Enemy patrol boat spawner
            class aiMapMarkers {};          // Intel-gated map markers for AI groups
        };
    };
};

// GUI definitions
#include "gui\ui_defines.hpp"
#include "gui\displays.hpp"
