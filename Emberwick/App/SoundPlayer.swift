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
        case .reveal(.diamond): 1025 // fuller chime for the top tier  (alt: 1335, 1327)
        case .reveal:           1057 // "Tink" — light positive chime   (alt: 1013 "Tock")
        case .winSaved:         1057 // "Tink"
        case .birthday:         1025 // celebratory                      (alt: 1330)
        case .launch:           1103 // soft "begin"                     (alt: 1113)
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
