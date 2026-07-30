//
//  JarSelector.swift
//  Emberwick
//
//  Pure weighted pick for the Jar: favors wins not seen in a long time (or never),
//  so a shake keeps rediscovering rather than replaying. All-time scope; wins only.
//

import Foundation

enum JarSelector {
    /// Picks a win, weighted by how long since it was last surfaced. Returns `nil`
    /// only when there are no wins.
    static func pick(
        from wins: [Entry],
        now: Date,
        using generator: inout some RandomNumberGenerator
    ) -> Entry? {
        guard !wins.isEmpty else { return nil }

        let weights = wins.map { win in
            let last = win.lastSeenAt ?? .distantPast
            // Days since last seen, floored at 1 so everything has some chance.
            return max(1, now.timeIntervalSince(last) / 86_400)
        }

        let total = weights.reduce(0, +)
        var roll = Double.random(in: 0..<total, using: &generator)
        for (index, weight) in weights.enumerated() {
            if roll < weight { return wins[index] }
            roll -= weight
        }
        return wins.last
    }
}
