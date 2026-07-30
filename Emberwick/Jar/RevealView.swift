//
//  RevealView.swift
//  Emberwick
//
//  The reveal after a shake: a tier-glowing card with the win's context ("2 years
//  ago"), title, and notes, plus "Put it back" (which never deletes). Haptic and
//  glow scale with the tier. Honors Reduce Motion.
//

import SwiftUI

struct RevealView: View {
    let win: Entry
    let onPutBack: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared = false

    private var tierColor: Color { win.tier?.color ?? EmberPalette.memoryNeutral }

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
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture(perform: onPutBack)

            VStack(spacing: EmberSpacing.md) {
                orb
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
                Button("Put it back", action: onPutBack)
                    .font(EmberTypography.body)
                    .foregroundStyle(EmberPalette.accentInk)
                    .padding(.top, EmberSpacing.sm)
            }
            .padding(EmberSpacing.xl)
            .frame(maxWidth: .infinity)
            .background(EmberPalette.paper, in: .rect(cornerRadius: EmberRadius.xLarge))
            .padding(EmberSpacing.xl)
            .scaleEffect(appeared || reduceMotion ? 1 : 0.8)
            .opacity(appeared || reduceMotion ? 1 : 0)
        }
        .onAppear {
            if reduceMotion {
                appeared = true
            } else {
                withAnimation(EmberMotion.reveal) { appeared = true }
            }
        }
        .sensoryFeedback(hapticFeedback, trigger: appeared)
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
            .shadow(color: tierColor.opacity(0.8), radius: glowRadius)
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
