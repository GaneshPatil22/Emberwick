//
//  TierSelector.swift
//  Emberwick
//
//  One-tap, optional tier picker for a win. Tapping the selected tier again clears
//  it (rating is never forced).
//

import SwiftUI

struct TierSelector: View {
    @Binding var tier: Tier?

    var body: some View {
        HStack(spacing: EmberSpacing.md) {
            ForEach(Tier.allCases, id: \.self) { option in
                Button {
                    tier = (tier == option) ? nil : option
                } label: {
                    Circle()
                        .fill(option.color)
                        .frame(width: 30, height: 30)
                        .overlay {
                            Circle()
                                .strokeBorder(EmberPalette.ink, lineWidth: tier == option ? 3 : 0)
                        }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(option.displayName)
                .accessibilityAddTraits(tier == option ? [.isSelected] : [])
            }
        }
    }
}
