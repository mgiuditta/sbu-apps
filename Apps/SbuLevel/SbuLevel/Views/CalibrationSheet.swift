import SbuKit
import SwiftUI

/// The guided two-step calibration of the side the iPhone rests on: measure, turn 180°, measure again.
struct CalibrationSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let model: LevelModel

    private var session: CalibrationSession {
        model.calibrationSession ?? CalibrationSession()
    }

    /// The side being calibrated: fixed by the first reading, live before it.
    private var side: CalibrationTarget {
        session.target ?? model.liveReading.calibrationTarget
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    LabeledContent("Lato") {
                        Text(side.name)
                            .foregroundStyle(SbuTheme.inkMuted)
                    }
                } footer: {
                    Text("Il lato si riconosce da come appoggi l'iPhone: un bordo, oppure il retro per la bolla.")
                }
                .listRowBackground(SbuTheme.surfaceRaised)

                CalibrationStepSection(session: session, measure: model.captureCalibrationStep, calibrateAnother: model.startCalibration)
                    .listRowBackground(SbuTheme.surfaceRaised)
            }
            .scrollContentBackground(.hidden)
            .background(SbuTheme.surface)
            .navigationTitle("Calibrazione")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if session.step == .done {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Fine", action: close)
                    }
                } else {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Annulla", action: close)
                    }
                }
            }
        }
        // Half height keeps the dial in sight; with accessibility text sizes the steps need the room.
        .presentationDetents(dynamicTypeSize.isAccessibilitySize ? [.large] : [.medium, .large])
    }

    private func close() {
        dismiss()
    }
}

#Preview("Light") {
    CalibrationSheetPreview()
}

#Preview("Dark") {
    CalibrationSheetPreview()
        .preferredColorScheme(.dark)
}

private struct CalibrationSheetPreview: View {
    @State private var model = LevelModel(source: FixedGravitySource.screenshot)

    var body: some View {
        Color.clear
            .sheet(isPresented: .constant(true)) {
                CalibrationSheet(model: model)
            }
            .task {
                model.startCalibration()
                await model.run()
            }
            .tint(SbuTheme.accentLevel)
    }
}
