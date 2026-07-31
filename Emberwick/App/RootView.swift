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
    @AppStorage("didTour") private var didTour = false
    /// One-shot trigger set by Settings' "Take a tour".
    @AppStorage("tourRequested") private var tourRequested = false

    @State private var selectedTab: AppTab = .map
    @State private var didSetInitialTab = false
    @State private var didApplyDebugFlags = false
    @State private var firstRunStep: FirstRunStep?

    @State private var tourAnchors = TourAnchors()
    @State private var tourActive = false
    @State private var tourIndex = 0

    /// First-run gates, presented in order. The intro is optional (skippable); the
    /// birthday is required — the app can't proceed without it.
    private enum FirstRunStep: Int, Identifiable {
        case intro, birthday
        var id: Int { rawValue }
    }

    private var winCount: Int {
        entries.count(where: { $0.kind == .win })
    }

    private var currentTourStep: TourStep? {
        tourActive && tourIndex < Tour.steps.count ? Tour.steps[tourIndex] : nil
    }

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                Tab("Map", systemImage: "square.grid.2x2", value: AppTab.map) {
                    MapView()
                }
                Tab("Jar", systemImage: "sparkles", value: AppTab.jar) {
                    JarView()
                }
            }
            .tint(EmberPalette.accentInk)
            .environment(tourAnchors)

            if let step = currentTourStep, let rect = tourAnchors.frames[step.target] {
                TourOverlay(
                    rect: rect,
                    step: step,
                    index: tourIndex,
                    total: Tour.steps.count,
                    onNext: tourNext,
                    onSkip: endTour
                )
                .transition(.opacity)
            }
        }
        .coordinateSpace(.named(Tour.space))
        .animation(EmberMotion.settle, value: tourIndex)
        .animation(.easeInOut(duration: 0.25), value: tourActive)
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
        .onChange(of: tourRequested) { _, requested in
            if requested {
                tourRequested = false
                startTour()
            }
        }
    }

    // MARK: - Tour

    private func startTour() {
        guard !Tour.steps.isEmpty else { return }
        tourIndex = 0
        selectedTab = Tour.steps[0].tab
        tourActive = true
        didTour = true
    }

    private func tourNext() {
        if tourIndex + 1 < Tour.steps.count {
            tourIndex += 1
            selectedTab = Tour.steps[tourIndex].tab
        } else {
            endTour()
        }
    }

    private func endTour() {
        tourActive = false
    }

    /// Auto-runs the tour once, after the first-run gates are cleared.
    private func startTourIfNeeded() {
        guard !didTour, !tourActive else { return }
        #if DEBUG
        if CommandLine.arguments.contains("-noTour") { didTour = true; return }
        #endif
        startTour()
    }

    /// Resolves the next required first-run screen: the (optional) intro, then the
    /// (required) birthday gate. Re-runs each time a step is dismissed until the app
    /// is cleared to open. Never presents while the splash is still up.
    private func advanceFirstRun() {
        guard !splashActive else { return }
        firstRunStep = nextFirstRunStep()
        if firstRunStep == nil { startTourIfNeeded() }
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
        if CommandLine.arguments.contains("-tour") { didTour = false }
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
