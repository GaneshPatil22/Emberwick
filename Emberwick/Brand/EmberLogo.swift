//
//  EmberLogo.swift
//  Emberwick
//
//  The Emberwick brand mark: a glass jar of glowing wins. A scalable SwiftUI vector
//  (no image assets), so it themes with light/dark and is the single source for the
//  splash, the onboarding welcome, and the app icon.
//
//  Two knobs drive the splash: `glow` (overall aliveness) and `litOrbs` (how many
//  wins have landed). Animate them at the call site with `withAnimation` and the
//  orbs light up smoothly.
//

import SwiftUI

struct EmberLogo: View {
    /// Overall glow / aliveness, 0…1. The splash animates this from dim to full.
    var glow: Double = 1
    /// How many orbs are lit (0…`orbCount`). The splash raises this as tokens land.
    var litOrbs: Int = orbCount
    /// Rendered edge length in points.
    var size: Double = 120

    static let orbCount = 6

    /// Authoring canvas; all geometry below is expressed in this box, then scaled.
    private let base: Double = 120
    private let glassLine = Color(hex: 0xC9B49E)

    /// Orb slots inside the jar: position (in the 120-box), diameter, tier tint.
    /// Tuned so the cluster's centroid sits at the jar-body center (≈60, 66) — the
    /// orbs fill the jar evenly instead of pooling at the bottom.
    private var orbs: [(pos: CGPoint, d: Double, color: Color)] {
        [
            (CGPoint(x: 51, y: 52), 16, EmberPalette.gold),
            (CGPoint(x: 70, y: 55), 17, EmberPalette.accent),
            (CGPoint(x: 60, y: 66), 18, EmberPalette.diamond),
            (CGPoint(x: 49, y: 70), 14, EmberPalette.silver),
            (CGPoint(x: 72, y: 72), 14, EmberPalette.bronze),
            (CGPoint(x: 60, y: 81), 13, EmberPalette.memoryNeutral)
        ]
    }

    var body: some View {
        ZStack {
            // Warm halo behind the jar. Positioned (not intrinsically sized) so it
            // doesn't stretch the ZStack's coordinate space wider than the 120-box —
            // otherwise every `.position(x: 60, …)` below lands left of true center.
            Circle()
                .fill(RadialGradient(
                    colors: [EmberPalette.gold.opacity(0.42 * glow), .clear],
                    center: .center, startRadius: 2, endRadius: 78
                ))
                .frame(width: 150, height: 150)
                .blur(radius: 6)
                .position(x: 60, y: 64)

            // Glass body.
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(LinearGradient(
                    colors: [.white.opacity(0.20), .white.opacity(0.06)],
                    startPoint: .top, endPoint: .bottom
                ))
                .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(glassLine, lineWidth: 3))
                .frame(width: 58, height: 64)
                .position(x: 60, y: 66)

            // Rim / lid.
            Capsule()
                .fill(glassLine)
                .frame(width: 44, height: 11)
                .position(x: 60, y: 33)

            // Glowing wins.
            ForEach(orbs.indices, id: \.self) { index in
                let orb = orbs[index]
                let lit = index < litOrbs
                Circle()
                    .fill(RadialGradient(
                        colors: [.white.opacity(0.92), orb.color],
                        center: .init(x: 0.35, y: 0.3), startRadius: 1, endRadius: orb.d
                    ))
                    .frame(width: orb.d, height: orb.d)
                    .shadow(color: orb.color.opacity(lit ? 0.8 * glow : 0), radius: lit ? 6 * glow : 0)
                    .opacity(lit ? 1 : 0.16) // unlit orbs wait as faint ghosts
                    .position(orb.pos)
            }
        }
        .frame(width: base, height: base)
        .scaleEffect(size / base)
        .frame(width: size, height: size)
        .accessibilityLabel("Emberwick")
    }
}

/// The brand mark on a warm full-bleed tile — used only to render the app icon
/// (the OS applies the rounded-corner mask).
struct EmberIcon: View {
    var size: Double = 1024

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: 0xFFF3E6), Color(hex: 0xF6D6BF)],
                startPoint: .top, endPoint: .bottom
            )
            EmberLogo(glow: 1, litOrbs: EmberLogo.orbCount, size: size * 0.72)
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    VStack(spacing: 40) {
        EmberLogo(size: 160)
        EmberLogo(glow: 0.4, litOrbs: 2, size: 120)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(EmberPalette.paper)
}
