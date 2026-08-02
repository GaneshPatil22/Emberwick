//
//  GridMathTests.swift
//  EmberwickTests
//
//  Locks in the pure day-of-year week mapping — the backbone of the whole app.
//  Uses a fixed Gregorian/UTC calendar so results are deterministic regardless
//  of where the tests run.
//

import Foundation
import Testing
@testable import Emberwick

@Suite("Grid math — day-of-year week mapping")
struct GridMathTests {
    /// Fixed calendar so tests never depend on the machine's locale/timezone.
    private let calendar: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC") ?? .gmt
        return cal
    }()

    private func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        let components = DateComponents(year: year, month: month, day: day)
        return calendar.date(from: components) ?? .distantPast
    }

    @Test("Box boundaries fall on 7-day steps from Jan 1")
    func boxBoundaries() {
        #expect(GridMath.boxIndex(for: date(2022, 1, 1), calendar: calendar) == 0)
        #expect(GridMath.boxIndex(for: date(2022, 1, 7), calendar: calendar) == 0)
        #expect(GridMath.boxIndex(for: date(2022, 1, 8), calendar: calendar) == 1)
        #expect(GridMath.boxIndex(for: date(2022, 1, 14), calendar: calendar) == 1)
        #expect(GridMath.boxIndex(for: date(2022, 1, 15), calendar: calendar) == 2)
    }

    @Test("The final days of the year land in the sliver box 52")
    func sliverBox() {
        #expect(GridMath.boxIndex(for: date(2022, 12, 31), calendar: calendar) == 52) // non-leap
        #expect(GridMath.boxIndex(for: date(2024, 12, 31), calendar: calendar) == 52) // leap
        #expect(GridMath.boxIndex(for: date(2024, 12, 30), calendar: calendar) == 52) // leap
    }

    @Test("An early-January date never leaks into the prior year's row")
    func earlyJanuaryStaysInOwnRow() {
        let jan2 = date(2022, 1, 2)
        #expect(GridMath.year(for: jan2, calendar: calendar) == 2022)
        #expect(GridMath.boxIndex(for: jan2, calendar: calendar) == 0)
    }

    @Test("Column index never exceeds the last valid box across a full leap year")
    func columnNeverExceedsMax() {
        for month in 1...12 {
            for day in 1...28 {
                let column = GridMath.boxIndex(for: date(2024, month, day), calendar: calendar)
                #expect(column <= GridConstants.lastColumnIndex)
            }
        }
        #expect(GridMath.boxIndex(for: date(2024, 12, 31), calendar: calendar) <= GridConstants.lastColumnIndex)
    }

    @Test("Row is the offset from the birth year")
    func rowFromBirthYear() {
        #expect(GridMath.row(for: date(2022, 6, 1), birthYear: 1990, calendar: calendar) == 32)
        #expect(GridMath.row(for: date(1990, 1, 1), birthYear: 1990, calendar: calendar) == 0)
    }

    @Test("Position combines row and column")
    func positionCombinesRowAndColumn() {
        let position = GridMath.position(for: date(2022, 1, 8), birthYear: 1990, calendar: calendar)
        #expect(position == GridPosition(row: 32, column: 1))
    }

    @Test("A week box maps to its exact 7-day calendar range")
    func dateRangeIsExact() {
        // Row 30 = 2020 (leap), column 20 → Jan 1 + 140 days = 20–26 May 2020.
        let range = GridMath.dateRange(row: 30, column: 20, birthYear: 1990, calendar: calendar)
        #expect(range.lowerBound == date(2020, 5, 20))
        #expect(range.upperBound == date(2020, 5, 26))
    }

    @Test("The sliver box is clamped to the year's last day")
    func dateRangeSliverClamped() {
        // Row 32 = 2022 (non-leap), box 52 begins on day 365 = 31 Dec.
        let range = GridMath.dateRange(row: 32, column: 52, birthYear: 1990, calendar: calendar)
        #expect(range.upperBound == date(2022, 12, 31))
    }

    @Test("A representative date round-trips back to its own box")
    func representativeRoundTrips() {
        for column in [0, 1, 10, 26, 51, 52] {
            let representative = GridMath.representativeDate(row: 30, column: column, birthYear: 1990, calendar: calendar)
            #expect(GridMath.boxIndex(for: representative, calendar: calendar) == column)
        }
    }
}
