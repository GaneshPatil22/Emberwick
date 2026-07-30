//
//  RootView.swift
//  Emberwick
//
//  The home shell: a Map / Jar bottom bar. The initial tab is adaptive — Jar-first
//  while the grid is sparse, then the grid — overridable in Settings.
//

import SwiftData
import SwiftUI

struct RootView: View {
    @Query private var entries: [Entry]
    @AppStorage("homeMode") private var homeMode: HomeMode = .adaptive
    @AppStorage("didOnboard") private var didOnboard = false

    @State private var selectedTab: AppTab = .map
    @State private var didSetInitialTab = false
    @State private var showOnboarding = false

    private var winCount: Int {
        entries.count(where: { $0.kind == .win })
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Map", systemImage: "square.grid.2x2", value: AppTab.map) {
                MapView()
            }
            Tab("Jar", systemImage: "sparkles", value: AppTab.jar) {
                JarView()
            }
        }
        .tint(EmberPalette.accentInk)
        .task {
            setInitialTabIfNeeded()
            showOnboardingIfNeeded()
        }
        .fullScreenCover(isPresented: $showOnboarding, onDismiss: { didOnboard = true }) {
            OnboardingView()
        }
    }

    private func showOnboardingIfNeeded() {
        if !didOnboard, entries.isEmpty {
            showOnboarding = true
        }
    }

    private func setInitialTabIfNeeded() {
        guard !didSetInitialTab else { return }
        didSetInitialTab = true
        #if DEBUG
        if CommandLine.arguments.contains("-openJar") { selectedTab = .jar; return }
        #endif
        switch homeMode {
        case .grid:
            selectedTab = .map
        case .jar:
            selectedTab = .jar
        case .adaptive:
            selectedTab = winCount >= HomeConstants.jarToGridThreshold ? .map : .jar
        }
    }
}

#Preview {
    RootView()
        .modelContainer(EmberwickModelContainer.preview())
}
