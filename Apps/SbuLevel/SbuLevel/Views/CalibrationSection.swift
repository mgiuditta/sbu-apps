import SbuKit
import SwiftUI

/// Settings section to clear the saved calibration.
struct CalibrationSection: View {
    let model: LevelModel

    @State private var isConfirmingReset = false

    var body: some View {
        Section {
            LabeledContent("Stato") {
                Text(model.isCalibrated ? "Calibrata" : "Non calibrata")
                    .foregroundStyle(SbuTheme.inkMuted)
            }

            // A plain row, not a full-width button: a rare action should not outweigh the page.
            if model.isCalibrated {
                Button("Azzera calibrazione", role: .destructive) {
                    isConfirmingReset = true
                }
                .foregroundStyle(SbuTheme.danger)
                .confirmationDialog("Azzera calibrazione", isPresented: $isConfirmingReset, titleVisibility: .visible) {
                    Button("Azzera calibrazione", role: .destructive, action: model.resetCalibration)
                }
            }
        } header: {
            Text("Calibrazione")
        } footer: {
            Text("Appoggia l'iPhone su una superficie in bolla e tocca Calibra. La calibrazione resta su questo iPhone.")
        }
    }
}
