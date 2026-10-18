import SbuKit
import SwiftUI

/// The colors of the pieces: the accents of eight sbu.dev apps (ADR-0015, as amended 18/10).
enum PieceTone {
    private static let accents: [SbuAccent] = [.subscriptions, .scanner, .habits, .clean, .moon, .level, .libretto, .tidy]

    static func color(_ tone: Int) -> Color {
        accents[tone % accents.count].base
    }
}
