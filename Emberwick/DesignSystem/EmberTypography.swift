//
//  EmberTypography.swift
//  Emberwick
//
//  Semantic font tokens. The spec calls for Gabarito (display) + DM Sans (body);
//  until those custom fonts are bundled we stand in with the system rounded design,
//  which reads warm and grown-up (not a serif). Swapping in the real families later
//  means changing only this file.
//

import SwiftUI

enum EmberTypography {
    /// Stand-in design for the display family (Gabarito).
    private static let displayDesign: Font.Design = .rounded
    /// Stand-in design for the body family (DM Sans).
    private static let bodyDesign: Font.Design = .rounded

    // Built on semantic text styles (not fixed point sizes) so every label scales
    // with the user's Dynamic Type setting. The chosen styles match the spec's
    // intended sizes at the default content size.

    // Display / headings
    static let title = Font.system(.title, design: displayDesign, weight: .heavy)         // ~28
    static let heading = Font.system(.title2, design: displayDesign, weight: .bold)        // ~22
    static let entryTitle = Font.system(.callout, design: displayDesign, weight: .semibold) // ~16

    // Body
    static let body = Font.system(.subheadline, design: bodyDesign)                        // ~15
    static let subtitle = Font.system(.footnote, design: bodyDesign)                       // ~13
    static let caption = Font.system(.caption, design: bodyDesign, weight: .medium)        // ~12
    static let legend = Font.system(.caption2, design: bodyDesign, weight: .medium)        // ~11
}
