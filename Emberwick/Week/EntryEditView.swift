//
//  EntryEditView.swift
//  Emberwick
//
//  Add or edit an entry for a week. Kind picker (win/loss/note), required title,
//  optional notes, optional photos, and — for wins only — an optional one-tap tier.
//  Persists via SwiftData; images are compressed on import.
//

import PhotosUI
import SwiftData
import SwiftUI

struct EntryEditView: View {
    let existingEntry: Entry?
    let weekDate: Date

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var kind: EntryKind
    @State private var title: String
    @State private var notes: String
    @State private var tier: Tier?
    @State private var imageData: [Data]
    @State private var pickerItems: [PhotosPickerItem] = []

    init(existingEntry: Entry?, weekDate: Date) {
        self.existingEntry = existingEntry
        self.weekDate = weekDate
        _kind = State(initialValue: existingEntry?.kind ?? .win)
        _title = State(initialValue: existingEntry?.title ?? "")
        _notes = State(initialValue: existingEntry?.notes ?? "")
        _tier = State(initialValue: existingEntry?.tier)
        _imageData = State(initialValue: existingEntry?.imageData ?? [])
    }

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Kind", selection: $kind) {
                        ForEach(EntryKind.allCases, id: \.self) { kind in
                            Text(kind.displayName).tag(kind)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Title") {
                    TextField("What happened?", text: $title, axis: .vertical)
                        .lineLimit(1...3)
                }

                Section("Notes") {
                    TextField("Anything you want to keep", text: $notes, axis: .vertical)
                        .lineLimit(3...8)
                }

                if kind == .win {
                    Section("Tier (optional)") {
                        TierSelector(tier: $tier)
                    }
                }

                Section("Photos") {
                    PhotosPicker(selection: $pickerItems, matching: .images) {
                        Label("Add photos", systemImage: "photo.badge.plus")
                    }
                    if !imageData.isEmpty {
                        EntryImageStrip(imageData: imageData)
                    }
                }

                if existingEntry != nil {
                    Section {
                        Button("Delete", role: .destructive, action: deleteEntry)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(EmberPalette.paper)
            .navigationTitle(existingEntry == nil ? "Add to this week" : "Edit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel", action: dismiss.callAsFunction)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save", action: save).disabled(!canSave)
                }
            }
            .onChange(of: pickerItems) { _, newItems in
                Task { await loadImages(newItems) }
            }
        }
    }

    private func save() {
        let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        let resolvedTier = kind == .win ? tier : nil

        if let entry = existingEntry {
            entry.kind = kind
            entry.title = title
            entry.notes = trimmedNotes.isEmpty ? nil : trimmedNotes
            entry.tier = resolvedTier
            entry.imageData = imageData
        } else {
            let entry = Entry(
                date: weekDate,
                kind: kind,
                title: title,
                notes: trimmedNotes.isEmpty ? nil : trimmedNotes,
                imageData: imageData,
                tier: resolvedTier
            )
            modelContext.insert(entry)
        }

        try? modelContext.save()
        dismiss()
    }

    private func deleteEntry() {
        if let entry = existingEntry {
            modelContext.delete(entry)
            try? modelContext.save()
        }
        dismiss()
    }

    private func loadImages(_ items: [PhotosPickerItem]) async {
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self) {
                imageData.append(ImageCompression.compressed(data))
            }
        }
        pickerItems = []
    }
}
