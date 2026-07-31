//
//  ResurfacingCard.swift
//  Emberwick
//
//  A warm, dismissible surface on the home: "You did this a year ago" + a past win.
//  Tapping opens its week. No notification, no guilt — a gentle nudge from your own
//  life.
//

import SwiftUI

struct ResurfacingCard: View {
    let win: Entry
    let onOpen: () -> Void
    let onDismiss: () -> Void

    private var tierColor: Color { win.tier?.color ?? EmberPalette.memoryNeutral }

    private var agoText: String {
        let years = Calendar.current.dateComponents([.year], from: win.date, to: .now).year ?? 1
        return years <= 1 ? "a year ago" : "\(years) years ago"
    }

    var body: some View {
        HStack(spacing: EmberSpacing.md) {
            Circle()
                .fill(tierColor)
                .frame(width: 12, height: 12)
                .shadow(color: tierColor.opacity(0.7), radius: 5)

            VStack(alignment: .leading, spacing: 2) {
                Text("You did this \(agoText)")
                    .font(EmberTypography.caption)
                    .foregroundStyle(EmberPalette.inkFaint)
                Text(win.title)
                    .font(EmberTypography.entryTitle)
                    .foregroundStyle(EmberPalette.ink)
                    .lineLimit(1)
            }

            Spacer(minLength: EmberSpacing.sm)

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(EmberPalette.inkFaint)
                    .frame(width: 28, height: 28)
            }
            .accessibilityLabel("Dismiss")
        }
        .padding(.horizontal, EmberSpacing.lg)
        .padding(.vertical, EmberSpacing.md)
        .background(EmberPalette.card, in: .rect(cornerRadius: EmberRadius.large))
        .shadow(color: EmberPalette.ink.opacity(0.06), radius: 8, y: 3)
        .contentShape(.rect)
        .onTapGesture(perform: onOpen)
        .accessibilityHint("Opens this memory's week")
    }
}
