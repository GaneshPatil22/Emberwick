//
//  LifeLevelView.swift
//  Emberwick
//
//  The Map home: warm header (+ add-era button), the zoomable life grid, and the
//  legend. Header and legend stay fixed as chrome; the grid zooms/pans between them.
//

import SwiftUI

struct LifeLevelView: View {
    let snapshot: GridSnapshot
    let entries: [Entry]
    let bands: [EraBand]
    var zoomNamespace: Namespace.ID
    let onOpenYear: (Int) -> Void

    @State private var showEras = false

    private var winCount: Int {
        entries.count(where: { $0.kind == .win })
    }

    // Win count stays hidden until a threshold so a sparse early grid doesn't
    // demotivate — a warm line shows instead.
    private var subtitle: String {
        winCount >= HomeConstants.hideWinCountThreshold
            ? "\(winCount) good moments and counting."
            : "Every glowing week is a moment worth keeping."
    }

    var body: some View {
        VStack(spacing: EmberSpacing.md) {
            HStack(alignment: .top) {
                GridHeaderView(
                    title: "Your life",
                    subtitle: subtitle
                )
                Spacer(minLength: EmberSpacing.sm)
                addEraButton
            }
            LifeGridInteractiveView(
                snapshot: snapshot,
                entries: entries,
                bands: bands,
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
        .sheet(isPresented: $showEras) {
            EraListView()
        }
    }

    private var addEraButton: some View {
        Button {
            showEras = true
        } label: {
            Image(systemName: "rectangle.stack")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(EmberPalette.accentInk)
                .frame(width: 44, height: 44)
                .background(EmberPalette.paper2, in: .rect(cornerRadius: EmberRadius.medium))
        }
        .accessibilityLabel("Eras")
    }
}
