//
//  EraRow.swift
//  Emberwick
//
//  One era in the eras list: tint swatch, name, and its span.
//

import SwiftUI

struct EraRow: View {
    let era: Era

    var body: some View {
        HStack(spacing: EmberSpacing.md) {
            Circle()
                .fill(Color(hexString: era.tintHex))
                .frame(width: 18, height: 18)
            VStack(alignment: .leading, spacing: 2) {
                Text(era.name)
                    .font(EmberTypography.entryTitle)
                    .foregroundStyle(EmberPalette.ink)
                Text(spanText)
                    .font(EmberTypography.caption)
                    .foregroundStyle(EmberPalette.inkSoft)
            }
        }
    }

    private var spanText: String {
        let start = era.startDate.formatted(.dateTime.month(.abbreviated).year())
        let end = era.endDate.formatted(.dateTime.month(.abbreviated).year())
        return "\(start) – \(end)"
    }
}
