import Foundation

/// One row of an imported file, ready to be saved.
nonisolated enum ImportedEntry: Equatable, Sendable {
    case fuel(FillRecord, station: String, note: String)
    case service(title: String, date: Date, odometerKm: Double?, cost: Decimal, note: String)

    var date: Date {
        switch self {
        case let .fuel(record, _, _): record.date
        case let .service(_, date, _, _, _): date
        }
    }
}
