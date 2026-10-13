import SbuKit
import SwiftUI
import UIKit

/// The tool screen: the angle as the figure, the clinometer dial or bubble, and the Calibra and Blocca pills.
struct MainView: View {
    private static let format = FloatingPointFormatStyle<Double>.number.precision(.fractionLength(1))

    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let model: LevelModel

    @State private var isCalibrating = false

    private var context: LocalizedStringKey {
        if model.isLocked {
            "Lettura bloccata"
        } else if model.reading.isLevel {
            "In bolla"
        } else if model.reading.mode == .flat {
            "In piano"
        } else {
            "Sul bordo"
        }
    }

    private var pillsLayout: AnyLayout {
        dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(spacing: SbuTheme.space2))
            : AnyLayout(HStackLayout(spacing: SbuTheme.space2))
    }

    private var keepsScreenOn: Bool {
        model.isMotionAvailable && model.keepsScreenOn(isActive: scenePhase == .active)
    }

    var body: some View {
        Group {
            if model.isMotionAvailable {
                SbuToolField(
                    "Inclinazione",
                    value: model.reading.displayedAngle,
                    format: Self.format,
                    unit: "°",
                    context: context,
                    contextSystemImage: model.isLocked ? "lock.fill" : nil
                ) {
                    LevelIndicator(reading: model.reading)
                        .frame(maxWidth: 320)
                } pills: {
                    // Side by side, or stacked with accessibility text sizes, where they would break the words.
                    pillsLayout {
                        LevelPills(isLocked: model.isLocked, calibrate: calibrate, toggleLock: toggleLock)
                    }
                }
            } else {
                // No figure and no controls: a 0,0 or a Calibra here would promise a reading there isn't.
                SbuToolField("Inclinazione", context: "Sensore di movimento non disponibile") {
                    EmptyView()
                } pills: {
                    EmptyView()
                }
            }
        }
        .sensoryFeedback(.success, trigger: model.reading.isLevel) { _, isLevel in isLevel }
        .sheet(isPresented: $isCalibrating, onDismiss: model.endCalibration) {
            CalibrationSheet(model: model)
        }
        .onChange(of: keepsScreenOn, initial: true) { _, keepsOn in
            UIApplication.shared.isIdleTimerDisabled = keepsOn
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }
        .task {
            await model.run()
        }
    }

    private func calibrate() {
        model.startCalibration()
        isCalibrating = true
    }

    private func toggleLock() {
        model.toggleLock()
        let message = if model.isLocked {
            String(localized: "Lettura bloccata, \(model.reading.displayedAngle.formatted(Self.format))°")
        } else {
            String(localized: "Lettura sbloccata")
        }
        AccessibilityNotification.Announcement(message).post()
    }
}

#Preview("Light") {
    MainView(model: LevelModel(source: FixedGravitySource.screenshot))
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentLevel)
}

#Preview("Dark") {
    MainView(model: LevelModel(source: FixedGravitySource(gravity: .lying(tiltedBy: 3))))
        .background(SbuTheme.surface)
        .tint(SbuTheme.accentLevel)
        .preferredColorScheme(.dark)
}
