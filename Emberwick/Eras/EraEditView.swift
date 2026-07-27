//
//  EraEditView.swift
//  Emberwick
//
//  Create an era: a name, a span (start/end), and a soft tint. v1 is create-only —
//  no drag-resize, overlap rules, or nesting.
//

import SwiftData
import SwiftUI

struct EraEditView: View {
    let existingEra: Era?

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var tintHex: String

    init(existingEra: Era? = nil) {
        self.existingEra = existingEra
        _name = State(initialValue: existingEra?.name ?? "")
        _startDate = State(initialValue: existingEra?.startDate ?? .now)
        _endDate = State(initialValue: existingEra?.endDate ?? .now)
        _tintHex = State(initialValue: existingEra?.tintHex ?? EraTints.default)
    }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && endDate >= startDate
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("e.g. University", text: $name)
                }

                Section("Span") {
                    DatePicker("Start", selection: $startDate, displayedComponents: .date)
                    DatePicker("End", selection: $endDate, in: startDate..., displayedComponents: .date)
                }

                Section("Tint") {
                    tintPicker
                }

                if existingEra != nil {
                    Section {
                        Button("Delete", role: .destructive, action: deleteEra)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(EmberPalette.paper)
            .navigationTitle(existingEra == nil ? "New era" : "Edit era")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel", action: dismiss.callAsFunction)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save", action: save).disabled(!canSave)
                }
            }
        }
    }

    private var tintPicker: some View {
        HStack(spacing: EmberSpacing.md) {
            ForEach(EraTints.options, id: \.self) { hex in
                Button {
                    tintHex = hex
                } label: {
                    Circle()
                        .fill(Color(hexString: hex))
                        .frame(width: 32, height: 32)
                        .overlay {
                            Circle().strokeBorder(EmberPalette.ink, lineWidth: tintHex == hex ? 3 : 0)
                        }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Tint \(hex)")
                .accessibilityAddTraits(tintHex == hex ? [.isSelected] : [])
            }
        }
    }

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if let era = existingEra {
            era.name = trimmedName
            era.startDate = startDate
            era.endDate = endDate
            era.tintHex = tintHex
        } else {
            modelContext.insert(Era(name: trimmedName, startDate: startDate, endDate: endDate, tintHex: tintHex))
        }
        try? modelContext.save()
        dismiss()
    }

    private func deleteEra() {
        if let era = existingEra {
            modelContext.delete(era)
            try? modelContext.save()
        }
        dismiss()
    }
}
