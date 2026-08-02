//
//  EmberwickApp.swift
//  Emberwick
//
//  Created by Ganesh Patil on 26/07/26.
//

import SwiftData
import SwiftUI

@main
struct EmberwickApp: App {
    private let container: ModelContainer

    init() {
        let container = EmberwickModelContainer.shared
        #if DEBUG
        // Test hook: `-birthday=YYYY-MM-DD` sets the birthday from the app itself, so
        // @AppStorage reads it reliably (external `defaults write` doesn't propagate).
        if let arg = CommandLine.arguments.first(where: { $0.hasPrefix("-birthday=") }) {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.timeZone = TimeZone(identifier: "UTC")
            if let date = formatter.date(from: String(arg.dropFirst("-birthday=".count))) {
                UserDefaults.standard.set(date.timeIntervalSinceReferenceDate, forKey: AppConfig.birthDateKey)
            }
        }
        if !CommandLine.arguments.contains("-skipSeed") {
            DemoSeeder.seedIfEmpty(context: container.mainContext, persona: .standard)
            // Demo runs get the fallback birthday so the required gate doesn't block
            // dev work; `-skipSeed` leaves it unset to exercise the gate.
            if !AppConfig.isBirthDateSet {
                UserDefaults.standard.set(
                    AppConfig.fallbackBirthDate.timeIntervalSinceReferenceDate,
                    forKey: AppConfig.birthDateKey
                )
            }
        }
        #endif
        self.container = container
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
