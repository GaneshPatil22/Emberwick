//
//  MemoryFlight.swift
//  Emberwick
//
//  A fully-resolved flight (plan + geometry) ready to hand to MemoryFlightView.
//

import Foundation

struct MemoryFlight: Identifiable {
    let id = UUID()
    let content: MemoryTokenContent
    let tier: Tier?
    let start: CGPoint
    let end: CGPoint
    let delay: Double
}
