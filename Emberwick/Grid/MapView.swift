//
//  MapView.swift
//  Emberwick
//
//  The Map mode: a NavigationStack whose root is the zoomable life grid. Tapping a
//  week cell zooms into its week page via the native zoom transition (flying from
//  the tapped cell). There is no separate year screen.
//

import SwiftData
import SwiftUI

struct MapView: View {
    @Query private var entries: [Entry]
    @Query private var eras: [Era]

    @Namespace private var zoomNamespace
    @State private var path: [MapRoute] = []

    private var birthYear: Int {
        GridMath.year(for: AppConfig.defaultBirthDate)
    }

    private var bands: [EraBand] {
        EraBandCalculator.bands(eras: eras, birthYear: birthYear, rowCount: GridConstants.lifespanYears)
    }

    var body: some View {
        NavigationStack(path: $path) {
            LifeLevelView(snapshot: snapshot, entries: entries, bands: bands, zoomNamespace: zoomNamespace) { row in
                path.append(.year(row))
            }
            .navigationDestination(for: MapRoute.self) { route in
                MapDestination(
                    route: route,
                    snapshot: snapshot,
                    zoomNamespace: zoomNamespace
                ) { position in
                    path.append(.week(position))
                }
            }
        }
        .tint(EmberPalette.accentInk)
        .onAppear(perform: applyDebugPathIfNeeded)
    }

    private var snapshot: GridSnapshot {
        GridSnapshot.make(
            entries: entries,
            birthDate: AppConfig.defaultBirthDate,
            today: .now
        )
    }

    /// DEBUG helper so the year/week can be screenshotted without a tap:
    /// `-openYear 32` (year) or `-openYear 32 -openWeekColumn 20` (year → week).
    private func applyDebugPathIfNeeded() {
        #if DEBUG
        guard path.isEmpty else { return }
        let arguments = CommandLine.arguments
        guard let row = intArgument("-openYear", in: arguments) else { return }
        var newPath: [MapRoute] = [.year(row)]
        if let column = intArgument("-openWeekColumn", in: arguments) {
            newPath.append(.week(GridPosition(row: row, column: column)))
        }
        path = newPath
        #endif
    }

    private func intArgument(_ flag: String, in arguments: [String]) -> Int? {
        guard let index = arguments.firstIndex(of: flag), index + 1 < arguments.count else { return nil }
        return Int(arguments[index + 1])
    }
}

#Preview {
    MapView()
        .modelContainer(EmberwickModelContainer.preview())
}
