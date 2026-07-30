//
//  GridCellStyle.swift
//  Emberwick
//
//  Maps a (domain) GridCellState to its palette colors. Lives in the design layer
//  so the grid's domain types stay free of SwiftUI.
//

import SwiftUI

extension GridCellState {
    /// The cell's fill. `.ahead` is drawn as an outline instead (see `strokeColor`).
    var fillColor: Color {
        switch self {
        case .beforeBirth: EmberPalette.cellBeforeBirth
        case .ahead: .clear
        case .thisWeek: EmberPalette.accent
        case .livedEmpty: EmberPalette.cellLived
        case .memory(let tier): tier?.color ?? EmberPalette.memoryNeutral
        }
    }

    /// A glow color for cells that emit light (this week + memories), else `nil`.
    var glowColor: Color? {
        switch self {
        case .thisWeek: EmberPalette.accent
        case .memory(let tier): tier?.color ?? EmberPalette.memoryNeutral
        default: nil
        }
    }

    /// Outline color for unlived cells, else `nil`.
    var strokeColor: Color? {
        switch self {
        case .ahead: EmberPalette.cellAhead
        default: nil
        }
    }
}
