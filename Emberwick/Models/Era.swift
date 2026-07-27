//
//  Era.swift
//  Emberwick
//
//  An era is a SPAN (a soft, low-saturation tint band behind the grid), as opposed
//  to a win which is a POINT. v1 is create-only: name, start, end, tint. No
//  drag-resize, overlap rules, or nesting.
//

import Foundation
import SwiftData

@Model
final class Era {
    var id: UUID
    var name: String
    var startDate: Date
    var endDate: Date
    /// Soft, low-saturation `0xRRGGBB` tint so wins always pop above the band.
    var tintHex: String

    init(
        id: UUID = UUID(),
        name: String,
        startDate: Date,
        endDate: Date,
        tintHex: String
    ) {
        self.id = id
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.tintHex = tintHex
    }
}
