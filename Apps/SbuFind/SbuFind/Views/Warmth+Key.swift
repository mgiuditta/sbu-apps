import SwiftUI

extension Warmth {
    /// The word as a key for the finder's context line, which takes a `LocalizedStringKey`.
    var key: LocalizedStringKey {
        switch self {
        case .cold: "Freddo"
        case .warm: "Tiepido"
        case .hot: "Caldo"
        case .veryClose: "Qui vicino"
        }
    }
}
