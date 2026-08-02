//
//  TourOverlay.swift
//  Emberwick
//
//  The spotlight itself: dims the screen except for a rounded cutout around the
//  current target, draws a warm ring, and floats a caption card in the opposite half
//  so it never covers the highlight. Tap anywhere (or Next) to advance; Skip ends it.
//

import SwiftUI

struct TourOverlay: View {
    let rect: CGRect
    let step: TourStep
    let index: Int
    let total: Int
    let onNext: () -> Void
    let onSkip: () -> Void

    private let inset: CGFloat = 10
    private let radius: CGFloat = 16

    @AccessibilityFocusState private var captionFocused: Bool

    var body: some View {
        GeometryReader { geo in
            let hole = rect.insetBy(dx: -inset, dy: -inset)
            let holeInTopHalf = hole.midY < geo.size.height / 2

            ZStack {
                Rectangle()
                    .fill(.black.opacity(0.72))
                    .reverseMask {
                        RoundedRectangle(cornerRadius: radius)
                            .frame(width: hole.width, height: hole.height)
                            .position(x: hole.midX, y: hole.midY)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture(perform: onNext)
                    .accessibilityHidden(true)

                RoundedRectangle(cornerRadius: radius)
                    .strokeBorder(EmberPalette.accent, lineWidth: 2)
                    .frame(width: hole.width, height: hole.height)
                    .position(x: hole.midX, y: hole.midY)
                    .shadow(color: EmberPalette.accent.opacity(0.6), radius: 10)
                    .allowsHitTesting(false)

                VStack(spacing: 0) {
                    if holeInTopHalf { Spacer(minLength: 0) }
                    caption
                    if !holeInTopHalf { Spacer(minLength: 0) }
                }
                .padding(.horizontal, EmberSpacing.xl)
                .padding(.vertical, 44)
            }
        }
        .ignoresSafeArea()
        .accessibilityAddTraits(.isModal)
        .onAppear { captionFocused = true }
        .onChange(of: step.target) { captionFocused = true }
    }

    private var caption: some View {
        VStack(alignment: .leading, spacing: EmberSpacing.sm) {
            Text("Step \(index + 1) of \(total)")
                .font(EmberTypography.caption)
                .foregroundStyle(EmberPalette.inkFaint)
                .accessibilityFocused($captionFocused)
            Text(step.title)
                .font(EmberTypography.heading)
                .foregroundStyle(EmberPalette.ink)
            Text(step.message)
                .font(EmberTypography.subtitle)
                .foregroundStyle(EmberPalette.inkSoft)
                .fixedSize(horizontal: false, vertical: true)

            HStack {
                Button("Skip", action: onSkip)
                    .font(EmberTypography.body)
                    .foregroundStyle(EmberPalette.inkSoft)
                Spacer()
                Button(action: onNext) {
                    Text(index + 1 == total ? "Done" : "Next")
                        .font(EmberTypography.body)
                        .foregroundStyle(.white)
                        .padding(.horizontal, EmberSpacing.lg)
                        .padding(.vertical, EmberSpacing.sm)
                        .background(EmberPalette.accent, in: .capsule)
                }
            }
            .padding(.top, EmberSpacing.xs)
        }
        .padding(EmberSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(EmberPalette.card, in: .rect(cornerRadius: EmberRadius.xLarge))
        .shadow(color: .black.opacity(0.22), radius: 16, y: 6)
    }
}
