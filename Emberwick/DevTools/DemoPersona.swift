//
//  DemoPersona.swift
//  Emberwick
//
//  Configuration + content pools for the dev demo seeder. Numbers are tuned so a
//  fresh install reads as a lived-in, mature grid for demos. No images are seeded —
//  the user adds a few photos later via the entry edit UI (Phase 3).
//

import Foundation

struct DemoPersona {
    let seed: UInt64
    let winCount: Int
    let lossCount: Int
    let noteCount: Int
    /// Earliest age (in years) at which the persona starts capturing moments.
    let firstActiveAge: Int
    let eras: [EraSpec]

    struct EraSpec {
        let name: String
        let startYear: Int
        let endYear: Int
        /// Soft, low-saturation `0xRRGGBB` tint.
        let tintHex: String
    }

    /// The standard demo persona (birth 1990, ~46 wins across ~20 years).
    static let standard = DemoPersona(
        seed: 424_242, // fixed seed → reproducible demo data
        winCount: 46,
        lossCount: 8,
        noteCount: 16,
        firstActiveAge: 15,
        eras: [
            EraSpec(name: "University", startYear: 2008, endYear: 2012, tintHex: "DCE7EC"),
            EraSpec(name: "First job", startYear: 2013, endYear: 2018, tintHex: "F5E6C8"),
            EraSpec(name: "A new city", startYear: 2019, endYear: 2023, tintHex: "D8ECEC")
        ]
    )

    static let winTitles = [
        "Got the senior role", "Ran my first 10k", "Shipped the app", "She said yes",
        "Moved into our place", "Finished the marathon", "Landed the client",
        "First paycheck", "Passed my driving test", "Gave the keynote",
        "Cooked a feast for friends", "Hit my savings goal", "Learned to surf",
        "Adopted the dog", "Fixed the old bike", "Read 30 books this year",
        "Started the side project", "Reconnected with an old friend", "Planted the garden",
        "Nailed the interview", "Sold my first painting", "Summited the trail"
    ]

    static let lossTitles = [
        "A hard goodbye", "The project fell through", "Grandad passed",
        "A tough diagnosis", "Lost the pitch", "A friendship ended",
        "The move got delayed", "A rough month"
    ]

    static let noteTitles = [
        "Quiet weekend at home", "Rain all Sunday", "Coffee with mum",
        "First snow of the year", "A long walk to think", "Tried a new recipe",
        "Rewatched an old favourite", "Slow morning, no plans", "Tidied the whole flat",
        "A good long phone call", "Sketching in the park", "Late-night drive",
        "Farmers' market haul", "Sorted the old photos", "A nap that helped",
        "Just a normal, good day"
    ]
}
