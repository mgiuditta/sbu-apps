import SbuKit
import SwiftUI
import UIKit

/// The tool screen: Livella and its cartiglio, the angle as the figure on the grid, the camera sight
/// in Mirino, Calibra in the bar as in Clinometer, and the Azzera qui, Blocca and Mirino pills. No
/// bubble: the full stop is the indicator, grey off level and in the accent in bolla.
struct MainView: View {
    /// How long the reading stays level before the Closure says "In bolla".
    private static let closureHold = Duration.milliseconds(1500)

    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let model: LevelModel

    @State private var camera = SightCamera()
    @State private var speaker = ReadingSpeaker()
    @State private var isCalibrating = false
    /// Bars and pills hidden while measuring. Never saved.
    @State private var isFullScreen = false
    @State private var isClosing = false

    private var format: AngleFormatStyle { AngleFormatStyle(unit: model.unit) }

    private var status: LevelStatus {
        LevelStatus(
            readout: model.readout,
            isLocked: model.isLocked,
            isWaitingForSteady: model.steadyProgress != nil,
            camera: model.isSighting ? camera.access : nil
        )
    }

    /// The Closure comes only for a live level reading: not locked, not relative, not in the sight.
    private var isInBolla: Bool { status == .level }

    private var cartiglio: String {
        ["Sbu", String(localized: "Livella"), String(localized: model.reading.axisName)].joined(separator: " · ")
    }

    private var caption: LocalizedStringResource {
        model.isSighting ? "Linea di mira" : "Inclinazione"
    }

    /// What VoiceOver reads for the figure: what it measures, the angle in words, and the context.
    private var spokenFigure: String {
        [String(localized: caption), format.spokenText(model.readout.angle), String(localized: status.text)]
            .joined(separator: ", ")
    }

    private var fullScreenAction: LocalizedStringKey {
        isFullScreen ? "Mostra i controlli" : "Schermo intero"
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
                toolScreen
            } else {
                // No figure and no controls: a 0,0 or a Calibra here would promise a reading there isn't.
                MotionUnavailableView()
            }
        }
        .toolbar {
            // Without a motion sensor there is nothing to calibrate, and the sight rests on no side.
            if model.isMotionAvailable, model.isSighting == false {
                ToolbarItem(placement: .topBarLeading) {
                    // A symbol in ink, like the gear: it shows in the large content viewer at any text size.
                    Button("Calibra", systemImage: "level", action: calibrate)
                }
            }
        }
        .toolbar(isFullScreen ? .hidden : .automatic, for: .navigationBar)
        .statusBarHidden(isFullScreen)
        .persistentSystemOverlays(isFullScreen ? .hidden : .automatic)
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
        // Once per entry into level: leaving it cancels the wait, and the next entry starts it again.
        .task(id: isInBolla) {
            guard isInBolla else { return }
            try? await Task.sleep(for: Self.closureHold)
            guard Task.isCancelled == false else { return }
            isClosing = true
        }
    }

    private var toolScreen: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SbuTheme.space6) {
                SbuScreenTitle("Livella", cartiglio: cartiglio)

                if model.isSighting {
                    LevelInstrument(
                        model: model,
                        camera: camera,
                        fullScreenAction: fullScreenAction,
                        toggleLock: toggleLock,
                        toggleFullScreen: toggleFullScreen
                    )
                }

                SbuFigure(
                    value: format.format(model.readout.angle),
                    unit: model.unit.symbol,
                    fullStop: model.readout.isLevel ? .set : .waiting,
                    context: Text(status.text),
                    accessibilityLabel: Text(verbatim: spokenFigure)
                )
                .accessibilityAction(named: Text(fullScreenAction), toggleFullScreen)
                .sbuClosure($isClosing, word: "In bolla")
                // A tap on the figure hides the bars and the pills, so nothing is pressed by mistake.
                .contentShape(.rect)
                .onTapGesture(perform: toggleFullScreen)
            }
            .padding(.horizontal, SbuTheme.space4)
            .padding(.vertical, SbuTheme.space4)
        }
        .scrollBounceBehavior(.basedOnSize)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            // Gone in full screen.
            if isFullScreen == false {
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
                .frame(maxWidth: .infinity)
                .padding(SbuTheme.space4)
                .background(SbuTheme.paper)
            }
        }
        .sbuPaper(grid: true)
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

    private func toggleFullScreen() {
        withAnimation(SbuMotion.animation(SbuMotion.base, reduceMotion: reduceMotion)) {
            isFullScreen.toggle()
        }
        let message = isFullScreen ? String(localized: "Controlli nascosti") : String(localized: "Controlli visibili")
        AccessibilityNotification.Announcement(message).post()
    }

    private func toggleSight() {
        model.toggleSight()
    }
}

#Preview("Light") {
    NavigationStack {
        MainView(model: LevelModel(source: FixedGravitySource.screenshot))
    }
    .environment(\.sbuAccent, .level)
}

#Preview("Dark") {
    NavigationStack {
        MainView(model: LevelModel(source: FixedGravitySource(gravity: .standing(rotatedBy: 0))))
    }
    .environment(\.sbuAccent, .level)
    .preferredColorScheme(.dark)
}
