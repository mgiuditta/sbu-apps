import SbuKit
import SwiftUI
import UIKit

/// The tool screen: the angle as the figure, the clinometer dial or bubble, and the Calibra and Blocca pills.
struct MainView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let model: LevelModel

    @State private var isCalibrating = false

    private var context: LocalizedStringKey {
        if model.isLocked {
            "Lettura bloccata"
        } else if model.readout.isLevel {
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

    private var format: AngleFormatStyle { AngleFormatStyle(unit: model.unit) }

    private var keepsScreenOn: Bool {
        model.isMotionAvailable && model.keepsScreenOn(isActive: scenePhase == .active)
    }

    var body: some View {
        Group {
            if model.isMotionAvailable {
                SbuToolField(
                    "Inclinazione",
                    value: model.readout.angle,
                    format: format,
                    unit: model.unit.symbol,
                    spokenValue: Text(verbatim: format.spokenText(model.readout.angle)),
                    context: context,
                    contextSystemImage: model.isLocked ? "lock.fill" : nil
                ) {
                    VStack(spacing: SbuTheme.space4) {
                        LevelIndicator(reading: model.reading)
                            .frame(maxWidth: 320)

                        // Always laid out, so the dial does not jump when the iPhone lies down.
                        BubbleAxes(tiltX: model.reading.tiltX, tiltY: model.reading.tiltY, unit: model.unit)
                            .opacity(model.reading.mode == .flat ? 1 : 0)
                            .accessibilityHidden(model.reading.mode != .flat)
                    }
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
        .sensoryFeedback(.success, trigger: model.readout.isLevel) { _, isLevel in isLevel }
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
            String(localized: "Lettura bloccata, \(format.spokenText(model.readout.angle))")
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
