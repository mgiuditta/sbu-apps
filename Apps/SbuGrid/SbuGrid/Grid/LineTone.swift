import SwiftUI

/// The color of the grid lines: dark or light, whichever stands out on the photo.
///
/// DrawinGrid has a free color picker; the design system has no invented colors, so the line is
/// `ink` (the logo's warm black) or `surface` (paper), always in their light values: a dark line
/// stays dark when the iPhone is in dark mode.
nonisolated enum LineTone: String, Codable, CaseIterable, Identifiable, Sendable {
    case dark
    case light

    var id: Self { self }

    /// The opposite tone, behind the row and column numbers so they read on any photo.
    var opposite: LineTone {
        switch self {
        case .dark: .light
        case .light: .dark
        }
    }

    var title: LocalizedStringResource {
        switch self {
        case .dark: "Scura"
        case .light: "Chiara"
        }
    }
}
