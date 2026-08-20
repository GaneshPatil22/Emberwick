//
//  DemoPhotos.swift
//  Emberwick
//
//  DEBUG-only: loads the presenter's own demo photos (image sets named
//  DemoPhoto1, DemoPhoto2, … in Assets) to attach to the highlight wins used in the
//  presentation. Falls back to a generated gradient if none have been added yet, so
//  the demo never shows an empty reveal.
//

#if DEBUG
import UIKit

enum DemoPhotos {
    /// All images for a highlight, e.g. base "DemoWedding" → DemoWedding_1, _2, …
    /// (in order) so the reveal shows a carousel. Falls back to a bare "DemoWedding"
    /// asset, then a generated gradient, so a win always has at least one photo.
    static func datas(baseNamed base: String) -> [Data] {
        var result: [Data] = []
        var index = 1
        while index <= 20, let image = UIImage(named: "\(base)_\(index)") {
            if let data = image.jpegData(compressionQuality: 0.85) { result.append(data) }
            index += 1
        }
        return result.isEmpty ? [data(named: base)] : result
    }

    /// A single named asset (e.g. "DemoWedding") as JPEG data, or a gradient
    /// placeholder if it hasn't been added yet.
    static func data(named name: String) -> Data {
        if let image = UIImage(named: name), let data = image.jpegData(compressionQuality: 0.85) {
            return data
        }
        return placeholder()
    }

    private static func placeholder() -> Data {
        let size = CGSize(width: 800, height: 560)
        let image = UIGraphicsImageRenderer(size: size).image { ctx in
            let colors = [
                UIColor(red: 0.96, green: 0.72, blue: 0.52, alpha: 1).cgColor,
                UIColor(red: 0.90, green: 0.34, blue: 0.48, alpha: 1).cgColor
            ] as CFArray
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 1])!
            ctx.cgContext.drawLinearGradient(
                gradient,
                start: .zero,
                end: CGPoint(x: size.width, y: size.height),
                options: []
            )
        }
        return image.jpegData(compressionQuality: 0.85) ?? Data()
    }
}
#endif
