//
//  IntroFlightPlanner.swift
//  Emberwick
//
//  Plans the first-run intro: 15–25 cards (random each launch). Wins are always
//  preferred and fly to their real week cells; any shortfall is filled with blank
//  paper cards sent to scattered lived-but-empty past weeks. Launch delays are spread
//  across a fixed window (independent of count).
//

import Foundation

enum IntroFlightPlanner {
    private struct Card {
        let position: GridPosition
        let content: MemoryTokenContent
        let tier: Tier?
    }

    static func plans(
        entries: [Entry],
        snapshot: GridSnapshot,
        birthYear: Int,
        launchWindow: Double,
        calendar: Calendar = .current
    ) -> [FlightPlan] {
        let count = Int.random(in: 15...25)

        // Wins → their real cells (photo if present, else title). Shuffled.
        let winCards = entries
            .filter { $0.kind == .win }
            .map { entry in
                Card(
                    position: GridMath.position(for: entry.date, birthYear: birthYear, calendar: calendar),
                    content: entry.imageData.first.map(MemoryTokenContent.image) ?? .title(entry.title),
                    tier: entry.tier
                )
            }
            .shuffled()

        var cards: [Card]
        if winCards.count >= count {
            cards = Array(winCards.prefix(count))                    // Case 3: too many wins
        } else {
            let winCells = Set(winCards.map(\.position))
            let emptyCells = scatteredEmptyCells(
                snapshot: snapshot,
                count: count - winCards.count,
                avoiding: winCells
            )
            cards = winCards + emptyCells.map { Card(position: $0, content: .fallback, tier: nil) }
        }

        // Interleave wins and blanks, then spread launch delays across the window.
        cards.shuffle()
        let total = cards.count
        return cards.enumerated().map { index, card in
            let delay = total > 1 ? launchWindow * Double(index) / Double(total - 1) : 0
            return FlightPlan(position: card.position, content: card.content, tier: card.tier, delay: delay)
        }
    }

    /// Lived-but-empty past weeks, picked spread apart (greedy min-distance, relaxed
    /// until enough are found). Blanks never land on a win's cell.
    private static func scatteredEmptyCells(
        snapshot: GridSnapshot,
        count: Int,
        avoiding winCells: Set<GridPosition>
    ) -> [GridPosition] {
        guard count > 0, snapshot.today.row >= 0 else { return [] }

        var candidates: [GridPosition] = []
        for row in 0...snapshot.today.row {
            for column in 0..<GridConstants.columnsPerYear {
                guard snapshot.state(row: row, column: column) == .livedEmpty else { continue }
                let position = GridPosition(row: row, column: column)
                if !winCells.contains(position) { candidates.append(position) }
            }
        }
        guard !candidates.isEmpty else { return [] }
        candidates.shuffle()

        var picked: [GridPosition] = []
        var minimumDistance = 8.0
        while picked.count < count, minimumDistance >= 1 {
            for candidate in candidates where picked.count < count {
                if picked.allSatisfy({ distance($0, candidate) >= minimumDistance }) {
                    picked.append(candidate)
                }
            }
            minimumDistance -= 2
        }
        // Grid too dense to keep spacing? Fill from whatever's left.
        if picked.count < count {
            for candidate in candidates where !picked.contains(candidate) {
                picked.append(candidate)
                if picked.count >= count { break }
            }
        }
        return Array(picked.prefix(count))
    }

    private static func distance(_ lhs: GridPosition, _ rhs: GridPosition) -> Double {
        let deltaRow = Double(lhs.row - rhs.row)
        let deltaColumn = Double(lhs.column - rhs.column)
        return (deltaRow * deltaRow + deltaColumn * deltaColumn).squareRoot()
    }
}
