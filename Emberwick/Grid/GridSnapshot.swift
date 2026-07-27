//
//  GridSnapshot.swift
//  Emberwick
//
//  A pure, immutable view of the grid at a moment in time. Built once from the
//  entries + today's date, then answers `state(row:column:)` for any cell without
//  further allocation. Only "interesting" cells (weeks with wins) are stored; every
//  other cell's state is computed positionally.
//

import Foundation

struct GridSnapshot {
    /// The cell for the current week.
    let today: GridPosition
    /// Column of the user's birth week within row 0 (weeks before it are "before you").
    let birthColumn: Int
    /// Highest tier of any win in a week. A present key means the week has a win;
    /// the value is the best tier, or `nil` for an untiered win.
    private let memories: [GridPosition: Tier?]

    func state(row: Int, column: Int) -> GridCellState {
        if row == 0, column < birthColumn {
            return .beforeBirth
        }

        let position = GridPosition(row: row, column: column)
        if position == today {
            return .thisWeek
        }
        if row > today.row || (row == today.row && column > today.column) {
            return .ahead
        }
        if let tier = memories[position] {
            return .memory(tier)
        }
        return .livedEmpty
    }

    /// Builds a snapshot from entries, anchored to a birth date and today's date.
    static func make(
        entries: [Entry],
        birthDate: Date,
        today: Date,
        calendar: Calendar = .current
    ) -> GridSnapshot {
        let birthYear = GridMath.year(for: birthDate, calendar: calendar)

        var memories: [GridPosition: Tier?] = [:]
        for entry in entries where entry.kind == .win {
            let position = GridMath.position(for: entry.date, birthYear: birthYear, calendar: calendar)
            memories[position] = highestTier(memories[position] ?? nil, entry.tier)
        }

        return GridSnapshot(
            today: GridMath.position(for: today, birthYear: birthYear, calendar: calendar),
            birthColumn: GridMath.boxIndex(for: birthDate, calendar: calendar),
            memories: memories
        )
    }

    /// The better of two optional tiers. A rated tier always beats an untiered win.
    private static func highestTier(_ lhs: Tier?, _ rhs: Tier?) -> Tier? {
        switch (lhs, rhs) {
        case let (lhs?, rhs?): max(lhs, rhs)
        case let (lhs?, nil): lhs
        case let (nil, rhs?): rhs
        case (nil, nil): nil
        }
    }
}
