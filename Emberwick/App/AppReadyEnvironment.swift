//
//  AppReadyEnvironment.swift
//  Emberwick
//
//  True once the app is actually on screen for the user — i.e. the splash has
//  faded, no first-run cover (onboarding / birthday) is up, and the guided tour
//  isn't running. The grid uses this to hold its intro flight until it would be
//  visible, instead of burning it off behind the splash.
//
//  Defaults to `true` so previews and any other host behave normally.
//

import SwiftUI

extension EnvironmentValues {
    @Entry var emberAppReady: Bool = true
}
