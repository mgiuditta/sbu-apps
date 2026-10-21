import AVFoundation
import SwiftUI

@main
struct SbuSocialApp: App {
    @State private var accounts = AccountStore()
    @State private var pool = WebViewPool()

    init() {
        // Videos play with the silent switch on and keep playing in the background, as in SocialLite.
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(accounts)
                .environment(pool)
                .task { await pool.prepare() }
        }
    }
}
