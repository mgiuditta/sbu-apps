import SbuKit
import SwiftUI
import UIKit

/// The tool screen: the angle as the figure, the clinometer dial, bubble or camera sight, Calibra
/// in the bar as in Clinometer, and the Azzera qui, Blocca and Mirino pills.
struct MainView: View {
    @Environment(\.scenePhase) private var scenePhase

    let model: LevelModel

    @State private var camera = SightCamera()
    @State private var speaker = ReadingSpeaker()
    @State private var isCalibrating = false

    private var format: AngleFormatStyle { AngleFormatStyle(unit: model.unit) }

    private var status: LevelStatus {
        LevelStatus(
            readout: model.readout,
            isLocked: model.isLocked,
            isWaitingForSteady: model.steadyProgress != nil,
            camera: model.isSighting ? camera.access : nil
        )
    }

    private var keepsScreenOn: Bool {
        model.isMotionAvailable && model.keepsScreenOn(isActive: scenePhase == .active)
    }

    /// The camera runs only while the sight is on screen.
    private var showsCamera: Bool {
        model.isSighting && scenePhase == .active
    }

    var body: some View {
        Group {
            if model.isMotionAvailable {
                SbuToolField(
                    model.isSighting ? "Linea di mira" : "Inclinazione",
                    value: model.readout.angle,
                    format: format,
                    unit: model.unit.symbol,
                    spokenValue: Text(verbatim: format.spokenText(model.readout.angle)),
                    context: status.text,
                    contextSystemImage: status.systemImage
                ) {
                    LevelInstrument(model: model, camera: camera)
                } pills: {
                    // In one row, wrapping onto more where they would not fit, as with large text sizes.
                    PillsLayout(spacing: SbuTheme.space2) {
                        LevelPills(
                            isRelative: model.readout.isRelative,
                            isLocked: model.isLocked,
                            isWaitingForSteady: model.steadyProgress != nil,
                            isSighting: model.isSighting,
                            toggleReference: toggleReference,
                            toggleLock: toggleLock,
                            toggleSight: toggleSight
                        )
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
            // Without a motion sensor there is nothing to calibrate, and the sight rests on no side.
            if model.isMotionAvailable, model.isSighting == false {
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
        .onChange(of: model.lockCount) {
            if model.playsSound { MeasureSound.play() }
            announceLock()
        }
        .onChange(of: model.readout) { _, readout in
            speaker.update(mode: model.speech, degrees: readout.angle, text: format.spokenText(readout.angle))
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
        .task(id: showsCamera) {
            if showsCamera {
                await camera.run()
            }
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
        let wasLocked = model.isLocked
        model.toggleLock()
        // A new lock is announced when it lands, by hand or once the reading holds still.
        if model.steadyProgress != nil {
            AccessibilityNotification.Announcement(String(localized: "Tieni fermo l'iPhone")).post()
        } else if wasLocked {
            AccessibilityNotification.Announcement(String(localized: "Lettura sbloccata")).post()
        }
    }

    /// Says a new lock: VoiceOver announces it, otherwise the voice reads it when it is on.
    private func announceLock() {
        let message = String(localized: "Lettura bloccata, \(format.spokenText(model.readout.angle))")
        if UIAccessibility.isVoiceOverRunning {
            AccessibilityNotification.Announcement(message).post()
        } else if model.speech != .off {
            speaker.speak(message)
        }
    }

    private func toggleSight() {
        model.toggleSight()
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
