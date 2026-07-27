//
//  EntryKind+Presentation.swift
//  Emberwick
//
//  Display strings and SF Symbols for each entry kind. Kept in the design layer so
//  the model stays free of UI concerns. Losses are framed gently ("A hard week"),
//  never harshly.
//

import Foundation

extension EntryKind {
    var displayName: String {
        switch self {
        case .win: "Win"
        case .loss: "A hard week"
        case .note: "Note"
        }
    }

    var systemImage: String {
        switch self {
        case .win: "trophy"
        case .loss: "cloud.rain"
        case .note: "text.alignleft"
        }
    }
}
