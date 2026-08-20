//
//  SoundPlayer.swift
//  Emberwick
//
//  Tiny, tasteful audio feedback using built-in iOS system sounds (no bundled audio).
//  Paired with the existing haptics at a few key moments. Honors the "Sound effects"
//  Settings toggle (on by default) and the device silent switch.
//
//  All sound IDs live in one place so they're easy to audition and swap. IDs come
//  from /System/Library/Audio/UISounds; a few pleasant alternatives are noted inline.
//

import AudioToolbox
import Foundation

enum EmberSound {
    /// UserDefaults key for the Settings toggle.
    static let enabledKey = "soundEnabled"

    case reveal(Tier?)
    case winSaved
    case birthday
    case launch

    /// The system sound to play. Tune these freely.
    var systemSoundID: SystemSoundID {
        switch self {
        // One warm "Tink" across every reveal and save, so the app speaks with a single
        // voice. A bigger win isn't a *different* sound — its size is carried by the
        // confetti and haptics, which already scale by tier. Keeps it cohesive.
        case .reveal, .winSaved, .birthday: 1057 // "Tink" (alt family: 1013 "Tock")
        case .launch:                       1103 // soft "begin" at app open
        }
    }
}

enum SoundPlayer {
    static func play(_ sound: EmberSound) {
        guard isEnabled else { return }
        AudioServicesPlaySystemSound(sound.systemSoundID)
    }

    /// On by default: absent key means the user hasn't opted out.
    private static var isEnabled: Bool {
        let defaults = UserDefaults.standard
        return defaults.object(forKey: EmberSound.enabledKey) == nil
            ? true
            : defaults.bool(forKey: EmberSound.enabledKey)
    }
}
