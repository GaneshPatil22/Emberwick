//
//  HomeMode.swift
//  Emberwick
//
//  Which mode the app opens to. Stored in @AppStorage. `adaptive` opens to the Jar
//  while the grid is sparse, then to the grid once enough wins exist.
//

import Foundation

enum HomeMode: String, CaseIterable {
    case adaptive
    case jar
    case grid

    var label: String {
        switch self {
        case .adaptive: "Adaptive"
        case .jar: "Jar"
        case .grid: "Grid"
        }
    }
}
