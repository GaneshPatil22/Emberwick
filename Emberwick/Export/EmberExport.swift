//
//  EmberExport.swift
//  Emberwick
//
//  Private, on-device data export and restore. Everything you save can be handed to
//  you as a plain JSON file via the share sheet — nothing leaves the device unless
//  you choose to share it — and that same file can be imported back (e.g. onto a new
//  phone). Reinforces the "your data is yours" promise and gives you a real backup.
//

import CoreTransferable
import Foundation
import SwiftData
import UniformTypeIdentifiers

/// A JSON blob the share sheet can write to a file / hand to another app.
///
/// The data is produced lazily — only when the system actually resolves the transfer
/// (i.e. the user taps Share) — not when the `ShareLink` is built. Building it eagerly
/// in a view body would re-serialize the whole store on every render and, worse, could
/// read `@Query` models mid-deletion (a detached-fault crash right after a reset/wipe).
struct EmberExport: Transferable {
    let makeData: () -> Data

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .json) { $0.makeData() }
            .suggestedFileName("emberwick-export.json")
    }
}

enum EmberExporter {
    private struct File: Codable {
        var app = "Emberwick"
        var exportedAt: Date
        /// The grid anchor — the whole map is meaningless without it, so it travels
        /// with the backup (it lives in UserDefaults, not the SwiftData store).
        var birthDate: Date?
        var birthDayKnown: Bool?
        var entries: [EntryDTO]
        var eras: [EraDTO]
    }

    private struct EntryDTO: Codable {
        var id: UUID?
        var date: Date
        var kind: String
        var title: String
        var notes: String?
        var tier: String?
    }

    private struct EraDTO: Codable {
        var id: UUID?
        var name: String
        var startDate: Date
        var endDate: Date
        var tintHex: String
    }

    /// What a restore added (existing items are kept, not overwritten) plus the
    /// birthday the caller should adopt (nil if the file didn't carry one).
    struct RestoreSummary {
        let entriesAdded: Int
        let erasAdded: Int
        let birthDate: Date?
        let birthDayKnown: Bool
    }

    private static func decoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }

    /// Builds a stable, human-readable JSON export. Photos are omitted by design
    /// (kept on-device; the export stays small and shareable). The birthday travels
    /// with it; the derived birth-marker win does NOT — it's regenerated on restore.
    static func json(entries: [Entry], eras: [Era], birthDate: Date?, birthDayKnown: Bool, now: Date) -> Data {
        let file = File(
            exportedAt: now,
            birthDate: birthDate,
            birthDayKnown: birthDayKnown,
            entries: entries
                .filter { !$0.isBirthMarker } // derived from the birthday — not exported
                .sorted { $0.date < $1.date }
                .map { EntryDTO(id: $0.id, date: $0.date, kind: $0.kind.rawValue, title: $0.title, notes: $0.notes, tier: $0.tier?.rawValue) },
            eras: eras
                .sorted { $0.startDate < $1.startDate }
                .map { EraDTO(id: $0.id, name: $0.name, startDate: $0.startDate, endDate: $0.endDate, tintHex: $0.tintHex) }
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        encoder.dateEncodingStrategy = .iso8601
        return (try? encoder.encode(file)) ?? Data()
    }

    /// Restores an exported file, adding only items not already present (matched by
    /// id). A safe merge — importing your own backup never duplicates or overwrites.
    /// Photos aren't in the export, so restored entries come back without images.
    @MainActor
    static func restore(from data: Data, into context: ModelContext) throws -> RestoreSummary {
        let file = try decoder().decode(File.self, from: data)

        let existingEntryIDs = Set((try? context.fetch(FetchDescriptor<Entry>()))?.map(\.id) ?? [])
        let existingEraIDs = Set((try? context.fetch(FetchDescriptor<Era>()))?.map(\.id) ?? [])

        // The birthday to adopt: the file's explicit value, or — for older files that
        // predate birthday-in-export — the date of the "story begins" win it carries.
        let importedBirthDate = file.birthDate
            ?? file.entries.first(where: { $0.title == BirthdayWin.title })?.date

        var entriesAdded = 0
        for dto in file.entries {
            // Never import a "story begins" win as data — it's derived from the
            // birthday and regenerated on the receiving device (avoids duplicates).
            guard dto.title != BirthdayWin.title else { continue }
            let id = dto.id ?? UUID()
            guard !existingEntryIDs.contains(id) else { continue }
            context.insert(Entry(
                id: id,
                date: dto.date,
                kind: EntryKind(rawValue: dto.kind) ?? .win,
                title: dto.title,
                notes: dto.notes,
                tier: dto.tier.flatMap(Tier.init(rawValue:))
            ))
            entriesAdded += 1
        }

        var erasAdded = 0
        for dto in file.eras {
            let id = dto.id ?? UUID()
            guard !existingEraIDs.contains(id) else { continue }
            context.insert(Era(id: id, name: dto.name, startDate: dto.startDate, endDate: dto.endDate, tintHex: dto.tintHex))
            erasAdded += 1
        }

        try context.save()
        // The caller adopts the birthday (it lives in UserDefaults, and setting it
        // regenerates the single birth-marker win at the right week).
        return RestoreSummary(
            entriesAdded: entriesAdded,
            erasAdded: erasAdded,
            birthDate: importedBirthDate,
            birthDayKnown: file.birthDayKnown ?? true
        )
    }
}
