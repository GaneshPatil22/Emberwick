//
//  AppearanceMode.swift
//  Emberwick
//
//  The user's appearance preference. Defaults to following the device.
//

import SwiftUI

enum AppearanceMode: String, CaseIterable {
    case system
    case light
    case dark

    var label: String {
        switch self {
        case .system: "System"
        case .light: "Light"
        case .dark: "Dark"
        }
    }

    /// `nil` follows the device; otherwise forces the chosen scheme.
    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}
