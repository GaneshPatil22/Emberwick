//
//  HomeConstants.swift
//  Emberwick
//
//  Tunable thresholds for the adaptive home + hidden win count (see Doc 02 §8).
//

import Foundation

enum HomeConstants {
    /// Adaptive home opens to the Jar below this many wins, then to the grid.
    static let jarToGridThreshold = 20

    /// The grid's win count stays hidden (warm subtitle instead) until this many wins.
    static let hideWinCountThreshold = 50
}
