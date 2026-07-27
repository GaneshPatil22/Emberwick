//
//  EntrySheet.swift
//  Emberwick
//
//  Identifies the entry-editor sheet: either adding a new entry to a week (with the
//  week's representative date) or editing an existing entry.
//

import Foundation

struct EntrySheet: Identifiable {
    let id = UUID()
    let entry: Entry?
    let weekDate: Date
}
