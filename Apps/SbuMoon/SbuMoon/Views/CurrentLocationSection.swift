import SbuKit
import SwiftUI

/// The first section of the place sheet: use the iPhone's position, and what went wrong if it
/// could not be read.
struct CurrentLocationSection: View {
    let state: PlaceModel.LocationState
    let isSelected: Bool
    let useCurrentLocation: () -> Void
    let openSettings: () -> Void

    var body: some View {
        Section {
            Button(action: useCurrentLocation) {
                HStack(spacing: SbuTheme.space3) {
                    Image(systemName: "location")
                        .fontWeight(.medium)
                        .imageScale(.medium)
                        .accessibilityHidden(true)

                    Text("Usa la mia posizione")
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if state == .locating {
                        ProgressView()
                    } else if isSelected {
                        Image(systemName: "checkmark")
                            .fontWeight(.medium)
                            .imageScale(.medium)
                            .foregroundStyle(.tint)
                            .accessibilityHidden(true)
                    }
                }
            }
            .disabled(state == .locating)
            .accessibilityAddTraits(isSelected ? .isSelected : [])
            .accessibilityIdentifier("useCurrentLocation")

            if state == .denied {
                Button("Apri Impostazioni", action: openSettings)
            }
        } footer: {
            switch state {
            case .denied:
                Text("La posizione è disattivata per Sbu Moon. Attivala nelle Impostazioni dell'iPhone, o scegli una città.")
            case .unavailable:
                Text("Posizione non trovata. Riprova all'aperto, o scegli una città.")
            case .idle, .locating:
                Text("Letta una volta, con la precisione di un chilometro. Resta su questo iPhone.")
            }
        }
    }
}

#Preview("Light") {
    CurrentLocationPreview()
}

#Preview("Dark") {
    CurrentLocationPreview()
        .preferredColorScheme(.dark)
}

private struct CurrentLocationPreview: View {
    var body: some View {
        List {
            CurrentLocationSection(state: .idle, isSelected: true, useCurrentLocation: {}, openSettings: {})
            CurrentLocationSection(state: .denied, isSelected: false, useCurrentLocation: {}, openSettings: {})
            CurrentLocationSection(state: .unavailable, isSelected: false, useCurrentLocation: {}, openSettings: {})
        }
        .tint(SbuTheme.ink)
    }
}
