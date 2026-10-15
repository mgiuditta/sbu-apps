import SbuKit
import SwiftUI

/// One saved trip: its times and numbers, and Elimina viaggio.
struct TripDetailView: View {
    let trip: TripRecord
    let log: TripLog
    let unit: SpeedUnit

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            Section {
                LabeledContent("Inizio") {
                    Text(trip.startedAt, format: .dateTime.day().month().year().hour().minute())
                }
                LabeledContent("Fine") {
                    Text(trip.endedAt, format: .dateTime.day().month().year().hour().minute())
                }
            }
            .listRowBackground(SbuTheme.surfaceRaised)

            Section {
                LabeledContent("Distanza", value: unit.distanceText(meters: trip.distance))
                LabeledContent("Durata") {
                    Text(verbatim: Trip.clockText(trip.movingDuration))
                        .accessibilityLabel(Text(verbatim: Trip.spokenText(trip.movingDuration)))
                }
                LabeledContent("Massima", value: unit.speedText(metersPerSecond: trip.maxSpeed))
                LabeledContent("Media", value: unit.speedText(metersPerSecond: trip.averageSpeed))
            } footer: {
                Text("La durata e la media contano solo il tempo in movimento.")
            }
            .listRowBackground(SbuTheme.surfaceRaised)
            .monospacedDigit()

            Section {
                SbuButton("Elimina viaggio", kind: .destructive, confirmationTitle: "Eliminare questo viaggio?", action: delete)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(SbuTheme.surface)
        .navigationTitle(Text(trip.startedAt, format: .dateTime.day().month()))
        .navigationBarTitleDisplayMode(.inline)
    }

    private func delete() {
        log.delete(trip)
        dismiss()
    }
}

#Preview("Light") {
    TripDetailPreview()
}

#Preview("Dark") {
    TripDetailPreview()
        .preferredColorScheme(.dark)
}

private struct TripDetailPreview: View {
    private let log = TripLog(trips: TripLogFile.demo(now: .now).trips)

    var body: some View {
        NavigationStack {
            TripDetailView(trip: log.trips[0], log: log, unit: .kilometersPerHour)
        }
        .tint(SbuTheme.accentSpeed)
    }
}
