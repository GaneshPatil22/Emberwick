//
//  MemoryTokenView.swift
//  Emberwick
//
//  Renders one flying token: a photo thumbnail, a title on a paper card, or a soft
//  blurred-handwriting fallback. Carries a tier-colored glow.
//

import SwiftUI

struct MemoryTokenView: View {
    let content: MemoryTokenContent
    let tier: Tier?

    private let size = CGSize(width: 62, height: 56)

    var body: some View {
        inner
            .frame(width: size.width, height: size.height)
            .clipShape(.rect(cornerRadius: EmberRadius.small))
            .shadow(color: (tier?.color ?? EmberPalette.memoryNeutral).opacity(0.6), radius: 8)
    }

    @ViewBuilder private var inner: some View {
        switch content {
        case .image(let data):
            if let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                paper { EmptyView() }
            }
        case .title(let text):
            paper {
                Text(text)
                    .font(EmberTypography.legend)
                    .foregroundStyle(EmberPalette.ink)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .padding(EmberSpacing.xs)
            }
        case .fallback:
            paper { EmptyView() }   // a blank paper note
        }
    }

    private func paper<Inner: View>(@ViewBuilder _ inner: () -> Inner) -> some View {
        ZStack {
            EmberPalette.paper2
            inner()
        }
    }
}
