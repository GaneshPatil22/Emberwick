//
//  MapDestination.swift
//  Emberwick
//
//  Routes a MapRoute to its destination view and applies the zoom transition from
//  the matching source cell. The zoom `sourceID` is the route value itself, which
//  matches the id set on the tapped source cell.
//

import SwiftUI

struct MapDestination: View {
    let route: MapRoute
    let snapshot: GridSnapshot
    var zoomNamespace: Namespace.ID
    let onOpenWeek: (GridPosition) -> Void

    var body: some View {
        switch route {
        case .year(let row):
            YearLevelView(
                row: row,
                snapshot: snapshot,
                zoomNamespace: zoomNamespace,
                onOpenWeek: onOpenWeek
            )
            .navigationTransition(.zoom(sourceID: route, in: zoomNamespace))
        case .week(let position):
            WeekLevelView(position: position)
                .navigationTransition(.zoom(sourceID: route, in: zoomNamespace))
        }
    }
}
