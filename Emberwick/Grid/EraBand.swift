//
//  EraBand.swift
//  Emberwick
//
//  An era resolved to a start and end WEEK cell — drawn as a soft tint band behind
//  the grid (a text-selection-style range: partial start/end rows, full rows between).
//  An era is a SPAN; a win is a POINT (glowing cell).
//

import Foundation

struct EraBand: Identifiable {
    let id = UUID()
    let name: String
    /// Soft, low-saturation `"RRGGBB"` tint.
    let tintHex: String
    let start: GridPosition
    let end: GridPosition
}
