import SbuKit
import SwiftUI
import UIKit

/// The tool screen: the speed as the figure, the dial, the trip, and Azzera viaggio.
struct MainView: View {
    let model: SpeedModel

    @Environment(\.openURL) private var openURL

    private var context: LocalizedStringKey {
        switch model.status {
        case .needsAccess: "Consenti la posizione"
        case .denied: "Posizione non consentita"
        case .approximate: "Serve la posizione esatta"
        case .searching: "Cerco il segnale GPS"
        case .still: "Fermo"
        case .moving: "In movimento"
        }
    }

    private var gaugeFraction: Double {
        guard let speed = model.speed else { return 0 }
        return model.unit.value(ofMetersPerSecond: speed) / model.unit.fullScale
    }

    var body: some View {
        SbuToolField(
            "Velocità",
            value: model.speed,
            format: SpeedFigureStyle(unit: model.unit),
            unit: model.unit.symbol,
            context: context
        ) {
            VStack(spacing: SbuTheme.space6) {
                SpeedGauge(fraction: gaugeFraction)
                    .frame(maxWidth: 240)

                TripSummary(trip: model.trip, unit: model.unit)
            }
        } pills: {
            if model.status.needsSettings {
                Button("Apri Impostazioni", action: openSettings)
                    .buttonStyle(SbuFieldPillStyle())
            } else {
                SbuButton("Azzera viaggio", kind: .destructive, action: model.resetTrip)
                    .disabled(model.trip.isEmpty)
            }
        }
        // A speedometer is read at a glance: the screen stays on while it is shown.
        .onAppear { UIApplication.shared.isIdleTimerDisabled = true }
        .onDisappear { UIApplication.shared.isIdleTimerDisabled = false }
        .task {
            await model.run()
        }
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            openURL(url)
        }
    }
}

#Preview("Light") {
    MainView(model: SpeedModel())
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentSpeed)
}

#Preview("Dark") {
    MainView(model: SpeedModel())
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentSpeed)
        .preferredColorScheme(.dark)
}
