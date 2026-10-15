import SbuKit
import SwiftUI
import UIKit

/// The tool screen: the angle as the figure, the clinometer dial or bubble, Calibra in the bar
/// as in Clinometer, and the Azzera qui and Blocca pills.
struct MainView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let model: LevelModel

    @State private var isCalibrating = false

    private var context: LocalizedStringKey {
        if model.isLocked {
            model.readout.isRelative ? "Lettura bloccata, relativa" : "Lettura bloccata"
        } else if model.readout.isRelative {
            model.readout.isLevel ? "Relativo, allo zero" : "Relativo"
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
                        LevelPills(isRelative: model.readout.isRelative, isLocked: model.isLocked, toggleReference: toggleReference, toggleLock: toggleLock)
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
        .toolbar {
            // Without a motion sensor there is nothing to calibrate.
            if model.isMotionAvailable {
                ToolbarItem(placement: .topBarLeading) {
                    // A symbol in ink, like the gear: the accent belongs to the figure's full stop, and
                    // a symbol in the bar shows in the large content viewer at any text size.
                    Button("Calibra", systemImage: "level", action: calibrate)
                        .tint(SbuTheme.ink)
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

    private func toggleReference() {
        model.toggleReference()
        let message = if model.readout.isRelative {
            String(localized: "Angolo relativo: zero qui")
        } else {
            String(localized: "Angolo assoluto")
        }
        AccessibilityNotification.Announcement(message).post()
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
    NavigationStack {
        MainView(model: LevelModel(source: FixedGravitySource.screenshot))
            .background(SbuTheme.surface)
    }
    .tint(SbuTheme.accentLevel)
}

#Preview("Dark") {
    NavigationStack {
        MainView(model: LevelModel(source: FixedGravitySource(gravity: .lying(tiltedBy: 3))))
            .background(SbuTheme.surface)
    }
    .tint(SbuTheme.accentLevel)
    .preferredColorScheme(.dark)
}
