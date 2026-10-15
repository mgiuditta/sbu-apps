import SwiftUI

extension LevelStatus {
    /// The words, for the context line of the tool screen.
    var text: LocalizedStringKey {
        switch self {
        case .locked(isRelative: true): "Lettura bloccata, relativa"
        case .locked(isRelative: false): "Lettura bloccata"
        case .relative(atZero: true): "Relativo, allo zero"
        case .relative(atZero: false): "Relativo"
        case .level: "In bolla"
        case .flat: "In piano"
        case .edge: "Sul bordo"
        case .aboveHorizon: "Sopra l'orizzonte"
        case .belowHorizon: "Sotto l'orizzonte"
        case .onHorizon: "All'orizzonte"
        case .cameraUnavailable: "Fotocamera non disponibile"
        case .cameraDenied: "Fotocamera non consentita"
        }
    }
}
