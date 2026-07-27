//
//  AppConfig.swift
//  Emberwick
//
//  App-wide configuration values. Until onboarding (Phase 8) captures a real birth
//  date, the grid and the demo seeder both read the default from here so they stay
//  aligned (one source of truth).
//

import Foundation

enum AppConfig {
    /// The birth date the life grid is anchored to. Row 0 is this year.
    static let defaultBirthDate: Date = {
        let components = DateComponents(year: 1990, month: 4, day: 12)
        return Calendar.current.date(from: components) ?? .distantPast
    }()
}
