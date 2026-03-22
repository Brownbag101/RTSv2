/*
    Build Factory
    
    Creates a new factory. Costs resources.
    Factory is immediately available (no build time for now — can add later).
    
    Cost: 10 Steel, 5 Wood
    
    Usage:
        [] call OpsRoom_fnc_buildFactory;
*/

private _factories = missionNamespace getVariable ["OpsRoom_Factories", []];
private _maxFactories = missionNamespace getVariable ["OpsRoom_MaxFactories", 1];

// Check if we can build more
if (count _factories >= _maxFactories) exitWith {
    hint "Maximum factory capacity reached.\nResearch upgrades to increase capacity.";
};

// Check resources
private _steel = missionNamespace getVariable ["OpsRoom_Resource_Steel", 0];
private _wood = missionNamespace getVariable ["OpsRoom_Resource_Wood", 0];

if (_steel < 10 || _wood < 5) exitWith {
    hint format ["Not enough resources to build factory.\n\nNeed: 10 Steel, 5 Wood\nHave: %1 Steel, %2 Wood", _steel, _wood];
};

// Deduct resources
missionNamespace setVariable ["OpsRoom_Resource_Steel", _steel - 10];
OpsRoom_Resource_Steel = _steel - 10;
missionNamespace setVariable ["OpsRoom_Resource_Wood", _wood - 5];
OpsRoom_Resource_Wood = _wood - 5;
[] call OpsRoom_fnc_updateResources;

// Create factory
private _factoryNum = (count _factories) + 1;
private _newFactory = createHashMapFromArray [
    ["id", format ["factory_%1", _factoryNum]],
    ["name", format ["Factory %1", _factoryNum]],
    ["producing", ""],
    ["startTime", 0],
    ["cycleTime", 0],
    ["continuous", true]
];

_factories pushBack _newFactory;
missionNamespace setVariable ["OpsRoom_Factories", _factories];

["PRIORITY", "FACTORY BUILT", format ["Factory %1 is ready for production!", _factoryNum]] call OpsRoom_fnc_dispatch;

// Refresh the grid
[] call OpsRoom_fnc_populateFactoryGrid;

diag_log format ["[OpsRoom] Factory built: Factory %1 (total: %2)", _factoryNum, count _factories];
