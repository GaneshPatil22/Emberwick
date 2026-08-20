//
//  RevealView.swift
//  Emberwick
//
//  The staged reveal after a shake:
//    1. a brief glow beat while the memory sits at the bottom of the jar,
//    2. it rises up and out of the jar's mouth (small),
//    3. travels to center,
//    4. then grows and the card's text fades in — revealed.
//  "Put it back" plays the same stages in reverse, sending it back down into the jar.
//  Honors Reduce Motion (snaps straight to revealed / dismissed).
//

import SwiftUI

struct RevealView: View {
    let win: Entry
    let jarSize: CGSize
    let onPutBack: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @AccessibilityFocusState private var revealFocused: Bool

    private enum Stage { case bottom, mouth, center, revealed }
    @State private var stage: Stage = .bottom
    @State private var isClosing = false
    @State private var showPhotos = false
    @State private var shareImage: Image?

    private var hasPhotos: Bool { !win.imageData.isEmpty }

    private var tierColor: Color {
        guard !win.isDetached else { return EmberPalette.memoryNeutral }
        return win.tier?.color ?? EmberPalette.memoryNeutral
    }

    private var glowRadius: Double {
        switch win.tier {
        case .diamond: 46
        case .gold: 36
        case .silver: 28
        case .bronze: 22
        case nil: 20
        }
    }

    private var metaText: String {
        let ago = win.date.formatted(.relative(presentation: .named))
        if let tier = win.tier { return "\(ago) · \(tier.displayName)" }
        return ago
    }

    var body: some View {
        // If the memory has left its context (e.g. deleted by a wipe/reset while the
        // reveal is up), reading any of its attributes would fault — close cleanly.
        if win.isDetached {
            Color.clear.onAppear(perform: onPutBack)
        } else {
            revealContent
        }
    }

    private var revealContent: some View {
        ZStack {
            Color.black.opacity(dimOpacity)
                .ignoresSafeArea()
                .onTapGesture(perform: putBack)

            card
                .scaleEffect(cardScale)
                .position(cardPoint)

            if stage == .revealed && !reduceMotion {
                ConfettiBurst(tier: win.tier, origin: burstOrigin)
            }
        }
        .accessibilityAddTraits(.isModal) // trap VoiceOver in the reveal
        .task { await animateIn() }
        .sensoryFeedback(trigger: stage) { _, newStage in
            // A soft tick as it rises through the mouth and settles at center,
            // then the tier-scaled haptic on the full reveal.
            switch newStage {
            case .mouth, .center: return .impact(weight: .light, intensity: 0.4)
            case .revealed: return hapticFeedback
            default: return nil
            }
        }
        .onChange(of: stage) { _, newStage in
            if newStage == .revealed {
                SoundPlayer.play(.reveal(win.tier))
                revealFocused = true // move VoiceOver to the revealed memory
                renderShareCard()
            }
        }
        .fullScreenCover(isPresented: $showPhotos) {
            PhotoViewer(imageData: win.imageData) { showPhotos = false }
        }
    }

    /// Renders the shareable memory card once, when revealed.
    private func renderShareCard() {
        guard !win.isDetached else { return }
        let renderer = ImageRenderer(content: MemoryShareCard(win: win))
        renderer.scale = 3
        if let image = renderer.uiImage { shareImage = Image(uiImage: image) }
    }

    /// The spoken form of the revealed memory.
    private var accessibilityLabel: String {
        var parts = ["A memory from your jar.", win.title + ".", metaText + "."]
        if let notes = win.notes, !notes.isEmpty { parts.append(notes) }
        return parts.joined(separator: " ")
    }

    // MARK: - Card

    private var card: some View {
        VStack(spacing: EmberSpacing.md) {
            if stage == .revealed, hasPhotos {
                RevealPhotoHero(imageData: win.imageData, tierColor: tierColor) { showPhotos = true }
                    .transition(.opacity)
            } else {
                orb
                    .accessibilityHidden(true)
            }
            VStack(spacing: EmberSpacing.md) {
                VStack(spacing: EmberSpacing.md) {
                    Text(metaText)
                        .font(EmberTypography.caption)
                        .foregroundStyle(EmberPalette.inkFaint)
                    Text(win.title)
                        .font(EmberTypography.heading)
                        .foregroundStyle(EmberPalette.ink)
                        .multilineTextAlignment(.center)
                    if let notes = win.notes, !notes.isEmpty {
                        Text(notes)
                            .font(EmberTypography.body)
                            .foregroundStyle(EmberPalette.inkSoft)
                            .multilineTextAlignment(.center)
                    }
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel(accessibilityLabel)
                .accessibilityFocused($revealFocused)

                HStack(spacing: EmberSpacing.xl) {
                    if let shareImage {
                        ShareLink(
                            item: shareImage,
                            preview: SharePreview(win.title, image: shareImage)
                        ) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                        .font(EmberTypography.body)
                        .foregroundStyle(EmberPalette.accentInk)
                    }
                    Button("Put it back", action: putBack)
                        .font(EmberTypography.body)
                        .foregroundStyle(EmberPalette.accentInk)
                }
                .padding(.top, EmberSpacing.sm)
            }
            .opacity(stage == .revealed ? 1 : 0) // text appears only once grown
            .accessibilityHidden(stage != .revealed)
        }
        .padding(EmberSpacing.xl)
        .frame(maxWidth: .infinity)
        .background(EmberPalette.paper.opacity(stage == .bottom ? 0 : 1), in: .rect(cornerRadius: EmberRadius.xLarge))
        .padding(EmberSpacing.xl)
    }

    private var orb: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [.white.opacity(0.95), tierColor],
                    center: .init(x: 0.35, y: 0.3),
                    startRadius: 2,
                    endRadius: 42
                )
            )
            .frame(width: 80, height: 80)
            .shadow(color: tierColor.opacity(0.85), radius: glowRadius)
    }

    // MARK: - Stage geometry

    private var cardPoint: CGPoint {
        let x = jarSize.width / 2
        switch stage {
        case .bottom: return CGPoint(x: x, y: jarSize.height * 0.50) // deep in the jar
        case .mouth: return CGPoint(x: x, y: jarSize.height * 0.30)  // up through the mouth
        case .center, .revealed: return CGPoint(x: x, y: jarSize.height * 0.42)
        }
    }

    /// The revealed orb sits above the card's center; the confetti pops from there.
    private var burstOrigin: CGPoint {
        CGPoint(x: jarSize.width / 2, y: jarSize.height * 0.34)
    }

    private var cardScale: Double {
        switch stage {
        case .bottom: 0.26
        case .mouth: 0.42
        case .center: 0.6
        case .revealed: 1.0
        }
    }

    private var dimOpacity: Double {
        switch stage {
        case .bottom: 0
        case .mouth: 0.12
        case .center: 0.26
        case .revealed: 0.35
        }
    }

    // MARK: - Animation

    // Sequenced with Task.sleep instead of nested withAnimation-completion handlers
    // (the latter crashes the async renderer). Cancellation-safe via `.task`.
    private func animateIn() async {
        guard !reduceMotion else {
            stage = .revealed
            return
        }
        try? await Task.sleep(for: .seconds(0.35)) // glow beat at the bottom
        if Task.isCancelled { return }
        withAnimation(.easeOut(duration: 0.55)) { stage = .mouth }   // rise out the mouth
        try? await Task.sleep(for: .seconds(0.55))
        if Task.isCancelled { return }
        withAnimation(.easeInOut(duration: 0.4)) { stage = .center } // travel to center
        try? await Task.sleep(for: .seconds(0.4))
        if Task.isCancelled { return }
        withAnimation(EmberMotion.reveal) { stage = .revealed }      // grow + reveal
    }

    private func putBack() {
        // Ignore taps during the rise — only a fully-revealed card can be put back.
        // Prevents animateIn/animateOut fighting over `stage` (jitter + stray confetti).
        guard stage == .revealed, !isClosing else { return }
        isClosing = true
        Task { await animateOut() }
    }

    private func animateOut() async {
        guard !reduceMotion else {
            onPutBack()
            return
        }
        withAnimation(.easeInOut(duration: 0.4)) { stage = .center } // shrink back to the orb
        try? await Task.sleep(for: .seconds(0.4))
        withAnimation(.easeInOut(duration: 0.4)) { stage = .mouth }  // back up to the mouth
        try? await Task.sleep(for: .seconds(0.4))
        withAnimation(.easeIn(duration: 0.5)) { stage = .bottom }    // down into the jar
        try? await Task.sleep(for: .seconds(0.5))
        onPutBack()
    }

    private var hapticFeedback: SensoryFeedback {
        switch win.tier {
        case .diamond: .success
        case .gold: .impact(weight: .heavy)
        case .silver: .impact(weight: .medium)
        case .bronze: .impact(weight: .light)
        case nil: .impact(weight: .light)
        }
    }
}
