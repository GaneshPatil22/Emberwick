//
//  GridCellState.swift
//  Emberwick
//
//  The visual state of a single week cell, derived (never stored) from entries and
//  today's date. This is domain data; the color mapping lives in the design layer
//  (GridCellStyle).
//

import Foundation

enum GridCellState: Equatable, Sendable {
    /// Weeks in row 0 that fall before the user was born — a quiet "before you" state.
    case beforeBirth
    /// A future, unlived week — outline only.
    case ahead
    /// The current week — accent.
    case thisWeek
    /// A lived week with no memory captured — neutral fill.
    case livedEmpty
    /// A lived week holding at least one win. Associated value is the highest tier
    /// present, or `nil` for an untiered (unrated) win.
    case memory(Tier?)
}
