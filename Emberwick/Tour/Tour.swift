//
//  Tour.swift
//  Emberwick
//
//  A one-time guided spotlight tour of the app's key features. Each highlighted view
//  registers its frame (in a shared coordinate space) into `TourAnchors`; the overlay
//  reads the current step's frame and dims everything else. Robust across the TabView
//  because frames flow through an observable store, not view preferences.
//
//  Auto-runs once after first-run setup; replayable from Settings ("Take a tour").
//

import SwiftUI

/// The elements the tour can spotlight.
enum TourTarget: Hashable {
    case mapGrid, tiers, eras, jar, shake
}

struct TourStep: Identifiable {
    var id: TourTarget { target }
    let target: TourTarget
    let tab: AppTab
    let title: String
    let message: String
}

enum Tour {
    /// The shared named coordinate space anchors are measured in.
    static let space = "tour"

    static let steps: [TourStep] = [
        TourStep(
            target: .mapGrid, tab: .map,
            title: "Your life, in weeks",
            message: "Every square is one week. Pinch to zoom into a year, and tap any week to open it."
        ),
        TourStep(
            target: .tiers, tab: .map,
            title: "Wins that glow",
            message: "Rate a win from bronze to diamond — the bigger it felt, the brighter it shines. Tap the colour key any time to see what each glow means."
        ),
        TourStep(
            target: .eras, tab: .map,
            title: "Chapters of your life",
            message: "Group stretches of time — a city, a job, school — into soft colored bands."
        ),
        TourStep(
            target: .jar, tab: .jar,
            title: "A jar of your wins",
            message: "The Jar is a lens on your best moments — it never stores or deletes anything."
        ),
        TourStep(
            target: .shake, tab: .jar,
            title: "Shake to remember",
            message: "Shake your phone (or tap the button) to relive a good moment you might have forgotten."
        )
    ]
}

/// Live frames of the tour targets, keyed by target, in the `Tour.space` space.
@Observable
final class TourAnchors {
    var frames: [TourTarget: CGRect] = [:]
}

extension View {
    /// Registers this view as a tour target, publishing its frame while on screen.
    func tourTarget(_ target: TourTarget) -> some View {
        modifier(TourTargetModifier(target: target))
    }

    /// Masks out the region drawn by `mask` (a "hole"), keeping the rest of `self`.
    func reverseMask<Mask: View>(@ViewBuilder _ mask: () -> Mask) -> some View {
        self.mask {
            Rectangle().overlay { mask().blendMode(.destinationOut) }
        }
    }
}

private struct TourTargetModifier: ViewModifier {
    let target: TourTarget
    @Environment(TourAnchors.self) private var anchors: TourAnchors?

    func body(content: Content) -> some View {
        content.onGeometryChange(for: CGRect.self) { proxy in
            proxy.frame(in: .named(Tour.space))
        } action: { rect in
            anchors?.frames[target] = rect
        }
    }
}
