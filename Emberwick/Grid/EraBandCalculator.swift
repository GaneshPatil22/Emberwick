//
//  EraBandCalculator.swift
//  Emberwick
//
//  Pure mapping from eras to start/end WEEK cells, clamped to the visible grid, so a
//  mid-year era (e.g. July→July) starts and ends partway across its rows.
//

import Foundation

enum EraBandCalculator {
    static func bands(
        eras: [Era],
        birthYear: Int,
        rowCount: Int,
        calendar: Calendar = .current
    ) -> [EraBand] {
        let lastColumn = GridConstants.columnsPerYear - 1

        return eras.compactMap { era in
            let rawStart = GridMath.position(for: era.startDate, birthYear: birthYear, calendar: calendar)
            let rawEnd = GridMath.position(for: era.endDate, birthYear: birthYear, calendar: calendar)

            // Skip eras entirely outside the visible grid.
            guard rawEnd.row >= 0, rawStart.row <= rowCount - 1 else { return nil }

            let start = clamped(rawStart, rowCount: rowCount, lastColumn: lastColumn)
            let end = clamped(rawEnd, rowCount: rowCount, lastColumn: lastColumn)

            let isOrdered = end.row > start.row || (end.row == start.row && end.column >= start.column)
            guard isOrdered else { return nil }

            return EraBand(name: era.name, tintHex: era.tintHex, start: start, end: end)
        }
    }

    private static func clamped(_ position: GridPosition, rowCount: Int, lastColumn: Int) -> GridPosition {
        if position.row < 0 { return GridPosition(row: 0, column: 0) }
        if position.row > rowCount - 1 { return GridPosition(row: rowCount - 1, column: lastColumn) }
        return GridPosition(row: position.row, column: min(max(position.column, 0), lastColumn))
    }
}
