//
//  SettingsView.swift
//  Emberwick
//
//  Minimal settings for v1: choose which mode the app opens to.
//

import SwiftData
import SwiftUI

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

    private var birthDateBinding: Binding<Date> {
        Binding(
            get: { AppConfig.birthDate(interval: birthInterval) },
            set: { birthInterval = $0.timeIntervalSinceReferenceDate }
        )
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
                        item: EmberExport(data: EmberExporter.json(entries: entries, eras: eras, now: .now)),
                        preview: SharePreview("Emberwick export")
                    ) {
                        Label("Export my data", systemImage: "square.and.arrow.up")
                            .foregroundStyle(EmberPalette.accentInk)
                    }
                } header: {
                    Text("Your data")
                } footer: {
                    Text("A private JSON copy of everything you've saved. It never leaves your device unless you share it.")
                }
            }
            .onChange(of: birthInterval) {
                // Move the pinned birth win to match the new birthday.
                BirthdayWin.sync(to: AppConfig.birthDate(interval: birthInterval), in: modelContext)
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
