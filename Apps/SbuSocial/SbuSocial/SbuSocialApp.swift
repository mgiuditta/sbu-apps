import AVFoundation
import SwiftUI

@main
struct SbuSocialApp: App {
    @State private var accounts = AccountStore()
    @State private var options: OptionStore
    @State private var pool: WebViewPool
    @State private var usage = UsageLog.isDemo ? UsageLog.demo() : UsageLog()
    @State private var shield = ShieldModel()
    @Environment(\.scenePhase) private var scenePhase

    init() {
        let options = OptionStore()
        _options = State(initialValue: options)
        _pool = State(initialValue: WebViewPool(options: options))
        // Videos play with the silent switch on and keep playing in the background, as in SocialLite.
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(accounts)
                .environment(pool)
                .environment(options)
                .environment(usage)
                .environment(shield)
                .task { await pool.prepare() }
                .onChange(of: scenePhase, initial: true) {
                    if scenePhase == .active { shield.refresh() }
                }
                // With the app open, the Shield comes back on time even if iOS is late.
                .task(id: [shield.postModeEnd, shield.focusEnd]) {
                    guard let end = [shield.postModeEnd, shield.focusEnd].compactMap(\.self).min() else { return }
                    try? await Task.sleep(for: .seconds(max(end.timeIntervalSinceNow, 0)))
                    shield.refresh()
                }
        }
    }
}
