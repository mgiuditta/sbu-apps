import SbuKit
import SwiftUI

/// Settings section for the calibration: the state of each side, Calibra, and a reset per side.
struct CalibrationSection: View {
    let model: LevelModel

    @State private var isCalibrating = false
    @State private var isConfirmingReset = false

    var body: some View {
        Section {
            ForEach(CalibrationTarget.allCases, id: \.self) { target in
                LabeledContent {
                    Text(model.calibration.isCalibrated(target) ? "Calibrata" : "Non calibrata")
                        .foregroundStyle(SbuTheme.inkMuted)
                } label: {
                    Text(target.name)
                }
            }

            Button("Calibra", action: calibrate)
                .disabled(model.isMotionAvailable == false)

            // A plain row, not a full-width button: a rare action should not outweigh the page.
            if model.isCalibrated {
                Button("Ripristina calibrazione", role: .destructive, action: confirmReset)
                    .foregroundStyle(SbuTheme.danger)
                    .confirmationDialog("Ripristina calibrazione", isPresented: $isConfirmingReset, titleVisibility: .visible) {
                        ForEach(model.calibration.calibratedTargets, id: \.self) { target in
                            Button(role: .destructive) {
                                model.resetCalibration(target)
                            } label: {
                                Text(target.name)
                            }
                        }
                        if model.calibration.calibratedTargets.count > 1 {
                            Button("Tutti i lati", role: .destructive) {
                                model.resetCalibration()
                            }
                        }
                    } message: {
                        Text("Il lato torna alla lettura del sensore senza correzioni.")
                    }
            }
        } header: {
            Text("Calibrazione")
        } footer: {
            Text("Ogni lato si calibra a parte, in due misure. La calibrazione resta su questo iPhone.")
        }
        .sheet(isPresented: $isCalibrating, onDismiss: model.endCalibration) {
            CalibrationSheet(model: model)
        }
    }

    private func calibrate() {
        model.startCalibration()
        isCalibrating = true
    }

    private func confirmReset() {
        isConfirmingReset = true
    }
}

#Preview("Light") {
    List {
        CalibrationSection(model: LevelModel(source: FixedGravitySource.screenshot))
    }
}

#Preview("Dark") {
    List {
        CalibrationSection(model: LevelModel(source: FixedGravitySource.screenshot))
    }
    .preferredColorScheme(.dark)
}
