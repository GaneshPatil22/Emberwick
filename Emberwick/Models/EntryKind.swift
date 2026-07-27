//
//  EntryKind.swift
//  Emberwick
//
//  One unified entry model uses this to distinguish the three kinds.
//  Do NOT build win/loss/note as separate types.
//

import Foundation

enum EntryKind: String, Codable, CaseIterable, Sendable {
    case win
    case loss
    case note
}
