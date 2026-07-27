//
//  YearWeekCell.swift
//  Emberwick
//
//  One enlarged week cell in the year view. A real view (unlike the Canvas-drawn
//  life grid) so it can act as a zoom transition source into the week page.
//

import SwiftUI

struct YearWeekCell: View {
    let state: GridCellState

    var body: some View {
        RoundedRectangle(cornerRadius: EmberRadius.small)
            .fill(state.fillColor)
            .stroke(state.strokeColor ?? .clear, lineWidth: 1.5)
            .aspectRatio(1, contentMode: .fit)
            .shadow(color: (state.glowColor ?? .clear).opacity(0.5), radius: 6)
    }
}
