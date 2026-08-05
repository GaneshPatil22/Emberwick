//
//  BirthdayWin.swift
//  Emberwick
//
//  The single diamond "story begins" win pinned to the user's birthday. Created when
//  the birthday is first set and MOVED (not duplicated) whenever it's edited, so the
//  map's first glow always sits on the birth week.
//
//  Also the home for the "valid win" rule: a win only counts once it's on or after
//  the birth date. Wins dated before it (e.g. after the birthday is moved later) are
//  hidden everywhere — never deleted — so moving the birthday back reveals them again.
//

import Foundation
import SwiftData

enum BirthdayWin {
    static let title = "My story begins"

    /// Ensures EXACTLY ONE birth-marker win exists at `birthDate` — creating it,
    /// moving the existing one, and deleting any accidental extras (e.g. after an
    /// import). Only derived birth markers are ever removed, never real wins.
    @MainActor
    static func sync(to birthDate: Date, in context: ModelContext) {
        let markers = (try? context.fetch(FetchDescriptor<Entry>(predicate: #Predicate { $0.isBirthMarker }))) ?? []
        if let keep = markers.first {
            keep.date = birthDate
            for extra in markers.dropFirst() { context.delete(extra) } // collapse duplicates
        } else {
            context.insert(Entry(date: birthDate, kind: .win, title: title, tier: .diamond, isBirthMarker: true))
        }
        try? context.save()
    }
}

extension Entry {
    /// A win is valid (shown, counted, jar-eligible) only from the birth date onward.
    /// Non-wins are unaffected.
    func isValidWin(bornOn birthDate: Date) -> Bool {
        kind == .win && date >= birthDate
    }
}

extension Sequence where Element == Entry {
    /// Wins on or after the birth date — hides any left "before you were born".
    func validWins(bornOn birthDate: Date) -> [Entry] {
        filter { $0.isValidWin(bornOn: birthDate) }
    }
}
