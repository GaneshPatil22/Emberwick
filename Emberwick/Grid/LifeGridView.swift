//
//  LifeGridView.swift
//  Emberwick
//
//  Renders the full-life grid with a single Canvas (~4,770 cells) for performance.
//  Memory and this-week cells emit a soft glow — the app's signature. Drawn crisp
//  at whatever size it's given, so pinch-zoom (which resizes the Canvas) stays sharp.
//

import SwiftUI

struct LifeGridView: View {
    let snapshot: GridSnapshot
    let bands: [EraBand]
    let rowCount: Int

    var body: some View {
        Canvas { context, size in
            let metrics = GridCanvasMetrics(
                size: size,
                columns: GridConstants.columnsPerYear,
                rows: rowCount,
                gap: GridConstants.cellSpacing
            )
            // Era bands first (background) so tier-colored wins pop above them.
            for band in bands {
                drawBand(band, metrics: metrics, context: &context)
            }
            for row in 0..<rowCount {
                for column in 0..<GridConstants.columnsPerYear {
                    let state = snapshot.state(row: row, column: column)
                    draw(state, in: metrics.rect(row: row, column: column), context: &context)
                }
            }
        }
        .accessibilityElement()
        .accessibilityLabel("Life grid. Each cell is one week; glowing cells hold a memory.")
    }

    private func drawBand(_ band: EraBand, metrics: GridCanvasMetrics, context: inout GraphicsContext) {
        // Text-selection-style range: the start row runs from its start column to the
        // row end, middle rows are full width, the end row runs to its end column.
        let tint = Color(hexString: band.tintHex).opacity(0.55)
        for row in band.start.row...band.end.row {
            let firstColumn = (row == band.start.row) ? band.start.column : 0
            let lastColumn = (row == band.end.row) ? band.end.column : GridConstants.columnsPerYear - 1
            guard lastColumn >= firstColumn else { continue }

            let leftCell = metrics.rect(row: row, column: firstColumn)
            let rightCell = metrics.rect(row: row, column: lastColumn)
            var rect = CGRect(
                x: leftCell.minX,
                y: leftCell.minY,
                width: rightCell.maxX - leftCell.minX,
                height: leftCell.height
            )
            if row < band.end.row { rect.size.height += metrics.gap } // bridge the inter-row gap
            context.fill(Path(rect), with: .color(tint))
        }
    }

    private func draw(_ state: GridCellState, in rect: CGRect, context: inout GraphicsContext) {
        let path = Path(roundedRect: rect, cornerRadius: GridConstants.cellCornerRadius)

        if let stroke = state.strokeColor {
            context.stroke(path, with: .color(stroke), lineWidth: 0.5)
            return
        }

        if let glow = state.glowColor {
            let glowRadius = min(rect.width * 0.7, 24)
            context.drawLayer { layer in
                layer.addFilter(.shadow(color: glow.opacity(0.7), radius: glowRadius))
                layer.fill(path, with: .color(state.fillColor))
            }
        } else {
            context.fill(path, with: .color(state.fillColor))
        }
    }
}
