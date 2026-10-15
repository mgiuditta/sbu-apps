import SbuKit
import SwiftUI

/// Under the odometer: the entry the reading clashes with, or the last reading as a hint.
struct OdometerFooter: View {
    let problem: FuelUpDraft.Problem?
    let lastKm: Double?
    let unit: DistanceUnit

    var body: some View {
        if case let .conflict(conflict) = problem {
            ProblemLabel(text: message(conflict))
        } else if let lastKm {
            Text("Ultima lettura: \(unit.formatted(km: lastKm))")
        }
    }

    private func message(_ conflict: OdometerConflict) -> Text {
        let reading = conflict.reading
        let date = reading.date.formatted(.dateTime.day().month(.abbreviated).year())
        let km = unit.formatted(km: reading.km)
        switch conflict {
        case .earlierIsHigher: return Text("\(date): il contachilometri segnava già \(km). Controlla la lettura o la data.")
        case .laterIsLower: return Text("\(date): il contachilometri segnava \(km), meno di questa lettura. Controlla la lettura o la data.")
        case .sameReading: return Text("Un altro rifornimento ha già questa lettura (\(date)).")
        }
    }
}

#Preview("Light") {
    Form {
        Section {
        } footer: {
            OdometerFooter(problem: nil, lastKm: 45_210, unit: .kilometres)
        }
    }
}

#Preview("Dark") {
    Form {
        Section {
        } footer: {
            OdometerFooter(problem: .conflict(.earlierIsHigher(OdometerReading(id: UUID(), date: .now, km: 45_210, source: .fuelUp))),
                           lastKm: nil, unit: .kilometres)
        }
    }
    .preferredColorScheme(.dark)
}
