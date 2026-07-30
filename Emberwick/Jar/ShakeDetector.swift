//
//  ShakeDetector.swift
//  Emberwick
//
//  Detects a device shake via CoreMotion while the Jar is on screen. Fires `onShake`
//  once per shake, with a short cooldown so one wobble doesn't trigger repeatedly.
//  (No accelerometer in the simulator — use the on-screen "Shake" button there.)
//

import CoreMotion
import Foundation

@Observable
final class ShakeDetector {
    var onShake: () -> Void = {}

    @ObservationIgnored private let motion = CMMotionManager()
    @ObservationIgnored private var lastFired = Date.distantPast
    @ObservationIgnored private let threshold = 2.4      // g-force sum over 1
    @ObservationIgnored private let cooldown = 1.0       // seconds

    func start() {
        guard motion.isAccelerometerAvailable, !motion.isAccelerometerActive else { return }
        motion.accelerometerUpdateInterval = 1.0 / 30.0
        motion.startAccelerometerUpdates(to: .main) { [weak self] data, _ in
            guard let self, let acceleration = data?.acceleration else { return }
            let magnitude = abs(acceleration.x) + abs(acceleration.y) + abs(acceleration.z)
            if magnitude > self.threshold, Date.now.timeIntervalSince(self.lastFired) > self.cooldown {
                self.lastFired = .now
                self.onShake()
            }
        }
    }

    func stop() {
        if motion.isAccelerometerActive {
            motion.stopAccelerometerUpdates()
        }
    }
}
