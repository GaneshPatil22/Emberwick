//
//  AddWinIntent.swift
//  Emberwick
//
//  Capture a win without opening the app — from Siri, Spotlight, or the Shortcuts
//  app ("Add a win to Emberwick"). Writes straight into the shared store, so it
//  appears on the map and in the jar next time you open the app.
//

import AppIntents
import SwiftData

struct AddWinIntent: AppIntent {
    static let title: LocalizedStringResource = "Add a Win"
    static let description = IntentDescription("Save a good moment to Emberwick.")
    /// Keep the app in the background — no need to bring it forward to log a win.
    static let openAppWhenRun = false

    @Parameter(title: "Win", requestValueDialog: "What's the win?")
    var text: String

    static var parameterSummary: some ParameterSummary {
        Summary("Add \(\.$text) to Emberwick")
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw $text.needsValueError("What's the win?")
        }
        let context = EmberwickModelContainer.shared.mainContext
        context.insert(Entry(date: .now, kind: .win, title: trimmed))
        try? context.save()
        return .result(dialog: "Added “\(trimmed)” to your jar. ✨")
    }
}

struct EmberShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddWinIntent(),
            phrases: [
                "Add a win to \(.applicationName)",
                "Log a win in \(.applicationName)",
                "Save a moment in \(.applicationName)"
            ],
            shortTitle: "Add a Win",
            systemImageName: "sparkles"
        )
    }
}
