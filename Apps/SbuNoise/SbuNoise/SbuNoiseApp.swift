import SwiftUI

@main
struct SbuNoiseApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var model: PlayerModel
    @State private var timers: TimersModel
    @State private var alarms: AlarmsModel
    private let systemAudio: SystemAudio
    private let widgetSync: WidgetSync
    private let alarmNotifications: AlarmNotifications

    init() {
        let model = PlayerModel()
        let alarms = AlarmsModel(player: model)
        _model = State(initialValue: model)
        _timers = State(initialValue: TimersModel(player: model))
        _alarms = State(initialValue: alarms)
        systemAudio = SystemAudio(model: model)
        widgetSync = WidgetSync(model: model)
        // Here and not in a view: a tap on an alarm notification can launch the app.
        alarmNotifications = AlarmNotifications(alarms: alarms)
        // Here and not in a view: an intent can launch the app in the background, with no UI.
        PlaybackCommands.handler = { [model] in model.perform($0) }
        // UI tests: the ringing alarm, without waiting for a real time.
        if ProcessInfo.processInfo.environment["SBU_NOISE_RING"] == "1" { alarms.ring(SoundAlarm()) }
    }

    var body: some Scene {
        WindowGroup {
            RootView(model: model, timers: timers, alarms: alarms)
        }
        .onChange(of: scenePhase) { _, phase in
            // Back from the background or from Impostazioni: missed alarms, permission, backup.
            if phase == .active { alarms.refresh() }
        }
    }
}
