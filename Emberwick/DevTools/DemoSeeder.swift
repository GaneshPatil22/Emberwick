//
//  DemoSeeder.swift
//  Emberwick
//
//  Fills an empty store with a deterministic demo persona (wins / losses / notes /
//  eras) so the grid reads as lived-in for demos. Idempotent: does nothing if the
//  store already holds entries. Debug-only — called behind `#if DEBUG`.
//

import Foundation
import SwiftData

enum DemoSeeder {
    /// Seeds the persona only when the store is empty.
    @MainActor
    static func seedIfEmpty(context: ModelContext, persona: DemoPersona) {
        let existing = (try? context.fetchCount(FetchDescriptor<Entry>())) ?? 0
        guard existing == 0 else { return }
        seed(context: context, persona: persona)
    }

    @MainActor
    static func seed(context: ModelContext, persona: DemoPersona) {
        var rng = SeededRandomNumberGenerator(seed: persona.seed)
        let calendar = Calendar.current
        let today = Date.now
        let birthDate = AppConfig.defaultBirthDate

        let earliest = calendar.date(byAdding: .year, value: persona.firstActiveAge, to: birthDate) ?? birthDate
        let maxDaysAgo = max(1, calendar.dateComponents([.day], from: earliest, to: today).day ?? 3650)

        func randomPastDate() -> Date {
            let fraction = Double.random(in: 0..<1, using: &rng)
            let daysAgo = 1 + Int(fraction * Double(maxDaysAgo - 1))
            return calendar.date(byAdding: .day, value: -daysAgo, to: today) ?? today
        }

        func randomTitle(from pool: [String]) -> String {
            pool.randomElement(using: &rng) ?? "A good day"
        }

        for _ in 0..<persona.winCount {
            let entry = Entry(
                date: randomPastDate(),
                kind: .win,
                title: randomTitle(from: DemoPersona.winTitles),
                tier: randomTier(using: &rng)
            )
            context.insert(entry)
        }

        for _ in 0..<persona.lossCount {
            context.insert(Entry(date: randomPastDate(), kind: .loss, title: randomTitle(from: DemoPersona.lossTitles)))
        }

        for _ in 0..<persona.noteCount {
            context.insert(Entry(date: randomPastDate(), kind: .note, title: randomTitle(from: DemoPersona.noteTitles)))
        }

        for spec in persona.eras {
            let start = calendar.date(from: DateComponents(year: spec.startYear, month: 1, day: 1)) ?? today
            let end = calendar.date(from: DateComponents(year: spec.endYear, month: 12, day: 31)) ?? today
            context.insert(Era(name: spec.name, startDate: start, endDate: end, tintHex: spec.tintHex))
        }

        try? context.save()
    }

    /// Tier distribution: diamond rare, then gold, silver, bronze, with a few untiered.
    private static func randomTier(using rng: inout SeededRandomNumberGenerator) -> Tier? {
        let roll = Double.random(in: 0..<1, using: &rng)
        return switch roll {
        case ..<0.05: .diamond
        case ..<0.30: .gold
        case ..<0.60: .silver
        case ..<0.90: .bronze
        default: nil
        }
    }
}
