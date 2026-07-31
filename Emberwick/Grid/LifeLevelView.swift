//
//  LifeLevelView.swift
//  Emberwick
//
//  The Map home: warm header (+ add-era button), the zoomable life grid, and the
//  legend. Header and legend stay fixed as chrome; the grid zooms/pans between them.
//

import SwiftData
import SwiftUI

struct LifeLevelView: View {
    let snapshot: GridSnapshot
    let entries: [Entry]
    let bands: [EraBand]
    var zoomNamespace: Namespace.ID
    let onOpenYear: (Int) -> Void
    let onOpenResurfaced: (GridPosition) -> Void

    @Environment(\.modelContext) private var modelContext
    @AppStorage(AppConfig.birthDateKey) private var birthInterval = 0.0
    @State private var showEras = false
    /// Frozen for the session so the card doesn't vanish once it's marked seen.
    @State private var resurfaced: Entry?
    @State private var didPickResurfaced = false

    private var birthDate: Date {
        AppConfig.birthDate(interval: birthInterval)
    }

    private var winCount: Int {
        entries.validWins(bornOn: birthDate).count
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

            if let win = resurfaced {
                ResurfacingCard(
                    win: win,
                    onOpen: { openResurfaced(win) },
                    onDismiss: { resurfaced = nil }
                )
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
        .task(id: entries.isEmpty) {
            pickResurfacedIfNeeded()
        }
    }

    /// Picks the resurfacing win once (when entries are available), marks it seen so
    /// it won't resurface again, and freezes it for the session.
    private func pickResurfacedIfNeeded() {
        guard !didPickResurfaced, !entries.isEmpty else { return }
        didPickResurfaced = true
        guard let win = ResurfacingSelector.resurfaced(
            wins: entries.validWins(bornOn: birthDate),
            today: .now
        ) else { return }
        win.resurfacedAt = .now
        try? modelContext.save()
        resurfaced = win
    }

    private func openResurfaced(_ win: Entry) {
        let birthYear = GridMath.year(for: birthDate)
        onOpenResurfaced(GridMath.position(for: win.date, birthYear: birthYear))
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
