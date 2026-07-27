//
//  Tier.swift
//  Emberwick
//
//  The optional, one-tap quality rating on a win. Drives both the grid glow and
//  the reveal effect. Order is meaningful (bronze → silver → gold → diamond);
//  diamond is deliberately rare. Kept free of SwiftUI — the color mapping lives
//  in the design layer (Tier+Palette).
//

import Foundation

enum Tier: String, Codable, CaseIterable, Sendable {
    case bronze
    case silver
    case gold
    case diamond

    /// User-facing name, e.g. "Gold".
    var displayName: String {
        rawValue.capitalized
    }
}

extension Tier: Comparable {
    /// Ordering follows declaration order: bronze < silver < gold < diamond.
    /// Centralized here so "highest tier in a week" comparisons stay consistent.
    static func < (lhs: Tier, rhs: Tier) -> Bool {
        lhs.rank < rhs.rank
    }

    private var rank: Int {
        Self.allCases.firstIndex(of: self) ?? 0
    }
}
