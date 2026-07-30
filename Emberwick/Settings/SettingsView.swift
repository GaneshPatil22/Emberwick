//
//  SettingsView.swift
//  Emberwick
//
//  Minimal settings for v1: choose which mode the app opens to.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("homeMode") private var homeMode: HomeMode = .adaptive
    @AppStorage("appearanceMode") private var appearanceMode: AppearanceMode = .system

    var body: some View {
        NavigationStack {
            Form {
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
