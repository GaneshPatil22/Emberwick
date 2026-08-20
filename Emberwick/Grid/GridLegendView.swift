//
//  GridLegendView.swift
//  Emberwick
//
//  The colour key: bronze, silver, gold, diamond, this week, ahead. It's a reference,
//  not a permanent fixture — so it's collapsed to a small pill by default and the user
//  taps to reveal it when they need it. The choice persists.
//

import SwiftUI

struct GridLegendView: View {
    @AppStorage("legendExpanded") private var expanded = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

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
        VStack(spacing: EmberSpacing.sm) {
            if expanded {
                swatches
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
            toggle
        }
        .animation(reduceMotion ? nil : EmberMotion.settle, value: expanded)
    }

    private var swatches: some View {
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

    private var toggle: some View {
        Button {
            expanded.toggle()
        } label: {
            HStack(spacing: EmberSpacing.xs) {
                Image(systemName: "paintpalette.fill")
                Text(expanded ? "Hide colour key" : "Colour key")
                Image(systemName: expanded ? "chevron.down" : "chevron.up")
                    .font(.system(size: 9, weight: .semibold))
            }
            .font(EmberTypography.legend)
            .foregroundStyle(EmberPalette.inkSoft)
            .padding(.horizontal, EmberSpacing.md)
            .padding(.vertical, EmberSpacing.xs)
            .background(EmberPalette.paper2, in: .capsule)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(expanded ? "Hide colour key" : "Show colour key")
    }
}

#Preview {
    GridLegendView()
        .padding()
        .background(EmberPalette.paper)
}
