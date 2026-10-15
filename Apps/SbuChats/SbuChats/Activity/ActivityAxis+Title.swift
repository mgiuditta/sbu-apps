import Foundation

extension ActivityAxis {
    /// The name in the segmented control.
    var title: LocalizedStringResource {
        switch self {
        case .hour: "Ora"
        case .weekday: "Giorno"
        case .month: "Mese"
        case .year: "Anno"
        }
    }

    /// What the chart shows, for VoiceOver.
    var chartTitle: LocalizedStringResource {
        switch self {
        case .hour: "Messaggi per ora del giorno"
        case .weekday: "Messaggi per giorno della settimana"
        case .month: "Messaggi per mese"
        case .year: "Messaggi per anno"
        }
    }
}
