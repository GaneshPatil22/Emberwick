//
//  OnboardingView.swift
//  Emberwick
//
//  First-run milestone backfill: drop a handful of wins so the map feels alive on
//  day one and the mechanic is taught without a tutorial. Shown only on an empty
//  store (see RootView). Milestones are added to the current week; dates can be
//  refined later.
//

import SwiftData
import SwiftUI

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var added: Set<String> = []

    private let milestones = [
        "Graduated",
        "Moved somewhere new",
        "Started a job",
        "Met someone special",
        "A trip to remember",
        "Something I made"
    ]

    private let columns = [
        GridItem(.flexible(), spacing: EmberSpacing.md),
        GridItem(.flexible(), spacing: EmberSpacing.md)
    ]

    var body: some View {
        VStack(spacing: EmberSpacing.lg) {
            Spacer(minLength: 0)

            VStack(spacing: EmberSpacing.sm) {
                Text("Welcome to Emberwick")
                    .font(EmberTypography.title)
                    .foregroundStyle(EmberPalette.ink)
                    .multilineTextAlignment(.center)
                Text("Drop a few milestones so your map starts with some light. You can add more anytime.")
                    .font(EmberTypography.subtitle)
                    .foregroundStyle(EmberPalette.inkSoft)
                    .multilineTextAlignment(.center)
            }

            LazyVGrid(columns: columns, spacing: EmberSpacing.md) {
                ForEach(milestones, id: \.self) { milestone in
                    milestoneChip(milestone)
                }
            }

            Spacer(minLength: 0)

            Button(action: finish) {
                Text(added.isEmpty ? "Skip for now" : "Start")
                    .font(EmberTypography.body)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, EmberSpacing.md)
                    .foregroundStyle(.white)
                    .background(EmberPalette.accent, in: .rect(cornerRadius: EmberRadius.medium))
            }
        }
        .padding(EmberSpacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(EmberPalette.paper)
    }

    private func milestoneChip(_ milestone: String) -> some View {
        let isAdded = added.contains(milestone)
        return Button {
            addMilestone(milestone)
        } label: {
            HStack(spacing: EmberSpacing.xs) {
                Image(systemName: isAdded ? "checkmark.circle.fill" : "plus.circle")
                Text(milestone)
                    .multilineTextAlignment(.leading)
            }
            .font(EmberTypography.body)
            .foregroundStyle(isAdded ? EmberPalette.accentInk : EmberPalette.ink)
            .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
            .padding(.horizontal, EmberSpacing.md)
            .background(isAdded ? EmberPalette.accent.opacity(0.12) : EmberPalette.card, in: .rect(cornerRadius: EmberRadius.large))
        }
        .buttonStyle(.plain)
        .disabled(isAdded)
    }

    private func addMilestone(_ title: String) {
        guard !added.contains(title) else { return }
        modelContext.insert(Entry(date: .now, kind: .win, title: title))
        try? modelContext.save()
        added.insert(title)
    }

    private func finish() {
        dismiss()
    }
}
