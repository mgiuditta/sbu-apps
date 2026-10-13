import Foundation

/// The four instants of a lunation that have a date: new moon, the quarters and full moon.
nonisolated enum PrincipalPhase: CaseIterable, Sendable {
    case new
    case firstQuarter
    case full
    case lastQuarter

    /// Fraction of a lunation after the new moon, as Meeus adds it to the lunation number `k`.
    var lunationOffset: Double {
        switch self {
        case .new: 0
        case .firstQuarter: 0.25
        case .full: 0.5
        case .lastQuarter: 0.75
        }
    }

    /// How the phase is saved in the settings and named in notification identifiers.
    var storageKey: String {
        switch self {
        case .new: "new"
        case .firstQuarter: "firstQuarter"
        case .full: "full"
        case .lastQuarter: "lastQuarter"
        }
    }

    /// The phase's name as text, for a notification.
    var localizedName: String {
        switch self {
        case .new: String(localized: "Luna nuova")
        case .firstQuarter: String(localized: "Primo quarto")
        case .full: String(localized: "Luna piena")
        case .lastQuarter: String(localized: "Ultimo quarto")
        }
    }

    /// The phase shown on the day this instant falls.
    var phase: MoonPhase {
        switch self {
        case .new: .new
        case .firstQuarter: .firstQuarter
        case .full: .full
        case .lastQuarter: .lastQuarter
        }
    }

    /// The phase shown on the days after this instant, until the next principal phase.
    var following: MoonPhase {
        switch self {
        case .new: .waxingCrescent
        case .firstQuarter: .waxingGibbous
        case .full: .waningGibbous
        case .lastQuarter: .waningCrescent
        }
    }
}
