//
//  GridLegendSwatch.swift
//  Emberwick
//
//  The small color chip in a legend row. "Ahead" renders as an outline to match the
//  grid's unlived cells.
//

import SwiftUI

struct GridLegendSwatch: View {
    let entry: GridLegendEntry

    private let size: Double = 11

    var body: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(entry.isOutline ? Color.clear : entry.color)
            .stroke(entry.isOutline ? EmberPalette.line2 : Color.clear, lineWidth: 1.5)
            .frame(width: size, height: size)
    }
}
