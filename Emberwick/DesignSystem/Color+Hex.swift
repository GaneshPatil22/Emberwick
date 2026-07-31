//
//  Color+Hex.swift
//  Emberwick
//
//  Convenience initializer so palette tokens can be declared from the hex
//  values in the design spec without repeating channel-splitting math.
//

import SwiftUI

extension Color {
    /// Creates a color from a packed `0xRRGGBB` value in the sRGB space.
    /// - Parameters:
    ///   - hex: Packed red/green/blue channels, e.g. `0xF0567A`.
    ///   - opacity: Alpha, `0...1`.
    init(hex: UInt, opacity: Double = 1) {
        let red = Double((hex >> 16) & 0xFF) / 255
        let green = Double((hex >> 8) & 0xFF) / 255
        let blue = Double(hex & 0xFF) / 255
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }

    /// Creates a color from an `"RRGGBB"` hex string (used for stored era tints).
    init(hexString: String, opacity: Double = 1) {
        let value = UInt(hexString, radix: 16) ?? 0
        self.init(hex: value, opacity: opacity)
    }

    /// Adaptive color from packed `0xRRGGBB` values for light and dark.
    ///
    /// SwiftUI resolves colors on its ASYNC render thread during animations. The
    /// dynamic provider must therefore be `nonisolated` and build the `UIColor` from
    /// raw components — never bridge a SwiftUI `Color` and never let the closure be
    /// inferred `@MainActor` (the module defaults to MainActor isolation), or it trips
    /// a concurrency assertion off-main (EXC_BREAKPOINT).
    init(lightHex: UInt, darkHex: UInt) {
        #if canImport(UIKit)
        self = Color(emberDynamicColor(lightHex: lightHex, darkHex: darkHex))
        #else
        self = Color(hex: lightHex)
        #endif
    }
}

#if canImport(UIKit)
import UIKit

private extension UIColor {
    /// From a packed `0xRRGGBB` value using components only — no SwiftUI bridging.
    convenience init(rgbHex hex: UInt) {
        let red = CGFloat((hex >> 16) & 0xFF) / 255
        let green = CGFloat((hex >> 8) & 0xFF) / 255
        let blue = CGFloat(hex & 0xFF) / 255
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
}

/// `nonisolated` so the dynamic provider closure is NOT tied to the main actor.
private nonisolated func emberDynamicColor(lightHex: UInt, darkHex: UInt) -> UIColor {
    UIColor { traits in
        UIColor(rgbHex: traits.userInterfaceStyle == .dark ? darkHex : lightHex)
    }
}
#endif
