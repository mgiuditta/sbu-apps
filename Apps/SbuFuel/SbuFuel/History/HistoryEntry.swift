import Foundation

/// A fuel-up or a service in the history, newest first.
enum HistoryEntry: Identifiable {
    case fuel(FuelUp)
    case service(ServiceEntry)

    var id: UUID {
        switch self {
        case let .fuel(fuelUp): fuelUp.id
        case let .service(service): service.id
        }
    }

    var date: Date {
        switch self {
        case let .fuel(fuelUp): fuelUp.date
        case let .service(service): service.date
        }
    }

    var odometerKm: Double {
        switch self {
        case let .fuel(fuelUp): fuelUp.odometerKm
        case let .service(service): service.odometerKm ?? 0
        }
    }

    /// The entries of a vehicle, newest first by date then by odometer, grouped by month.
    static func months(_ vehicle: Vehicle, filter: HistoryFilter, calendar: Calendar) -> [(month: Date, entries: [HistoryEntry])] {
        var entries: [HistoryEntry] = []
        if filter != .services { entries += (vehicle.fuelUps ?? []).map(HistoryEntry.fuel) }
        if filter != .fuel { entries += (vehicle.services ?? []).map(HistoryEntry.service) }
        let sorted = entries.sorted { lhs, rhs in
            let left = calendar.startOfDay(for: lhs.date), right = calendar.startOfDay(for: rhs.date)
            return left != right ? left > right : lhs.odometerKm > rhs.odometerKm
        }
        var months: [(month: Date, entries: [HistoryEntry])] = []
        for entry in sorted {
            let month = calendar.dateInterval(of: .month, for: entry.date)?.start ?? entry.date
            if months.last?.month == month {
                months[months.count - 1].entries.append(entry)
            } else {
                months.append((month, [entry]))
            }
        }
        return months
    }
}
