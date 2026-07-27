//
//  EraSheet.swift
//  Emberwick
//
//  Identifies the era-editor sheet: a new era (nil) or an existing one to edit.
//

import Foundation

struct EraSheet: Identifiable {
    let id = UUID()
    let era: Era?
}
