//
//  MapRoute.swift
//  Emberwick
//
//  Navigation destinations pushed on the map's NavigationStack: a year, then a week.
//  Also used as the zoom-transition source ids.
//

import Foundation

enum MapRoute: Hashable {
    case year(Int)              // row index (= age)
    case week(GridPosition)
}
