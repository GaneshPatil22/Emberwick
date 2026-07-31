//
//  BirthdayGate.swift
//  Emberwick
//
//  The one required screen: the app can't open without a birthday, because every
//  week cell is derived from it — and we never invent a default for someone. Shown
//  full-screen and non-dismissable until a birthday is actively chosen (Continue
//  stays disabled until the user changes the field, so today's placeholder is never
//  saved as-is). Presented by RootView after the (optional) intro.
//
//  Confirming also drops a diamond (top-tier) "story begins" win on the birth week,
//  so the map lights up with its very first glow at the start of your life.
//

import SwiftData
import SwiftUI

struct BirthdayGate: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @AppStorage(AppConfig.birthDateKey) private var birthInterval = 0.0
    @AppStorage(AppConfig.birthDayKnownKey) private var storedDayKnown = true

    // Starts at "today" (an impossible birthday) with Continue disabled, so the user
    // must actively pick — we never assume a default.
    @State private var draftDate = Date.now
    @State private var dayKnown = true
    @State private var picked = false

    var body: some View {
        ZStack {
            EmberPalette.paper.ignoresSafeArea()

            VStack(spacing: EmberSpacing.xl) {
                Spacer(minLength: 0)

                EmberLogo(size: 96)

                VStack(spacing: EmberSpacing.sm) {
                    Text("When did your story begin?")
                        .font(EmberTypography.title)
                        .foregroundStyle(EmberPalette.ink)
                        .multilineTextAlignment(.center)
                    Text("Your birthday anchors the whole grid — it's how each square becomes the right week of the right year. Prefer not to share the exact day? Just give the month and year.")
                        .font(EmberTypography.subtitle)
                        .foregroundStyle(EmberPalette.inkSoft)
                        .multilineTextAlignment(.center)
                }

                BirthdayField(date: $draftDate, dayKnown: $dayKnown)
                    .onChange(of: draftDate) { picked = true }
                    .onChange(of: dayKnown) { picked = true }

                Spacer(minLength: 0)

                Button(action: confirm) {
                    Text(picked ? "Continue" : "Pick your birthday")
                        .font(EmberTypography.body)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, EmberSpacing.md)
                        .foregroundStyle(.white)
                        .background(EmberPalette.accent, in: .rect(cornerRadius: EmberRadius.medium))
                }
                .disabled(!picked)
                .opacity(picked ? 1 : 0.5)
            }
            .padding(EmberSpacing.xl)
        }
        .interactiveDismissDisabled(true) // cannot be swiped/tapped away
    }

    private func confirm() {
        guard picked else { return }
        storedDayKnown = dayKnown
        birthInterval = draftDate.timeIntervalSinceReferenceDate
        BirthdayWin.sync(to: draftDate, in: modelContext)
        SoundPlayer.play(.birthday)
        dismiss()
    }
}
