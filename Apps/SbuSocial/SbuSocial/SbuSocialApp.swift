import AVFoundation
import SwiftUI

@main
struct SbuSocialApp: App {
    @State private var accounts = AccountStore()
    @State private var pool = WebViewPool()
    @State private var usage = UsageLog()
    @State private var shield = ShieldModel()
    @Environment(\.scenePhase) private var scenePhase

    init() {
        // Videos play with the silent switch on and keep playing in the background, as in SocialLite.
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(accounts)
                .environment(pool)
                .environment(usage)
                .environment(shield)
                .task { await pool.prepare() }
                .onChange(of: scenePhase, initial: true) {
                    if scenePhase == .active { shield.refresh() }
                }
                // With the app open, the Shield comes back on time even if iOS is late.
                .task(id: shield.postModeEnd) {
                    guard let end = shield.postModeEnd else { return }
                    try? await Task.sleep(for: .seconds(max(end.timeIntervalSinceNow, 0)))
                    shield.refresh()
                }
        }
    }
}
