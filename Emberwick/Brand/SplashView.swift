//
//  SplashView.swift
//  Emberwick
//
//  The launch moment (~3.5s): the jar starts dim and empty, memory tokens fly in
//  from the edges and light its orbs one by one, the whole mark blooms into a warm
//  glow, then the wordmark settles in before handing off to the app.
//
//  Reuses the app's `MemoryFlightView` flight primitive so the motion matches the
//  intro / Jar reveal. Honors Reduce Motion (shows the lit mark, then continues).
//

import SwiftUI

struct SplashView: View {
    var onFinish: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var tokens: [SplashToken] = []
    @State private var litOrbs = 0
    @State private var glow = 0.4
    @State private var showWordmark = false
    @State private var didStart = false

    private let flightDuration: Double = 0.95
    private let stagger: Double = 0.16
    private let logoSize: Double = 170

    private let orbColors: [Color] = [
        EmberPalette.gold, EmberPalette.accent, EmberPalette.diamond,
        EmberPalette.silver, EmberPalette.bronze, EmberPalette.memoryNeutral
    ]

    var body: some View {
        GeometryReader { geo in
            let jarCenter = CGPoint(x: geo.size.width / 2, y: geo.size.height * 0.42)
            ZStack {
                EmberPalette.paper.ignoresSafeArea()

                EmberLogo(glow: glow, litOrbs: litOrbs, size: logoSize)
                    .position(jarCenter)

                wordmark
                    .opacity(showWordmark ? 1 : 0)
                    .offset(y: showWordmark ? 0 : 8)
                    .position(x: geo.size.width / 2, y: jarCenter.y + logoSize / 2 + 44)

                // Memory tokens streaming into the jar.
                ForEach(tokens) { token in
                    MemoryFlightView(
                        start: token.start,
                        end: jarCenter,
                        delay: token.delay,
                        duration: flightDuration,
                        onComplete: { orbLanded() }
                    ) {
                        SplashDot(color: token.color)
                    }
                }
            }
            .onAppear { start(in: geo.size, center: jarCenter) }
        }
    }

    private var wordmark: some View {
        VStack(spacing: EmberSpacing.xs) {
            Text("Emberwick")
                .font(EmberTypography.title)
                .foregroundStyle(EmberPalette.ink)
            Text("A warm, private map of your life.")
                .font(EmberTypography.subtitle)
                .foregroundStyle(EmberPalette.inkSoft)
        }
        .multilineTextAlignment(.center)
    }

    // MARK: - Sequence

    private func start(in size: CGSize, center: CGPoint) {
        guard !didStart else { return }
        didStart = true

        guard !reduceMotion else {
            litOrbs = EmberLogo.orbCount
            glow = 1
            showWordmark = true
            SoundPlayer.play(.launch)
            Task { try? await Task.sleep(for: .seconds(1.6)); onFinish() }
            return
        }

        tokens = makeTokens(in: size, center: center)
        Task { await runFinale() }
    }

    /// Called as each token tucks into the jar — lights one more orb.
    private func orbLanded() {
        guard litOrbs < EmberLogo.orbCount else { return }
        withAnimation(EmberMotion.reveal) {
            litOrbs += 1
            glow = min(1, 0.4 + Double(litOrbs) / Double(EmberLogo.orbCount) * 0.6)
        }
    }

    private func runFinale() async {
        // Wait for the last token to have landed.
        let lastArrival = 0.25 + stagger * Double(orbColors.count - 1) + flightDuration
        try? await Task.sleep(for: .seconds(lastArrival + 0.15))
        withAnimation(.easeOut(duration: 0.6)) { glow = 1 }        // final bloom
        SoundPlayer.play(.launch)
        try? await Task.sleep(for: .seconds(0.35))
        withAnimation(.easeOut(duration: 0.5)) { showWordmark = true }
        try? await Task.sleep(for: .seconds(1.1))
        onFinish()
    }

    private func makeTokens(in size: CGSize, center: CGPoint) -> [SplashToken] {
        let radius = max(size.width, size.height) * 0.6
        return orbColors.enumerated().map { index, color in
            // Spread launch points around the screen so tokens arrive from all sides.
            let angle = Double(index) / Double(orbColors.count) * 2 * .pi - .pi / 2
            let start = CGPoint(
                x: center.x + cos(angle) * radius,
                y: center.y + sin(angle) * radius * 0.8
            )
            return SplashToken(start: start, color: color, delay: 0.25 + stagger * Double(index))
        }
    }
}

private struct SplashToken: Identifiable {
    let id = UUID()
    let start: CGPoint
    let color: Color
    let delay: Double
}

/// A small glowing bead — the in-flight form of a memory before it settles in the jar.
private struct SplashDot: View {
    let color: Color

    var body: some View {
        Circle()
            .fill(RadialGradient(
                colors: [.white.opacity(0.95), color],
                center: .init(x: 0.35, y: 0.3), startRadius: 1, endRadius: 14
            ))
            .frame(width: 26, height: 26)
            .shadow(color: color.opacity(0.7), radius: 7)
    }
}

#Preview {
    SplashView(onFinish: {})
}
