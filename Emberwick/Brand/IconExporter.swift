//
//  IconExporter.swift
//  Emberwick
//
//  Dev-only: renders the brand mark to 1024pt PNGs so the app icon stays in sync
//  with the in-app logo — no separate art file to maintain. Run the app with
//  `-exportIcon`; it writes a light and a dark variant and prints their paths.
//

#if DEBUG
import SwiftUI
import UIKit

enum IconExporter {
    @MainActor
    static func exportIfRequested() {
        guard CommandLine.arguments.contains("-exportIcon") else { return }
        write(EmberIcon(size: 1024), to: "AppIcon-1024.png")
        write(darkIcon(size: 1024), to: "AppIcon-1024-dark.png")
        // Social/brand cards: the mark + wordmark + tagline (not for the App Store icon).
        write(brandCard(size: 1080, dark: true), to: "Emberwick-BrandCard-Dark-1080.png")
        write(brandCard(size: 1080, dark: false), to: "Emberwick-BrandCard-Light-1080.png")
    }

    /// The mark on a warm, deep tile for a dark-mode / social icon.
    private static func darkIcon(size: Double) -> some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: 0x2A1E22), Color(hex: 0x3C2A31)],
                startPoint: .top, endPoint: .bottom
            )
            EmberLogo(glow: 1, litOrbs: EmberLogo.orbCount, size: size * 0.72)
        }
        .frame(width: size, height: size)
        .environment(\.colorScheme, .dark)
    }

    /// A square social card: glowing jar + "Emberwick" wordmark + tagline.
    private static func brandCard(size: Double, dark: Bool) -> some View {
        let s = size / 1080
        let background: [Color] = dark
            ? [Color(hex: 0x2A1E22), Color(hex: 0x3C2A31)]
            : [Color(hex: 0xFFF3E6), Color(hex: 0xF6D6BF)]
        return ZStack {
            LinearGradient(colors: background, startPoint: .top, endPoint: .bottom)
            VStack(spacing: 44 * s) {
                EmberLogo(glow: 1, litOrbs: EmberLogo.orbCount, size: 460 * s)
                VStack(spacing: 20 * s) {
                    Text("Emberwick")
                        .font(.system(size: 104 * s, weight: .heavy, design: .rounded))
                        .foregroundStyle(EmberPalette.ink)
                    Text("A warm, private map of your life —\none good week at a time.")
                        .font(.system(size: 36 * s, weight: .regular, design: .rounded))
                        .foregroundStyle(EmberPalette.inkSoft)
                        .multilineTextAlignment(.center)
                        .lineSpacing(5 * s)
                }
            }
            .padding(.horizontal, 80 * s)
        }
        .frame(width: size, height: size)
        .environment(\.colorScheme, dark ? .dark : .light)
    }

    @MainActor
    private static func write(_ content: some View, to filename: String) {
        let renderer = ImageRenderer(content: content)
        renderer.scale = 1
        guard let image = renderer.uiImage, let data = image.pngData() else {
            print("EMBERWICK_ICON_FAILED: \(filename)")
            return
        }
        let url = URL.documentsDirectory.appending(path: filename)
        try? data.write(to: url)
        print("EMBERWICK_ICON_WRITTEN: \(url.path)")
    }
}
#endif
