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
        // Real first-run behavior in every build: an empty store runs onboarding + the
        // birthday gate. Demo data is loaded on demand from Settings › Presentation (Debug).
        self.container = EmberwickModelContainer.shared
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
