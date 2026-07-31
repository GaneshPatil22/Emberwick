//
//  ContentView.swift
//  Emberwick
//
//  Created by Ganesh Patil on 26/07/26.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @AppStorage("appearanceMode") private var appearanceMode: AppearanceMode = .system

    @State private var showSplash = ContentView.wantsSplash
    /// Stays true until the splash has fully faded out, so onboarding (a window-level
    /// full-screen cover) can't pop up over the splash while it's still playing.
    @State private var splashActive = ContentView.wantsSplash

    var body: some View {
        ZStack {
            RootView(splashActive: splashActive)

            if showSplash {
                SplashView {
                    withAnimation(.easeInOut(duration: 0.5)) { showSplash = false } completion: {
                        splashActive = false
                    }
                }
                .transition(.opacity)
            }
        }
        .preferredColorScheme(appearanceMode.colorScheme)
        #if DEBUG
        .task { IconExporter.exportIfRequested() }
        #endif
    }

    /// The animated splash plays on every cold launch, except when a debug run opts
    /// out to keep test iterations fast.
    private static var wantsSplash: Bool {
        #if DEBUG
        !CommandLine.arguments.contains("-skipSplash")
        #else
        true
        #endif
    }
}

#Preview {
    ContentView()
        .modelContainer(EmberwickModelContainer.preview())
}
