//
//  MemoryFlightView.swift
//  Emberwick
//
//  The reusable "flying memory" primitive: flies `content` from `start` to `end`
//  along an arc with a letter-flutter, growing mid-flight then tucking into the
//  target. Used by the intro overlay (many) and the Jar reveal (one).
//
//  The motion lives in `FlightModifier` (Animatable, evaluated at every intermediate
//  `t`). We animate `t` 0→1 with `withAnimation … completion:`, so completion is tied
//  to the animation itself — never a parallel timer — and a token can't be removed
//  before it has actually landed.
//

import SwiftUI

struct MemoryFlightView<Content: View>: View {
    let start: CGPoint
    let end: CGPoint
    let delay: Double
    let duration: Double
    var onComplete: () -> Void = {}
    @ViewBuilder let content: () -> Content

    @State private var t: Double = 0

    var body: some View {
        content()
            .modifier(FlightModifier(t: t, start: start, end: end))
            .allowsHitTesting(false)
            .onAppear {
                withAnimation(.linear(duration: duration).delay(delay)) {
                    t = 1
                } completion: {
                    onComplete()
                }
            }
    }
}
