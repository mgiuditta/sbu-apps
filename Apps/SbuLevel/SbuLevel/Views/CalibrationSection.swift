import SbuKit
import SwiftUI

/// Settings section to clear the saved calibration.
struct CalibrationSection: View {
    let model: LevelModel

    var body: some View {
        Section {
            LabeledContent("Stato") {
                Text(model.isCalibrated ? "Calibrata" : "Non calibrata")
                    .foregroundStyle(SbuTheme.inkMuted)
            }

            SbuButton("Azzera calibrazione", kind: .destructive, action: model.resetCalibration)
                .disabled(model.isCalibrated == false)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
        } header: {
            Text("Calibrazione")
        } footer: {
            Text("Appoggia l'iPhone su una superficie in bolla e tocca Calibra. La calibrazione resta su questo iPhone.")
        }
    }
}
