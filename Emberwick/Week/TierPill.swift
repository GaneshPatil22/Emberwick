//
//  TierPill.swift
//  Emberwick
//
//  A small tinted pill showing a win's tier, e.g. "Gold win".
//

import SwiftUI

struct TierPill: View {
    let tier: Tier

    var body: some View {
        Text("\(tier.displayName) win")
            .font(EmberTypography.caption)
            .foregroundStyle(tier.color)
            .padding(.horizontal, EmberSpacing.sm)
            .padding(.vertical, EmberSpacing.xs / 2)
            .background(tier.color.opacity(0.16), in: .capsule)
    }
}
