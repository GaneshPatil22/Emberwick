//
//  LifeZoomSourceOverlay.swift
//  Emberwick
//
//  An invisible anchor over the tapped cell, giving the zoom transition into the
//  week page a precise source rect to fly from (the Canvas can't host a per-cell
//  transition source itself). Tracks zoom/pan because it lives inside the same
//  transformed content.
//

import SwiftUI

struct LifeZoomSourceOverlay: View {
    let position: GridPosition
    let gridSize: CGSize
    let rowCount: Int
    var zoomNamespace: Namespace.ID

    var body: some View {
        let metrics = GridCanvasMetrics(
            size: gridSize,
            columns: GridConstants.columnsPerYear,
            rows: rowCount,
            gap: GridConstants.cellSpacing
        )
        let rect = metrics.rect(row: position.row, column: position.column)

        Color.clear
            .frame(width: rect.width, height: rect.height)
            .matchedTransitionSource(id: MapRoute.year(position.row), in: zoomNamespace)
            .position(x: rect.midX, y: rect.midY)
            .allowsHitTesting(false)
    }
}
