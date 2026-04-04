/*
    Training Courses Configuration
    
    Defines all available training courses, durations, and skill bonuses.
    Duration in minutes (in-game time).
    
    Format per course:
        [courseId, displayName, description, durationMins, skillBonuses, qualifications, prereqQuals, minCourage]
    
    prereqQuals: array of qualification strings the unit must already have (empty = no prereqs)
                 If multiple listed, unit needs ANY ONE of them (OR logic)
    minCourage:  minimum courage skill value required (0.0 = no gate, 1.0 = max)
    requiresResearch: research item ID that must be completed ("" = always available)
*/

OpsRoom_TrainingCourses = [
    // ========================================
    // BASIC & GENERAL COURSES
    // ========================================
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
        [],  // No special qualifications
        [],  // No prereqs
        0,   // No courage gate
        ""   // No research required
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
        ["marksmanShot"],
        [],
        0,
        ""
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
        [],
        [],
        0,
        ""
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
        [],
        [],
        0,
        ""
    ],
    [
        "medical",
        "Medical Training",
        "First aid and battlefield medicine. Qualifies unit as a combat medic.",
        30,
        [
            ["general", 0.2]
        ],
        ["medic", "heal"],
        [],
        0,
        ""
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
        ["suppressiveFire"],
        [],
        0,
        ""
    ],
    [
        "engineering",
        "Combat Engineering",
        "Explosives, fortifications, and mine clearance. Qualifies unit as an engineer.",
        45,
        [
            ["general", 0.2]
        ],
        ["engineer", "repair"],
        [],
        0,
        ""
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
        [],
        [],
        0,
        ""
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
        [],
        [],
        0,
        ""
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
        [],
        [],
        0,
        ""
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
        [],
        [],
        0,
        ""
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
        ["reconnoitre"],
        [],
        0,
        ""
    ],
    [
        "radio_operator",
        "Radio Operator Training",
        "Signals and communications training. Qualifies unit to coordinate air strikes and artillery fire missions using field radios.",
        45,
        [
            ["general", 0.2],
            ["commanding", 0.3]
        ],
        ["airStrike", "artillery"],
        [],
        0,
        ""
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
        ["timebomb"],
        [],
        0,
        ""
    ],
    [
        "royal_engineers",
        "Royal Engineers Training",
        "Field engineering, fortification construction, and demolition. Qualifies unit to build defensive structures, lay minefields, and demolish player-built objects. Also grants Repair ability.",
        60,
        [
            ["general", 0.2],
            ["courage", 0.2]
        ],
        ["build", "repair"],
        [],
        0,
        ""
    ],

    // ========================================
    // AVIATION COURSES
    // ========================================
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
        ["pilot"],
        [],
        0,
        ""
    ],
    [
        "paratrooper",
        "Paratrooper Training",
        "Airborne forces qualification. Jump training, parachute packing, and air-landing operations. Qualifies unit to perform combat drops from transport aircraft.",
        60,
        [
            ["courage", 0.3],
            ["general", 0.2]
        ],
        ["paratrooper"],
        [],
        0,
        ""
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
        ["airCrew"],
        [],
        0,
        ""
    ],

    // ========================================
    // ELITE / SPECIAL FORCES COURSES
    // ========================================
    [
        "commando_course",
        "Commando Training",
        "Achnacarry Castle commando course. Gruelling physical and tactical training including speed marches, cliff assault, boat work, and live-fire exercises. Only the most courageous soldiers are accepted. Requires Commando Training research.",
        90,
        [
            ["aimingAccuracy", 0.2],
            ["aimingSpeed", 0.2],
            ["courage", 0.3],
            ["general", 0.3],
            ["spotDistance", 0.2],
            ["reloadSpeed", 0.2]
        ],
        ["commando"],
        [],        // No prereq qualifications needed
        0.8,       // Courage must be >= 0.8
        "commando_training"  // Requires Commando Training research
    ],
    [
        "sas_selection",
        "SAS Selection",
        "Special Air Service selection and training. Extreme endurance, navigation, and combat survival in hostile terrain. Only soldiers who have completed Commando or Paratrooper training may apply. Requires maximum courage.",
        120,
        [
            ["aimingAccuracy", 0.3],
            ["aimingSpeed", 0.3],
            ["aimingShake", 0.3],
            ["spotDistance", 0.3],
            ["spotTime", 0.3],
            ["courage", 0.3],
            ["general", 0.3],
            ["reloadSpeed", 0.2]
        ],
        ["sas", "infiltrate", "reconnoitre"],
        ["commando", "paratrooper"],  // Must have commando OR paratrooper
        1.0,       // Courage must be 1.0 (maximum)
        "ungentlemanly_warfare"  // Requires Ungentlemanly Warfare research
    ],
    [
        "soe_training",
        "SOE Training",
        "Special Operations Executive agent training at Beaulieu. Tradecraft, sabotage, silent killing, clandestine communications, and resistance circuit management. Only soldiers who have completed Commando or Paratrooper training may apply.",
        120,
        [
            ["general", 0.3],
            ["courage", 0.4],
            ["spotDistance", 0.3],
            ["spotTime", 0.3]
        ],
        ["soe", "infiltrate", "assassinate", "timebomb"],
        ["commando", "paratrooper"],  // Must have commando OR paratrooper
        1.0,       // Courage must be 1.0 (maximum)
        "ungentlemanly_warfare"  // Requires Ungentlemanly Warfare research
    ],
    [
        "soe_fieldcraft",
        "SOE Advanced Fieldcraft",
        "Advanced SOE operational training. Deep cover techniques, agent recruitment, dead drops, and escape and evasion. For trained SOE agents only.",
        60,
        [
            ["general", 0.3],
            ["courage", 0.2],
            ["spotDistance", 0.2],
            ["spotTime", 0.2]
        ],
        ["reconnoitre"],
        ["soe"],   // Must already be SOE qualified
        0,
        "ungentlemanly_warfare"
    ]
];

// Initialize global training tracker
if (isNil "OpsRoom_UnitsInTraining") then {
    OpsRoom_UnitsInTraining = [];
};
