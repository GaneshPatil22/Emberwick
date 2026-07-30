//
//  Entry.swift
//  Emberwick
//
//  The single model for all three kinds (win / loss / note). A week is DERIVED
//  from an entry's date via GridMath — it is never stored on the entry.
//

import Foundation
import SwiftData

@Model
final class Entry {
    var id: UUID
    /// Maps to a (row, column) grid position via day-of-year math.
    var date: Date
    var kind: EntryKind
    var title: String
    var notes: String?
    /// Optional attachments on any kind. Heavy for sync — compress before persisting.
    var imageData: [Data]
    /// Wins only, optional. `nil` means an unrated win.
    var tier: Tier?
    /// When this win was last surfaced by the Jar. `nil` = never seen. Drives the
    /// weighted shake (long-unseen wins are favored). Never used to delete anything.
    var lastSeenAt: Date?

    init(
        id: UUID = UUID(),
        date: Date,
        kind: EntryKind,
        title: String,
        notes: String? = nil,
        imageData: [Data] = [],
        tier: Tier? = nil,
        lastSeenAt: Date? = nil
    ) {
        self.id = id
        self.date = date
        self.kind = kind
        self.title = title
        self.notes = notes
        self.imageData = imageData
        self.tier = tier
        self.lastSeenAt = lastSeenAt
    }

    /// Only wins are eligible to be surfaced by the Jar.
    var isJarEligible: Bool {
        kind == .win
    }
}
