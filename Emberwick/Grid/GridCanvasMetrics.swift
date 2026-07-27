//
//  GridCanvasMetrics.swift
//  Emberwick
//
//  Pure layout math for the life-grid Canvas: fits square cells into the available
//  size, centers the lattice, and maps a point back to a cell (for taps).
//

import CoreGraphics

struct GridCanvasMetrics {
    let cell: Double
    let gap: Double
    private let origin: CGPoint

    init(size: CGSize, columns: Int, rows: Int, gap: Double) {
        self.gap = gap

        let totalGapWidth = gap * Double(max(columns - 1, 0))
        let totalGapHeight = gap * Double(max(rows - 1, 0))
        let cellWidth = (Double(size.width) - totalGapWidth) / Double(columns)
        let cellHeight = (Double(size.height) - totalGapHeight) / Double(rows)
        cell = max(min(cellWidth, cellHeight), 0)

        let gridWidth = Double(columns) * cell + totalGapWidth
        let gridHeight = Double(rows) * cell + totalGapHeight
        origin = CGPoint(
            x: (Double(size.width) - gridWidth) / 2,
            y: (Double(size.height) - gridHeight) / 2
        )
    }

    func rect(row: Int, column: Int) -> CGRect {
        CGRect(
            x: origin.x + Double(column) * (cell + gap),
            y: origin.y + Double(row) * (cell + gap),
            width: cell,
            height: cell
        )
    }

    /// The grid position under a point, or `nil` if outside the lattice.
    func position(at point: CGPoint, rowCount: Int, columns: Int) -> GridPosition? {
        guard cell > 0 else { return nil }
        let step = cell + gap
        let column = Int((Double(point.x) - origin.x) / step)
        let row = Int((Double(point.y) - origin.y) / step)
        guard (0..<rowCount).contains(row), (0..<columns).contains(column) else { return nil }
        return GridPosition(row: row, column: column)
    }
}
