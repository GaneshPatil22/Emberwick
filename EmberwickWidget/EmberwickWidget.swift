//
//  EmberwickWidget.swift
//  EmberwickWidget
//
//  Home-screen widget: a glanceable "a year ago" resurfacing win (or a gentle
//  this-week nudge). Reads a small snapshot the app publishes into the App Group —
//  no SwiftData access needed. Self-contained; the @main bundle lives alongside.
//

import SwiftUI
import WidgetKit

// MARK: - Shared snapshot (mirrors WidgetBridge.Snapshot in the app target)

struct Snapshot: Codable {
    var title: String
    var caption: String
    var tier: String?
    var updatedAt: Date
}

enum WidgetStore {
    static let appGroup = "group.testing.Emberwick"
    static let key = "emberwick.widget.snapshot"

    static func read() -> Snapshot? {
        guard let defaults = UserDefaults(suiteName: appGroup),
              let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(Snapshot.self, from: data)
    }
}

// MARK: - Timeline

struct EmberEntry: TimelineEntry {
    let date: Date
    let snapshot: Snapshot?
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> EmberEntry {
        EmberEntry(date: .now, snapshot: Snapshot(title: "Ran my first 10k", caption: "A year ago", tier: "gold", updatedAt: .now))
    }

    func getSnapshot(in context: Context, completion: @escaping (EmberEntry) -> Void) {
        completion(EmberEntry(date: .now, snapshot: WidgetStore.read() ?? placeholder(in: context).snapshot))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<EmberEntry>) -> Void) {
        let entry = EmberEntry(date: .now, snapshot: WidgetStore.read())
        // Refresh a few times a day; the app also reloads on demand when data changes.
        let next = Calendar.current.date(byAdding: .hour, value: 6, to: .now) ?? .now.addingTimeInterval(21_600)
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
}

// MARK: - View

struct EmberwickWidgetEntryView: View {
    var entry: EmberEntry

    private var tint: Color {
        switch entry.snapshot?.tier {
        case "diamond": Color(red: 0.31, green: 0.75, blue: 0.84)
        case "gold": Color(red: 0.95, green: 0.65, blue: 0.17)
        case "silver": Color(red: 0.60, green: 0.63, blue: 0.68)
        case "bronze": Color(red: 0.75, green: 0.46, blue: 0.23)
        default: Color(red: 0.91, green: 0.70, blue: 0.48) // memoryNeutral
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Circle()
                    .fill(tint)
                    .frame(width: 12, height: 12)
                    .shadow(color: tint.opacity(0.8), radius: 4)
                Text(entry.snapshot?.caption ?? "This week")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
            Text(entry.snapshot?.title ?? "Add a win to light up this week")
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(.primary)
                .lineLimit(3)
            Spacer(minLength: 0)
            Text("Emberwick")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}

// MARK: - Widget

struct EmberwickWidget: Widget {
    let kind = "EmberwickWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            EmberwickWidgetEntryView(entry: entry)
                .containerBackground(.background, for: .widget)
        }
        .configurationDisplayName("A moment worth keeping")
        .description("A win from a year ago, or a nudge to add one this week.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    EmberwickWidget()
} timeline: {
    EmberEntry(date: .now, snapshot: nil)
    EmberEntry(date: .now, snapshot: nil)
}
