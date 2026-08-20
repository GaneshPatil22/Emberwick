//
//  OnboardingFlow.swift
//  Emberwick
//
//  First-run story: Welcome (the mark) → your life in weeks → a private jar of wins
//  → add your first win. A skippable paged flow with a shared footer (dots + button).
//  Birthday is NOT here — it's a separate required gate (see BirthdayGate / RootView).
//  Finishing or skipping marks onboarding done.
//

import SwiftData
import SwiftUI

struct OnboardingFlow: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.modelContext) private var modelContext

    @AppStorage("didOnboard") private var didOnboard = false

    @State private var page = 0
    @State private var winTitle = ""
    @State private var winDate = Date.now
    /// The first captured win is a milestone — default it to the top tier.
    @State private var winTier: Tier? = .diamond

    private let lastPage = 3

    private var hasWin: Bool {
        !winTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        TabView(selection: $page) {
            welcomePage.tag(0)
            lifePage.tag(1)
            jarPage.tag(2)
            ScrollView {
                FirstWinStep(title: $winTitle, date: $winDate, tier: $winTier)
                    .padding(.horizontal, EmberSpacing.xl)
                    .padding(.top, EmberSpacing.xl)
            }
            .tag(3)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .animation(EmberMotion.settle, value: page)
        .background(EmberPalette.paper.ignoresSafeArea())
        .safeAreaBar(edge: .bottom) { footer }
    }

    // MARK: - Pages

    private var welcomePage: some View {
        valueProp(
            title: "Welcome to Emberwick",
            subtitle: "A warm, private map of your life — one good week at a time."
        ) {
            EmberLogo(size: 168)
        }
    }

    private var lifePage: some View {
        valueProp(
            title: "Your life, in weeks",
            subtitle: "Each little square is one week. Fill them with wins and watch the years light up."
        ) {
            MiniLifeGrid()
        }
    }

    private var jarPage: some View {
        valueProp(
            title: "A jar of your wins",
            subtitle: "Shake to relive a good moment you might have forgotten. Everything stays on your device — always private."
        ) {
            JarIllustration(
                orbColors: [EmberPalette.gold, EmberPalette.accent, EmberPalette.diamond,
                            EmberPalette.silver, EmberPalette.bronze, EmberPalette.memoryNeutral],
                animate: !reduceMotion
            )
        }
    }

    private func valueProp<Illustration: View>(
        title: String,
        subtitle: String,
        @ViewBuilder illustration: () -> Illustration
    ) -> some View {
        VStack(spacing: EmberSpacing.xl) {
            Spacer(minLength: 0)
            illustration()
                .frame(maxHeight: 220) // can shrink at large Dynamic Type so text never clips
            VStack(spacing: EmberSpacing.sm) {
                Text(title)
                    .font(EmberTypography.title)
                    .foregroundStyle(EmberPalette.ink)
                Text(subtitle)
                    .font(EmberTypography.subtitle)
                    .foregroundStyle(EmberPalette.inkSoft)
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, EmberSpacing.xl)
            Spacer(minLength: 0)
        }
    }

    // MARK: - Footer

    private var footer: some View {
        VStack(spacing: EmberSpacing.md) {
            PageDots(count: lastPage + 1, index: page)

            Button(action: advance) {
                Text(page == lastPage ? (hasWin ? "Add & start" : "Skip for now") : "Continue")
                    .font(EmberTypography.body)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, EmberSpacing.xs)
            }
            .buttonStyle(.glassProminent)
            .controlSize(.large)
            .tint(EmberPalette.accent)

            Button("Skip") { finish(saveWin: false) }
                .font(EmberTypography.caption)
                .foregroundStyle(EmberPalette.inkSoft)
                .opacity(page == lastPage ? 0 : 1)
                .disabled(page == lastPage)
        }
        .padding(.horizontal, EmberSpacing.xl)
        .padding(.bottom, EmberSpacing.xs)
    }

    private func advance() {
        if page < lastPage {
            withAnimation(EmberMotion.settle) { page += 1 }
        } else {
            finish(saveWin: true)
        }
    }

    /// Marks onboarding complete (so it never reappears) and leaves — the required
    /// birthday gate takes over next (see RootView).
    private func finish(saveWin: Bool) {
        if saveWin { saveFirstWinIfNeeded() }
        didOnboard = true
        dismiss()
    }

    /// Persists the entered win at its chosen date (only if a title was given).
    private func saveFirstWinIfNeeded() {
        let trimmed = winTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        modelContext.insert(Entry(date: winDate, kind: .win, title: trimmed, tier: winTier))
        try? modelContext.save()
        SoundPlayer.play(.winSaved)
    }
}

/// A row of dots for the pager; the active one stretches into an accent pill.
private struct PageDots: View {
    let count: Int
    let index: Int

    var body: some View {
        HStack(spacing: EmberSpacing.xs) {
            ForEach(0..<count, id: \.self) { dot in
                Capsule()
                    .fill(dot == index ? EmberPalette.accent : EmberPalette.line2)
                    .frame(width: dot == index ? 20 : 7, height: 7)
            }
        }
        .animation(EmberMotion.settle, value: index)
    }
}

/// A compact "life in weeks" glyph: a grid of faint cells with a handful glowing.
private struct MiniLifeGrid: View {
    private let columns = 7
    private let rows = 7
    private let lit: [Int: Color] = [
        3: EmberPalette.gold, 9: EmberPalette.accent, 16: EmberPalette.diamond,
        22: EmberPalette.silver, 27: EmberPalette.bronze, 33: EmberPalette.gold,
        40: EmberPalette.accent
    ]

    var body: some View {
        VStack(spacing: 6) {
            ForEach(0..<rows, id: \.self) { row in
                HStack(spacing: 6) {
                    ForEach(0..<columns, id: \.self) { col in
                        let index = row * columns + col
                        let tint = lit[index]
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(tint ?? EmberPalette.cellLived)
                            .frame(width: 20, height: 20)
                            .shadow(color: (tint ?? .clear).opacity(0.7), radius: tint == nil ? 0 : 5)
                    }
                }
            }
        }
    }
}

#Preview {
    OnboardingFlow()
        .modelContainer(EmberwickModelContainer.preview())
}
