//
//  Tier+Palette.swift
//  Emberwick
//
//  Maps the pure `Tier` domain enum to its palette color. Lives in the design
//  layer so the model stays free of SwiftUI.
//

import SwiftUI

extension Tier {
    var color: Color {
        switch self {
        case .bronze: EmberPalette.bronze
        case .silver: EmberPalette.silver
        case .gold: EmberPalette.gold
        case .diamond: EmberPalette.diamond
        }
    }
}
