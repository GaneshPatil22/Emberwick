//
//  PresentationDefaults.swift
//  Emberwick
//
//  UserDefaults keys for the DEBUG "Presentation" controls (stage-demo rigging).
//  Keys are defined in all builds so references compile; the controls themselves
//  are gated behind #if DEBUG.
//

import Foundation

enum PresentationDefaults {
    /// When true, every jar draw returns a Diamond/Gold win that has a photo.
    static let rigDrawsKey = "demoRigDraws"
}
