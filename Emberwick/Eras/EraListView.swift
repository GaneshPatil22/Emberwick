//
//  EraListView.swift
//  Emberwick
//
//  Manage eras: see them all, tap to edit, swipe to delete, or add a new one.
//

import SwiftData
import SwiftUI

struct EraListView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Era.startDate) private var eras: [Era]

    @State private var sheet: EraSheet?

    var body: some View {
        NavigationStack {
            Group {
                if eras.isEmpty {
                    ContentUnavailableView(
                        "No eras yet",
                        systemImage: "rectangle.stack",
                        description: Text("Add an era to tint a span of your life.")
                    )
                } else {
                    List {
                        ForEach(eras) { era in
                            Button {
                                sheet = EraSheet(era: era)
                            } label: {
                                EraRow(era: era)
                            }
                            .buttonStyle(.plain)
                        }
                        .onDelete(perform: deleteEras)
                    }
                }
            }
            .navigationTitle("Eras")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done", action: dismiss.callAsFunction)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add", systemImage: "plus") { sheet = EraSheet(era: nil) }
                }
            }
            .sheet(item: $sheet) { sheet in
                EraEditView(existingEra: sheet.era)
            }
        }
        .tint(EmberPalette.accentInk)
    }

    private func deleteEras(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(eras[index])
        }
        try? modelContext.save()
    }
}
