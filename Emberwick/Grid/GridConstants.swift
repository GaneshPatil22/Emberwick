//
//  GridConstants.swift
//  Emberwick
//
//  Fixed dimensions of the life grid. Kept with the grid feature (not the design
//  tokens) because they describe the week-math layout, not the visual theme.
//

import Foundation

enum GridConstants {
    /// Week boxes per year row. Day-of-year math yields column indices 0...52,
    /// so a row holds up to 53 boxes (box 52 is a 1–2 day sliver).
    static let columnsPerYear = 53

    /// Highest valid week-box (column) index.
    static let lastColumnIndex = columnsPerYear - 1  // 52

    /// Rows in a full-life grid (~90 years).
    static let lifespanYears = 90

    /// Gap between cells in the life grid, in points.
    static let cellSpacing: Double = 1.5

    /// Corner radius of a life-grid cell, in points.
    static let cellCornerRadius: Double = 2

    /// Most the life grid can be pinched in.
    static let maxZoomScale: Double = 10
}
