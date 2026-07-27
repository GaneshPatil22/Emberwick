//
//  YearLevelView.swift
//  Emberwick
//
//  A single year, its 53 weeks enlarged into tappable cells. Title shows age
//  (row-derived, so it's safe — it's the year, not a specific week). Tapping a week
//  zooms into the week page.
//

import SwiftUI

struct YearLevelView: View {
    let row: Int
    let snapshot: GridSnapshot
    var zoomNamespace: Namespace.ID
    let onOpenWeek: (GridPosition) -> Void

    private let columns = [GridItem(.adaptive(minimum: 40), spacing: EmberSpacing.sm)]

    var body: some View {
        VStack(alignment: .leading, spacing: EmberSpacing.lg) {
            Text("Age \(row)")
                .font(EmberTypography.title)
                .foregroundStyle(EmberPalette.ink)

            LazyVGrid(columns: columns, spacing: EmberSpacing.sm) {
                ForEach(0..<GridConstants.columnsPerYear, id: \.self) { column in
                    let position = GridPosition(row: row, column: column)
                    YearWeekCell(state: snapshot.state(row: row, column: column))
                        .matchedTransitionSource(id: MapRoute.week(position), in: zoomNamespace)
                        .onTapGesture { onOpenWeek(position) }
                }
            }

            Spacer(minLength: 0)
        }
        .padding(EmberSpacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(EmberPalette.paper)
    }
}
