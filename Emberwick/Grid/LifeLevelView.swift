//
//  LifeLevelView.swift
//  Emberwick
//
//  The Map home: warm header, the zoomable life grid, and the legend. Header and
//  legend stay fixed as chrome; the grid zooms/pans between them.
//

import SwiftUI

struct LifeLevelView: View {
    let snapshot: GridSnapshot
    let entries: [Entry]
    var zoomNamespace: Namespace.ID
    let onOpenYear: (Int) -> Void

    var body: some View {
        VStack(spacing: EmberSpacing.md) {
            GridHeaderView(
                title: "Your life",
                subtitle: "Every glowing week is a moment worth keeping."
            )
            LifeGridInteractiveView(
                snapshot: snapshot,
                entries: entries,
                rowCount: GridConstants.lifespanYears,
                zoomNamespace: zoomNamespace,
                onOpenYear: onOpenYear
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            GridLegendView()
        }
        .padding(.horizontal, EmberSpacing.xl)
        .padding(.top, EmberSpacing.lg)
        .padding(.bottom, EmberSpacing.md)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(EmberPalette.paper)
    }
}
