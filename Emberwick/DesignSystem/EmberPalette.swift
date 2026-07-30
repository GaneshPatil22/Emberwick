//
//  EmberPalette.swift
//  Emberwick
//
//  The single source of truth for color. Never use literal colors in views —
//  reference these tokens. Each is appearance-adaptive: a warm light theme and a
//  warm dark theme. The four tiers ARE the palette (kept constant across modes);
//  chrome stays warm-neutral, and glow is the signature.
//

import SwiftUI

enum EmberPalette {
    // Surfaces
    static let paper = Color(lightHex: 0xFDF6EE, darkHex: 0x201619)   // app background
    static let paper2 = Color(lightHex: 0xFBEFE3, darkHex: 0x2B2024)  // raised warm surface

    // Text
    static let ink = Color(lightHex: 0x34262C, darkHex: 0xF3EAE6)      // primary text
    static let inkSoft = Color(lightHex: 0x7B6A6F, darkHex: 0xB6A6AB)  // secondary text
    static let inkFaint = Color(lightHex: 0xA99AA0, darkHex: 0x8A7A80) // hints

    // Accent (this week + primary actions) — raspberry-coral
    static let accent = Color(hex: 0xF0567A)
    static let accentInk = Color(lightHex: 0xB62E51, darkHex: 0xFF9DB2) // text on accent tints

    // Tiers — same hue in both modes, brightened in dark so wins pop against the
    // warm-dark grid instead of going muddy.
    static let bronze = Color(lightHex: 0xC0763A, darkHex: 0xD98E52)
    static let silver = Color(lightHex: 0x98A0AD, darkHex: 0xC2C9D4)
    static let gold = Color(lightHex: 0xF2A72C, darkHex: 0xFFC24D)
    static let diamond = Color(lightHex: 0x31BFD6, darkHex: 0x5AD5EB)

    /// Warm glow for an untiered (unrated) win — distinct from any tier color.
    static let memoryNeutral = Color(lightHex: 0xE9B27A, darkHex: 0xF2C08D)

    // Life-grid cell states — explicit per mode so past / future weeks read warmly
    // (deriving from ink made them cool + washed in dark).
    static let cellLived = Color(lightHex: 0xF1EAE2, darkHex: 0x392C32)        // lived, no memory
    static let cellBeforeBirth = Color(lightHex: 0xF8F1EA, darkHex: 0x281E22)  // "before you" (row 0)
    static let cellAhead = Color(lightHex: 0xE1D7CF, darkHex: 0x4A3A40)        // future week outline

    // Hairlines / separators (derived from ink → adapt automatically)
    static let line = ink.opacity(0.10)
    static let line2 = ink.opacity(0.16)

    /// Raised card surface (entry cards) — sits above `paper`.
    static let card = Color(lightHex: 0xFFFFFF, darkHex: 0x2E2328)
}
