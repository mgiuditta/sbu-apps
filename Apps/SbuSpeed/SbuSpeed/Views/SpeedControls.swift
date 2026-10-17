import SbuKit
import SwiftUI
import UIKit

/// The pills under the figure, Salva e azzera and Parabrezza, then the quick limits; Apri
/// Impostazioni instead when only the Settings app can give the position.
struct SpeedControls: View {
    let model: SpeedModel
    /// Opens Parabrezza, the mirrored HUD.
    let showHUD: () -> Void
    /// Called when Salva e azzera kept the trip in Viaggi.
    let didSaveTrip: () -> Void

    @Environment(\.openURL) private var openURL
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var isConfirmingReset = false

    /// Salva e azzera when the trip went somewhere, Azzera viaggio when there is nothing to keep.
    private var resetTitle: LocalizedStringKey {
        model.canSaveTrip ? "Salva e azzera" : "Azzera viaggio"
    }

    /// Side by side, one under the other at accessibility text sizes, where two pills do not fit a row.
    private var pillsLayout: AnyLayout {
        dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: SbuTheme.space2))
            : AnyLayout(HStackLayout(spacing: SbuTheme.space2))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: SbuTheme.space6) {
            pillsLayout {
                if model.status.needsSettings {
                    Button("Apri Impostazioni", action: openSettings)
                        .buttonStyle(SbuFieldPillStyle())
                } else {
                    // A pill like the others, not a full-width red button: a rare action stays light.
                    Button(resetTitle) {
                        isConfirmingReset = true
                    }
                    .buttonStyle(SbuFieldPillStyle())
                    .disabled(model.trip.isEmpty)
                    .confirmationDialog(resetTitle, isPresented: $isConfirmingReset, titleVisibility: .visible) {
                        Button(resetTitle, role: .destructive, action: resetTrip)
                    } message: {
                        Text(model.canSaveTrip ? "Il viaggio va in Viaggi e riparte da zero." : "Il viaggio riparte da zero.")
                    }

                    Button("Parabrezza", action: showHUD)
                        .buttonStyle(SbuFieldPillStyle())
                }
            }

            QuickLimitPills(model: model)
        }
    }

    private func resetTrip() {
        // Once per trip: only a trip that went into Viaggi is closed by Salvato.
        if model.saveAndResetTrip() {
            didSaveTrip()
        }
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            openURL(url)
        }
    }
}

#Preview("Light") {
    SpeedControls(model: SpeedModel(), showHUD: {}, didSaveTrip: {})
        .padding(SbuTheme.space4)
        .frame(maxHeight: .infinity, alignment: .top)
        .sbuPaper()
}

#Preview("Dark") {
    SpeedControls(model: SpeedModel(), showHUD: {}, didSaveTrip: {})
        .padding(SbuTheme.space4)
        .frame(maxHeight: .infinity, alignment: .top)
        .sbuPaper()
        .preferredColorScheme(.dark)
}
