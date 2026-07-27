//
//  FlightPlan.swift
//  Emberwick
//
//  A geometry-free plan for one intro flight: which week it lands on, what it shows,
//  its tier glow, and when it launches. The view resolves the target point.
//

import Foundation

struct FlightPlan: Identifiable {
    let id = UUID()
    let position: GridPosition
    let content: MemoryTokenContent
    let tier: Tier?
    let delay: Double
}
