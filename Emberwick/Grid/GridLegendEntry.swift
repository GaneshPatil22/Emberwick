//
//  GridLegendEntry.swift
//  Emberwick
//
//  One row of the grid legend. Order is fixed by the caller.
//

import SwiftUI

struct GridLegendEntry: Identifiable {
    let id: String
    let color: Color
    let isOutline: Bool

    init(_ label: String, color: Color, isOutline: Bool = false) {
        id = label
        self.color = color
        self.isOutline = isOutline
    }

    var label: String { id }
}
