//
//  GridHeaderView.swift
//  Emberwick
//
//  The warm header above the life grid. The win count is intentionally hidden until
//  a threshold (Phase 6) — a sparse early grid shouldn't demotivate — so we show a
//  warm line instead.
//

import SwiftUI

struct GridHeaderView: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: EmberSpacing.xs) {
            Text(title)
                .font(EmberTypography.title)
                .foregroundStyle(EmberPalette.ink)
            Text(subtitle)
                .font(EmberTypography.subtitle)
                .foregroundStyle(EmberPalette.inkSoft)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    GridHeaderView(title: "Your life", subtitle: "Every glowing week is a moment worth keeping.")
        .padding()
        .background(EmberPalette.paper)
}
