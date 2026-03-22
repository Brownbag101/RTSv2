/*
    OpsRoom_fnc_getPhoneticName
    
    Generates phonetic team names (Able, Baker, Charlie, etc.)
    Tracks usage per parent group to assign next available name
    
    Parameters:
        _parentGroup - The original parent group
    
    Returns:
        String - Phonetic name (e.g., "Able", "Baker")
*/

params ["_parentGroup"];

// Phonetic alphabet array
private _phoneticNames = [
    "Able", "Baker", "Charlie", "Dog", "Easy", "Fox", "George", "How",
    "Item", "Jig", "King", "Love", "Mike", "Nan", "Oboe", "Peter",
    "Queen", "Roger", "Sugar", "Tare", "Uncle", "Victor", "William", "X-ray",
    "Yoke", "Zebra"
];

// Get or initialize counter for this parent group
private _counter = _parentGroup getVariable ["OpsRoom_SubTeamCounter", 0];

// Get next phonetic name (loop back if we run out)
private _phoneticName = _phoneticNames select (_counter mod (count _phoneticNames));

// Increment counter
_parentGroup setVariable ["OpsRoom_SubTeamCounter", _counter + 1];

_phoneticName
