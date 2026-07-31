//
//  IconExporter.swift
//  Emberwick
//
//  Dev-only: renders the brand mark (`EmberIcon`) to a 1024pt PNG so the app icon
//  stays in sync with the in-app logo — no separate art file to maintain. Run the
//  app with `-exportIcon`, then copy the printed file into Assets/AppIcon.
//

#if DEBUG
import SwiftUI
import UIKit

enum IconExporter {
    @MainActor
    static func exportIfRequested() {
        guard CommandLine.arguments.contains("-exportIcon") else { return }
        let renderer = ImageRenderer(content: EmberIcon(size: 1024))
        renderer.scale = 1
        guard let image = renderer.uiImage, let data = image.pngData() else {
            print("EMBERWICK_ICON_FAILED")
            return
        }
        let url = URL.documentsDirectory.appending(path: "AppIcon-1024.png")
        try? data.write(to: url)
        print("EMBERWICK_ICON_WRITTEN: \(url.path)")
    }
}
#endif
