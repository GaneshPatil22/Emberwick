//
//  AppConfig.swift
//  Emberwick
//
//  App-wide configuration. The life grid is anchored to the user's birth date,
//  captured in onboarding (and editable in Settings) and stored in UserDefaults.
//  Until it's set, everything falls back to `fallbackBirthDate` so the grid and the
//  demo seeder stay aligned (one source of truth).
//

import Foundation

enum AppConfig {
    /// UserDefaults key: birth date as `timeIntervalSinceReferenceDate` (0 = unset).
    static let birthDateKey = "birthDateInterval"
    /// UserDefaults key: whether the user gave an exact day (vs. month & year only).
    static let birthDayKnownKey = "birthDayKnown"

    /// Used until the user sets their own — keeps the grid + seeder aligned.
    static let fallbackBirthDate: Date = {
        let components = DateComponents(year: 1990, month: 4, day: 12)
        return Calendar.current.date(from: components) ?? .distantPast
    }()

    /// Resolves a stored interval to a date, falling back when unset (interval 0).
    static func birthDate(interval: Double) -> Date {
        interval == 0 ? fallbackBirthDate : Date(timeIntervalSinceReferenceDate: interval)
    }

    /// The birth date the life grid is anchored to. Row 0 is this year.
    static var birthDate: Date {
        birthDate(interval: UserDefaults.standard.double(forKey: birthDateKey))
    }

    /// Whether the user has set their birthday (vs. still on the fallback).
    static var isBirthDateSet: Bool {
        UserDefaults.standard.double(forKey: birthDateKey) != 0
    }
}
