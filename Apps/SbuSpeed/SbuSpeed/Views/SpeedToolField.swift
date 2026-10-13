import SbuKit
import SwiftUI
import UIKit

/// The speed as the figure with its context line, what goes under it, and the pills.
struct SpeedToolField<Indicator: View>: View {
    let model: SpeedModel
    /// Drawn under the figure: the dial and the trip in portrait, nothing in landscape where they sit beside.
    @ViewBuilder let indicator: Indicator

    @Environment(\.openURL) private var openURL
    @State private var isConfirmingReset = false

    private var context: LocalizedStringKey {
        if model.isOverLimit, let limit = model.speedLimit {
            return "Oltre il limite di \(limit.text())"
        }
        return switch model.status {
        case .needsAccess: "Consenti la posizione"
        case .denied: "Posizione non consentita"
        case .approximate: "Serve la posizione esatta"
        case .searching: "Cerco il segnale GPS"
        case .still: "Fermo"
        case .moving: "In movimento"
        }
    }

    var body: some View {
        SbuToolField(
            "Velocità",
            value: model.speed,
            format: SpeedFigureStyle(unit: model.unit),
            unit: model.unit.symbol,
            context: context,
            contextSystemImage: model.isOverLimit ? "exclamationmark.triangle" : nil,
            contextTone: model.isOverLimit ? .danger : .neutral
        ) {
            indicator
        } pills: {
            if model.status.needsSettings {
                Button("Apri Impostazioni", action: openSettings)
                    .buttonStyle(SbuFieldPillStyle())
            } else {
                // A pill like the others, not a full-width red button: a rare action stays light.
                Button("Azzera viaggio") {
                    isConfirmingReset = true
                }
                .buttonStyle(SbuFieldPillStyle())
                .disabled(model.trip.isEmpty)
                .confirmationDialog("Azzera viaggio", isPresented: $isConfirmingReset, titleVisibility: .visible) {
                    Button("Azzera viaggio", role: .destructive, action: model.resetTrip)
                } message: {
                    Text("Il viaggio riparte da zero.")
                }
            }
        }
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            openURL(url)
        }
    }
}

#Preview("Light") {
    SpeedToolField(model: SpeedModel()) {
        EmptyView()
    }
    .background(SbuTheme.surface)
    .tint(SbuTheme.accentSpeed)
}

#Preview("Dark") {
    SpeedToolField(model: SpeedModel()) {
        EmptyView()
    }
    .background(SbuTheme.surface)
    .tint(SbuTheme.accentSpeed)
    .preferredColorScheme(.dark)
}
