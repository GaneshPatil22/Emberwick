//
//  SettingsView.swift
//  Emberwick
//
//  Minimal settings for v1: choose which mode the app opens to.
//

import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var entries: [Entry]
    @Query private var eras: [Era]
    @AppStorage("homeMode") private var homeMode: HomeMode = .adaptive
    @AppStorage("appearanceMode") private var appearanceMode: AppearanceMode = .system
    @AppStorage(AppConfig.birthDateKey) private var birthInterval = 0.0
    @AppStorage(AppConfig.birthDayKnownKey) private var birthDayKnown = true
    @AppStorage(EmberSound.enabledKey) private var soundEnabled = true
    @AppStorage("tourRequested") private var tourRequested = false

    @State private var showImporter = false
    @State private var restoreMessage: String?

    private var birthDateBinding: Binding<Date> {
        Binding(
            get: { AppConfig.birthDate(interval: birthInterval) },
            set: { birthInterval = $0.timeIntervalSinceReferenceDate }
        )
    }

    private var showRestoreAlert: Binding<Bool> {
        Binding(get: { restoreMessage != nil }, set: { if !$0 { restoreMessage = nil } })
    }

    /// Reads the chosen JSON file (security-scoped) and merges it into the store.
    private func restore(from result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            let scoped = url.startAccessingSecurityScopedResource()
            defer { if scoped { url.stopAccessingSecurityScopedResource() } }
            do {
                let data = try Data(contentsOf: url)
                let summary = try EmberExporter.restore(from: data, into: modelContext)
                // Adopt the backup's birthday — this re-anchors the grid and (via the
                // birthInterval onChange) regenerates the birth-marker win.
                if let restoredBirth = summary.birthDate {
                    birthDayKnown = summary.birthDayKnown
                    birthInterval = restoredBirth.timeIntervalSinceReferenceDate
                }
                restoreMessage = summary.entriesAdded == 0 && summary.erasAdded == 0
                    ? "Everything in that file was already here — nothing to add."
                    : "Restored \(summary.entriesAdded) \(summary.entriesAdded == 1 ? "entry" : "entries") and \(summary.erasAdded) \(summary.erasAdded == 1 ? "era" : "eras")."
            } catch {
                restoreMessage = "Couldn't read that file. Make sure it's an Emberwick export."
            }
        case .failure:
            restoreMessage = "Couldn't open that file."
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    BirthdayField(date: birthDateBinding, dayKnown: $birthDayKnown)
                } header: {
                    Text("Your birthday")
                } footer: {
                    Text("Anchors your life grid so each square is the right week. Stays on your device.")
                }

                Section {
                    Picker("Open to", selection: $homeMode) {
                        ForEach(HomeMode.allCases, id: \.self) { mode in
                            Text(mode.label).tag(mode)
                        }
                    }
                } header: {
                    Text("Home")
                } footer: {
                    Text("Adaptive opens the Jar while your grid is still filling, then the grid once it's lit up.")
                }

                Section {
                    Picker("Appearance", selection: $appearanceMode) {
                        ForEach(AppearanceMode.allCases, id: \.self) { mode in
                            Text(mode.label).tag(mode)
                        }
                    }
                } header: {
                    Text("Appearance")
                } footer: {
                    Text("System follows your device's Light / Dark setting.")
                }

                Section {
                    Toggle("Sound effects", isOn: $soundEnabled)
                        .tint(EmberPalette.accent)
                } footer: {
                    Text("Soft chimes at moments like revealing a win. Always follows your silent switch.")
                }

                Section {
                    Button {
                        tourRequested = true
                        dismiss()
                    } label: {
                        Label("Take a tour", systemImage: "sparkles")
                            .foregroundStyle(EmberPalette.accentInk)
                    }
                } footer: {
                    Text("A quick walkthrough of the map, tiers, eras, and the jar.")
                }

                Section {
                    ShareLink(
                        item: EmberExport(data: EmberExporter.json(
                            entries: entries,
                            eras: eras,
                            birthDate: birthInterval == 0 ? nil : AppConfig.birthDate(interval: birthInterval),
                            birthDayKnown: birthDayKnown,
                            now: .now
                        )),
                        preview: SharePreview("Emberwick export")
                    ) {
                        Label("Export my data", systemImage: "square.and.arrow.up")
                            .foregroundStyle(EmberPalette.accentInk)
                    }
                    Button {
                        showImporter = true
                    } label: {
                        Label("Restore from a file", systemImage: "square.and.arrow.down")
                            .foregroundStyle(EmberPalette.accentInk)
                    }
                } header: {
                    Text("Your data")
                } footer: {
                    Text("A private JSON copy of everything you've saved — export it as a backup, or restore it onto a new phone. It never leaves your device unless you share it. (Photos stay on-device and aren't included.)")
                }
            }
            .onChange(of: birthInterval) {
                // Move the pinned birth win to match the new birthday.
                BirthdayWin.sync(to: AppConfig.birthDate(interval: birthInterval), in: modelContext)
            }
            .fileImporter(isPresented: $showImporter, allowedContentTypes: [.json]) { result in
                restore(from: result)
            }
            .alert("Restore", isPresented: showRestoreAlert) {
                Button("OK", role: .cancel) { restoreMessage = nil }
            } message: {
                Text(restoreMessage ?? "")
            }
            .scrollContentBackground(.hidden)
            .background(EmberPalette.paper)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done", action: dismiss.callAsFunction)
                }
            }
        }
    }
}
