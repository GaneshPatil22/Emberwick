//
//  JarView.swift
//  Emberwick
//
//  The Jar mode: a glass jar of glowing wins. Shake (device or button) surfaces a
//  weighted-random long-unseen win; "Add a win" drops a new one in. The Jar points
//  at wins (a lens) — it never contains or deletes them.
//

import SwiftData
import SwiftUI

struct JarView: View {
    @Query private var entries: [Entry]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var revealedWin: Entry?
    @State private var showAddWin = false
    @State private var showSettings = false
    @State private var shakeDetector = ShakeDetector()

    private var wins: [Entry] { entries.filter { $0.kind == .win } }

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
        .overlay {
            if let win = revealedWin {
                RevealView(win: win) { revealedWin = nil }
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
        }
        .onDisappear {
            shakeDetector.stop()
        }
    }

    private func performShake() {
        guard revealedWin == nil, !wins.isEmpty else { return }
        var generator = SystemRandomNumberGenerator()
        guard let win = JarSelector.pick(from: wins, now: .now, using: &generator) else { return }
        win.lastSeenAt = .now
        try? modelContext.save()
        revealedWin = win
    }
}

#Preview {
    JarView()
        .modelContainer(EmberwickModelContainer.preview())
}
