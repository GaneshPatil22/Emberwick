//
//  JarView.swift
//  Emberwick
//
//  The Jar mode: a glass jar of glowing wins. On entry, memories fly INTO the jar.
//  Shake (device or button) makes a weighted-random long-unseen win grow out of the
//  jar into a reveal; "Put it back" sends it back in. "Add a win" drops a new one in.
//  The Jar points at wins (a lens) — it never contains or deletes them.
//

import SwiftData
import SwiftUI

struct JarView: View {
    @Query private var entries: [Entry]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @AppStorage(AppConfig.birthDateKey) private var birthInterval = 0.0

    @State private var revealedWin: Entry?
    @State private var showAddWin = false
    @State private var showSettings = false
    @State private var shakeDetector = ShakeDetector()

    @State private var jarSize: CGSize = .zero
    @State private var fillFlights: [MemoryFlight] = []
    @State private var completedFillIDs: Set<UUID> = []
    @State private var isPlayingFill = false
    @State private var didPlayFill = false

    private let fillDuration: Double = 1.0
    private let fillWindow: Double = 1.2
    private let maxFillCards = 18

    /// Only wins from the birth date onward — pre-birth wins stay hidden here too.
    private var wins: [Entry] {
        entries.validWins(bornOn: AppConfig.birthDate(interval: birthInterval))
    }

    private var countTitle: String {
        wins.isEmpty ? "Your jar is empty" : "\(wins.count) good moments inside"
    }

    private var subtitle: String {
        wins.isEmpty ? "Add your first win to start filling it." : "Shake to relive one you might have forgotten."
    }

    var body: some View {
        ZStack {
            EmberPalette.paper.ignoresSafeArea()

            VStack(spacing: EmberSpacing.md) {
                HStack(alignment: .top) {
                    Text("Your jar")
                        .font(EmberTypography.title)
                        .foregroundStyle(EmberPalette.ink)
                    Spacer()
                    Button { showSettings = true } label: {
                        Image(systemName: "gearshape")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(EmberPalette.accentInk)
                            .frame(width: 44, height: 44)
                            .background(EmberPalette.paper2, in: .rect(cornerRadius: EmberRadius.medium))
                    }
                    .accessibilityLabel("Settings")
                }

                Spacer()

                JarIllustration(
                    orbColors: wins.prefix(6).map { $0.tier?.color ?? EmberPalette.memoryNeutral },
                    animate: !reduceMotion
                )
                Text(countTitle)
                    .font(EmberTypography.heading)
                    .foregroundStyle(EmberPalette.ink)
                Text(subtitle)
                    .font(EmberTypography.subtitle)
                    .foregroundStyle(EmberPalette.inkSoft)
                    .multilineTextAlignment(.center)

                Spacer()

                Button(action: performShake) {
                    Label("Shake for a memory", systemImage: "sparkles")
                        .font(EmberTypography.body)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, EmberSpacing.md)
                        .foregroundStyle(.white)
                        .background(EmberPalette.accent, in: .rect(cornerRadius: EmberRadius.medium))
                }
                .disabled(wins.isEmpty)
                .opacity(wins.isEmpty ? 0.5 : 1)

                Button(action: { showAddWin = true }) {
                    Label("Add a win", systemImage: "plus")
                        .font(EmberTypography.body)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, EmberSpacing.md)
                        .foregroundStyle(EmberPalette.inkSoft)
                        .background(
                            RoundedRectangle(cornerRadius: EmberRadius.medium)
                                .stroke(EmberPalette.line2, lineWidth: 1.5)
                        )
                }
            }
            .padding(EmberSpacing.xl)
        }
        .onGeometryChange(for: CGSize.self) { $0.size } action: { size in
            jarSize = size
            startFillIfNeeded()
        }
        .overlay {
            if isPlayingFill {
                IntroFlightOverlay(flights: fillFlights, flightDuration: fillDuration, onComplete: fillCompleted)
            }
        }
        .overlay {
            if let win = revealedWin {
                RevealView(win: win, jarSize: jarSize) { revealedWin = nil }
            }
        }
        .sheet(isPresented: $showAddWin) {
            EntryEditView(existingEntry: nil, weekDate: .now)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .onAppear {
            shakeDetector.onShake = performShake
            shakeDetector.start()
            startFillIfNeeded()
        }
        .onDisappear {
            shakeDetector.stop()
        }
    }

    // MARK: - Shake / reveal

    private func performShake() {
        guard revealedWin == nil, !wins.isEmpty else { return }
        var generator = SystemRandomNumberGenerator()
        guard let win = JarSelector.pick(from: wins, now: .now, using: &generator) else { return }
        win.lastSeenAt = .now
        try? modelContext.save()
        revealedWin = win
    }

    // MARK: - Fill (memories flying into the jar)

    private func startFillIfNeeded() {
        guard !didPlayFill, !reduceMotion, jarSize.width > 1, !wins.isEmpty else { return }
        didPlayFill = true

        let chosen = Array(wins.shuffled().prefix(maxFillCards))
        let count = chosen.count
        let jarCenter = CGPoint(x: jarSize.width / 2, y: jarSize.height * 0.44)

        completedFillIDs = []
        fillFlights = chosen.enumerated().map { index, win in
            MemoryFlight(
                content: tokenContent(for: win),
                tier: win.tier,
                start: fillStart(index: index),
                end: jarCenter,
                delay: fillWindow * Double(index) / Double(max(count - 1, 1))
            )
        }
        isPlayingFill = true
    }

    private func fillCompleted(_ flight: MemoryFlight) {
        completedFillIDs.insert(flight.id)
        guard completedFillIDs.count >= fillFlights.count else { return }
        isPlayingFill = false
        fillFlights = []
        completedFillIDs = []
    }

    /// Pseudo-scatter across the upper screen (golden-angle spread) so memories
    /// converge into the jar from many directions.
    private func fillStart(index: Int) -> CGPoint {
        let golden = 0.618_033
        let fractionX = (Double(index + 1) * golden).truncatingRemainder(dividingBy: 1)
        let fractionY = (Double(index + 1) * golden * 1.7).truncatingRemainder(dividingBy: 1)
        return CGPoint(
            x: jarSize.width * (0.08 + 0.84 * fractionX),
            y: jarSize.height * (0.04 + 0.5 * fractionY)
        )
    }

    private func tokenContent(for win: Entry) -> MemoryTokenContent {
        win.imageData.first.map(MemoryTokenContent.image) ?? .title(win.title)
    }
}

#Preview {
    JarView()
        .modelContainer(EmberwickModelContainer.preview())
}
