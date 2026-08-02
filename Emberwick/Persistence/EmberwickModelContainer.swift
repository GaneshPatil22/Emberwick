//
//  EmberwickModelContainer.swift
//  Emberwick
//
//  Builds the SwiftData container. `shared` is the on-disk store used by the app;
//  `preview` is an in-memory store, seeded with the demo persona, for #Preview.
//

import Foundation
import SwiftData

enum EmberwickModelContainer {
    private static let schema = Schema([Entry.self, Era.self])

    /// The persistent, on-disk container for the running app — a single shared
    /// instance so the app and the "Add a Win" App Intent write to the same store.
    static let shared: ModelContainer = {
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: configuration)
        } catch {
            fatalError("Failed to create the Emberwick model container: \(error)")
        }
    }()

    /// An in-memory container pre-seeded with the demo persona, for previews.
    @MainActor
    static func preview() -> ModelContainer {
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        do {
            let container = try ModelContainer(for: schema, configurations: configuration)
            DemoSeeder.seedIfEmpty(context: container.mainContext, persona: .standard)
            return container
        } catch {
            fatalError("Failed to create the Emberwick preview container: \(error)")
        }
    }
}
