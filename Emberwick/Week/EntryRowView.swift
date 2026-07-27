//
//  EntryRowView.swift
//  Emberwick
//
//  One entry as a soft card: a tier pill (rated wins) or a quiet kind label, the
//  title, optional notes, and photo thumbnails.
//

import SwiftUI

struct EntryRowView: View {
    let entry: Entry

    var body: some View {
        VStack(alignment: .leading, spacing: EmberSpacing.sm) {
            header
            Text(entry.title)
                .font(EmberTypography.entryTitle)
                .foregroundStyle(EmberPalette.ink)
            if let notes = entry.notes, !notes.isEmpty {
                Text(notes)
                    .font(EmberTypography.body)
                    .foregroundStyle(EmberPalette.inkSoft)
            }
            if !entry.imageData.isEmpty {
                EntryImageStrip(imageData: entry.imageData)
            }
        }
        .padding(EmberSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(EmberPalette.card, in: .rect(cornerRadius: EmberRadius.large))
        .shadow(color: EmberPalette.ink.opacity(0.06), radius: 10, y: 4)
    }

    @ViewBuilder private var header: some View {
        if entry.kind == .win, let tier = entry.tier {
            TierPill(tier: tier)
        } else {
            EntryKindLabel(kind: entry.kind)
        }
    }
}
