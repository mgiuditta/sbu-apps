import SbuKit
import SwiftUI

/// Viaggi: the trips kept by Salva e azzera, newest first, with Esporta CSV.
/// Swiping a trip deletes it after a confirmation; tapping it opens its detail.
struct TripLogView: View {
    let log: TripLog
    let unit: SpeedUnit

    @State private var pendingDeletion: TripRecord?

    private var isConfirmingDeletion: Binding<Bool> {
        Binding { pendingDeletion != nil } set: { if !$0 { pendingDeletion = nil } }
    }

    var body: some View {
        List {
            if !log.trips.isEmpty {
                Section {
                    ForEach(log.trips) { trip in
                        NavigationLink {
                            TripDetailView(trip: trip, log: log, unit: unit)
                        } label: {
                            TripRow(trip: trip, unit: unit)
                        }
                        .accessibilityIdentifier("trip")
                        .listRowBackground(SbuTheme.surfaceRaised)
                        .swipeActions {
                            Button("Elimina", systemImage: "trash", role: .destructive) {
                                pendingDeletion = trip
                            }
                        }
                    }
                } footer: {
                    Text("Solo numeri e orari: nessuna posizione.")
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(SbuTheme.surface)
        .overlay {
            if log.trips.isEmpty {
                ContentUnavailableView {
                    Label("Nessun viaggio", systemImage: "road.lanes")
                } description: {
                    Text("Salva e azzera un viaggio per trovarlo qui.")
                }
            }
        }
        .navigationTitle("Viaggi")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(
                    item: TripLogCSV(trips: log.trips, unit: unit, date: .now),
                    preview: SharePreview(Text("Viaggi"))
                ) {
                    Label("Esporta CSV", systemImage: "square.and.arrow.up")
                }
                .tint(SbuTheme.ink)
                .disabled(log.trips.isEmpty)
            }
        }
        .confirmationDialog("Eliminare questo viaggio?", isPresented: isConfirmingDeletion, titleVisibility: .visible, presenting: pendingDeletion) { trip in
            Button("Elimina viaggio", role: .destructive) {
                log.delete(trip)
            }
        }
    }
}

#Preview("Light") {
    NavigationStack {
        TripLogView(log: TripLog(trips: TripLogFile.demo(now: .now).trips), unit: .kilometersPerHour)
    }
    .tint(SbuTheme.accentSpeed)
}

#Preview("Dark") {
    NavigationStack {
        TripLogView(log: TripLog(trips: TripLogFile.demo(now: .now).trips), unit: .kilometersPerHour)
    }
    .tint(SbuTheme.accentSpeed)
    .preferredColorScheme(.dark)
}

#Preview("Vuoto") {
    NavigationStack {
        TripLogView(log: TripLog(trips: []), unit: .kilometersPerHour)
    }
    .tint(SbuTheme.accentSpeed)
}
