import SwiftUI

/// The eight names of the moon's phase.
nonisolated enum MoonPhase: CaseIterable, Sendable {
    case new
    case waxingCrescent
    case firstQuarter
    case waxingGibbous
    case full
    case waningGibbous
    case lastQuarter
    case waningCrescent

    var name: LocalizedStringKey {
        switch self {
        case .new: "Luna nuova"
        case .waxingCrescent: "Luna crescente"
        case .firstQuarter: "Primo quarto"
        case .waxingGibbous: "Gibbosa crescente"
        case .full: "Luna piena"
        case .waningGibbous: "Gibbosa calante"
        case .lastQuarter: "Ultimo quarto"
        case .waningCrescent: "Luna calante"
        }
    }
}
