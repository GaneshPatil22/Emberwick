//
//  MemoryShareCard.swift
//  Emberwick
//
//  The shareable rendering of a revealed memory — photo (or tier orb) + title + when +
//  the Emberwick mark, on the warm paper background. Rendered to an image via
//  ImageRenderer and shared from the Jar reveal. On-brand, and private-by-choice:
//  nothing leaves the device unless the user taps Share.
//

import SwiftUI

struct MemoryShareCard: View {
    let win: Entry

    private var tierColor: Color {
        guard !win.isDetached else { return EmberPalette.memoryNeutral }
        return win.tier?.color ?? EmberPalette.memoryNeutral
    }

    private var metaText: String {
        let ago = win.date.formatted(.relative(presentation: .named))
        if let tier = win.tier { return "\(ago) · \(tier.displayName)" }
        return ago
    }

    var body: some View {
        VStack(spacing: EmberSpacing.lg) {
            hero

            VStack(spacing: EmberSpacing.sm) {
                Text(win.title)
                    .font(EmberTypography.title)
                    .foregroundStyle(EmberPalette.ink)
                    .multilineTextAlignment(.center)
                Text(metaText)
                    .font(EmberTypography.caption)
                    .foregroundStyle(EmberPalette.inkFaint)
                if let notes = win.notes, !notes.isEmpty {
                    Text(notes)
                        .font(EmberTypography.subtitle)
                        .foregroundStyle(EmberPalette.inkSoft)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                }
            }

            Spacer(minLength: 0)

            HStack(spacing: EmberSpacing.xs) {
                EmberLogo(size: 26)
                Text("Emberwick")
                    .font(EmberTypography.caption)
                    .foregroundStyle(EmberPalette.inkSoft)
            }
        }
        .padding(EmberSpacing.xl)
        .frame(width: 340, height: 470)
        .background(EmberPalette.paper)
        .environment(\.colorScheme, .light) // consistent warm card regardless of app theme
    }

    @ViewBuilder
    private var hero: some View {
        if let data = win.imageData.first, let image = UIImage(data: data) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: 230)
                .clipShape(.rect(cornerRadius: EmberRadius.large))
                .shadow(color: tierColor.opacity(0.5), radius: 16)
        } else {
            Circle()
                .fill(RadialGradient(
                    colors: [.white.opacity(0.95), tierColor],
                    center: .init(x: 0.35, y: 0.3), startRadius: 2, endRadius: 60
                ))
                .frame(width: 120, height: 120)
                .shadow(color: tierColor.opacity(0.85), radius: 30)
                .padding(.top, EmberSpacing.xl)
        }
    }
}
