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
    /// While the splash is still on screen, hold off presenting onboarding — a
    /// full-screen cover would otherwise appear above (and hide) the splash.
    var splashActive: Bool = false

    @Query private var entries: [Entry]
    @AppStorage("homeMode") private var homeMode: HomeMode = .adaptive
    @AppStorage("didOnboard") private var didOnboard = false

    @State private var selectedTab: AppTab = .map
    @State private var didSetInitialTab = false
    @State private var didApplyDebugFlags = false
    @State private var firstRunStep: FirstRunStep?

    /// First-run gates, presented in order. The intro is optional (skippable); the
    /// birthday is required — the app can't proceed without it.
    private enum FirstRunStep: Int, Identifiable {
        case intro, birthday
        var id: Int { rawValue }
    }

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
        .task(id: splashActive) {
            applyDebugFlagsIfNeeded()
            setInitialTabIfNeeded()
            advanceFirstRun()
        }
        .fullScreenCover(item: $firstRunStep, onDismiss: advanceFirstRun) { step in
            switch step {
            case .intro: OnboardingFlow()
            case .birthday: BirthdayGate()
            }
        }
    }

    /// Resolves the next required first-run screen: the (optional) intro, then the
    /// (required) birthday gate. Re-runs each time a step is dismissed until the app
    /// is cleared to open. Never presents while the splash is still up.
    private func advanceFirstRun() {
        guard !splashActive else { return }
        firstRunStep = nextFirstRunStep()
    }

    private func nextFirstRunStep() -> FirstRunStep? {
        if shouldShowIntro { return .intro }
        if !AppConfig.isBirthDateSet { return .birthday } // hard requirement
        return nil
    }

    private var shouldShowIntro: Bool {
        #if DEBUG
        if CommandLine.arguments.contains("-onboard") { return !didOnboard }
        #endif
        return !didOnboard && entries.isEmpty
    }

    /// DEBUG: `-onboard` replays the intro by clearing the completion flag once.
    private func applyDebugFlagsIfNeeded() {
        #if DEBUG
        guard !didApplyDebugFlags else { return }
        didApplyDebugFlags = true
        if CommandLine.arguments.contains("-onboard") { didOnboard = false }
        #endif
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
