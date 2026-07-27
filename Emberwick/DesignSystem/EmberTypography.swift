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

    // Display / headings
    static let title = Font.system(size: 28, weight: .heavy, design: displayDesign)
    static let heading = Font.system(size: 24, weight: .bold, design: displayDesign)
    static let entryTitle = Font.system(size: 16.5, weight: .semibold, design: displayDesign)

    // Body
    static let body = Font.system(size: 14, weight: .regular, design: bodyDesign)
    static let subtitle = Font.system(size: 13.5, weight: .regular, design: bodyDesign)
    static let caption = Font.system(size: 12, weight: .medium, design: bodyDesign)
    static let legend = Font.system(size: 11.5, weight: .medium, design: bodyDesign)
}
