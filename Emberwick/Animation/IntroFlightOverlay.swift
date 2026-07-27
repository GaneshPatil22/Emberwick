//
//  IntroFlightOverlay.swift
//  Emberwick
//
//  Renders the first-run intro: memory tokens flying from the bottom into their
//  week cells. Purely decorative — never intercepts touches.
//

import SwiftUI

struct IntroFlightOverlay: View {
    let flights: [MemoryFlight]
    let flightDuration: Double
    var onComplete: (MemoryFlight) -> Void = { _ in }

    var body: some View {
        ZStack {
            ForEach(flights) { flight in
                MemoryFlightView(
                    start: flight.start,
                    end: flight.end,
                    delay: flight.delay,
                    duration: flightDuration,
                    onComplete: { onComplete(flight) }
                ) {
                    MemoryTokenView(content: flight.content, tier: flight.tier)
                }
            }
        }
        .allowsHitTesting(false)
    }
}
