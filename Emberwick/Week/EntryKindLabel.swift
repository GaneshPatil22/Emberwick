//
//  EntryKindLabel.swift
//  Emberwick
//
//  The quiet kind indicator on an entry row (used for notes and hard weeks; wins
//  show a TierPill instead when rated).
//

import SwiftUI

struct EntryKindLabel: View {
    let kind: EntryKind

    var body: some View {
        Label(kind.displayName, systemImage: kind.systemImage)
            .font(EmberTypography.caption)
            .foregroundStyle(EmberPalette.inkFaint)
    }
}
