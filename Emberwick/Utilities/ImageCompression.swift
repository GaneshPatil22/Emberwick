//
//  ImageCompression.swift
//  Emberwick
//
//  Downscales + JPEG-compresses picked images before they're persisted. Images are
//  the heavy part of any future sync, so we shrink them at the edge (on import).
//

import SwiftUI

enum ImageCompression {
    static func compressed(_ data: Data, maxDimension: CGFloat = 1200, quality: CGFloat = 0.7) -> Data {
        guard let image = UIImage(data: data) else { return data }

        let longestSide = max(image.size.width, image.size.height)
        let scale = longestSide > maxDimension ? maxDimension / longestSide : 1
        let target = CGSize(width: image.size.width * scale, height: image.size.height * scale)

        let renderer = UIGraphicsImageRenderer(size: target)
        let resized = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: target))
        }
        return resized.jpegData(compressionQuality: quality) ?? data
    }
}
