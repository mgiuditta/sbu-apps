import SwiftUI

/// The eight names of the moon's phase, each with the SF Symbol iOS uses for it.
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

    var systemImage: String {
        switch self {
        case .new: "moonphase.new.moon"
        case .waxingCrescent: "moonphase.waxing.crescent"
        case .firstQuarter: "moonphase.first.quarter"
        case .waxingGibbous: "moonphase.waxing.gibbous"
        case .full: "moonphase.full.moon"
        case .waningGibbous: "moonphase.waning.gibbous"
        case .lastQuarter: "moonphase.last.quarter"
        case .waningCrescent: "moonphase.waning.crescent"
        }
    }
}
