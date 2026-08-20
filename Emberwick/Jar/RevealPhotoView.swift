//
//  RevealPhotoView.swift
//  Emberwick
//
//  The photo side of reliving a memory in the Jar: a hero image (or a paged carousel
//  for several) shown right in the reveal, and a full-screen, swipeable viewer when
//  you tap it. Photos are the strongest relive trigger, so they lead the moment.
//

import SwiftUI

/// The revealed memory's photo(s), shown as the hero of the reveal card with the
/// tier glow. Tap to open full screen.
struct RevealPhotoHero: View {
    let imageData: [Data]
    let tierColor: Color
    let onTap: () -> Void

    @State private var index = 0
    private let height: Double = 210

    var body: some View {
        Group {
            if imageData.count <= 1 {
                imageView(imageData.first)
            } else {
                TabView(selection: $index) {
                    ForEach(imageData.indices, id: \.self) { i in
                        imageView(imageData[i]).tag(i)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .clipShape(.rect(cornerRadius: EmberRadius.large))
        .shadow(color: tierColor.opacity(0.55), radius: 18)
        .contentShape(.rect)
        .onTapGesture(perform: onTap)
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel(imageData.count > 1 ? "\(imageData.count) photos. Double-tap to view full screen." : "Photo. Double-tap to view full screen.")
    }

    @ViewBuilder
    private func imageView(_ data: Data?) -> some View {
        if let data, let image = UIImage(data: data) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        } else {
            EmberPalette.paper2
        }
    }
}

/// Full-screen, swipeable viewer for a memory's photos.
struct PhotoViewer: View {
    let imageData: [Data]
    var onClose: () -> Void

    @State private var index = 0

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.ignoresSafeArea()

            TabView(selection: $index) {
                ForEach(imageData.indices, id: \.self) { i in
                    Group {
                        if let image = UIImage(data: imageData[i]) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                        }
                    }
                    .accessibilityLabel(imageData.count > 1 ? "Photo \(i + 1) of \(imageData.count)" : "Photo")
                    .tag(i)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: imageData.count > 1 ? .always : .never))
            .ignoresSafeArea()
            .contentShape(.rect)
            .onTapGesture(perform: onClose) // tap anywhere to dismiss

            Button(action: onClose) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 30))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.white)
                    .padding(EmberSpacing.md)
            }
            .accessibilityLabel("Close")
        }
    }
}
