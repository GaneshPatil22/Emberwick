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

    /// An appearance-adaptive color that resolves to `light` or `dark` per the
    /// current interface style.
    init(light: Color, dark: Color) {
        #if canImport(UIKit)
        self = Color(UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
        #else
        self = light
        #endif
    }

    /// Adaptive color from packed `0xRRGGBB` values for light and dark.
    init(lightHex: UInt, darkHex: UInt) {
        self.init(light: Color(hex: lightHex), dark: Color(hex: darkHex))
    }
}
