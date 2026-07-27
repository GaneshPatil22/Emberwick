//
//  GridPosition.swift
//  Emberwick
//
//  A cell coordinate in the life grid. `row` is the 0-based offset from the user's
//  birth year; `column` is the week-box index (0...52) within that year.
//

import Foundation

struct GridPosition: Equatable, Hashable, Sendable {
    let row: Int
    let column: Int
}
