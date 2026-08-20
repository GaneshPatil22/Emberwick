//
//  JarIllustration.swift
//  Emberwick
//
//  A simple glass jar holding glowing orbs (one per recent win, tinted by tier).
//  Orbs bob gently unless Reduce Motion is on.
//

import SwiftUI

struct JarIllustration: View {
    let orbColors: [Color]
    let animate: Bool

    @State private var bob = false

    // Fixed scatter of (offset, diameter) inside the jar body.
    private let slots: [(offset: CGSize, size: Double)] = [
        (CGSize(width: -26, height: 34), 20),
        (CGSize(width: 18, height: 44), 24),
        (CGSize(width: 34, height: 20), 17),
        (CGSize(width: -4, height: 12), 15),
        (CGSize(width: 8, height: 26), 14),
        (CGSize(width: -20, height: 8), 13)
    ]

    var body: some View {
        ZStack {
            Circle()
                .fill(RadialGradient(
                    colors: [EmberPalette.gold.opacity(0.38), .clear],
                    center: .center, startRadius: 4, endRadius: 140
                ))
                .frame(width: 270, height: 270)
                .blur(radius: 6)

            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(LinearGradient(
                    colors: [.white.opacity(0.32), .white.opacity(0.08)],
                    startPoint: .top, endPoint: .bottom
                ))
                .frame(width: 150, height: 176)
                .overlay(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .stroke(Color(hex: 0xC9B49E), lineWidth: 3)
                )
                .overlay(alignment: .top) {
                    Capsule() // soft glass sheen just below the rim
                        .fill(.white.opacity(0.4))
                        .frame(width: 92, height: 10)
                        .blur(radius: 6)
                        .offset(y: 20)
                }
                .overlay(alignment: .top) {
                    Capsule()
                        .fill(Color(hex: 0xC9B49E))
                        .frame(width: 76, height: 14)
                        .offset(y: -7)
                }
                .shadow(color: EmberPalette.ink.opacity(0.06), radius: 12, y: 6)

            ForEach(orbColors.indices.prefix(slots.count), id: \.self) { index in
                Circle()
                    .fill(orbColors[index])
                    .frame(width: slots[index].size, height: slots[index].size)
                    .shadow(color: orbColors[index].opacity(0.7), radius: 5)
                    .offset(slots[index].offset)
                    .offset(y: (animate && bob) ? -4 : 0)
                    .animation(
                        animate
                            ? .easeInOut(duration: 2.6).repeatForever(autoreverses: true).delay(Double(index) * 0.2)
                            : nil,
                        value: bob
                    )
            }
        }
        .frame(width: 220, height: 220)
        .onAppear { bob = true }
    }
}
