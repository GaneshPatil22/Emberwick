//
//  EmberPalette.swift
//  Emberwick
//
//  The single source of truth for color. Never use literal colors in views —
//  reference these tokens so the warm, glow-forward look stays consistent.
//  The four tiers ARE the palette; chrome stays warm-neutral.
//

import SwiftUI

enum EmberPalette {
    // Surfaces
    static let paper = Color(hex: 0xFDF6EE)   // app background
    static let paper2 = Color(hex: 0xFBEFE3)  // raised warm surface

    // Text
    static let ink = Color(hex: 0x34262C)      // primary text
    static let inkSoft = Color(hex: 0x7B6A6F)  // secondary text
    static let inkFaint = Color(hex: 0xA99AA0) // hints

    // Accent (this week + primary actions) — raspberry-coral
    static let accent = Color(hex: 0xF0567A)
    static let accentInk = Color(hex: 0xB62E51) // text on accent tints

    // Tiers — locked. diamond is deliberately rare.
    static let bronze = Color(hex: 0xC0763A)
    static let silver = Color(hex: 0x98A0AD)
    static let gold = Color(hex: 0xF2A72C)
    static let diamond = Color(hex: 0x31BFD6)

    /// Warm glow for an untiered (unrated) win — distinct from any tier color.
    static let memoryNeutral = Color(hex: 0xE9B27A)

    // Neutral cell fills for the life grid
    static let cellLived = ink.opacity(0.06)   // lived week, no memory
    static let cellBeforeBirth = ink.opacity(0.03)  // "before you" weeks in row 0

    // Hairlines / separators
    static let line = ink.opacity(0.10)
    static let line2 = ink.opacity(0.16)

    /// Raised card surface (entry cards) — sits above `paper`.
    static let card = Color(hex: 0xFFFFFF)
}
