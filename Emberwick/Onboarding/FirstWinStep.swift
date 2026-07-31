//
//  FirstWinStep.swift
//  Emberwick
//
//  The final onboarding step: capture one real win — a title, a rough date, and an
//  optional tier — so the map starts with a true, correctly-placed moment and the
//  add-flow is taught with real data (no fabricated same-week entries). The
//  surrounding flow owns the values and saves them on "Start".
//

import SwiftUI

struct FirstWinStep: View {
    @Binding var title: String
    @Binding var date: Date
    @Binding var tier: Tier?

    var body: some View {
        VStack(spacing: EmberSpacing.xl) {
            VStack(spacing: EmberSpacing.sm) {
                Text("Add your first win")
                    .font(EmberTypography.title)
                    .foregroundStyle(EmberPalette.ink)
                Text("One good moment to light up your map. You can add as many as you like later — this one's optional too.")
                    .font(EmberTypography.subtitle)
                    .foregroundStyle(EmberPalette.inkSoft)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: EmberSpacing.md) {
                TextField("What happened?", text: $title, axis: .vertical)
                    .font(EmberTypography.body)
                    .foregroundStyle(EmberPalette.ink)
                    .lineLimit(1...3)
                    .padding(EmberSpacing.md)
                    .background(EmberPalette.card, in: .rect(cornerRadius: EmberRadius.large))

                HStack {
                    Text("When")
                        .font(EmberTypography.body)
                        .foregroundStyle(EmberPalette.inkSoft)
                    Spacer()
                    DatePicker("", selection: $date, in: ...Date.now, displayedComponents: .date)
                        .labelsHidden()
                        .tint(EmberPalette.accentInk)
                }
                .padding(EmberSpacing.md)
                .background(EmberPalette.card, in: .rect(cornerRadius: EmberRadius.large))

                VStack(alignment: .leading, spacing: EmberSpacing.sm) {
                    Text("How big? (optional)")
                        .font(EmberTypography.caption)
                        .foregroundStyle(EmberPalette.inkFaint)
                    TierSelector(tier: $tier)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(EmberSpacing.md)
                .background(EmberPalette.card, in: .rect(cornerRadius: EmberRadius.large))
            }
        }
        .padding(.horizontal, EmberSpacing.xs)
    }
}
