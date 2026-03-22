/*
    fn_openOperationWizard
    
    Opens the operation creation wizard.
    Manages multi-step flow:
        Step 1: Name the operation
        Step 2: Select target (from strategic locations)
        Step 3: Choose task type (contextual to target)
        Step 4: Assign regiment(s)
        Step 5: Confirm and create
*/

// Initialize wizard state
OpsRoom_WizardState = createHashMapFromArray [
    ["step", 1],
    ["name", ""],
    ["targetId", ""],
    ["targetName", ""],
    ["targetType", ""],
    ["taskType", ""],
    ["regiments", []],
    ["regimentNames", []]
];

createDialog "OpsRoom_OperationWizardDialog";
waitUntil {!isNull findDisplay 8012};

private _display = findDisplay 8012;

// Show step 1
[1] call OpsRoom_fnc_wizardShowStep;
