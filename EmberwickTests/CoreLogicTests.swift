//
//  CoreLogicTests.swift
//  EmberwickTests
//
//  Locks in the pure decision logic that drives the app: which cell state a week
//  shows, how the Jar weights a shake, what "a year ago" resurfaces, which wins are
//  valid, and that export is well-formed. All deterministic (fixed UTC calendar,
//  seeded RNG) so results never depend on where the tests run.
//

import Foundation
import SwiftData
import Testing
@testable import Emberwick

private let cal: Calendar = {
    var c = Calendar(identifier: .gregorian)
    c.timeZone = TimeZone(identifier: "UTC") ?? .gmt
    return c
}()

private func d(_ year: Int, _ month: Int, _ day: Int) -> Date {
    cal.date(from: DateComponents(year: year, month: month, day: day)) ?? .distantPast
}

@MainActor
@Suite("Grid snapshot — cell state")
struct GridSnapshotTests {
    @Test("Weeks before the birth week in row 0 read as before-birth")
    func beforeBirth() {
        let birth = d(1990, 7, 1)
        let snapshot = GridSnapshot.make(entries: [], birthDate: birth, today: d(2010, 1, 1), calendar: cal)
        let birthColumn = GridMath.boxIndex(for: birth, calendar: cal)

        #expect(snapshot.state(row: 0, column: 0) == .beforeBirth)
        #expect(snapshot.state(row: 0, column: birthColumn - 1) == .beforeBirth)
        #expect(snapshot.state(row: 0, column: birthColumn) != .beforeBirth)
    }

    @Test("The current week reads as this-week; later weeks read as ahead")
    func thisWeekAndAhead() {
        let today = d(2020, 6, 15)
        let snapshot = GridSnapshot.make(entries: [], birthDate: d(1990, 1, 1), today: today, calendar: cal)
        let here = GridMath.position(for: today, birthYear: 1990, calendar: cal)

        #expect(snapshot.state(row: here.row, column: here.column) == .thisWeek)
        #expect(snapshot.state(row: here.row + 1, column: here.column) == .ahead)
    }

    @Test("A win lights its week with the highest tier present")
    func memoryHighestTier() {
        let winDate = d(2010, 3, 10)
        let bronze = Entry(date: winDate, kind: .win, title: "b", tier: .bronze)
        let gold = Entry(date: winDate, kind: .win, title: "g", tier: .gold)
        let snapshot = GridSnapshot.make(entries: [bronze, gold], birthDate: d(1990, 1, 1), today: d(2020, 1, 1), calendar: cal)
        let position = GridMath.position(for: winDate, birthYear: 1990, calendar: cal)

        #expect(snapshot.state(row: position.row, column: position.column) == .memory(.gold))
        #expect(snapshot.memoryCount == 1)
    }

    @Test("Wins before the birth date are hidden from the grid")
    func preBirthWinsHidden() {
        let preBirth = Entry(date: d(1995, 5, 5), kind: .win, title: "x", tier: .gold)
        let snapshot = GridSnapshot.make(entries: [preBirth], birthDate: d(2000, 1, 1), today: d(2020, 1, 1), calendar: cal)
        #expect(snapshot.memoryCount == 0)
    }
}

@MainActor
@Suite("Jar selector — weighted shake")
struct JarSelectorTests {
    @Test("An empty jar yields nothing")
    func emptyJar() {
        var rng = SeededRandomNumberGenerator(seed: 1)
        #expect(JarSelector.pick(from: [], now: .now, using: &rng) == nil)
    }

    @Test("Long-unseen wins are strongly favored over recently-seen ones")
    func favorsLongUnseen() {
        let now = d(2020, 1, 1)
        let recent = Entry(date: d(2019, 1, 1), kind: .win, title: "recent")
        recent.lastSeenAt = d(2019, 12, 31) // seen ~yesterday → weight ~1
        let neverSeen = Entry(date: d(2010, 1, 1), kind: .win, title: "old") // huge weight

        var rng = SeededRandomNumberGenerator(seed: 42)
        var oldCount = 0
        for _ in 0..<500 {
            if JarSelector.pick(from: [recent, neverSeen], now: now, using: &rng)?.title == "old" { oldCount += 1 }
        }
        #expect(oldCount > 480) // the never-seen win wins almost every time
    }
}

@MainActor
@Suite("Resurfacing — a year ago")
struct ResurfacingSelectorTests {
    @Test("Surfaces a previous-year win near today's day-of-year")
    func picksAnniversary() {
        let today = d(2020, 6, 15)
        let match = Entry(date: d(2017, 6, 14), kind: .win, title: "match")
        let offSeason = Entry(date: d(2017, 1, 1), kind: .win, title: "off")
        let result = ResurfacingSelector.resurfaced(wins: [offSeason, match], today: today, calendar: cal)
        #expect(result?.title == "match")
    }

    @Test("Excludes this-year, future, and already-surfaced wins")
    func excludes() {
        let today = d(2020, 6, 15)
        let sameYear = Entry(date: d(2020, 6, 14), kind: .win, title: "sameYear")
        let already = Entry(date: d(2018, 6, 15), kind: .win, title: "already")
        already.resurfacedAt = d(2019, 1, 1)
        #expect(ResurfacingSelector.resurfaced(wins: [sameYear, already], today: today, calendar: cal) == nil)
    }

    @Test("Prefers the most recent matching anniversary")
    func mostRecent() {
        let today = d(2020, 6, 15)
        let older = Entry(date: d(2015, 6, 15), kind: .win, title: "older")
        let newer = Entry(date: d(2018, 6, 15), kind: .win, title: "newer")
        let result = ResurfacingSelector.resurfaced(wins: [older, newer], today: today, calendar: cal)
        #expect(result?.title == "newer")
    }
}

@MainActor
@Suite("Win validity — hidden before birth")
struct ValidWinTests {
    @Test("A win counts only from the birth date onward; non-wins never count")
    func validity() {
        let birth = d(2000, 1, 1)
        let before = Entry(date: d(1998, 1, 1), kind: .win, title: "before")
        let after = Entry(date: d(2005, 1, 1), kind: .win, title: "after")
        let note = Entry(date: d(2005, 1, 1), kind: .note, title: "note")

        #expect(before.isValidWin(bornOn: birth) == false)
        #expect(after.isValidWin(bornOn: birth) == true)
        #expect(note.isValidWin(bornOn: birth) == false)
        #expect([before, after, note].validWins(bornOn: birth).map(\.title) == ["after"])
    }
}

@MainActor
@Suite("Export — well-formed JSON")
struct ExportTests {
    @Test("Export encodes entries and eras into valid JSON")
    func exportsValidJSON() throws {
        let win = Entry(date: d(2020, 1, 1), kind: .win, title: "Won", tier: .gold)
        let era = Era(name: "School", startDate: d(2005, 1, 1), endDate: d(2010, 1, 1), tintHex: "AABBCC")

        let data = EmberExporter.json(entries: [win], eras: [era], birthDate: d(1990, 4, 12), birthDayKnown: true, now: d(2020, 1, 1))
        let object = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        #expect(object?["app"] as? String == "Emberwick")
        #expect(object?["birthDate"] != nil) // the grid anchor travels with the backup
        let entries = object?["entries"] as? [[String: Any]]
        #expect(entries?.count == 1)
        #expect(entries?.first?["title"] as? String == "Won")
        #expect(entries?.first?["tier"] as? String == "gold")
        #expect((object?["eras"] as? [[String: Any]])?.count == 1)
    }

    @Test("Export then restore round-trips; re-restoring the same file adds nothing")
    func exportRestoreRoundTrips() throws {
        let container = try ModelContainer(
            for: Entry.self, Era.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = container.mainContext

        let win = Entry(date: d(2020, 1, 1), kind: .win, title: "Won", tier: .gold)
        let birthMarker = Entry(date: d(1990, 4, 12), kind: .win, title: "My story begins", tier: .diamond, isBirthMarker: true)
        let era = Era(name: "School", startDate: d(2005, 1, 1), endDate: d(2010, 1, 1), tintHex: "AABBCC")
        let data = EmberExporter.json(entries: [win, birthMarker], eras: [era], birthDate: d(1990, 4, 12), birthDayKnown: false, now: d(2020, 1, 1))

        let first = try EmberExporter.restore(from: data, into: context)
        #expect(first.entriesAdded == 1) // the birth-marker win is excluded, not re-imported
        #expect(first.erasAdded == 1)
        #expect(first.birthDate == d(1990, 4, 12)) // birthday travels with the backup
        #expect(first.birthDayKnown == false)

        // Importing your own backup again is a safe no-op (matched by id).
        let second = try EmberExporter.restore(from: data, into: context)
        #expect(second.entriesAdded == 0)
        #expect(second.erasAdded == 0)

        let restored = try context.fetch(FetchDescriptor<Entry>())
        #expect(restored.count == 1)
        #expect(restored.first?.title == "Won")
        #expect(restored.first?.tier == .gold)
        #expect(restored.first?.id == win.id) // id preserved → dedup works
    }

    @Test("An older file (no birthDate) derives the DOB from its story-begins win")
    func restoreDerivesBirthdayFromOldFile() throws {
        let container = try ModelContainer(
            for: Entry.self, Era.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = container.mainContext

        // A pre-fix export: no birthDate field, and the birth win stored as data.
        let oldFile = """
        {"app":"Emberwick","exportedAt":"2020-01-01T00:00:00Z","entries":[\
        {"date":"1995-04-12T00:00:00Z","kind":"win","title":"My story begins","tier":"diamond"},\
        {"date":"2005-01-01T00:00:00Z","kind":"win","title":"Real win","tier":"gold"}],"eras":[]}
        """.data(using: .utf8)!

        let summary = try EmberExporter.restore(from: oldFile, into: context)
        #expect(summary.birthDate == d(1995, 4, 12)) // DOB recovered from the marker
        #expect(summary.entriesAdded == 1)           // "story begins" is NOT re-imported

        let stored = try context.fetch(FetchDescriptor<Entry>())
        #expect(stored.map(\.title).sorted() == ["Real win"])
    }

    @Test("Syncing the birthday collapses duplicate birth markers to a single one")
    func birthdaySyncCollapsesDuplicates() throws {
        let container = try ModelContainer(
            for: Entry.self, Era.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = container.mainContext
        context.insert(Entry(date: d(1980, 6, 1), kind: .win, title: BirthdayWin.title, tier: .diamond, isBirthMarker: true))
        context.insert(Entry(date: d(1990, 1, 1), kind: .win, title: BirthdayWin.title, tier: .diamond, isBirthMarker: true))
        try context.save()

        BirthdayWin.sync(to: d(1995, 4, 12), in: context)

        let markers = try context.fetch(FetchDescriptor<Entry>(predicate: #Predicate { $0.isBirthMarker }))
        #expect(markers.count == 1)
        #expect(markers.first?.date == d(1995, 4, 12))
    }
}
