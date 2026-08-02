//
//  GridMath.swift
//  Emberwick
//
//  The pure functional core of the app: day-of-year week mapping. Every result is
//  a function of its inputs, with no side effects, so it is trivially testable.
//
//  Deliberately NOT ISO-week based. ISO weeks push early-January dates into the
//  prior year's week 52/53; day-of-year restarts every row at box 0 on Jan 1, so a
//  date can never leak into the previous year's row.
//

import Foundation

enum GridMath {
    /// Day of the year for `date`, 1...366.
    static func dayOfYear(for date: Date, calendar: Calendar = .current) -> Int {
        calendar.ordinality(of: .day, in: .year, for: date) ?? 1
    }

    /// Week-box (column) index for `date`, 0...52.
    /// Box 0 = Jan 1–7, box 1 = Jan 8–14, … box 52 = the final 1–2 day sliver.
    static func boxIndex(for date: Date, calendar: Calendar = .current) -> Int {
        (dayOfYear(for: date, calendar: calendar) - 1) / 7
    }

    /// Calendar year for `date`.
    static func year(for date: Date, calendar: Calendar = .current) -> Int {
        calendar.component(.year, from: date)
    }

    /// Row (0-based offset from `birthYear`) for `date`.
    static func row(for date: Date, birthYear: Int, calendar: Calendar = .current) -> Int {
        year(for: date, calendar: calendar) - birthYear
    }

    /// Full grid position for `date`, given the user's birth year.
    static func position(for date: Date, birthYear: Int, calendar: Calendar = .current) -> GridPosition {
        GridPosition(
            row: row(for: date, birthYear: birthYear, calendar: calendar),
            column: boxIndex(for: date, calendar: calendar)
        )
    }

    /// A representative date that maps back to `(row, column)` — the first day of
    /// that week box. Used when creating a new entry for a derived week.
    static func representativeDate(
        row: Int,
        column: Int,
        birthYear: Int,
        calendar: Calendar = .current
    ) -> Date {
        let january1 = calendar.date(from: DateComponents(year: birthYear + row, month: 1, day: 1)) ?? .now
        return calendar.date(byAdding: .day, value: column * 7, to: january1) ?? january1
    }

    /// The precise calendar date range a week box covers: its first day through its
    /// last (the final box of a year is a 1–2 day sliver, clamped to Dec 31). Since
    /// boxes are exact 7-day windows from Jan 1, this is accurate — not an estimate.
    static func dateRange(
        row: Int,
        column: Int,
        birthYear: Int,
        calendar: Calendar = .current
    ) -> ClosedRange<Date> {
        let start = representativeDate(row: row, column: column, birthYear: birthYear, calendar: calendar)
        let naturalEnd = calendar.date(byAdding: .day, value: 6, to: start) ?? start
        // Clamp to the last day of the box's calendar year so the sliver box is honest.
        let yearEnd = calendar.date(from: DateComponents(year: birthYear + row, month: 12, day: 31)) ?? naturalEnd
        return start...min(naturalEnd, yearEnd)
    }
}
