//
//  GridLegendView.swift
//  Emberwick
//
//  The fixed-order legend: bronze, silver, gold, diamond, this week, ahead.
//  Laid out as a 3-column grid so it reads left-to-right in that order.
//

import SwiftUI

struct GridLegendView: View {
    private let columns = Array(
        repeating: GridItem(.flexible(), alignment: .leading),
        count: 3
    )

    private let entries: [GridLegendEntry] = [
        GridLegendEntry("Bronze", color: EmberPalette.bronze),
        GridLegendEntry("Silver", color: EmberPalette.silver),
        GridLegendEntry("Gold", color: EmberPalette.gold),
        GridLegendEntry("Diamond", color: EmberPalette.diamond),
        GridLegendEntry("This week", color: EmberPalette.accent),
        GridLegendEntry("Ahead", color: EmberPalette.line, isOutline: true)
    ]

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: EmberSpacing.sm) {
            ForEach(entries) { entry in
                HStack(spacing: EmberSpacing.xs) {
                    GridLegendSwatch(entry: entry)
                    Text(entry.label)
                        .font(EmberTypography.legend)
                        .foregroundStyle(EmberPalette.inkSoft)
                }
            }
        }
    }
}

#Preview {
    GridLegendView()
        .padding()
        .background(EmberPalette.paper)
}
