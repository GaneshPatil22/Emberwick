//
//  EmberRadius.swift
//  Emberwick
//
//  Corner-radius tokens. The spec favors generous corners (14–24pt) on surfaces;
//  the grid cell radius lives with the grid constants since it is a grid concern.
//

import Foundation

enum EmberRadius {
    static let small: Double = 9    // year-view week cells
    static let medium: Double = 14  // buttons
    static let large: Double = 16   // entry cards
    static let xLarge: Double = 24  // sheets / reveal card
}
