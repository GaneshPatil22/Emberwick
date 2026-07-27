//
//  EraChip.swift
//  Emberwick
//
//  The soft chip shown at the top of a week page when the week falls inside an era.
//

import SwiftUI

struct EraChip: View {
    let name: String
    let tintHex: String

    var body: some View {
        HStack(spacing: EmberSpacing.xs) {
            Circle()
                .fill(Color(hexString: tintHex))
                .frame(width: 8, height: 8)
            Text(name)
                .font(EmberTypography.caption)
                .foregroundStyle(EmberPalette.inkSoft)
        }
        .padding(.horizontal, EmberSpacing.md)
        .padding(.vertical, EmberSpacing.xs)
        .background(Color(hexString: tintHex).opacity(0.35), in: .capsule)
    }
}
