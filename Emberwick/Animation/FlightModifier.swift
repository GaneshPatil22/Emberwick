//
//  FlightModifier.swift
//  Emberwick
//
//  Drives a flying token from `start` to `end` as a function of the clock `t` (0 =
//  source, 1 = tucked into the box). Being `Animatable` with `animatableData = t`
//  means SwiftUI evaluates it at every intermediate `t` (a real arc + visible fade),
//  unlike a plain `withAnimation` which would only interpolate the two endpoints.
//

import SwiftUI

struct FlightModifier: ViewModifier, Animatable {
    var t: Double
    let start: CGPoint
    let end: CGPoint

    /// Fraction of the flight spent travelling; the rest is the tuck-into-the-box.
    private let travelPortion = 0.68

    var animatableData: Double {
        get { t }
        set { t = newValue }
    }

    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(rotation))
            .scaleEffect(scale)
            .opacity(opacity)
            .position(position)
    }

    /// Quadratic Bézier arc during travel, then held at the cell during the tuck.
    private var position: CGPoint {
        let travel = Swift.min(t / travelPortion, 1)
        let eased = 1 - pow(1 - travel, 2)               // ease-out into the cell
        let controlX = (start.x + end.x) / 2
        let controlY = Swift.min(start.y, end.y) - 90     // lift for the arc
        let inverse = 1 - eased
        let x = inverse * inverse * start.x + 2 * inverse * eased * controlX + eased * eased * end.x
        let y = inverse * inverse * start.y + 2 * inverse * eased * controlY + eased * eased * end.y
        let flutter = sin(travel * .pi * 2.5) * 12 * (1 - travel)
        return CGPoint(x: x + flutter, y: y)
    }

    /// Pop out (0.6→1.05), settle to 1.0 while travelling, shrink into the box on tuck.
    private var scale: Double {
        if t < 0.15 {
            return 0.6 + (1.05 - 0.6) * (t / 0.15)
        }
        if t < travelPortion {
            return 1.05 + (1.0 - 1.05) * ((t - 0.15) / (travelPortion - 0.15))
        }
        return 1.0 + (0.16 - 1.0) * ((t - travelPortion) / (1 - travelPortion))
    }

    /// Fade in on launch, stay visible through the whole flight, fade only at the box.
    private var opacity: Double {
        if t < 0.12 { return t / 0.12 }
        if t < 0.82 { return 1 }
        return Swift.max(0, 1 - (t - 0.82) / 0.18)
    }

    /// Fluttering wobble that decays as it approaches the cell; upright once landed.
    private var rotation: Double {
        guard t < travelPortion else { return 0 }
        let progress = t / travelPortion
        return sin(progress * .pi * 2.5) * 8 * (1 - progress)
    }
}
