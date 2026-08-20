//
//  ConfettiView.swift
//  Emberwick
//
//  A one-shot celebratory confetti burst for the Jar reveal, styled per win `Tier`.
//  A single `Canvas` + `TimelineView` particle system (no per-piece SwiftUI views),
//  so even the lavish diamond burst stays cheap. Physics: each piece fountains
//  outward from the orb, arcs under gravity, flutters, spins, and fades. Purely
//  decorative and non-interactive; the caller skips it under Reduce Motion.
//
//  Bigger wins get louder confetti — more pieces, wider spread, richer palette,
//  sparkles for silver+ — so the reward scales with the moment.
//

import SwiftUI

struct ConfettiBurst: View {
    private let style: ConfettiStyle
    /// Frozen at creation (the reveal moment) so elapsed time is measured from there —
    /// more reliable than `.onAppear` state writes inside a `TimelineView`.
    @State private var start: Date
    @State private var pieces: [ConfettiPiece]
    @State private var finished = false

    /// - Parameters:
    ///   - tier: the win's tier, which picks the recipe.
    ///   - origin: where the burst starts (the reveal orb), in view coordinates.
    init(tier: Tier?, origin: CGPoint) {
        let style = ConfettiStyle.forTier(tier)
        self.style = style
        _start = State(initialValue: .now)
        _pieces = State(initialValue: ConfettiPiece.make(style: style, origin: origin))
    }

    var body: some View {
        Group {
            if finished {
                Color.clear // stop the per-frame redraw once the burst has settled
            } else {
                TimelineView(.animation) { timeline in
                    Canvas { context, _ in
                        let elapsed = timeline.date.timeIntervalSince(start)
                        guard elapsed <= style.duration else { return }
                        for piece in pieces {
                            draw(piece, at: elapsed, context: context)
                        }
                    }
                    .ignoresSafeArea()
                }
            }
        }
        .allowsHitTesting(false)
        .task {
            try? await Task.sleep(for: .seconds(style.duration + 0.15))
            finished = true
        }
    }

    private func draw(_ piece: ConfettiPiece, at t: Double, context: GraphicsContext) {
        let progress = t / style.duration
        // Hold full opacity, then fade over the final stretch.
        let opacity = progress < 0.62 ? 1 : max(0, 1 - (progress - 0.62) / 0.38)
        guard opacity > 0 else { return }

        let x = piece.origin.x
            + piece.velocity.dx * t
            + piece.wobbleAmp * sin(piece.wobbleFreq * t + piece.phase)
        let y = piece.origin.y
            + piece.velocity.dy * t
            + 0.5 * style.gravity * t * t

        var ctx = context // value copy → per-piece transform, no accumulation
        ctx.translateBy(x: x, y: y)
        ctx.rotate(by: .radians(piece.spin * t))
        ctx.fill(piece.path(at: t), with: .color(piece.color.opacity(opacity)))
    }
}

// MARK: - Piece

private struct ConfettiPiece {
    let origin: CGPoint
    let velocity: CGVector
    let color: Color
    let shape: ConfettiShape
    let size: Double
    let spin: Double        // radians / second
    let phase: Double
    let wobbleAmp: Double    // horizontal drift amplitude
    let wobbleFreq: Double
    let flutterFreq: Double  // tumbling (width breathing) speed

    /// The piece's shape centered on the origin; some shapes "flutter" over time.
    func path(at t: Double) -> Path {
        switch shape {
        case .rectangle:
            let flutter = 0.35 + 0.65 * abs(cos(flutterFreq * t + phase))
            let w = size * flutter
            let h = size * 1.6
            return Path(CGRect(x: -w / 2, y: -h / 2, width: w, height: h))
        case .circle:
            return Path(ellipseIn: CGRect(x: -size / 2, y: -size / 2, width: size, height: size))
        case .streamer:
            let flutter = 0.4 + 0.6 * abs(cos(flutterFreq * t + phase))
            let w = size * 0.5 * flutter
            let h = size * 3
            return Path(roundedRect: CGRect(x: -w / 2, y: -h / 2, width: w, height: h), cornerRadius: w / 2)
        case .sparkle:
            return Self.sparklePath(size: size)
        }
    }

    /// A concave four-point "twinkle".
    private static func sparklePath(size: Double) -> Path {
        let s = size
        let waist = size * 0.3
        var path = Path()
        path.move(to: CGPoint(x: 0, y: -s))
        path.addQuadCurve(to: CGPoint(x: s, y: 0), control: CGPoint(x: waist, y: -waist))
        path.addQuadCurve(to: CGPoint(x: 0, y: s), control: CGPoint(x: waist, y: waist))
        path.addQuadCurve(to: CGPoint(x: -s, y: 0), control: CGPoint(x: -waist, y: waist))
        path.addQuadCurve(to: CGPoint(x: 0, y: -s), control: CGPoint(x: -waist, y: -waist))
        path.closeSubpath()
        return path
    }

    static func make(style: ConfettiStyle, origin: CGPoint) -> [ConfettiPiece] {
        (0..<style.count).map { _ in
            let angle = Double.random(in: 0..<(2 * .pi))
            let speed = Double.random(in: style.speedRange)
            return ConfettiPiece(
                origin: origin,
                // Bias upward (negative y) so it pops as a fountain before raining down.
                velocity: CGVector(dx: cos(angle) * speed, dy: sin(angle) * speed - style.launchBoost),
                color: style.colors.randomElement() ?? EmberPalette.memoryNeutral,
                shape: style.shapes.randomElement() ?? .rectangle,
                size: Double.random(in: style.sizeRange),
                spin: Double.random(in: -6...6),
                phase: Double.random(in: 0..<(2 * .pi)),
                wobbleAmp: Double.random(in: 6...22),
                wobbleFreq: Double.random(in: 2...5),
                flutterFreq: Double.random(in: 6...11)
            )
        }
    }
}

private enum ConfettiShape {
    case rectangle, circle, streamer, sparkle
}

// MARK: - Per-tier recipes

private struct ConfettiStyle {
    let count: Int
    let colors: [Color]
    let shapes: [ConfettiShape]
    let speedRange: ClosedRange<Double>
    let launchBoost: Double
    let gravity: Double
    let duration: Double
    let sizeRange: ClosedRange<Double>

    /// The reward scales with the tier: untiered is a soft warm puff; diamond is a
    /// wide, long, multi-color sparkle storm.
    static func forTier(_ tier: Tier?) -> ConfettiStyle {
        switch tier {
        case nil:
            ConfettiStyle(
                count: 18,
                colors: [EmberPalette.memoryNeutral, EmberPalette.accent, EmberPalette.gold],
                shapes: [.circle, .rectangle],
                speedRange: 55...150, launchBoost: 70, gravity: 230,
                duration: 1.9, sizeRange: 7...11
            )
        case .bronze:
            ConfettiStyle(
                count: 26,
                colors: [EmberPalette.bronze, EmberPalette.accent, EmberPalette.gold, EmberPalette.memoryNeutral],
                shapes: [.rectangle, .circle],
                speedRange: 65...180, launchBoost: 90, gravity: 250,
                duration: 2.1, sizeRange: 7...12
            )
        case .silver:
            ConfettiStyle(
                count: 34,
                colors: [EmberPalette.silver, EmberPalette.diamond, EmberPalette.accent],
                shapes: [.rectangle, .circle, .sparkle],
                speedRange: 75...200, launchBoost: 105, gravity: 270,
                duration: 2.2, sizeRange: 7...12
            )
        case .gold:
            ConfettiStyle(
                count: 50,
                colors: [EmberPalette.gold, EmberPalette.accent, EmberPalette.memoryNeutral, EmberPalette.bronze],
                shapes: [.rectangle, .streamer, .circle, .sparkle],
                speedRange: 85...230, launchBoost: 125, gravity: 290,
                duration: 2.5, sizeRange: 8...14
            )
        case .diamond:
            ConfettiStyle(
                count: 72,
                colors: [EmberPalette.diamond, EmberPalette.gold, EmberPalette.accent, EmberPalette.silver, EmberPalette.bronze],
                shapes: [.sparkle, .rectangle, .streamer, .circle],
                speedRange: 95...260, launchBoost: 145, gravity: 310,
                duration: 2.8, sizeRange: 8...15
            )
        }
    }
}
