//
//  WidgetBridge.swift
//  Emberwick
//
//  Publishes a tiny snapshot (the current "a year ago" resurfacing win, or a gentle
//  this-week nudge) into the App Group so the home-screen widget can show it without
//  touching the SwiftData store. Harmless if the App Group isn't configured yet.
//
//  Widget target lives in ../EmberwickWidget (added in Xcode — see README).
//

import Foundation
import WidgetKit

enum WidgetBridge {
    static let appGroup = "group.testing.Emberwick"
    static let snapshotKey = "emberwick.widget.snapshot"

    /// Mirror of the widget's model (duplicated there to avoid cross-target membership).
    struct Snapshot: Codable {
        var title: String
        var caption: String   // "A year ago" / "This week"
        var tier: String?     // Tier.rawValue, or nil for a neutral win
        var updatedAt: Date
    }

    static func publish(_ snapshot: Snapshot) {
        guard let defaults = UserDefaults(suiteName: appGroup),
              let data = try? JSONEncoder().encode(snapshot) else { return }
        defaults.set(data, forKey: snapshotKey)
        WidgetCenter.shared.reloadAllTimelines()
    }

    /// Publishes a resurfaced win if there is one, else a gentle nudge.
    static func publishResurfacing(_ win: Entry?, now: Date) {
        if let win {
            publish(Snapshot(title: win.title, caption: "A year ago", tier: win.tier?.rawValue, updatedAt: now))
        } else {
            publish(Snapshot(title: "Add a win to light up this week", caption: "This week", tier: nil, updatedAt: now))
        }
    }
}
