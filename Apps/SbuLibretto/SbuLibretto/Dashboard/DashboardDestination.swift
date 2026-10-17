import SwiftUI

/// The parts of the libretto the tool screen opens, in the order of its card.
enum DashboardDestination: String, CaseIterable, Identifiable {
    case simulate
    case studyPlan
    case upcoming
    case timetable

    /// Also the row's accessibility identifier.
    var id: String { rawValue }

    var title: LocalizedStringKey {
        switch self {
        case .simulate: "Simula esame"
        case .studyPlan: "Piano di studi"
        case .upcoming: "Prossimi appelli"
        case .timetable: "Orario lezioni"
        }
    }

    var systemImage: String {
        switch self {
        case .simulate: "chart.line.uptrend.xyaxis"
        case .studyPlan: "list.bullet.rectangle"
        case .upcoming: "calendar"
        case .timetable: "clock"
        }
    }
}
