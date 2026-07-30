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

    var body: some View {
        RootView()
            .preferredColorScheme(appearanceMode.colorScheme)
    }
}

#Preview {
    ContentView()
        .modelContainer(EmberwickModelContainer.preview())
}
