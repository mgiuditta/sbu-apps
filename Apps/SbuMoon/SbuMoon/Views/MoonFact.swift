import SwiftUI

/// One row of a card under the moon: what it is, and its value already formatted.
struct MoonFact: Identifiable {
    let id: String
    let label: LocalizedStringKey
    let value: Text
}
