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
        let container = EmberwickModelContainer.shared()
        #if DEBUG
        DemoSeeder.seedIfEmpty(context: container.mainContext, persona: .standard)
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
