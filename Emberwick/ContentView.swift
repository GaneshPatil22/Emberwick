//
//  ContentView.swift
//  Emberwick
//
//  Created by Ganesh Patil on 26/07/26.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    var body: some View {
        MapView()
    }
}

#Preview {
    ContentView()
        .modelContainer(EmberwickModelContainer.preview())
}
