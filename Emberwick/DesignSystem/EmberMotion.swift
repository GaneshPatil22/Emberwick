//
//  EmberMotion.swift
//  Emberwick
//
//  Shared animation tokens. Introduced now that motion is real, so timings/springs
//  live in one place instead of being sprinkled through views.
//

import SwiftUI

enum EmberMotion {
    /// A lively spring for reveals (a little overshoot).
    static let reveal = Animation.spring(response: 0.45, dampingFraction: 0.7)

    /// A calmer spring for settling / reflow.
    static let settle = Animation.spring(response: 0.4, dampingFraction: 0.85)
}
