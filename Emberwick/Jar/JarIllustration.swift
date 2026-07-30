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
                    colors: [EmberPalette.gold.opacity(0.28), .clear],
                    center: .center, startRadius: 4, endRadius: 130
                ))
                .frame(width: 260, height: 260)
                .blur(radius: 6)

            RoundedRectangle(cornerRadius: 28)
                .fill(.white.opacity(0.45))
                .frame(width: 150, height: 176)
                .overlay(RoundedRectangle(cornerRadius: 28).stroke(Color(hex: 0xC9B49E), lineWidth: 3))
                .overlay(alignment: .top) {
                    Capsule()
                        .fill(Color(hex: 0xC9B49E))
                        .frame(width: 76, height: 14)
                        .offset(y: -7)
                }

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
