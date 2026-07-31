//
//  ResurfacingSelector.swift
//  Emberwick
//
//  Pure pick for "you did this a year ago": a win from a previous year that lands on
//  roughly this week (within a few days of today's day-of-year). Own past win, never
//  a quote. Prefers the most recent matching anniversary.
//

import Foundation

enum ResurfacingSelector {
    static func resurfaced(
        wins: [Entry],
        today: Date,
        windowDays: Int = 4,
        calendar: Calendar = .current
    ) -> Entry? {
        let todayDayOfYear = GridMath.dayOfYear(for: today, calendar: calendar)
        let todayYear = GridMath.year(for: today, calendar: calendar)

        let candidates = wins.filter { win in
            guard win.resurfacedAt == nil else { return false } // already surfaced before
            let winYear = GridMath.year(for: win.date, calendar: calendar)
            guard winYear < todayYear else { return false } // a previous year
            let winDayOfYear = GridMath.dayOfYear(for: win.date, calendar: calendar)
            return abs(winDayOfYear - todayDayOfYear) <= windowDays
        }

        // The most recent matching anniversary (closest year back).
        return candidates.max { $0.date < $1.date }
    }
}
