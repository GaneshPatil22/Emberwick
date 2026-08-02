//
//  EmberExport.swift
//  Emberwick
//
//  Private, on-device data export. Everything you save can be handed to you as a
//  plain JSON file via the share sheet — nothing leaves the device unless you choose
//  to share it. Reinforces the "your data is yours" promise and gives you a backup.
//

import CoreTransferable
import Foundation
import UniformTypeIdentifiers

/// A JSON blob the share sheet can write to a file / hand to another app.
struct EmberExport: Transferable {
    let data: Data

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .json) { $0.data }
            .suggestedFileName("emberwick-export.json")
    }
}

enum EmberExporter {
    private struct File: Codable {
        var app = "Emberwick"
        var exportedAt: Date
        var entries: [EntryDTO]
        var eras: [EraDTO]
    }

    private struct EntryDTO: Codable {
        var date: Date
        var kind: String
        var title: String
        var notes: String?
        var tier: String?
    }

    private struct EraDTO: Codable {
        var name: String
        var startDate: Date
        var endDate: Date
        var tintHex: String
    }

    /// Builds a stable, human-readable JSON export. Photos are omitted by design
    /// (kept on-device; the export stays small and shareable).
    static func json(entries: [Entry], eras: [Era], now: Date) -> Data {
        let file = File(
            exportedAt: now,
            entries: entries
                .sorted { $0.date < $1.date }
                .map { EntryDTO(date: $0.date, kind: $0.kind.rawValue, title: $0.title, notes: $0.notes, tier: $0.tier?.rawValue) },
            eras: eras
                .sorted { $0.startDate < $1.startDate }
                .map { EraDTO(name: $0.name, startDate: $0.startDate, endDate: $0.endDate, tintHex: $0.tintHex) }
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        encoder.dateEncodingStrategy = .iso8601
        return (try? encoder.encode(file)) ?? Data()
    }
}
