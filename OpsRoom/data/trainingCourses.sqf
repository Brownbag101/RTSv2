/*
    Training Courses Configuration
    
    Defines all available training courses, durations, and skill bonuses.
    Duration in minutes (in-game time).
*/

OpsRoom_TrainingCourses = [
    [
        "basic",
        "Basic Training",
        "Fundamental military skills and discipline. Improves overall combat readiness across all areas.",
        30,  // 30 minutes
        [
            ["aimingAccuracy", 0.2],
            ["aimingShake", 0.2],
            ["aimingSpeed", 0.2],
            ["spotDistance", 0.2],
            ["spotTime", 0.2],
            ["courage", 0.2],
            ["reloadSpeed", 0.2],
            ["commanding", 0.2],
            ["general", 0.2]
        ],
        []  // No special qualifications
    ],
    [
        "marksmanship",
        "Marksmanship Training",
        "Advanced rifle training. Significantly improves accuracy, weapon handling, and target acquisition. Qualifies unit for Aimed Shot.",
        45,
        [
            ["aimingAccuracy", 0.3],
            ["aimingSpeed", 0.3],
            ["aimingShake", 0.3]
        ],
        ["marksmanShot"]  // Grants Aimed Shot ability
    ],
    [
        "leadership",
        "Leadership Course",
        "Officer training program. Develops command ability and courage under fire.",
        60,
        [
            ["commanding", 0.4],
            ["courage", 0.4]
        ],
        []
    ],
    [
        "tactical",
        "Tactical Maneuvers",
        "Field exercises in reconnaissance and situational awareness. Improves observation and tactical thinking.",
        45,
        [
            ["spotDistance", 0.3],
            ["spotTime", 0.3],
            ["general", 0.3]
        ],
        []
    ],
    [
        "medical",
        "Medical Training",
        "First aid and battlefield medicine. Qualifies unit as a combat medic.",
        30,
        [
            ["general", 0.2]
        ],
        ["medic", "heal"]  // Medic qualification + Heal ability
    ],
    [
        "mg",
        "Machine Gun Training",
        "Heavy weapons employment and suppressive fire tactics. Grants ability to coordinate sustained fire.",
        45,
        [
            ["reloadSpeed", 0.2],
            ["aimingShake", 0.2],
            ["courage", 0.2]
        ],
        ["suppressiveFire"]  // Grants Suppress ability
    ],
    [
        "engineering",
        "Combat Engineering",
        "Explosives, fortifications, and mine clearance. Qualifies unit as an engineer.",
        45,
        [
            ["general", 0.2]
        ],
        ["engineer", "repair"]  // Engineer qualification + Repair ability
    ],
    [
        "advanced_weapons",
        "Advanced Weapons",
        "Heavy weapons and crew-served equipment training. Improves reload speed and accuracy.",
        60,
        [
            ["reloadSpeed", 0.3],
            ["aimingAccuracy", 0.3]
        ],
        []
    ],
    [
        "reconnaissance",
        "Reconnaissance Training",
        "Stealth, observation, and intelligence gathering. Significantly improves spotting ability.",
        45,
        [
            ["spotDistance", 0.4],
            ["spotTime", 0.4]
        ],
        []
    ],
    [
        "cqb",
        "Close Quarters Battle",
        "Urban combat and room clearing. Improves reaction time and general effectiveness.",
        30,
        [
            ["aimingSpeed", 0.3],
            ["general", 0.3]
        ],
        []
    ],
    [
        "officer",
        "Officer School",
        "Advanced leadership and strategic thinking. Comprehensive command training.",
        90,
        [
            ["commanding", 0.5],
            ["general", 0.5]
        ],
        []
    ],
    [
        "forward_observer",
        "Forward Observer Training",
        "Advanced observation and intelligence gathering. Qualifies unit to perform reconnaissance missions, identifying enemy positions and feeding intel to command.",
        45,
        [
            ["spotDistance", 0.4],
            ["spotTime", 0.4]
        ],
        ["reconnoitre"]
    ],
    [
        "soe_fieldcraft",
        "SOE Field Craft",
        "Special Operations Executive training in stealth, infiltration, and elimination techniques. Qualifies agent for covert operations behind enemy lines.",
        60,
        [
            ["general", 0.3],
            ["courage", 0.4]
        ],
        ["infiltrate", "assassinate"]
    ],
    [
        "radio_operator",
        "Radio Operator Training",
        "Signals and communications training. Qualifies unit to coordinate air strikes with ground attack aircraft using field radios.",
        45,
        [
            ["general", 0.2],
            ["commanding", 0.3]
        ],
        ["airStrike"]
    ],
    [
        "demolitions",
        "Demolitions Training",
        "Explosives handling, placement, and detonation. Qualifies unit to deploy timed explosive charges against enemy positions and infrastructure.",
        45,
        [
            ["general", 0.2],
            ["courage", 0.3]
        ],
        ["timebomb"]
    ],
    [
        "pilot_training",
        "Pilot Training",
        "RAF pilot training programme. Ground school, basic flying training, and operational conversion. Qualifies unit as a combat pilot eligible for assignment to an Air Wing.",
        90,
        [
            ["spotDistance", 0.3],
            ["spotTime", 0.3],
            ["courage", 0.3],
            ["general", 0.2]
        ],
        ["pilot"]
    ],
    [
        "air_gunner",
        "Air Gunner Training",
        "Aerial gunnery and observer course. Trains personnel to operate turret-mounted weapons aboard multi-crew aircraft. Qualifies unit as aircrew for bombers and multi-seat fighters.",
        60,
        [
            ["aimingAccuracy", 0.3],
            ["aimingSpeed", 0.3],
            ["spotDistance", 0.2],
            ["courage", 0.3]
        ],
        ["airCrew"]
    ]
];

// Initialize global training tracker
if (isNil "OpsRoom_UnitsInTraining") then {
    OpsRoom_UnitsInTraining = [];
};
