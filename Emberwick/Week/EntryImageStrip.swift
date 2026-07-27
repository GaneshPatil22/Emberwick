//
//  EntryImageStrip.swift
//  Emberwick
//
//  A horizontal strip of an entry's photo thumbnails.
//

import SwiftUI

struct EntryImageStrip: View {
    let imageData: [Data]

    private let side: Double = 88

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: EmberSpacing.sm) {
                ForEach(imageData.indices, id: \.self) { index in
                    if let image = UIImage(data: imageData[index]) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: side, height: side)
                            .clipShape(.rect(cornerRadius: EmberRadius.medium))
                    }
                }
            }
        }
        .scrollIndicators(.hidden)
    }
}
