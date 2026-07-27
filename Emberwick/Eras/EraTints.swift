//
//  EraTints.swift
//  Emberwick
//
//  A small palette of soft, low-saturation tints for eras — chosen so bands stay
//  quiet enough that tier-colored wins always pop above them.
//

import Foundation

enum EraTints {
    /// `"RRGGBB"` hex values, in picker order.
    static let options: [String] = [
        "DCE7EC", // soft blue
        "F5E6C8", // soft gold
        "D8ECEC", // soft teal
        "EAD9E6", // soft mauve
        "E3EAD3", // soft sage
        "F3DED2"  // soft peach
    ]

    static var `default`: String { options[0] }
}
