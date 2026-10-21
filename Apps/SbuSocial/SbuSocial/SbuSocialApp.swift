import SwiftUI

@main
struct SbuSocialApp: App {
    @State private var accounts = AccountStore()
    @State private var pool = WebViewPool()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(accounts)
                .environment(pool)
                .task { await pool.prepare() }
        }
    }
}
