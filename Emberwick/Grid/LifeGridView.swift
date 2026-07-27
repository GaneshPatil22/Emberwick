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
    let rowCount: Int

    var body: some View {
        Canvas { context, size in
            let metrics = GridCanvasMetrics(
                size: size,
                columns: GridConstants.columnsPerYear,
                rows: rowCount,
                gap: GridConstants.cellSpacing
            )
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
